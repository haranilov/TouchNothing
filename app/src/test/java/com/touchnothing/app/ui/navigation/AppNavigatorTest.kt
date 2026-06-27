package com.touchnothing.app.ui.navigation

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AppNavigatorTest {
    @Test
    fun bootstrapOpensMainMenuWhenSessionActive() {
        val navigator = AppNavigator(
            hasActiveSession = { true },
            rulesHidden = { false },
            onSignOut = {},
            onResetSessionSave = {},
        )

        navigator.bootstrap()

        assertEquals(AppDestination.MainMenu, navigator.destination)
    }

    @Test
    fun bootstrapOpensAuthWhenNoSession() {
        val navigator = AppNavigator(
            hasActiveSession = { false },
            rulesHidden = { false },
            onSignOut = {},
            onResetSessionSave = {},
        )

        navigator.bootstrap()

        assertEquals(AppDestination.Auth, navigator.destination)
    }

    @Test
    fun startSessionFlowSkipsRulesWhenHidden() {
        val navigator = AppNavigator(
            hasActiveSession = { true },
            rulesHidden = { true },
            onSignOut = {},
            onResetSessionSave = {},
        )
        navigator.bootstrap()

        navigator.startSessionFlow()

        assertEquals(AppDestination.Session, navigator.destination)
    }

    @Test
    fun startSessionFlowShowsRulesWhenNotHidden() {
        val navigator = AppNavigator(
            hasActiveSession = { true },
            rulesHidden = { false },
            onSignOut = {},
            onResetSessionSave = {},
        )
        navigator.bootstrap()

        navigator.startSessionFlow()

        assertEquals(AppDestination.Rules, navigator.destination)
    }

    @Test
    fun finishSessionNavigatesToResult() {
        val navigator = AppNavigator(
            hasActiveSession = { true },
            rulesHidden = { true },
            onSignOut = {},
            onResetSessionSave = {},
        )
        navigator.bootstrap()
        navigator.startSessionFlow()

        navigator.finishSession(42)

        val destination = navigator.destination
        assertTrue(destination is AppDestination.SessionResult)
        assertEquals(42, (destination as AppDestination.SessionResult).elapsedSeconds)
    }

    @Test
    fun signOutResetsToAuth() {
        var signedOut = false
        val navigator = AppNavigator(
            hasActiveSession = { true },
            rulesHidden = { true },
            onSignOut = { signedOut = true },
            onResetSessionSave = {},
        )
        navigator.bootstrap()

        navigator.signOut()

        assertTrue(signedOut)
        assertEquals(AppDestination.Auth, navigator.destination)
    }
}
