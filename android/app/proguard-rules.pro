# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Timezone
-keep class timezone.** { *; }

# Firebase (if you're using Firebase Messaging alongside)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# General rules for Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Prevent obfuscation of classes used in reflection
-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature

# Add these rules for Play Store split installation
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**