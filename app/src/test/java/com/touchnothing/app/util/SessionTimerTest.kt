package com.touchnothing.app.util

import org.junit.Assert.assertEquals
import org.junit.Test

class SessionTimerTest {
    @Test
    fun elapsedSecondsNeverNegative() {
        val timer = SessionTimer(startMillis = 10_000L)
        assertEquals(0, timer.elapsedSeconds(endMillis = 5_000L))
    }

    @Test
    fun elapsedSecondsCountsWholeSeconds() {
        val timer = SessionTimer(startMillis = 1_000L)
        assertEquals(4, timer.elapsedSeconds(endMillis = 5_500L))
    }
}
