import Foundation

enum LeaderboardCache {
    static func saveBestSession(entries: [LeaderboardEntry]) {
        save(entries, forKey: StorageKeys.leaderboardCache)
    }

    static func loadBestSession() -> [LeaderboardEntry] {
        load(forKey: StorageKeys.leaderboardCache)
    }

    static func saveTotal(entries: [TotalLeaderboardEntry]) {
        save(entries, forKey: StorageKeys.totalLeaderboardCache)
    }

    static func loadTotal() -> [TotalLeaderboardEntry] {
        load(forKey: StorageKeys.totalLeaderboardCache)
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: StorageKeys.leaderboardCache)
        UserDefaults.standard.removeObject(forKey: StorageKeys.totalLeaderboardCache)
    }

    private static func save<T: Encodable>(_ entries: [T], forKey key: String) {
        guard let encodedData = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(encodedData, forKey: key)
    }

    private static func load<T: Decodable>(forKey key: String) -> [T] {
        guard let cachedData = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        return (try? JSONDecoder().decode([T].self, from: cachedData)) ?? []
    }
}
