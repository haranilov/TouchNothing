package com.touchnothing.app.data.remote

import com.touchnothing.app.data.model.AuthRpcResponse
import com.touchnothing.app.data.model.AuthSession
import com.touchnothing.app.util.NicknameValidator
import kotlinx.serialization.json.Json

object AuthResponseDecoder {
    private val json = Json { ignoreUnknownKeys = true }

    fun decodeSession(data: String, fallbackNickname: String): AuthSession {
        runCatching {
            val payload = json.decodeFromString<AuthRpcResponse>(data)
            payload.serviceError?.let { throw it }
            payload.authSession?.let { return it }
        }

        runCatching {
            return json.decodeFromString<AuthSession>(data)
        }

        runCatching {
            val token = json.decodeFromString<String>(data)
            return AuthSession(
                nickname = NicknameValidator.normalized(fallbackNickname),
                sessionToken = token,
            )
        }

        throw SupabaseServiceError.ServerUpgradeRequired
    }
}

private val AuthRpcResponse.authSession: AuthSession?
    get() {
        if (ok == false) return null
        val nick = nickname ?: return null
        val token = sessionToken ?: return null
        return AuthSession(nickname = nick, sessionToken = token)
    }

private val AuthRpcResponse.serviceError: SupabaseServiceError?
    get() {
        if (ok != false) return null
        if (error == "invalid_credentials") {
            return SupabaseServiceError.InvalidCredentials(remainingAttempts)
        }
        return SupabaseRpcErrorMapper.mapAuthErrorToken(error) ?: SupabaseServiceError.NetworkFailure
    }
