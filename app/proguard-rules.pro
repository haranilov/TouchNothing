-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

-keep,includedescriptorclasses class com.touchnothing.app.**$$serializer { *; }
-keepclassmembers class com.touchnothing.app.** {
    *** Companion;
}
-keepclasseswithmembers class com.touchnothing.app.** {
    kotlinx.serialization.KSerializer serializer(...);
}

-dontwarn io.ktor.**
-dontwarn kotlinx.atomicfu.**
