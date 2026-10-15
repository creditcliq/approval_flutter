# ==========================================================================
# CreditChek Approval Flutter Example - ProGuard / R8 Rules
# ==========================================================================

# ── 1. Google ML Kit (Critical: prevents UnsatisfiedDependencyException in MlKitInitProvider)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class * implements com.google.firebase.components.ComponentRegistrar
-keep class * implements com.google.android.datatransport.runtime.backends.BackendFactory

-keepclassmembers class * {
    @com.google.android.gms.common.annotation.KeepForSdk <fields>;
    @com.google.android.gms.common.annotation.KeepForSdk <methods>;
}

-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ── 2. TensorFlow Lite & JNI ───────────────────────────────────────────────
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class com.google.ai.edge.litert.** { *; }
-dontwarn com.google.ai.edge.litert.**

# ── 3. CameraX ─────────────────────────────────────────────────────────────
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# ── 4. Networking, Gson & Retrofit ─────────────────────────────────────────
-keepattributes Signature, *Annotation*, InnerClasses, EnclosingMethod
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── 5. CreditChek Approval Native & Flutter SDKs ───────────────────────────
-keep class com.creditchek.approval_android.** { *; }
-keep class com.creditchek.approval_flutter.** { *; }
