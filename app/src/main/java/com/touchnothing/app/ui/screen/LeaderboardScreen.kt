package com.touchnothing.app.ui.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.touchnothing.app.R
import com.touchnothing.app.data.model.LeaderboardMode
import com.touchnothing.app.data.model.LeaderboardRow
import com.touchnothing.app.domain.LeaderboardLoadResult
import com.touchnothing.app.domain.LeaderboardService
import com.touchnothing.app.ui.component.LeaderboardRowView
import com.touchnothing.app.ui.component.LoadingStateView
import com.touchnothing.app.ui.component.ScreenBackButton
import com.touchnothing.app.ui.component.TouchNothingScreenLayout
import com.touchnothing.app.ui.component.TouchNothingSegmentedPicker
import com.touchnothing.app.ui.theme.AppColors
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LeaderboardScreen(
    leaderboardService: LeaderboardService,
    currentNickname: String?,
    onBack: () -> Unit,
) {
    val context = LocalContext.current
    val refreshScope = rememberCoroutineScope()
    var mode by remember { mutableStateOf(LeaderboardMode.BEST_SESSION) }
    var rows by remember { mutableStateOf<List<LeaderboardRow>>(emptyList()) }
    var statusMessage by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var isRefreshing by remember { mutableStateOf(false) }
    var loadFailed by remember { mutableStateOf(false) }
    var loadGeneration by remember { mutableIntStateOf(0) }

    val modeOptions = listOf(
        stringResource(R.string.leaderboard_mode_best_session),
        stringResource(R.string.leaderboard_mode_total),
    )
    val selectedModeIndex = if (mode == LeaderboardMode.BEST_SESSION) 0 else 1

    suspend fun applyLoadResult(result: LeaderboardLoadResult) {
        rows = result.rows
        statusMessage = result.statusMessage(context)
        loadFailed = result.isFailure
    }

    suspend fun loadLeaderboard(generation: Int) {
        val result = leaderboardService.load(mode, currentNickname)
        if (generation != loadGeneration) return
        applyLoadResult(result)
    }

    LaunchedEffect(mode) {
        loadGeneration += 1
        val generation = loadGeneration
        isLoading = true
        loadFailed = false
        loadLeaderboard(generation)
        isLoading = false
    }

    fun refreshLeaderboard() {
        refreshScope.launch {
            isRefreshing = true
            loadGeneration += 1
            val generation = loadGeneration
            loadLeaderboard(generation)
            isRefreshing = false
        }
    }

    Column(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        TouchNothingScreenLayout {
            Column(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = stringResource(R.string.leaderboard_title),
                    fontSize = 22.sp,
                    color = AppColors.TextPrimary,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 24.dp, bottom = 12.dp),
                    textAlign = TextAlign.Center,
                )
                TouchNothingSegmentedPicker(
                    options = modeOptions,
                    selectedIndex = selectedModeIndex,
                    onSelected = { index ->
                        mode = if (index == 0) LeaderboardMode.BEST_SESSION else LeaderboardMode.TOTAL_TIME
                    },
                )
                statusMessage?.let { message ->
                    Text(
                        text = message,
                        color = AppColors.TextSecondary,
                        fontSize = 12.sp,
                        modifier = Modifier.padding(top = 8.dp),
                    )
                }
            }
        }

        PullToRefreshBox(
            isRefreshing = isRefreshing,
            onRefresh = ::refreshLeaderboard,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                when {
                    isLoading && rows.isEmpty() -> LoadingStateView(Modifier.align(Alignment.Center))
                    loadFailed -> Text(
                        text = stringResource(R.string.leaderboard_error),
                        color = AppColors.TextSecondary,
                        modifier = Modifier.align(Alignment.Center).padding(horizontal = 16.dp),
                        textAlign = TextAlign.Center,
                    )
                    rows.isEmpty() -> Text(
                        text = stringResource(R.string.leaderboard_empty),
                        color = AppColors.TextSecondary,
                        modifier = Modifier.align(Alignment.Center),
                    )
                    else -> LazyColumn(modifier = Modifier.fillMaxSize()) {
                        items(rows, key = { it.id }) { row ->
                            LeaderboardRowView(
                                row = row,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .background(
                                        if (row.isCurrentUser) AppColors.FieldBackground else AppColors.Background,
                                    )
                                    .padding(horizontal = 16.dp, vertical = 12.dp),
                            )
                        }
                    }
                }
            }
        }

        ScreenBackButton(onClick = onBack)
    }
}
