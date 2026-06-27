package com.touchnothing.app.ui.component

import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.touchnothing.app.R

@Composable
fun ScreenBackButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    TouchNothingButton(
        text = stringResource(R.string.result_back),
        onClick = onClick,
        modifier = modifier.padding(horizontal = 32.dp, vertical = 24.dp),
    )
}
