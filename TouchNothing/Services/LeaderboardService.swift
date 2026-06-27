import Foundation

enum LeaderboardLoadStatus: Equatable {
    case success
    case offlineCached
    case failed
}

struct LeaderboardLoadResult {
    let rows: [LeaderboardRow]
    let status: LeaderboardLoadStatus

    var statusMessage: String? {
        switch status {
        case .success, .failed:
            return nil
        case .offlineCached:
            return LocalizationKey.leaderboardOffline.localized
        }
    }

    var isFailure: Bool {
        status == .failed
    }
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
                status: .success
            )
        } catch {
            return cachedResult(
                cachedEntries: LeaderboardCache.loadBestSession(),
                currentNickname: currentNickname,
                mapRows: LeaderboardRowMapper.map(entries:currentNickname:)
            )
        }
    }

    private static func loadTotal(currentNickname: String?) async -> LeaderboardLoadResult {
        do {
            let entries = try await SupabaseService.shared.fetchTotalLeaderboard()
            LeaderboardCache.saveTotal(entries: entries)
            return LeaderboardLoadResult(
                rows: LeaderboardRowMapper.mapTotal(entries: entries, currentNickname: currentNickname),
                status: .success
            )
        } catch {
            return cachedResult(
                cachedEntries: LeaderboardCache.loadTotal(),
                currentNickname: currentNickname,
                mapRows: LeaderboardRowMapper.mapTotal(entries:currentNickname:)
            )
        }
    }

    private static func cachedResult<T>(
        cachedEntries: [T],
        currentNickname: String?,
        mapRows: ([T], String?) -> [LeaderboardRow]
    ) -> LeaderboardLoadResult {
        guard !cachedEntries.isEmpty else {
            return LeaderboardLoadResult(rows: [], status: .failed)
        }

        return LeaderboardLoadResult(
            rows: mapRows(cachedEntries, currentNickname),
            status: .offlineCached
        )
    }
}
