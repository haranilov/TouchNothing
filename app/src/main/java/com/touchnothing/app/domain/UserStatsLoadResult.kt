package com.touchnothing.app.domain

import com.touchnothing.app.data.model.UserStats

data class UserStatsLoadResult(
    val stats: UserStats,
    val status: UserStatsLoadStatus,
)
