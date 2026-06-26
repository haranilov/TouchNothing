import Foundation

enum LeaderboardRowMapper {
    static func map(
        entries: [LeaderboardEntry],
        currentNickname: String?
    ) -> [LeaderboardRow] {
        mapRanked(
            items: entries.map { ($0.id.uuidString, $0.nickname, $0.durationSeconds) },
            currentNickname: currentNickname
        )
    }

    static func mapTotal(
        entries: [TotalLeaderboardEntry],
        currentNickname: String?
    ) -> [LeaderboardRow] {
        mapRanked(
            items: entries.map { ($0.nickname, $0.nickname, $0.totalDurationSeconds) },
            currentNickname: currentNickname
        )
    }

    private static func mapRanked(
        items: [(id: String, nickname: String, durationSeconds: Int)],
        currentNickname: String?
    ) -> [LeaderboardRow] {
        let normalizedCurrent = currentNickname.map { NicknameValidator.normalized($0).lowercased() }

        return items.enumerated().map { index, item in
            LeaderboardRow(
                id: item.id,
                rank: index + 1,
                nickname: item.nickname,
                durationSeconds: item.durationSeconds,
                isCurrentUser: item.nickname.lowercased() == normalizedCurrent
            )
        }
    }
}
