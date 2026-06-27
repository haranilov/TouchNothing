package com.touchnothing.app.util

object GuestNicknameGenerator {
    private const val PREFIX = "guest_"
    private const val SUFFIX_LENGTH = 6
    private const val CHARSET = "abcdefghijklmnopqrstuvwxyz0123456789"

    fun generate(): String {
        val suffix = (1..SUFFIX_LENGTH)
            .map { CHARSET.random() }
            .joinToString("")
        return PREFIX + suffix
    }
}
