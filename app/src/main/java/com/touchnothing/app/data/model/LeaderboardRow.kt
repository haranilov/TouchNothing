package com.touchnothing.app.data.model

data class LeaderboardRow(
    val id: String,
    val rank: Int,
    val nickname: String,
    val durationSeconds: Int,
    val isCurrentUser: Boolean,
)
