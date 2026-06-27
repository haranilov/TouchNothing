package com.touchnothing.app.util

enum class NicknameValidationError {
    EMPTY,
    INVALID_LENGTH,
    INVALID_CHARACTERS,
}

object NicknameValidator {
    private val allowedCharacters = Regex("^[a-zA-Z0-9_]+$")

    fun validate(nickname: String): NicknameValidationError? {
        val trimmed = normalized(nickname)
        if (trimmed.isEmpty()) return NicknameValidationError.EMPTY
        if (trimmed.length < AppConstants.MIN_NICKNAME_LENGTH ||
            trimmed.length > AppConstants.MAX_NICKNAME_LENGTH
        ) {
            return NicknameValidationError.INVALID_LENGTH
        }
        if (!allowedCharacters.matches(trimmed)) {
            return NicknameValidationError.INVALID_CHARACTERS
        }
        return null
    }

    fun normalized(nickname: String): String = nickname.trim()
}
