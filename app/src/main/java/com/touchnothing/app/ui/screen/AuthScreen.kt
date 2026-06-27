package com.touchnothing.app.ui.screen

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.touchnothing.app.R
import com.touchnothing.app.data.model.AuthCredentials
import com.touchnothing.app.data.model.AuthMode
import com.touchnothing.app.data.remote.SupabaseServiceError
import com.touchnothing.app.domain.AuthErrorMessage
import com.touchnothing.app.domain.AuthService
import com.touchnothing.app.ui.component.HiddenStatusBarEffect
import com.touchnothing.app.ui.component.TouchNothingButton
import com.touchnothing.app.ui.component.TouchNothingScreenLayout
import com.touchnothing.app.ui.component.TouchNothingSegmentedPicker
import com.touchnothing.app.ui.theme.AppColors
import com.touchnothing.app.util.GuestNicknameGenerator
import kotlinx.coroutines.launch

@Composable
fun AuthScreen(
    authService: AuthService,
    savedNickname: String?,
    onContinue: () -> Unit,
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val networkErrorMessage = stringResource(R.string.nickname_network_error)

    HiddenStatusBarEffect()

    var authMode by remember { mutableStateOf(AuthMode.REGISTER) }
    var registeredNickname by remember { mutableStateOf("") }
    var guestNickname by remember { mutableStateOf("") }
    var pin by remember { mutableStateOf("") }
    var confirmPin by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isSubmitting by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        if (registeredNickname.isEmpty() && savedNickname != null) {
            registeredNickname = savedNickname
            authMode = AuthMode.SIGN_IN
        }
    }

    val modeOptions = listOf(
        stringResource(R.string.auth_mode_register),
        stringResource(R.string.auth_mode_sign_in),
        stringResource(R.string.auth_mode_guest),
    )
    val selectedModeIndex = when (authMode) {
        AuthMode.REGISTER -> 0
        AuthMode.SIGN_IN -> 1
        AuthMode.GUEST -> 2
    }

    val submitTitle = if (isSubmitting) {
        when (authMode) {
            AuthMode.REGISTER -> stringResource(R.string.auth_creating)
            AuthMode.SIGN_IN -> stringResource(R.string.auth_signing_in)
            AuthMode.GUEST -> stringResource(R.string.auth_guest_creating)
        }
    } else {
        when (authMode) {
            AuthMode.GUEST -> stringResource(R.string.auth_guest_continue)
            AuthMode.REGISTER, AuthMode.SIGN_IN -> stringResource(R.string.nickname_continue)
        }
    }

    fun clearError() {
        errorMessage = null
    }

    fun selectAuthMode(index: Int) {
        authMode = when (index) {
            0 -> AuthMode.REGISTER
            1 -> AuthMode.SIGN_IN
            2 -> AuthMode.GUEST
            else -> AuthMode.GUEST
        }
        errorMessage = null
        confirmPin = ""
        if (authMode == AuthMode.GUEST && guestNickname.isEmpty()) {
            guestNickname = GuestNicknameGenerator.generate()
        }
    }

    fun submit() {
        val credentials = AuthCredentials(
            mode = authMode,
            nickname = if (authMode == AuthMode.GUEST) guestNickname else registeredNickname,
            pin = pin,
            confirmPin = confirmPin,
        )

        authService.validate(credentials)?.let { validationError ->
            errorMessage = AuthErrorMessage.validationMessage(context, validationError)
            return
        }

        isSubmitting = true
        errorMessage = null
        scope.launch {
            try {
                authService.authenticate(credentials)
                pin = ""
                confirmPin = ""
                onContinue()
            } catch (error: SupabaseServiceError) {
                errorMessage = AuthErrorMessage.serviceMessage(context, error)
                if (authMode == AuthMode.GUEST && error is SupabaseServiceError.NicknameTaken) {
                    guestNickname = GuestNicknameGenerator.generate()
                }
            } catch (_: Exception) {
                errorMessage = networkErrorMessage
            } finally {
                isSubmitting = false
            }
        }
    }

    TouchNothingScreenLayout(
        modifier = Modifier.fillMaxSize(),
        applyStatusBarPadding = false,
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(modifier = Modifier.weight(1f))

            Text(
                text = stringResource(R.string.app_name),
                fontSize = 34.sp,
                color = AppColors.TextPrimary,
            )

            Spacer(modifier = Modifier.height(24.dp))

            TouchNothingSegmentedPicker(
                options = modeOptions,
                selectedIndex = selectedModeIndex,
                onSelected = ::selectAuthMode,
            )

            Spacer(modifier = Modifier.height(24.dp))

            when (authMode) {
                AuthMode.GUEST -> AuthGuestForm(
                    guestNickname = guestNickname,
                    onGuestNicknameChange = {
                        guestNickname = it
                        clearError()
                    },
                )
                AuthMode.REGISTER, AuthMode.SIGN_IN -> AuthAccountForm(
                    authMode = authMode,
                    nickname = registeredNickname,
                    pin = pin,
                    confirmPin = confirmPin,
                    onNicknameChange = {
                        registeredNickname = it
                        clearError()
                    },
                    onPinChange = {
                        pin = it
                        clearError()
                    },
                    onConfirmPinChange = {
                        confirmPin = it
                        clearError()
                    },
                )
            }

            errorMessage?.let { message ->
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = message,
                    color = AppColors.TextSecondary,
                    fontSize = 12.sp,
                    textAlign = TextAlign.Center,
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            TouchNothingButton(
                text = submitTitle,
                onClick = ::submit,
                enabled = !isSubmitting,
            )

            Spacer(modifier = Modifier.weight(1f))
        }
    }
}
