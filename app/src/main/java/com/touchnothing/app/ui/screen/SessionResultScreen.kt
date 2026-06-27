package com.touchnothing.app.ui.screen

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.touchnothing.app.R
import com.touchnothing.app.domain.SessionSaveService
import com.touchnothing.app.domain.SessionSaveState
import com.touchnothing.app.ui.component.HiddenStatusBarEffect
import com.touchnothing.app.ui.component.TouchNothingButton
import com.touchnothing.app.ui.component.TouchNothingScreenLayout
import com.touchnothing.app.ui.theme.AppColors
import com.touchnothing.app.util.AppConstants
import com.touchnothing.app.util.DurationFormatter

@Composable
fun SessionResultScreen(
    elapsedSeconds: Int,
    sessionSaveService: SessionSaveService,
    onBack: () -> Unit,
) {
    val saveState by sessionSaveService.state.collectAsState()
    val formattedDuration = DurationFormatter.format(elapsedSeconds)
    val sessionTooShort = elapsedSeconds < AppConstants.MIN_SESSION_SECONDS

    HiddenStatusBarEffect()

    TouchNothingScreenLayout(modifier = Modifier.fillMaxSize(), applyStatusBarPadding = false) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = stringResource(R.string.result_title, formattedDuration),
                fontSize = 22.sp,
                color = AppColors.TextPrimary,
                textAlign = TextAlign.Center,
            )
            Spacer(modifier = Modifier.height(24.dp))

            if (sessionTooShort) {
                Text(
                    text = stringResource(R.string.result_too_short),
                    color = AppColors.TextSecondary,
                    fontSize = 12.sp,
                    textAlign = TextAlign.Center,
                )
            }
            if (!sessionTooShort) {
                val statusText = when (saveState) {
                    SessionSaveState.IDLE, SessionSaveState.SAVING -> stringResource(R.string.result_saving)
                    SessionSaveState.SAVED -> stringResource(R.string.result_saved)
                    SessionSaveState.FAILED -> stringResource(R.string.result_save_failed)
                }
                Text(
                    text = statusText,
                    color = AppColors.TextSecondary,
                    fontSize = 12.sp,
                    textAlign = TextAlign.Center,
                )
            }

            if (saveState == SessionSaveState.FAILED) {
                Spacer(modifier = Modifier.height(16.dp))
                TouchNothingButton(
                    text = stringResource(R.string.result_retry_save),
                    onClick = { sessionSaveService.retry() },
                )
            }

            Spacer(modifier = Modifier.height(24.dp))
            TouchNothingButton(
                text = stringResource(R.string.result_back),
                onClick = onBack,
            )
            Spacer(modifier = Modifier.weight(1f))
        }
    }
}
