package com.touchnothing.app.ui.screen

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.touchnothing.app.R
import com.touchnothing.app.ui.component.HiddenStatusBarEffect
import com.touchnothing.app.ui.component.TouchNothingButton
import com.touchnothing.app.ui.component.TouchNothingScreenLayout
import com.touchnothing.app.ui.theme.AppColors

@Composable
fun RulesScreen(
    onHideRulesChanged: (Boolean) -> Unit,
    onStart: () -> Unit,
) {
    var hideRules by remember { mutableStateOf(false) }

    HiddenStatusBarEffect()

    TouchNothingScreenLayout(modifier = Modifier.fillMaxSize(), applyStatusBarPadding = false) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = stringResource(R.string.rules_body),
                color = AppColors.TextPrimary,
                textAlign = TextAlign.Center,
            )
            Spacer(modifier = Modifier.height(24.dp))
            Switch(
                checked = hideRules,
                onCheckedChange = {
                    hideRules = it
                    onHideRulesChanged(it)
                },
            )
            Text(
                text = stringResource(R.string.rules_dont_show),
                color = AppColors.TextPrimary,
            )
            Spacer(modifier = Modifier.height(24.dp))
            TouchNothingButton(
                text = stringResource(R.string.rules_start),
                onClick = onStart,
            )
            Spacer(modifier = Modifier.weight(1f))
        }
    }
}
