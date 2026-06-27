package com.touchnothing.app.data.remote

object SupabaseRpcErrorMapper {
    private val authErrorTokens = mapOf(
        "nickname_taken" to SupabaseServiceError.NicknameTaken,
        "invalid_credentials" to SupabaseServiceError.InvalidCredentials(),
        "account_locked" to SupabaseServiceError.AccountLocked,
        "invalid_pin" to SupabaseServiceError.InvalidPin,
        "invalid_nickname" to SupabaseServiceError.InvalidNickname,
        "invalid_session_token" to SupabaseServiceError.InvalidSessionToken,
        "nickname_not_registered" to SupabaseServiceError.NicknameNotRegistered,
    )

    fun mapAuthErrorToken(token: String?): SupabaseServiceError? {
        if (token == null) return null
        return authErrorTokens[token]
    }

    fun map(error: Throwable): SupabaseServiceError {
        val message = error.message?.lowercase() ?: error.toString().lowercase()

        if (isLikelyEmptyAuthResponse(error)) {
            return SupabaseServiceError.ServerUpgradeRequired
        }

        return mapMessage(message)
    }

    fun mapMessage(message: String): SupabaseServiceError {
        val lower = message.lowercase()
        authErrorTokens.forEach { (token, serviceError) ->
            if (lower.contains(token)) return serviceError
        }
        if (lower.contains("function") && lower.contains("does not exist")) {
            return SupabaseServiceError.ServerUpgradeRequired
        }
        return SupabaseServiceError.NetworkFailure
    }

    fun isLikelyEmptyAuthResponse(error: Throwable): Boolean {
        val message = error.message?.lowercase() ?: error.toString().lowercase()
        return message.contains("decoding") ||
            message.contains("correct format") ||
            message.contains("unexpected end of file") ||
            message.contains("expected start")
    }
}
