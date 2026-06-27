package com.touchnothing.app.domain

import com.touchnothing.app.data.local.LeaderboardCache
import com.touchnothing.app.data.local.LocalUserStore
import com.touchnothing.app.data.remote.SupabaseService
import com.touchnothing.app.data.remote.SupabaseServiceError
import com.touchnothing.app.util.AppConstants
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class SessionSaveService(
    private val localUserStore: LocalUserStore,
    private val authService: AuthService,
    private val leaderboardCache: LeaderboardCache,
    private val saveScope: CoroutineScope,
    private val supabaseService: SupabaseService = SupabaseService.shared,
) {
    private val mutableState = MutableStateFlow(SessionSaveState.IDLE)
    val state: StateFlow<SessionSaveState> = mutableState.asStateFlow()

    private var pendingSeconds = 0
    private var saveJob: Job? = null

    fun queueSave(elapsedSeconds: Int) {
        if (elapsedSeconds < AppConstants.MIN_SESSION_SECONDS) {
            mutableState.value = SessionSaveState.IDLE
            pendingSeconds = 0
            saveJob?.cancel()
            return
        }
        pendingSeconds = elapsedSeconds
        mutableState.value = SessionSaveState.SAVING
        startSaveTask()
    }

    fun retry() {
        if (mutableState.value != SessionSaveState.FAILED) return
        if (pendingSeconds < AppConstants.MIN_SESSION_SECONDS) return
        mutableState.value = SessionSaveState.SAVING
        startSaveTask()
    }

    fun resetIfNotSaving() {
        if (mutableState.value == SessionSaveState.SAVING) return
        mutableState.value = SessionSaveState.IDLE
        pendingSeconds = 0
    }

    private fun startSaveTask() {
        saveJob?.cancel()
        saveJob = saveScope.launch {
            performSaveIfNeeded()
        }
    }

    private suspend fun performSaveIfNeeded(isRetryAfterReauth: Boolean = false) {
        if (mutableState.value != SessionSaveState.SAVING) return

        val nickname = localUserStore.nickname
        val sessionToken = localUserStore.sessionToken
        if (nickname == null || sessionToken == null) {
            mutableState.value = SessionSaveState.FAILED
            return
        }

        runCatching {
            supabaseService.submitSession(
                nickname = nickname,
                durationSeconds = pendingSeconds,
                sessionToken = sessionToken,
            )
            leaderboardCache.clearAll()
            mutableState.value = SessionSaveState.SAVED
        }.onFailure { error ->
            if (error is SupabaseServiceError.InvalidSessionToken &&
                !isRetryAfterReauth &&
                authService.recoverGuestSession()
            ) {
                performSaveIfNeeded(isRetryAfterReauth = true)
                return
            }
            if (error is SupabaseServiceError.InvalidSessionToken) {
                localUserStore.signOut()
            }
            mutableState.value = SessionSaveState.FAILED
        }
    }
}
