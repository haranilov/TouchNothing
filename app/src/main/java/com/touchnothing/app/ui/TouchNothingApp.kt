package com.touchnothing.app.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.touchnothing.app.data.local.LocalUserStore
import com.touchnothing.app.domain.AuthService
import com.touchnothing.app.domain.LeaderboardService
import com.touchnothing.app.domain.SessionSaveService
import com.touchnothing.app.domain.UserStatsService
import com.touchnothing.app.ui.navigation.AppDestination
import com.touchnothing.app.ui.navigation.AppDestinationSaver
import com.touchnothing.app.ui.navigation.AppNavigator
import com.touchnothing.app.ui.screen.AuthScreen
import com.touchnothing.app.ui.screen.LeaderboardScreen
import com.touchnothing.app.ui.screen.MainMenuScreen
import com.touchnothing.app.ui.screen.MyTotalScreen
import com.touchnothing.app.ui.screen.RulesScreen
import com.touchnothing.app.ui.screen.SessionResultScreen
import com.touchnothing.app.ui.screen.SessionScreen
import com.touchnothing.app.ui.theme.AppColors

@Composable
fun TouchNothingApp(
    localUserStore: LocalUserStore,
    authService: AuthService,
    leaderboardService: LeaderboardService,
    userStatsService: UserStatsService,
    sessionSaveService: SessionSaveService,
) {
    var hideRulesNextTime by remember { mutableStateOf(false) }

    val navigator = remember {
        AppNavigator(
            hasActiveSession = { localUserStore.hasActiveSession },
            rulesHidden = { localUserStore.rulesHidden },
            onSignOut = { localUserStore.signOut() },
            onResetSessionSave = { sessionSaveService.resetIfNotSaving() },
        )
    }

    var destination by rememberSaveable(stateSaver = AppDestinationSaver) {
        mutableStateOf<AppDestination>(AppDestination.Auth)
    }
    var bootstrapped by rememberSaveable { mutableStateOf(false) }

    DisposableEffect(Unit) {
        if (!bootstrapped) {
            navigator.bootstrap()
            destination = navigator.destination
            bootstrapped = true
        }
        onDispose { }
    }

    fun navigate(action: () -> Unit) {
        action()
        destination = navigator.destination
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background),
    ) {
        when (val current = destination) {
            AppDestination.Auth -> AuthScreen(
                authService = authService,
                savedNickname = localUserStore.nickname,
                onContinue = { navigate { navigator.completeAuth() } },
            )
            AppDestination.MainMenu -> MainMenuScreen(
                onStart = { navigate { navigator.startSessionFlow() } },
                onLeaderboard = { navigate { navigator.openLeaderboard() } },
                onMyTotal = { navigate { navigator.openMyTotal() } },
                onSignOut = { navigate { navigator.signOut() } },
            )
            AppDestination.Rules -> RulesScreen(
                onHideRulesChanged = { hideRulesNextTime = it },
                onStart = {
                    if (hideRulesNextTime) {
                        localUserStore.rulesHidden = true
                    }
                    navigate { navigator.beginSession() }
                },
            )
            AppDestination.Session -> SessionScreen(
                onFinish = { elapsed ->
                    sessionSaveService.queueSave(elapsed)
                    navigate { navigator.finishSession(elapsed) }
                },
            )
            is AppDestination.SessionResult -> SessionResultScreen(
                elapsedSeconds = current.elapsedSeconds,
                sessionSaveService = sessionSaveService,
                onBack = { navigate { navigator.returnToMenu() } },
            )
            AppDestination.Leaderboard -> LeaderboardScreen(
                leaderboardService = leaderboardService,
                currentNickname = localUserStore.nickname,
                onBack = { navigate { navigator.returnToMenu() } },
            )
            AppDestination.MyTotal -> MyTotalScreen(
                userStatsService = userStatsService,
                nickname = localUserStore.nickname,
                onBack = { navigate { navigator.returnToMenu() } },
            )
        }
    }
}
