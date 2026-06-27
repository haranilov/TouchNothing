package com.touchnothing.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.lifecycleScope
import com.touchnothing.app.data.local.LeaderboardCache
import com.touchnothing.app.data.local.LocalUserStore
import com.touchnothing.app.domain.AuthService
import com.touchnothing.app.domain.LeaderboardService
import com.touchnothing.app.domain.SessionSaveService
import com.touchnothing.app.domain.UserStatsService
import com.touchnothing.app.ui.TouchNothingApp
import com.touchnothing.app.ui.theme.TouchNothingTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val localUserStore = LocalUserStore(this)
        val leaderboardCache = LeaderboardCache(this)
        val authService = AuthService(localUserStore)
        val leaderboardService = LeaderboardService(leaderboardCache)
        val userStatsService = UserStatsService()
        val sessionSaveService = SessionSaveService(
            localUserStore = localUserStore,
            authService = authService,
            leaderboardCache = leaderboardCache,
            saveScope = lifecycleScope,
        )

        setContent {
            TouchNothingTheme {
                TouchNothingApp(
                    localUserStore = localUserStore,
                    authService = authService,
                    leaderboardService = leaderboardService,
                    userStatsService = userStatsService,
                    sessionSaveService = sessionSaveService,
                )
            }
        }
    }
}
