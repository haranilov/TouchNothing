package com.touchnothing.app.data.remote

import com.touchnothing.app.data.model.AuthSession
import com.touchnothing.app.data.model.LeaderboardEntry
import com.touchnothing.app.data.model.NicknameParams
import com.touchnothing.app.data.model.SessionParams
import com.touchnothing.app.data.model.TotalLeaderboardEntry
import com.touchnothing.app.data.model.UserStats
import com.touchnothing.app.data.model.UserStatsParams
import com.touchnothing.app.util.AppConstants
import com.touchnothing.app.util.NicknameValidator
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.parameter
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.isSuccess
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

class SupabaseService {
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    private val client: HttpClient? = if (SupabaseConfig.isConfigured) {
        HttpClient(OkHttp) {
            install(ContentNegotiation) { json(json) }
        }
    } else {
        null
    }

    val isConfigured: Boolean
        get() = client != null

    suspend fun registerUser(nickname: String, pin: String): AuthSession =
        performAuthRpc("register_user", NicknameParams(pNickname = nickname, pPin = pin))

    suspend fun loginUser(nickname: String, pin: String): AuthSession =
        performAuthRpc("login_user", NicknameParams(pNickname = nickname, pPin = pin))

    suspend fun submitSession(nickname: String, durationSeconds: Int, sessionToken: String) {
        if (durationSeconds < AppConstants.MIN_SESSION_SECONDS) return
        executeVoidRpc(
            "submit_session",
            SessionParams(
                pNickname = nickname,
                pDuration = durationSeconds,
                pSessionToken = sessionToken,
            ),
        )
    }

    suspend fun fetchUserStats(nickname: String): UserStats {
        val http = client ?: throw SupabaseServiceError.NotConfigured
        val normalizedNickname = NicknameValidator.normalized(nickname)

        runCatching {
            val stats: List<UserStats> = fetchRpc(
                "get_user_stats",
                UserStatsParams(pNickname = normalizedNickname),
            )
            stats.firstOrNull()?.let { return it }
        }

        val stats: List<UserStats> = http.get("$baseUrl/rest/v1/user_stats") {
            applyHeaders()
            parameter("select", "total_duration_seconds,session_count")
            parameter("nickname", "ilike.$normalizedNickname")
            parameter("limit", 1)
        }.body()

        return stats.firstOrNull() ?: throw SupabaseServiceError.NetworkFailure
    }

    suspend fun fetchLeaderboard(limit: Int = AppConstants.LEADERBOARD_LIMIT): List<LeaderboardEntry> {
        val http = client ?: throw SupabaseServiceError.NotConfigured
        return http.get("$baseUrl/rest/v1/records") {
            applyHeaders()
            parameter("select", "*")
            parameter("order", "duration_seconds.desc")
            parameter("limit", limit)
        }.body()
    }

    suspend fun fetchTotalLeaderboard(limit: Int = AppConstants.LEADERBOARD_LIMIT): List<TotalLeaderboardEntry> {
        val http = client ?: throw SupabaseServiceError.NotConfigured
        return http.get("$baseUrl/rest/v1/user_stats") {
            applyHeaders()
            parameter("select", "nickname,total_duration_seconds")
            parameter("total_duration_seconds", "gt.0")
            parameter("order", "total_duration_seconds.desc")
            parameter("limit", limit)
        }.body()
    }

    private suspend fun performAuthRpc(function: String, params: NicknameParams): AuthSession {
        return try {
            decodeAuthSession(function, params)
        } catch (error: SupabaseServiceError) {
            throw error
        } catch (error: Exception) {
            throw mapUnexpectedAuthError(error)
        }
    }

    private suspend fun decodeAuthSession(function: String, params: NicknameParams): AuthSession {
        val http = client ?: throw SupabaseServiceError.NotConfigured
        val response = http.post("$baseUrl/rest/v1/rpc/$function") {
            applyHeaders()
            contentType(ContentType.Application.Json)
            setBody(params)
        }
        val body = response.bodyAsText()
        if (!response.status.isSuccess()) {
            throw SupabaseRpcErrorMapper.mapMessage(body.lowercase())
        }
        return AuthResponseDecoder.decodeSession(body, params.pNickname)
    }

    private suspend fun executeVoidRpc(function: String, params: SessionParams, mapErrors: Boolean = true) {
        val http = client ?: throw SupabaseServiceError.NotConfigured
        try {
            val response = http.post("$baseUrl/rest/v1/rpc/$function") {
                applyHeaders()
                contentType(ContentType.Application.Json)
                setBody(params)
            }
            if (!response.status.isSuccess()) {
                val body = response.bodyAsText()
                throw if (mapErrors) {
                    SupabaseRpcErrorMapper.mapMessage(body.lowercase())
                } else {
                    SupabaseServiceError.NetworkFailure
                }
            }
        } catch (error: SupabaseServiceError) {
            throw error
        } catch (error: Exception) {
            throw if (mapErrors) SupabaseRpcErrorMapper.map(error) else SupabaseServiceError.NetworkFailure
        }
    }

    private suspend inline fun <reified T> fetchRpc(
        function: String,
        params: UserStatsParams,
        mapErrors: Boolean = true,
    ): T {
        val http = client ?: throw SupabaseServiceError.NotConfigured
        return try {
            val response = http.post("$baseUrl/rest/v1/rpc/$function") {
                applyHeaders()
                contentType(ContentType.Application.Json)
                setBody(params)
            }
            if (!response.status.isSuccess()) {
                val body = response.bodyAsText()
                throw if (mapErrors) {
                    SupabaseRpcErrorMapper.mapMessage(body.lowercase())
                } else {
                    SupabaseServiceError.NetworkFailure
                }
            }
            response.body()
        } catch (error: SupabaseServiceError) {
            throw error
        } catch (error: Exception) {
            throw if (mapErrors) SupabaseRpcErrorMapper.map(error) else SupabaseServiceError.NetworkFailure
        }
    }

    private fun mapUnexpectedAuthError(error: Exception): SupabaseServiceError {
        if (SupabaseRpcErrorMapper.isLikelyEmptyAuthResponse(error)) {
            return SupabaseServiceError.ServerUpgradeRequired
        }
        return SupabaseRpcErrorMapper.map(error)
    }

    private fun io.ktor.client.request.HttpRequestBuilder.applyHeaders() {
        val key = SupabaseConfig.anonKey ?: throw SupabaseServiceError.NotConfigured
        header("apikey", key)
        header("Authorization", "Bearer $key")
    }

    private val baseUrl: String
        get() = SupabaseConfig.url ?: throw SupabaseServiceError.NotConfigured

    companion object {
        val shared = SupabaseService()
    }
}
