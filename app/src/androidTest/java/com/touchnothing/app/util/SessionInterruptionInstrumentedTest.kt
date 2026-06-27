package com.touchnothing.app.util

import android.Manifest
import android.content.Context
import android.media.AudioManager
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class SessionInterruptionInstrumentedTest {
    private val context: Context = ApplicationProvider.getApplicationContext()
    private val instrumentation = InstrumentationRegistry.getInstrumentation()

    @Test
    fun telephonyMonitor_doesNotCrashWithoutActiveCall() {
        instrumentation.runOnMainSync {
            if (!SessionTelephonyMonitor.hasPhoneStatePermission(context)) {
                instrumentation.uiAutomation.grantRuntimePermission(
                    context.packageName,
                    Manifest.permission.READ_PHONE_STATE,
                )
            }
            val monitor = SessionTelephonyMonitor(context)
            monitor.endSessionIfPhoneCallIsActive()
            monitor.start()
            monitor.stop()
        }
    }

    @Test
    fun audioModeMonitor_detectsCommunicationModeConstant() {
        assertFalse(SessionAudioModeMonitor.isCallAudioMode(AudioManager.MODE_NORMAL))
        assertFalse(SessionAudioModeMonitor.isCallAudioMode(AudioManager.MODE_RINGTONE))
        assertTrue(SessionAudioModeMonitor.isCallAudioMode(AudioManager.MODE_IN_COMMUNICATION))
        assertTrue(SessionAudioModeMonitor.isCallAudioMode(AudioManager.MODE_IN_CALL))
    }

    @Test
    fun audioFocusMonitor_doesNotEndSessionOnTransientLoss() {
        assertFalse(
            SessionAudioFocusMonitor.isInterruptingFocusChange(AudioManager.AUDIOFOCUS_LOSS_TRANSIENT),
        )
    }

    @Test
    fun audioFocusMonitor_startAndStopDoesNotCrash() {
        instrumentation.runOnMainSync {
            val monitor = SessionAudioFocusMonitor(context)
            monitor.start()
            monitor.stop()
        }
    }
}
