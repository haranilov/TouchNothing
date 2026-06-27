package com.touchnothing.app.util

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class NicknameValidatorTest {
    @Test
    fun normalizedTrimsWhitespace() {
        assertEquals("kos", NicknameValidator.normalized("  kos  "))
    }

    @Test
    fun validateRejectsEmptyNickname() {
        assertEquals(NicknameValidationError.EMPTY, NicknameValidator.validate(""))
    }

    @Test
    fun validateRejectsTooShortNickname() {
        assertEquals(NicknameValidationError.INVALID_LENGTH, NicknameValidator.validate("a"))
    }

    @Test
    fun validateRejectsInvalidCharacters() {
        assertEquals(NicknameValidationError.INVALID_CHARACTERS, NicknameValidator.validate("bad-name"))
    }

    @Test
    fun validateAcceptsValidNickname() {
        assertNull(NicknameValidator.validate("Kos_123"))
    }
}
