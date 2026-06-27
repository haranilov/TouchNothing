package com.touchnothing.app.util

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telecom.TelecomManager
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat

class SessionTelephonyMonitor(private val context: Context) {
    private val telephonyManager =
        context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    var onPhoneCall: (() -> Unit)? = null
    private var isListening = false
    private var pollRunnable: Runnable? = null

    @RequiresApi(Build.VERSION_CODES.S)
    private val telephonyCallback = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
        override fun onCallStateChanged(state: Int) {
            if (state != TelephonyManager.CALL_STATE_IDLE) {
                onPhoneCall?.invoke()
            }
        }
    }

    @Suppress("DEPRECATION")
    private val phoneStateListener = object : PhoneStateListener() {
        @Deprecated("Deprecated in Java")
        override fun onCallStateChanged(state: Int, phoneNumber: String?) {
            if (state != TelephonyManager.CALL_STATE_IDLE) {
                onPhoneCall?.invoke()
            }
        }
    }

    fun start() {
        if (!hasPhoneStatePermission(context)) return
        if (isListening) return
        isListening = true
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            telephonyManager.registerTelephonyCallback(
                ContextCompat.getMainExecutor(context),
                telephonyCallback,
            )
        } else {
            registerLegacyPhoneStateListener()
        }
        startPolling()
    }

    fun stop() {
        if (!isListening) return
        isListening = false
        stopPolling()
        if (!hasPhoneStatePermission(context)) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            telephonyManager.unregisterTelephonyCallback(telephonyCallback)
            return
        }
        unregisterLegacyPhoneStateListener()
    }

    fun endSessionIfPhoneCallIsActive() {
        if (!hasPhoneStatePermission(context)) return
        if (isPhoneCallActive()) {
            onPhoneCall?.invoke()
        }
    }

    @Suppress("DEPRECATION")
    private fun registerLegacyPhoneStateListener() {
        telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
    }

    @Suppress("DEPRECATION")
    private fun unregisterLegacyPhoneStateListener() {
        telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
    }

    private fun startPolling() {
        stopPolling()
        val runnable = object : Runnable {
            override fun run() {
                if (isPhoneCallActive()) {
                    onPhoneCall?.invoke()
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

    @SuppressLint("MissingPermission")
    private fun isPhoneCallActive(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            if (telecomManager.isInCall) return true
        }
        return readLegacyCallState() != TelephonyManager.CALL_STATE_IDLE
    }

    @Suppress("DEPRECATION")
    private fun readLegacyCallState(): Int = telephonyManager.callState

    companion object {
        private const val POLL_INTERVAL_MS = 500L

        fun hasPhoneStatePermission(context: Context): Boolean =
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.READ_PHONE_STATE,
            ) == PackageManager.PERMISSION_GRANTED
    }
}
