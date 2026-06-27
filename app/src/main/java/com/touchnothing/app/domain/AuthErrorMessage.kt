package com.touchnothing.app.domain

import android.content.Context
import com.touchnothing.app.R
import com.touchnothing.app.data.model.AuthValidationError
import com.touchnothing.app.data.remote.SupabaseServiceError
import com.touchnothing.app.util.NicknameValidationError

object AuthErrorMessage {
    fun validationMessage(context: Context, error: AuthValidationError): String =
        when (error) {
            is AuthValidationError.Nickname -> nicknameMessage(context, error.error)
            AuthValidationError.InvalidPin -> context.getString(R.string.auth_invalid_pin)
            AuthValidationError.PinMismatch -> context.getString(R.string.auth_pin_mismatch)
        }

    fun nicknameMessage(context: Context, error: NicknameValidationError): String =
        when (error) {
            NicknameValidationError.EMPTY -> context.getString(R.string.nickname_empty)
            NicknameValidationError.INVALID_LENGTH -> context.getString(R.string.nickname_invalid_length)
            NicknameValidationError.INVALID_CHARACTERS -> context.getString(R.string.nickname_invalid_characters)
        }

    fun serviceMessage(context: Context, error: SupabaseServiceError): String =
        when (error) {
            SupabaseServiceError.NicknameTaken -> context.getString(R.string.nickname_taken)
            is SupabaseServiceError.InvalidCredentials -> {
                error.remainingAttempts?.let { remaining ->
                    context.getString(R.string.auth_invalid_credentials_remaining, remaining)
                } ?: context.getString(R.string.auth_invalid_credentials)
            }
            SupabaseServiceError.AccountLocked -> context.getString(R.string.auth_account_locked)
            SupabaseServiceError.InvalidPin -> context.getString(R.string.auth_invalid_pin)
            SupabaseServiceError.InvalidNickname -> context.getString(R.string.nickname_invalid_length)
            SupabaseServiceError.InvalidSessionToken -> context.getString(R.string.auth_session_expired)
            SupabaseServiceError.NicknameNotRegistered -> context.getString(R.string.auth_invalid_credentials)
            SupabaseServiceError.ServerUpgradeRequired -> context.getString(R.string.auth_server_upgrade_required)
            SupabaseServiceError.NotConfigured,
            SupabaseServiceError.NetworkFailure,
            -> context.getString(R.string.nickname_network_error)
        }
}
