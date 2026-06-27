package com.touchnothing.app.domain

import com.touchnothing.app.data.model.LeaderboardEntry
import com.touchnothing.app.data.model.LeaderboardRow
import com.touchnothing.app.data.model.TotalLeaderboardEntry
import com.touchnothing.app.util.NicknameValidator

object LeaderboardRowMapper {
    fun map(entries: List<LeaderboardEntry>, currentNickname: String?): List<LeaderboardRow> =
        mapRanked(
            items = entries.map { Triple(it.id, it.nickname, it.durationSeconds) },
            currentNickname = currentNickname,
        )

    fun mapTotal(entries: List<TotalLeaderboardEntry>, currentNickname: String?): List<LeaderboardRow> =
        mapRanked(
            items = entries.map { Triple(it.nickname, it.nickname, it.totalDurationSeconds) },
            currentNickname = currentNickname,
        )

    private fun mapRanked(
        items: List<Triple<String, String, Int>>,
        currentNickname: String?,
    ): List<LeaderboardRow> {
        val normalizedCurrent = currentNickname?.let {
            NicknameValidator.normalized(it).lowercase()
        }
        return items.mapIndexed { index, item ->
            LeaderboardRow(
                id = item.first,
                rank = index + 1,
                nickname = item.second,
                durationSeconds = item.third,
                isCurrentUser = item.second.lowercase() == normalizedCurrent,
            )
        }
    }
}
