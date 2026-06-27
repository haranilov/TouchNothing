package com.touchnothing.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColorScheme = darkColorScheme(
    primary = AppColors.TextPrimary,
    onPrimary = AppColors.Background,
    background = AppColors.Background,
    onBackground = AppColors.TextPrimary,
    surface = AppColors.Background,
    onSurface = AppColors.TextPrimary,
    secondary = AppColors.TextSecondary,
    onSecondary = AppColors.Background,
    outline = AppColors.FieldBackground,
)

@Composable
fun TouchNothingTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        content = content,
    )
}
