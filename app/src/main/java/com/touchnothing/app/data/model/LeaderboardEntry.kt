package com.touchnothing.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class LeaderboardEntry(
    val id: String,
    val nickname: String,
    @Serializable(with = FlexibleIntSerializer::class)
    @SerialName("duration_seconds") val durationSeconds: Int,
    @SerialName("created_at") val createdAt: String? = null,
)
