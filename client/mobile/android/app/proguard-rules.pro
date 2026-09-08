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

# Play Core / deferred components.
# Flutter's embedding references com.google.android.play.core.* from
# FlutterPlayStoreSplitApplication and PlayStoreDeferredComponentManager, but
# this app does not use deferred components and does not ship Play Core, so
# R8 fails the release build on the missing classes. This app does not use
# deferred components, so suppressing the references is correct here.
-dontwarn com.google.android.play.core.**

# General optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
