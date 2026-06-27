package com.touchnothing.app.util

import android.content.Context
import android.media.AudioFocusRequest
import android.media.AudioManager

class SessionAudioFocusMonitor(private val context: Context) {
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    var onAudioFocusLost: (() -> Unit)? = null

    private var focusRequest: AudioFocusRequest? = null

    fun start() {
        val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setOnAudioFocusChangeListener { focusChange ->
                if (isInterruptingFocusChange(focusChange)) {
                    onAudioFocusLost?.invoke()
                }
            }
            .build()
        focusRequest = request
        audioManager.requestAudioFocus(request)
    }

    fun stop() {
        focusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
        focusRequest = null
    }

    companion object {
        fun isInterruptingFocusChange(focusChange: Int): Boolean =
            focusChange == AudioManager.AUDIOFOCUS_LOSS
    }
}
