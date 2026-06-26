import Foundation

struct LeaderboardLoadResult {
    let rows: [LeaderboardRow]
    let statusMessage: String?
}

enum LeaderboardService {
    static func load(
        mode: LeaderboardMode,
        currentNickname: String?
    ) async -> LeaderboardLoadResult {
        switch mode {
        case .bestSession:
            await loadBestSession(currentNickname: currentNickname)
        case .totalTime:
            await loadTotal(currentNickname: currentNickname)
        }
    }

    private static func loadBestSession(currentNickname: String?) async -> LeaderboardLoadResult {
        do {
            let entries = try await SupabaseService.shared.fetchLeaderboard()
            LeaderboardCache.saveBestSession(entries: entries)
            return LeaderboardLoadResult(
                rows: LeaderboardRowMapper.map(entries: entries, currentNickname: currentNickname),
                statusMessage: nil
            )
        } catch {
            return cachedBestSessionResult(currentNickname: currentNickname)
        }
    }

    private static func loadTotal(currentNickname: String?) async -> LeaderboardLoadResult {
        do {
            let entries = try await SupabaseService.shared.fetchTotalLeaderboard()
            LeaderboardCache.saveTotal(entries: entries)
            return LeaderboardLoadResult(
                rows: LeaderboardRowMapper.mapTotal(entries: entries, currentNickname: currentNickname),
                statusMessage: nil
            )
        } catch {
            return cachedTotalResult(currentNickname: currentNickname)
        }
    }

    private static func cachedBestSessionResult(currentNickname: String?) -> LeaderboardLoadResult {
        let cachedEntries = LeaderboardCache.loadBestSession()
        guard !cachedEntries.isEmpty else {
            return LeaderboardLoadResult(rows: [], statusMessage: LocalizationKey.leaderboardError.localized)
        }

        return LeaderboardLoadResult(
            rows: LeaderboardRowMapper.map(entries: cachedEntries, currentNickname: currentNickname),
            statusMessage: LocalizationKey.leaderboardOffline.localized
        )
    }

    private static func cachedTotalResult(currentNickname: String?) -> LeaderboardLoadResult {
        let cachedEntries = LeaderboardCache.loadTotal()
        guard !cachedEntries.isEmpty else {
            return LeaderboardLoadResult(rows: [], statusMessage: LocalizationKey.leaderboardError.localized)
        }

        return LeaderboardLoadResult(
            rows: LeaderboardRowMapper.mapTotal(entries: cachedEntries, currentNickname: currentNickname),
            statusMessage: LocalizationKey.leaderboardOffline.localized
        )
    }
}
