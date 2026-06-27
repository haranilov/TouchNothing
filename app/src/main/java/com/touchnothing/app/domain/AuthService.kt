package com.touchnothing.app.domain

import com.touchnothing.app.data.model.AuthCredentials
import com.touchnothing.app.data.model.AuthMode
import com.touchnothing.app.data.model.AuthValidationError
import com.touchnothing.app.data.local.LocalUserStore
import com.touchnothing.app.data.remote.SupabaseService
import com.touchnothing.app.util.NicknameValidator
import com.touchnothing.app.util.PinInput

class AuthService(
    private val localUserStore: LocalUserStore,
    private val supabaseService: SupabaseService = SupabaseService.shared,
) {
    fun validate(credentials: AuthCredentials): AuthValidationError? {
        val normalizedNickname = NicknameValidator.normalized(credentials.nickname)
        NicknameValidator.validate(normalizedNickname)?.let {
            return AuthValidationError.Nickname(it)
        }

        if (credentials.mode == AuthMode.GUEST) return null

        if (!PinInput.isValid(credentials.pin)) return AuthValidationError.InvalidPin
        if (credentials.mode == AuthMode.REGISTER && credentials.pin != credentials.confirmPin) {
            return AuthValidationError.PinMismatch
        }
        return null
    }

    suspend fun authenticate(credentials: AuthCredentials) {
        val nickname = NicknameValidator.normalized(credentials.nickname)
        when (credentials.mode) {
            AuthMode.REGISTER, AuthMode.SIGN_IN -> persistAccountSession(
                nickname = nickname,
                pin = credentials.pin,
                mode = credentials.mode,
            )
            AuthMode.GUEST -> registerGuestSession(nickname)
        }
    }

    suspend fun recoverGuestSession(): Boolean {
        if (!localUserStore.isGuest) return false
        val nickname = localUserStore.nickname ?: return false
        val guestPin = localUserStore.guestPin ?: return false

        return runCatching {
            val session = supabaseService.loginUser(nickname = nickname, pin = guestPin)
            localUserStore.nickname = session.nickname
            localUserStore.sessionToken = session.sessionToken
            true
        }.getOrDefault(false)
    }

    private suspend fun registerGuestSession(nickname: String) {
        val guestPin = PinInput.randomPin()
        val session = supabaseService.registerUser(nickname = nickname, pin = guestPin)
        localUserStore.saveSession(
            nickname = session.nickname,
            sessionToken = session.sessionToken,
            isGuest = true,
            guestPin = guestPin,
        )
    }

    private suspend fun persistAccountSession(nickname: String, pin: String, mode: AuthMode) {
        val session = when (mode) {
            AuthMode.REGISTER -> supabaseService.registerUser(nickname = nickname, pin = pin)
            AuthMode.SIGN_IN -> supabaseService.loginUser(nickname = nickname, pin = pin)
            AuthMode.GUEST -> return
        }
        localUserStore.saveSession(
            nickname = session.nickname,
            sessionToken = session.sessionToken,
            isGuest = false,
        )
    }
}
