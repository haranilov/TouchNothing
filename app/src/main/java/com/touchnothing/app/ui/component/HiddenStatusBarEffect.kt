package com.touchnothing.app.ui.component

import android.app.Activity
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.ui.platform.LocalContext
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat

@Composable
fun HiddenStatusBarEffect() {
    val context = LocalContext.current
    DisposableEffect(Unit) {
        val window = (context as Activity).window
        val controller = WindowCompat.getInsetsController(window, window.decorView)
        controller.hide(WindowInsetsCompat.Type.statusBars())
        onDispose {
            controller.show(WindowInsetsCompat.Type.statusBars())
        }
    }
}
