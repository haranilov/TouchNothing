package com.touchnothing.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class UserStats(
    @Serializable(with = FlexibleIntSerializer::class)
    @SerialName("total_duration_seconds") val totalDurationSeconds: Int = 0,
    @Serializable(with = FlexibleIntSerializer::class)
    @SerialName("session_count") val sessionCount: Int = 0,
) {
    companion object {
        val Empty = UserStats()
    }
}
