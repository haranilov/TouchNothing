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
        Group {
            switch appNavigator.destination {
            case .mainMenu:
                MainMenuScreen(
                    onStart: appNavigator.startSessionFlow,
                    onLeaderboard: appNavigator.openLeaderboard,
                    onMyTotal: appNavigator.openMyTotal,
                    onSignOut: appNavigator.signOut
                )
            case .leaderboard:
                LeaderboardScreen(onBack: appNavigator.returnToMenu)
            case .myTotal:
                MyTotalScreen(onBack: appNavigator.returnToMenu)
            default:
                EmptyView()
            }
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
        .hiddenStatusBarChrome()
    }
}
