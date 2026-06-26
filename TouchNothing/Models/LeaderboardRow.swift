import Foundation

struct LeaderboardRow: Identifiable, Equatable {
    let id: String
    let rank: Int
    let nickname: String
    let durationSeconds: Int
    let isCurrentUser: Bool
}
