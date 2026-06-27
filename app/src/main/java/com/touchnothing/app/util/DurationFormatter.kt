package com.touchnothing.app.util

object DurationFormatter {
    fun format(seconds: Int): String {
        val totalSeconds = maxOf(0, seconds)
        val hours = totalSeconds / 3600
        val minutes = (totalSeconds % 3600) / 60
        val remainingSeconds = totalSeconds % 60

        return when {
            hours > 0 -> "${hours}h ${minutes}m ${remainingSeconds}s"
            minutes > 0 -> "${minutes}m ${remainingSeconds}s"
            else -> "${remainingSeconds}s"
        }
    }
}
