package com.touchnothing.app.util

import android.content.Context
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat

class SessionAudioModeMonitor(private val context: Context) {
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    var onCallAudioActive: (() -> Unit)? = null

    private var pollRunnable: Runnable? = null

    private val modeListener = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        AudioManager.OnModeChangedListener { mode ->
            if (isCallAudioMode(mode)) {
                onCallAudioActive?.invoke()
            }
        }
    } else {
        null
    }

    fun start() {
        if (isCallAudioMode(audioManager.mode)) {
            onCallAudioActive?.invoke()
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && modeListener != null) {
            audioManager.addOnModeChangedListener(
                ContextCompat.getMainExecutor(context),
                modeListener,
            )
            return
        }
        startPolling()
    }

    fun stop() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && modeListener != null) {
            audioManager.removeOnModeChangedListener(modeListener)
        }
        stopPolling()
    }

    fun endSessionIfCallAudioActive() {
        if (isCallAudioMode(audioManager.mode)) {
            onCallAudioActive?.invoke()
        }
    }

    private fun startPolling() {
        stopPolling()
        val runnable = object : Runnable {
            override fun run() {
                if (isCallAudioMode(audioManager.mode)) {
                    onCallAudioActive?.invoke()
                    return
                }
                mainHandler.postDelayed(this, POLL_INTERVAL_MS)
            }
        }
        pollRunnable = runnable
        mainHandler.post(runnable)
    }

    private fun stopPolling() {
        pollRunnable?.let { mainHandler.removeCallbacks(it) }
        pollRunnable = null
    }

    companion object {
        private const val POLL_INTERVAL_MS = 500L

        fun isCallAudioMode(mode: Int): Boolean =
            mode == AudioManager.MODE_IN_CALL || mode == AudioManager.MODE_IN_COMMUNICATION
    }
}
