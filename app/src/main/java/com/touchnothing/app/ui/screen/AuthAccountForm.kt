package com.touchnothing.app.ui.screen

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.touchnothing.app.R
import com.touchnothing.app.data.model.AuthMode
import com.touchnothing.app.ui.component.NicknameTextField
import com.touchnothing.app.ui.component.PinSecureField
import com.touchnothing.app.ui.theme.AppColors
import com.touchnothing.app.util.PinInput

@Composable
fun AuthAccountForm(
    authMode: AuthMode,
    nickname: String,
    pin: String,
    confirmPin: String,
    onNicknameChange: (String) -> Unit,
    onPinChange: (String) -> Unit,
    onConfirmPinChange: (String) -> Unit,
) {
    NicknameTextField(
        value = nickname,
        onValueChange = onNicknameChange,
        placeholder = stringResource(R.string.nickname_placeholder),
    )
    Spacer(modifier = Modifier.height(16.dp))
    PinSecureField(
        value = pin,
        onValueChange = { onPinChange(PinInput.sanitize(it)) },
        placeholder = stringResource(R.string.auth_pin_placeholder),
    )
    if (authMode == AuthMode.REGISTER) {
        Spacer(modifier = Modifier.height(16.dp))
        PinSecureField(
            value = confirmPin,
            onValueChange = { onConfirmPinChange(PinInput.sanitize(it)) },
            placeholder = stringResource(R.string.auth_confirm_pin_placeholder),
        )
    }
    if (authMode == AuthMode.SIGN_IN) {
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = stringResource(R.string.auth_forgot_pin),
            color = AppColors.TextSecondary,
            fontSize = 12.sp,
            textAlign = TextAlign.Center,
        )
    }
}
