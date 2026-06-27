package com.touchnothing.app.util

class SessionTimer(private val startMillis: Long = System.currentTimeMillis()) {
    fun elapsedSeconds(endMillis: Long = System.currentTimeMillis()): Int {
        val interval = (endMillis - startMillis) / 1000.0
        return maxOf(0, interval.toInt())
    }
}
