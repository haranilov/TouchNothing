package com.touchnothing.app.ui.screen

import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.touchnothing.app.R
import com.touchnothing.app.ui.component.NicknameTextField
import com.touchnothing.app.ui.theme.AppColors

@Composable
fun ColumnScope.AuthGuestForm(
    guestNickname: String,
    onGuestNicknameChange: (String) -> Unit,
) {
    Text(
        text = stringResource(R.string.auth_guest_nickname_label),
        color = AppColors.TextSecondary,
        modifier = Modifier.align(Alignment.Start),
    )
    Spacer(modifier = Modifier.height(8.dp))
    NicknameTextField(
        value = guestNickname,
        onValueChange = onGuestNicknameChange,
        placeholder = stringResource(R.string.nickname_placeholder),
    )
    Spacer(modifier = Modifier.height(16.dp))
    Text(
        text = stringResource(R.string.auth_guest_warning),
        color = AppColors.TextSecondary,
        fontSize = 12.sp,
        textAlign = TextAlign.Center,
    )
}
