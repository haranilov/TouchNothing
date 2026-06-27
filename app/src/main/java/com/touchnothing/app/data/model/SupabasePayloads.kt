package com.touchnothing.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AuthSession(
    val nickname: String,
    @SerialName("session_token") val sessionToken: String,
)

@Serializable
data class AuthRpcResponse(
    val ok: Boolean? = null,
    val error: String? = null,
    val nickname: String? = null,
    @SerialName("session_token") val sessionToken: String? = null,
    @SerialName("remaining_attempts") val remainingAttempts: Int? = null,
)

@Serializable
data class NicknameParams(
    @SerialName("p_nickname") val pNickname: String,
    @SerialName("p_pin") val pPin: String,
)

@Serializable
data class SessionParams(
    @SerialName("p_nickname") val pNickname: String,
    @SerialName("p_duration") val pDuration: Int,
    @SerialName("p_session_token") val pSessionToken: String,
)

@Serializable
data class UserStatsParams(
    @SerialName("p_nickname") val pNickname: String,
)
