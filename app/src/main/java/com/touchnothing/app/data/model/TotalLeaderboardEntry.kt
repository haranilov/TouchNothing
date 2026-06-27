package com.touchnothing.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class TotalLeaderboardEntry(
    val nickname: String,
    @Serializable(with = FlexibleIntSerializer::class)
    @SerialName("total_duration_seconds") val totalDurationSeconds: Int,
)
