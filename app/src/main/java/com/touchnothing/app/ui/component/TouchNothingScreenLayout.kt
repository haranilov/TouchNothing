package com.touchnothing.app.ui.component

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.touchnothing.app.ui.theme.AppColors

@Composable
fun TouchNothingScreenLayout(
    modifier: Modifier = Modifier,
    applyStatusBarPadding: Boolean = true,
    content: @Composable () -> Unit,
) {
    Column(
        modifier = modifier
            .background(AppColors.Background)
            .then(
                if (applyStatusBarPadding) {
                    Modifier.statusBarsPadding()
                } else {
                    Modifier
                },
            )
            .padding(horizontal = 32.dp),
    ) {
        content()
    }
}
