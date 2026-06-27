package com.touchnothing.app.data.local

import android.content.Context
import com.touchnothing.app.data.model.LeaderboardEntry
import com.touchnothing.app.data.model.TotalLeaderboardEntry
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class LeaderboardCache(
    private val prefs: android.content.SharedPreferences,
    private val json: Json,
) {
    constructor(context: Context) : this(
        context.getSharedPreferences(LocalUserStore.PREFS_NAME, Context.MODE_PRIVATE),
        Json { ignoreUnknownKeys = true },
    )

    fun saveBestSession(entries: List<LeaderboardEntry>) {
        save(entries, StorageKeys.LEADERBOARD_CACHE)
    }

    fun loadBestSession(): List<LeaderboardEntry> = load(StorageKeys.LEADERBOARD_CACHE)

    fun saveTotal(entries: List<TotalLeaderboardEntry>) {
        save(entries, StorageKeys.TOTAL_LEADERBOARD_CACHE)
    }

    fun loadTotal(): List<TotalLeaderboardEntry> = load(StorageKeys.TOTAL_LEADERBOARD_CACHE)

    fun clearAll() {
        prefs.edit()
            .remove(StorageKeys.LEADERBOARD_CACHE)
            .remove(StorageKeys.TOTAL_LEADERBOARD_CACHE)
            .apply()
    }

    private inline fun <reified T> save(entries: List<T>, key: String) {
        prefs.edit().putString(key, json.encodeToString(entries)).apply()
    }

    private inline fun <reified T> load(key: String): List<T> {
        val cached = prefs.getString(key, null) ?: return emptyList()
        return runCatching { json.decodeFromString<List<T>>(cached) }
            .getOrDefault(emptyList())
    }
}
