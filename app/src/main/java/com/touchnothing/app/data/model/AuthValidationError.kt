package com.touchnothing.app.data.model

import com.touchnothing.app.util.NicknameValidationError

sealed class AuthValidationError {
    data class Nickname(val error: NicknameValidationError) : AuthValidationError()
    data object InvalidPin : AuthValidationError()
    data object PinMismatch : AuthValidationError()
}
