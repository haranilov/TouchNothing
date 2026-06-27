import Foundation

enum UserStatsLoadStatus: Equatable {
    case success
    case failed
    case missingNickname
}

struct UserStatsLoadResult {
    let stats: UserStats
    let status: UserStatsLoadStatus
}

enum UserStatsService {
    static func load(nickname: String?) async -> UserStatsLoadResult {
        guard let nickname else {
            return UserStatsLoadResult(stats: .empty, status: .missingNickname)
        }

        do {
            let stats = try await SupabaseService.shared.fetchUserStats(nickname: nickname)
            return UserStatsLoadResult(stats: stats, status: .success)
        } catch {
            return UserStatsLoadResult(stats: .empty, status: .failed)
        }
    }
}
