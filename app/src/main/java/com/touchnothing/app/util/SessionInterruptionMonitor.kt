package com.touchnothing.app.util

import android.content.Context

class SessionInterruptionMonitor(context: Context) {
    private val telephonyMonitor = SessionTelephonyMonitor(context)
    private val audioModeMonitor = SessionAudioModeMonitor(context)
    private val audioFocusMonitor = SessionAudioFocusMonitor(context)

    var onInterrupted: (() -> Unit)? = null

    fun start() {
        val interrupt: () -> Unit = { onInterrupted?.invoke() }
        audioModeMonitor.onCallAudioActive = interrupt
        telephonyMonitor.onPhoneCall = interrupt
        audioFocusMonitor.onAudioFocusLost = interrupt
        audioModeMonitor.start()
        audioFocusMonitor.start()
        telephonyMonitor.start()
    }

    fun startTelephonyMonitoring() {
        telephonyMonitor.start()
        telephonyMonitor.endSessionIfPhoneCallIsActive()
    }

    fun stop() {
        audioModeMonitor.stop()
        audioFocusMonitor.stop()
        telephonyMonitor.stop()
    }

    fun endSessionIfInterruptionActive() {
        audioModeMonitor.endSessionIfCallAudioActive()
        telephonyMonitor.endSessionIfPhoneCallIsActive()
    }
}
