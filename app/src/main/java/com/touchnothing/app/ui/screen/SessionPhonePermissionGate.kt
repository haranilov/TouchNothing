package com.touchnothing.app.ui.screen

import android.Manifest
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import com.touchnothing.app.R
import com.touchnothing.app.util.SessionTelephonyMonitor

@Composable
fun SessionPhonePermissionGate(onPermissionSettled: () -> Unit) {
    val context = LocalContext.current
    var showRationale by remember { mutableStateOf(false) }

    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) { _ ->
        onPermissionSettled()
    }

    fun requestPermission() {
        permissionLauncher.launch(Manifest.permission.READ_PHONE_STATE)
    }

    LaunchedEffect(Unit) {
        if (SessionTelephonyMonitor.hasPhoneStatePermission(context)) return@LaunchedEffect
        showRationale = true
    }

    if (!showRationale) return

    AlertDialog(
        onDismissRequest = {
            showRationale = false
            requestPermission()
        },
        title = { Text(stringResource(R.string.session_phone_permission_title)) },
        text = { Text(stringResource(R.string.session_phone_permission_message)) },
        confirmButton = {
            TextButton(
                onClick = {
                    showRationale = false
                    requestPermission()
                },
            ) {
                Text(stringResource(R.string.session_phone_permission_allow))
            }
        },
        dismissButton = {
            TextButton(onClick = { showRationale = false }) {
                Text(stringResource(R.string.session_phone_permission_skip))
            }
        },
    )
}
