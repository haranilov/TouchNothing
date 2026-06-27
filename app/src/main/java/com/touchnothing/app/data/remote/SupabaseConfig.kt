package com.touchnothing.app.data.remote

import com.touchnothing.app.BuildConfig

object SupabaseConfig {
    val url: String?
        get() {
            val value = BuildConfig.SUPABASE_URL
            if (value.isBlank() || value.contains("YOUR_PROJECT_REF")) return null
            return value.trimEnd('/')
        }

    val anonKey: String?
        get() {
            val value = BuildConfig.SUPABASE_ANON_KEY
            if (value.isBlank() || value.contains("YOUR_ANON_KEY")) return null
            return value
        }

    val isConfigured: Boolean
        get() = url != null && anonKey != null
}
