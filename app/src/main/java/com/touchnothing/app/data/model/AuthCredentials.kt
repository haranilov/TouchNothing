package com.touchnothing.app.data.model

data class AuthCredentials(
    val mode: AuthMode,
    val nickname: String,
    val pin: String,
    val confirmPin: String,
)
