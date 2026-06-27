package com.touchnothing.app.ui.component

import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.touchnothing.app.ui.theme.AppColors

@Composable
fun TouchNothingTextButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    TextButton(onClick = onClick, modifier = modifier) {
        Text(text = text, color = AppColors.TextSecondary)
    }
}
