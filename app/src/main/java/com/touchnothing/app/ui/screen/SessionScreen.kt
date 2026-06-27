package com.touchnothing.app.ui.screen

import android.app.Activity
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import com.touchnothing.app.ui.theme.AppColors
import com.touchnothing.app.util.SessionInterruptionMonitor
import com.touchnothing.app.util.SessionTimer

@Composable
fun SessionScreen(onFinish: (Int) -> Unit) {
    val context = LocalContext.current
    val activity = context as Activity
    val lifecycleOwner = LocalLifecycleOwner.current
    val sessionTimer = remember { SessionTimer() }
    var sessionEnded by remember { mutableStateOf(false) }
    val interruptionMonitor = remember { SessionInterruptionMonitor(context) }

    fun endSessionIfNeeded() {
        if (sessionEnded) return
        sessionEnded = true
        onFinish(sessionTimer.elapsedSeconds())
    }

    SessionPhonePermissionGate(
        onPermissionSettled = { interruptionMonitor.startTelephonyMonitoring() },
    )

    DisposableEffect(lifecycleOwner) {
        interruptionMonitor.onInterrupted = { endSessionIfNeeded() }
        interruptionMonitor.start()
        interruptionMonitor.endSessionIfInterruptionActive()

        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_STOP) {
                endSessionIfNeeded()
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)

        val window = activity.window
        val controller = WindowCompat.getInsetsController(window, window.decorView)
        controller.hide(WindowInsetsCompat.Type.systemBars())
        controller.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE

        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
            interruptionMonitor.stop()
            controller.show(WindowInsetsCompat.Type.systemBars())
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .clickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() },
                onClick = { endSessionIfNeeded() },
            ),
    )
}
