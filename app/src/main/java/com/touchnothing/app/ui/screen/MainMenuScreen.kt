package com.touchnothing.app.ui.screen

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.touchnothing.app.R
import com.touchnothing.app.ui.component.TouchNothingButton
import com.touchnothing.app.ui.component.TouchNothingScreenLayout
import com.touchnothing.app.ui.component.TouchNothingTextButton
import com.touchnothing.app.ui.theme.AppColors

@Composable
fun MainMenuScreen(
    onStart: () -> Unit,
    onLeaderboard: () -> Unit,
    onMyTotal: () -> Unit,
    onSignOut: () -> Unit,
) {
    TouchNothingScreenLayout(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = stringResource(R.string.app_name),
                fontSize = 34.sp,
                color = AppColors.TextPrimary,
            )
            Spacer(modifier = Modifier.weight(1f))
            Column {
                TouchNothingButton(text = stringResource(R.string.menu_start), onClick = onStart)
                Spacer(modifier = Modifier.height(16.dp))
                TouchNothingButton(text = stringResource(R.string.menu_leaderboard), onClick = onLeaderboard)
                Spacer(modifier = Modifier.height(16.dp))
                TouchNothingButton(text = stringResource(R.string.menu_my_total), onClick = onMyTotal)
            }
            Spacer(modifier = Modifier.height(8.dp))
            TouchNothingTextButton(text = stringResource(R.string.menu_sign_out), onClick = onSignOut)
            Spacer(modifier = Modifier.weight(1f))
        }
    }
}
