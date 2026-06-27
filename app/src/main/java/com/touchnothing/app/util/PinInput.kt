package com.touchnothing.app.util

object PinInput {
    fun sanitize(value: String): String =
        value.filter { it.isDigit() }.take(AppConstants.PIN_LENGTH)

    fun isValid(value: String): Boolean =
        value.length == AppConstants.PIN_LENGTH && value.all { it.isDigit() }

    fun randomPin(): String = "%04d".format((0..9999).random())
}
