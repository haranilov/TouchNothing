package com.touchnothing.app.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.touchnothing.app.R
import com.touchnothing.app.data.model.UserStats
import com.touchnothing.app.domain.UserStatsLoadStatus
import com.touchnothing.app.domain.UserStatsService
import com.touchnothing.app.ui.component.LoadingStateView
import com.touchnothing.app.ui.component.ScreenBackButton
import com.touchnothing.app.ui.component.TouchNothingScreenLayout
import com.touchnothing.app.ui.theme.AppColors
import com.touchnothing.app.util.DurationFormatter

@Composable
fun MyTotalScreen(
    userStatsService: UserStatsService,
    nickname: String?,
    onBack: () -> Unit,
) {
    var userStats by remember { mutableStateOf(UserStats.Empty) }
    var isLoading by remember { mutableStateOf(true) }
    var loadFailed by remember { mutableStateOf(false) }
    var loadGeneration by remember { mutableIntStateOf(0) }

    LaunchedEffect(nickname) {
        loadGeneration += 1
        val generation = loadGeneration
        isLoading = true
        loadFailed = false
        val result = userStatsService.load(nickname)
        if (generation == loadGeneration) {
            userStats = result.stats
            loadFailed = result.status != UserStatsLoadStatus.SUCCESS
            isLoading = false
        }
    }

    Column(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        TouchNothingScreenLayout(modifier = Modifier.weight(1f)) {
            Column(
                modifier = Modifier.fillMaxSize(),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = stringResource(R.string.my_total_title),
                    color = AppColors.TextSecondary,
                    letterSpacing = 3.sp,
                    fontSize = 12.sp,
                )
                nickname?.let { name ->
                    Spacer(modifier = Modifier.height(20.dp))
                    Text(
                        text = name,
                        fontSize = 48.sp,
                        color = AppColors.TextPrimary,
                        textAlign = TextAlign.Center,
                        maxLines = 2,
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(AppColors.FieldBackground)
                            .padding(vertical = 32.dp, horizontal = 24.dp),
                    )
                }
                Spacer(modifier = Modifier.height(32.dp))
                Text(
                    text = stringResource(R.string.my_total_label),
                    color = AppColors.TextSecondary,
                )
                Spacer(modifier = Modifier.height(8.dp))
                Box(
                    modifier = Modifier.height(88.dp),
                    contentAlignment = Alignment.Center,
                ) {
                    when {
                        isLoading -> LoadingStateView()
                        loadFailed -> Text(
                            text = stringResource(R.string.my_total_load_failed),
                            color = AppColors.TextSecondary,
                            fontSize = 12.sp,
                            textAlign = TextAlign.Center,
                        )
                        else -> Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                text = DurationFormatter.format(userStats.totalDurationSeconds),
                                fontSize = 36.sp,
                                fontWeight = FontWeight.Medium,
                                color = AppColors.TextPrimary,
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            val sessionsText = if (userStats.sessionCount > 0) {
                                stringResource(R.string.my_total_sessions, userStats.sessionCount)
                            } else {
                                stringResource(R.string.my_total_no_sessions)
                            }
                            Text(
                                text = sessionsText,
                                color = AppColors.TextSecondary,
                                fontSize = 12.sp,
                            )
                        }
                    }
                }
                Spacer(modifier = Modifier.weight(1f))
            }
        }
        ScreenBackButton(onClick = onBack)
    }
}
