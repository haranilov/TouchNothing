package com.touchnothing.app.data.local

import android.content.Context
import com.touchnothing.app.util.NicknameValidator
import com.touchnothing.app.util.PinInput

class LocalUserStore(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val leaderboardCache = LeaderboardCache(context)

    var nickname: String?
        get() {
            val raw = prefs.getString(StorageKeys.NICKNAME, null) ?: return null
            val normalized = NicknameValidator.normalized(raw)
            return normalized.ifEmpty { null }
        }
        set(value) {
            if (value == null) {
                prefs.edit().remove(StorageKeys.NICKNAME).apply()
                return
            }
            prefs.edit().putString(StorageKeys.NICKNAME, value).apply()
        }

    var sessionToken: String?
        get() {
            val token = prefs.getString(StorageKeys.SESSION_TOKEN, null) ?: return null
            return token.ifEmpty { null }
        }
        set(value) {
            if (value == null) {
                prefs.edit().remove(StorageKeys.SESSION_TOKEN).apply()
                return
            }
            prefs.edit().putString(StorageKeys.SESSION_TOKEN, value).apply()
        }

    var isGuest: Boolean
        get() = prefs.getBoolean(StorageKeys.IS_GUEST, false)
        set(value) = prefs.edit().putBoolean(StorageKeys.IS_GUEST, value).apply()

    var guestPin: String?
        get() {
            val pin = prefs.getString(StorageKeys.GUEST_PIN, null) ?: return null
            if (!PinInput.isValid(pin)) return null
            return pin
        }
        set(value) {
            if (value == null) {
                prefs.edit().remove(StorageKeys.GUEST_PIN).apply()
                return
            }
            prefs.edit().putString(StorageKeys.GUEST_PIN, value).apply()
        }

    var rulesHidden: Boolean
        get() = prefs.getBoolean(StorageKeys.RULES_HIDDEN, false)
        set(value) = prefs.edit().putBoolean(StorageKeys.RULES_HIDDEN, value).apply()

    val hasNickname: Boolean
        get() = !nickname.isNullOrEmpty()

    val hasActiveSession: Boolean
        get() = hasNickname && sessionToken != null

    fun saveSession(
        nickname: String,
        sessionToken: String,
        isGuest: Boolean = false,
        guestPin: String? = null,
    ) {
        this.nickname = nickname
        this.sessionToken = sessionToken
        this.isGuest = isGuest
        this.guestPin = if (isGuest) guestPin else null
    }

    fun signOut() {
        nickname = null
        sessionToken = null
        isGuest = false
        guestPin = null
        leaderboardCache.clearAll()
    }

    companion object {
        const val PREFS_NAME = "touch_nothing_prefs"
    }
}
