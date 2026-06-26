import Foundation

struct UserStats: Codable, Equatable {
    let totalDurationSeconds: Int
    let sessionCount: Int

    enum CodingKeys: String, CodingKey {
        case totalDurationSeconds = "total_duration_seconds"
        case sessionCount = "session_count"
    }

    init(totalDurationSeconds: Int, sessionCount: Int) {
        self.totalDurationSeconds = totalDurationSeconds
        self.sessionCount = sessionCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalDurationSeconds = try Self.decodeFlexibleInt(from: container, forKey: .totalDurationSeconds)
        sessionCount = try Self.decodeFlexibleInt(from: container, forKey: .sessionCount)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalDurationSeconds, forKey: .totalDurationSeconds)
        try container.encode(sessionCount, forKey: .sessionCount)
    }

    static let empty = UserStats(totalDurationSeconds: 0, sessionCount: 0)

    static func decodeFlexibleInt<K: CodingKey>(
        from container: KeyedDecodingContainer<K>,
        forKey key: K
    ) throws -> Int {
        if let value = try? container.decode(Int.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return Int(value)
        }
        if let string = try? container.decode(String.self, forKey: key),
           let value = Int(string) {
            return value
        }

        throw DecodingError.typeMismatch(
            Int.self,
            DecodingError.Context(
                codingPath: container.codingPath + [key],
                debugDescription: "Expected Int, Int64, or numeric String."
            )
        )
    }
}
