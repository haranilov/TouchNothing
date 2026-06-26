import Foundation

struct TotalLeaderboardEntry: Codable, Identifiable, Equatable {
    let nickname: String
    let totalDurationSeconds: Int

    var id: String { nickname }

    enum CodingKeys: String, CodingKey {
        case nickname
        case totalDurationSeconds = "total_duration_seconds"
    }

    init(nickname: String, totalDurationSeconds: Int) {
        self.nickname = nickname
        self.totalDurationSeconds = totalDurationSeconds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nickname = try container.decode(String.self, forKey: .nickname)
        totalDurationSeconds = try UserStats.decodeFlexibleInt(from: container, forKey: .totalDurationSeconds)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(totalDurationSeconds, forKey: .totalDurationSeconds)
    }
}
