# --- Flutter & App ---
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class com.devis.remindly.MainActivity { *; }

# --- Hive ---
-keep class * extends hive.TypeAdapter { *; }
-keep class * implements hive.TypeAdapter { *; }
-keepclassmembers class * {
    @hive.HiveField <fields>;
}
-keep class **.g.dart { *; }
-keep class com.devis.remindly.** { *; }

# --- Google Mobile Ads (google_mobile_ads Flutter plugin v5.x) ---
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.gms.ads.initialization.** { *; }
-keep class com.google.android.gms.ads.interstitial.** { *; }
-keep class com.google.android.gms.ads.admanager.** { *; }
-keep class com.google.android.gms.ads.nativead.** { *; }
-keep class com.google.android.gms.ads.rewarded.** { *; }
-keep class com.google.android.gms.ads.rewardedinterstitial.** { *; }
-keep class com.google.android.gms.ads.query.** { *; }
-keep class com.google.android.gms.ads.formats.** { *; }
-keep class com.google.android.gms.ads.mediation.** { *; }

# Keep all Google Play Services Ad ID and common classes
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Keep the internal ads classes used by google_mobile_ads Flutter plugin
-keep class com.google.android.gms.internal.ads.** { *; }
-keep class com.google.android.gms.ads.internal.** { *; }

# Keep GMA SDK initialization classes
-keep class com.google.android.gms.ads.initialization.InitializationStatus { *; }
-keep class com.google.android.gms.ads.initialization.AdapterStatus { *; }

# Keep the Flutter plugin's platform channel handler
-keep class io.flutter.plugins.googlemobileads.** { *; }

# --- Google Play Core (for in-app updates / review) ---
-keep class com.google.android.play.core.** { *; }

# --- flutter_local_notifications (receiver classes registered programmatically) ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# --- Keep all native methods used by JNI (Flutter engine) ---
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.embedding.engine.dart.DartExecutor { *; }

# --- General ---
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# --- DontWarn (known non-fatal missing references) ---
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.ads.**
-dontwarn com.google.android.gms.internal.ads.**
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugins.**

# --- R8 full mode compatibility ---
# Prevent R8 from aggressively optimizing/obfuscating reflection-based access
-keep,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepclassmembers,allowshrinking,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep all classes with native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
