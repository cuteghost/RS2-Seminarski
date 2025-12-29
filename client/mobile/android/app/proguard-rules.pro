# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Facebook SDK
-keep class com.facebook.** { *; }
-keepattributes Signature

# Google services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Preserve BuildConfig (our secrets)
-keepclassmembers class **.BuildConfig {
    public static <fields>;
}

# General optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
