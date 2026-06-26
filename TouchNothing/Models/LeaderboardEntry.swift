import Foundation

struct LeaderboardEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let nickname: String
    let durationSeconds: Int
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case durationSeconds = "duration_seconds"
        case createdAt = "created_at"
    }

    init(id: UUID, nickname: String, durationSeconds: Int, createdAt: String?) {
        self.id = id
        self.nickname = nickname
        self.durationSeconds = durationSeconds
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        nickname = try container.decode(String.self, forKey: .nickname)
        durationSeconds = try UserStats.decodeFlexibleInt(from: container, forKey: .durationSeconds)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }
}
