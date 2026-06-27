package com.touchnothing.app.data.remote

sealed class SupabaseServiceError : Exception() {
    data object NicknameTaken : SupabaseServiceError()
    data class InvalidCredentials(val remainingAttempts: Int? = null) : SupabaseServiceError()
    data object AccountLocked : SupabaseServiceError()
    data object InvalidPin : SupabaseServiceError()
    data object InvalidNickname : SupabaseServiceError()
    data object InvalidSessionToken : SupabaseServiceError()
    data object NicknameNotRegistered : SupabaseServiceError()
    data object ServerUpgradeRequired : SupabaseServiceError()
    data object NotConfigured : SupabaseServiceError()
    data object NetworkFailure : SupabaseServiceError()
}
