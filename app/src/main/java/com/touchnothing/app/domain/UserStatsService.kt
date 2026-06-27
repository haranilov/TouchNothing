package com.touchnothing.app.domain

import com.touchnothing.app.data.model.UserStats
import com.touchnothing.app.data.remote.SupabaseService

class UserStatsService(
    private val supabaseService: SupabaseService = SupabaseService.shared,
) {
    suspend fun load(nickname: String?): UserStatsLoadResult {
        if (nickname == null) {
            return UserStatsLoadResult(stats = UserStats.Empty, status = UserStatsLoadStatus.MISSING_NICKNAME)
        }
        return runCatching {
            val stats = supabaseService.fetchUserStats(nickname)
            UserStatsLoadResult(stats = stats, status = UserStatsLoadStatus.SUCCESS)
        }.getOrElse {
            UserStatsLoadResult(stats = UserStats.Empty, status = UserStatsLoadStatus.FAILED)
        }
    }
}
