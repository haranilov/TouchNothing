package com.touchnothing.app.ui.navigation

import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.listSaver

private const val KIND_AUTH = "auth"
private const val KIND_MAIN_MENU = "main_menu"
private const val KIND_RULES = "rules"
private const val KIND_SESSION = "session"
private const val KIND_SESSION_RESULT = "session_result"
private const val KIND_LEADERBOARD = "leaderboard"
private const val KIND_MY_TOTAL = "my_total"

internal fun encodeDestination(destination: AppDestination): List<Any> =
    when (destination) {
        AppDestination.Auth -> listOf(KIND_AUTH)
        AppDestination.MainMenu -> listOf(KIND_MAIN_MENU)
        AppDestination.Rules -> listOf(KIND_RULES)
        AppDestination.Session -> listOf(KIND_SESSION)
        is AppDestination.SessionResult -> listOf(KIND_SESSION_RESULT, destination.elapsedSeconds)
        AppDestination.Leaderboard -> listOf(KIND_LEADERBOARD)
        AppDestination.MyTotal -> listOf(KIND_MY_TOTAL)
    }

internal fun decodeDestination(values: List<Any>): AppDestination =
    when (values[0] as String) {
        KIND_AUTH -> AppDestination.Auth
        KIND_MAIN_MENU -> AppDestination.MainMenu
        KIND_RULES -> AppDestination.Rules
        KIND_SESSION -> AppDestination.Session
        KIND_SESSION_RESULT -> AppDestination.SessionResult(values[1] as Int)
        KIND_LEADERBOARD -> AppDestination.Leaderboard
        KIND_MY_TOTAL -> AppDestination.MyTotal
        else -> AppDestination.Auth
    }

val AppDestinationSaver: Saver<AppDestination, Any> = listSaver(
    save = { encodeDestination(it) },
    restore = { decodeDestination(it) },
)
