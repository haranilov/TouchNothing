package com.touchnothing.app.util

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PinInputTest {
    @Test
    fun sanitizeKeepsOnlyDigitsAndMaxLength() {
        assertEquals("1234", PinInput.sanitize("12ab34cd56"))
    }

    @Test
    fun isValidRequiresFourDigits() {
        assertTrue(PinInput.isValid("1234"))
        assertFalse(PinInput.isValid("123"))
        assertFalse(PinInput.isValid("12a4"))
    }
}
