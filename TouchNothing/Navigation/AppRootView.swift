import SwiftUI

struct AppRootView: View {
    @StateObject private var appNavigator = AppNavigator()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            destinationView
        }
        .preferredColorScheme(.dark)
        .tint(AppColors.textPrimary)
        .animation(nil, value: appNavigator.destination)
        .fullScreenCover(isPresented: isSessionPresented) {
            SessionScreen(onFinish: appNavigator.finishSession)
        }
        .onAppear {
            appNavigator.bootstrap()
        }
    }

    private var isSessionPresented: Binding<Bool> {
        Binding(
            get: { appNavigator.destination == .session },
            set: { _ in }
        )
    }

    @ViewBuilder
    private var destinationView: some View {
        switch appNavigator.destination {
        case .auth:
            AuthScreen(onContinue: appNavigator.completeAuth)
        case .mainMenu, .leaderboard, .myTotal:
            menuStack
        case .rules:
            RulesScreen(onStart: appNavigator.beginSession)
        case .session:
            EmptyView()
        case .sessionResult(let elapsedSeconds):
            SessionResultScreen(
                elapsedSeconds: elapsedSeconds,
                onBack: appNavigator.returnToMenu
            )
        }
    }

    private var menuStack: some View {
        ZStack {
            MainMenuScreen(
                onStart: appNavigator.startSessionFlow,
                onLeaderboard: appNavigator.openLeaderboard,
                onMyTotal: appNavigator.openMyTotal,
                onSignOut: appNavigator.signOut
            )
            .opacity(appNavigator.destination == .mainMenu ? 1 : 0)
            .allowsHitTesting(appNavigator.destination == .mainMenu)
            .accessibilityHidden(appNavigator.destination != .mainMenu)

            if appNavigator.destination == .leaderboard {
                LeaderboardScreen(onBack: appNavigator.returnToMenu)
            } else if appNavigator.destination == .myTotal {
                MyTotalScreen(onBack: appNavigator.returnToMenu)
            }
        }
    }
}
