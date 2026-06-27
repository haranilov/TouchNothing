package com.touchnothing.app.domain

import com.touchnothing.app.data.model.AuthCredentials
import com.touchnothing.app.data.model.AuthMode
import com.touchnothing.app.data.model.AuthValidationError
import com.touchnothing.app.data.local.LocalUserStore
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class AuthServiceTest {
    private val localUserStore = mockk<LocalUserStore>(relaxed = true)
    private val authService = AuthService(localUserStore)

    @Test
    fun validateRejectsEmptyNickname() {
        val credentials = AuthCredentials(
            mode = AuthMode.SIGN_IN,
            nickname = "",
            pin = "1234",
            confirmPin = "",
        )

        val error = authService.validate(credentials)

        assertTrue(error is AuthValidationError.Nickname)
    }

    @Test
    fun validateRejectsInvalidPinForSignIn() {
        val credentials = AuthCredentials(
            mode = AuthMode.SIGN_IN,
            nickname = "kos",
            pin = "12",
            confirmPin = "",
        )

        assertEquals(AuthValidationError.InvalidPin, authService.validate(credentials))
    }

    @Test
    fun validateRejectsPinMismatchForRegister() {
        val credentials = AuthCredentials(
            mode = AuthMode.REGISTER,
            nickname = "kos",
            pin = "1234",
            confirmPin = "5678",
        )

        assertEquals(AuthValidationError.PinMismatch, authService.validate(credentials))
    }

    @Test
    fun validateAcceptsGuestWithoutPin() {
        val credentials = AuthCredentials(
            mode = AuthMode.GUEST,
            nickname = "guest_abc123",
            pin = "",
            confirmPin = "",
        )

        assertNull(authService.validate(credentials))
    }
}
