import Foundation

enum LeaderboardMode: String, CaseIterable {
    case bestSession
    case totalTime

    var titleKey: String {
        switch self {
        case .bestSession:
            return LocalizationKey.leaderboardModeBestSession
        case .totalTime:
            return LocalizationKey.leaderboardModeTotal
        }
    }
}
