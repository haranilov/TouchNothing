package com.touchnothing.app.util

import android.media.AudioManager
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SessionAudioFocusMonitorTest {
    @Test
    fun isInterruptingFocusChangeDetectsPermanentLoss() {
        assertTrue(SessionAudioFocusMonitor.isInterruptingFocusChange(AudioManager.AUDIOFOCUS_LOSS))
    }

    @Test
    fun isInterruptingFocusChangeIgnoresTransientLoss() {
        assertFalse(SessionAudioFocusMonitor.isInterruptingFocusChange(AudioManager.AUDIOFOCUS_LOSS_TRANSIENT))
    }

    @Test
    fun isInterruptingFocusChangeIgnoresGain() {
        assertFalse(SessionAudioFocusMonitor.isInterruptingFocusChange(AudioManager.AUDIOFOCUS_GAIN))
    }
}
