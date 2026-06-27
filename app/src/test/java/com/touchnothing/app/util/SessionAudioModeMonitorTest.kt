package com.touchnothing.app.util

import android.media.AudioManager
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SessionAudioModeMonitorTest {
    @Test
    fun isCallAudioModeDetectsCellularCall() {
        assertTrue(SessionAudioModeMonitor.isCallAudioMode(AudioManager.MODE_IN_CALL))
    }

    @Test
    fun isCallAudioModeDetectsVoipCommunication() {
        assertTrue(SessionAudioModeMonitor.isCallAudioMode(AudioManager.MODE_IN_COMMUNICATION))
    }

    @Test
    fun isCallAudioModeIgnoresNormalMode() {
        assertFalse(SessionAudioModeMonitor.isCallAudioMode(AudioManager.MODE_NORMAL))
    }
}
