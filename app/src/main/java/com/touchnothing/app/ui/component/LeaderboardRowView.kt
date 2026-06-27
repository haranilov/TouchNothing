package com.touchnothing.app.ui.component

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.touchnothing.app.data.model.LeaderboardRow
import com.touchnothing.app.ui.theme.AppColors
import com.touchnothing.app.util.DurationFormatter

@Composable
fun LeaderboardRowView(
    row: LeaderboardRow,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = row.rank.toString(),
            color = AppColors.TextPrimary,
            modifier = Modifier.padding(end = 8.dp),
        )
        Text(
            text = row.nickname,
            color = AppColors.TextPrimary,
            maxLines = 1,
            modifier = Modifier.weight(1f),
        )
        Text(
            text = DurationFormatter.format(row.durationSeconds),
            color = AppColors.TextPrimary,
        )
    }
}
