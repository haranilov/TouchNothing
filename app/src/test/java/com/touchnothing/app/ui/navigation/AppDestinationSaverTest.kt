package com.touchnothing.app.ui.navigation

import org.junit.Assert.assertEquals
import org.junit.Test

class AppDestinationSaverTest {
    @Test
    fun roundTripsSessionResult() {
        val destination = AppDestination.SessionResult(elapsedSeconds = 17)
        val restored = decodeDestination(encodeDestination(destination))
        assertEquals(destination, restored)
    }

    @Test
    fun roundTripsMainMenu() {
        val destination = AppDestination.MainMenu
        val restored = decodeDestination(encodeDestination(destination))
        assertEquals(destination, restored)
    }
}
