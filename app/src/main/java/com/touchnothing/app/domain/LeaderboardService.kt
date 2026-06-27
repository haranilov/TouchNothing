package com.touchnothing.app.domain

import com.touchnothing.app.data.local.LeaderboardCache
import com.touchnothing.app.data.model.LeaderboardMode
import com.touchnothing.app.data.model.LeaderboardRow
import com.touchnothing.app.data.remote.SupabaseService

class LeaderboardService(
    private val leaderboardCache: LeaderboardCache,
    private val supabaseService: SupabaseService = SupabaseService.shared,
) {
    suspend fun load(mode: LeaderboardMode, currentNickname: String?): LeaderboardLoadResult =
        when (mode) {
            LeaderboardMode.BEST_SESSION -> loadBestSession(currentNickname)
            LeaderboardMode.TOTAL_TIME -> loadTotal(currentNickname)
        }

    private suspend fun loadBestSession(currentNickname: String?): LeaderboardLoadResult {
        return runCatching {
            val entries = supabaseService.fetchLeaderboard()
            leaderboardCache.saveBestSession(entries)
            LeaderboardLoadResult(
                rows = LeaderboardRowMapper.map(entries, currentNickname),
                status = LeaderboardLoadStatus.SUCCESS,
            )
        }.getOrElse {
            cachedResult(
                cachedEntries = leaderboardCache.loadBestSession(),
                currentNickname = currentNickname,
            ) { entries, nickname ->
                LeaderboardRowMapper.map(entries, nickname)
            }
        }
    }

    private suspend fun loadTotal(currentNickname: String?): LeaderboardLoadResult {
        return runCatching {
            val entries = supabaseService.fetchTotalLeaderboard()
            leaderboardCache.saveTotal(entries)
            LeaderboardLoadResult(
                rows = LeaderboardRowMapper.mapTotal(entries, currentNickname),
                status = LeaderboardLoadStatus.SUCCESS,
            )
        }.getOrElse {
            cachedResult(
                cachedEntries = leaderboardCache.loadTotal(),
                currentNickname = currentNickname,
            ) { entries, nickname ->
                LeaderboardRowMapper.mapTotal(entries, nickname)
            }
        }
    }

    private fun <T> cachedResult(
        cachedEntries: List<T>,
        currentNickname: String?,
        mapRows: (List<T>, String?) -> List<LeaderboardRow>,
    ): LeaderboardLoadResult {
        if (cachedEntries.isEmpty()) {
            return LeaderboardLoadResult(emptyList(), LeaderboardLoadStatus.FAILED)
        }
        return LeaderboardLoadResult(
            rows = mapRows(cachedEntries, currentNickname),
            status = LeaderboardLoadStatus.OFFLINE_CACHED,
        )
    }
}
