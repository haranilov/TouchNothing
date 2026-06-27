package com.touchnothing.app.domain

import android.content.Context
import com.touchnothing.app.R
import com.touchnothing.app.data.model.LeaderboardRow

data class LeaderboardLoadResult(
    val rows: List<LeaderboardRow>,
    val status: LeaderboardLoadStatus,
) {
    fun statusMessage(context: Context): String? {
        if (status != LeaderboardLoadStatus.OFFLINE_CACHED) return null
        return context.getString(R.string.leaderboard_offline)
    }

    val isFailure: Boolean
        get() = status == LeaderboardLoadStatus.FAILED
}
