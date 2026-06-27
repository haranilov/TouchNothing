package com.touchnothing.app.ui.navigation

sealed class AppDestination {
    data object Auth : AppDestination()
    data object MainMenu : AppDestination()
    data object Rules : AppDestination()
    data object Session : AppDestination()
    data class SessionResult(val elapsedSeconds: Int) : AppDestination()
    data object Leaderboard : AppDestination()
    data object MyTotal : AppDestination()
}

class AppNavigator(
    private val hasActiveSession: () -> Boolean,
    private val rulesHidden: () -> Boolean,
    private val onSignOut: () -> Unit,
    private val onResetSessionSave: () -> Unit,
) {
    var destination: AppDestination = AppDestination.Auth
        private set

    fun bootstrap() {
        destination = if (hasActiveSession()) AppDestination.MainMenu else AppDestination.Auth
    }

    fun completeAuth() {
        destination = AppDestination.MainMenu
    }

    fun signOut() {
        onResetSessionSave()
        onSignOut()
        destination = AppDestination.Auth
    }

    fun startSessionFlow() {
        destination = if (rulesHidden()) {
            AppDestination.Session
        } else {
            AppDestination.Rules
        }
    }

    fun beginSession() {
        destination = AppDestination.Session
    }

    fun finishSession(elapsedSeconds: Int) {
        destination = AppDestination.SessionResult(elapsedSeconds)
    }

    fun openLeaderboard() {
        if (destination != AppDestination.Leaderboard) {
            destination = AppDestination.Leaderboard
        }
    }

    fun openMyTotal() {
        if (destination != AppDestination.MyTotal) {
            destination = AppDestination.MyTotal
        }
    }

    fun returnToMenu() {
        if (destination != AppDestination.MainMenu) {
            onResetSessionSave()
            destination = AppDestination.MainMenu
        }
    }
}
