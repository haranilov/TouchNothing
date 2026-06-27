import SwiftUI

enum AppDestination: Equatable {
    case auth
    case mainMenu
    case rules
    case session
    case sessionResult(elapsedSeconds: Int)
    case leaderboard
    case myTotal
}

@MainActor
final class AppNavigator: ObservableObject {
    @Published var destination: AppDestination = .auth

    func bootstrap() {
        destination = LocalUserStore.hasActiveSession ? .mainMenu : .auth
    }

    func completeAuth() {
        destination = .mainMenu
    }

    func signOut() {
        SessionSaveService.shared.resetIfNotSaving()
        LocalUserStore.signOut()
        destination = .auth
    }

    func startSessionFlow() {
        if LocalUserStore.rulesHidden {
            destination = .session
            return
        }
        destination = .rules
    }

    func beginSession() {
        destination = .session
    }

    func finishSession(elapsedSeconds: Int) {
        SessionSaveService.shared.queueSave(elapsedSeconds: elapsedSeconds)
        destination = .sessionResult(elapsedSeconds: elapsedSeconds)
    }

    func openLeaderboard() {
        guard destination != .leaderboard else { return }
        destination = .leaderboard
    }

    func openMyTotal() {
        guard destination != .myTotal else { return }
        destination = .myTotal
    }

    func returnToMenu() {
        guard destination != .mainMenu else { return }
        SessionSaveService.shared.resetIfNotSaving()
        destination = .mainMenu
    }
}
