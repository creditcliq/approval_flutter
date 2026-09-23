# CreditChek Approval Flutter Plugin

Official Flutter plugin for **CreditChek Approval**, providing biometric identity verification and active face liveness directly within your Flutter applications.

---

## 📚 Platform Development & Build Guides

Detailed, end-to-end guides for building native libraries, packaging artifacts (AAR / XCFramework), and continually testing new native features in Flutter:

- 🤖 **[Android & Flutter Integration Guide (ANDROID_FLUTTER_GUIDE.md)](./ANDROID_FLUTTER_GUIDE.md)**
  - Building `.aar` via Android Studio & Terminal (`./gradlew :approval_android:assembleRelease`).
  - Publishing to local Maven (`./gradlew :approval_android:publishToMavenLocal`) with automatic transitive dependency resolution (CameraX, ML Kit, Jetpack Compose, Retrofit).
  - Composite builds with `includeBuild` for instant zero-build iteration.
  - Gradle cache busting and continuous testing loop.

- 🍏 **[iOS & Flutter Integration Guide (iOS_FLUTTER_GUIDE.md)](./iOS_FLUTTER_GUIDE.md)**
  - One-time CocoaPods linking via `:path => '../../../approval_ios'`.
  - Native CocoaPod specification (`approval_ios.podspec`) and `BundleFinder.swift` compatibility.
  - Universal `.xcframework` generation via `build_xcframework.sh` for distribution.
  - Camera permissions (`NSCameraUsageDescription`), UIHostingController presentation, and physical device testing.

---

## 🚀 Getting Started

### 1. Add Dependency

In your Flutter app's `pubspec.yaml`:

```yaml
dependencies:
  approval_flutter:
    path: ../approval_flutter # for local development
    # or git:
    #   url: https://github.com/creditcliq/approval_flutter.git
```

---

## 🤖 Android Integration Process

The native Android SDK uses Jetpack Compose, CameraX, and Google ML Kit Face Detection. To ensure seamless compilation and execution in your Flutter app, follow these integration steps:

### A. Minimum SDK & Java Compatibility
Open `android/app/build.gradle` (or `android/app/build.gradle.kts`):

1. **Set `minSdkVersion` / `minSdk` to 24 or higher** (required by CameraX and ML Kit):
   ```kotlin
   android {
       defaultConfig {
           minSdk = 24 // or minSdkVersion 24
           compileSdk = 34 // or higher
           ...
       }

       compileOptions {
           sourceCompatibility = JavaVersion.VERSION_17
           targetCompatibility = JavaVersion.VERSION_17
       }

       kotlin {
           compilerOptions {
               jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
           }
       }
   }
   ```

### B. Add JitPack Repository
The native `approval_android` AAR is distributed via JitPack. Ensure JitPack is declared in your repositories.

In `android/settings.gradle` (or `android/settings.gradle.kts`):
```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
        // For local development with publishToMavenLocal():
        // mavenLocal()
    }
}
```

*(If your project uses root `android/build.gradle` without `dependencyResolutionManagement`, add `maven { url 'https://jitpack.io' }` inside `allprojects { repositories { ... } }`).*

### C. Android Permissions
In `android/app/src/main/AndroidManifest.xml`, declare camera and internet access:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Camera & Internet access for biometric liveness verification -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />

    <application
        ... >
        ...
    </application>
</manifest>
```

### D. ProGuard / R8 Rules (Release Builds)
If you enable code shrinking / obfuscation in release builds (`isMinifyEnabled = true`), add the following to `android/app/proguard-rules.pro`:

```proguard
# CreditChek Approval SDK
-keep class com.creditchek.approval_android.** { *; }
-keep interface com.creditchek.approval_android.** { *; }

# Google ML Kit Face Detection
-keep class com.google.mlkit.vision.face.** { *; }

# CameraX
-keep class androidx.camera.** { *; }
```

---

## 🍏 iOS Integration Process

### A. Camera Permission
In `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to verify your identity with live face detection.</string>
```

### B. Minimum Deployment Target
Ensure your `ios/Podfile` targets iOS 15.0+:
```ruby
platform :ios, '15.0'
```

---

## 💻 Flutter Usage Example

> [!IMPORTANT]
> **Prerequisite**: Generate a `sessionId` on your server first by calling CreditChek's Widget Session API (`POST /v1/auth/widget-session/create`). Pass that `sessionId` into `ApprovalConfig`.

```dart
import 'package:flutter/material.dart';
import 'package:approval_flutter/approval_flutter.dart';

Future<void> launchCreditChekVerification(BuildContext context, String backendSessionId) async {
  final config = ApprovalConfig(
    publicKey: 'YOUR_CREDITCHEK_PUBLIC_KEY',
    sessionId: backendSessionId, // Obtained from your backend
    environment: ApprovalEnvironment.sandbox, // or ApprovalEnvironment.production
    modules: const [ApprovalModule.identity, ApprovalModule.liveliness],
    userData: const AUserData(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      bvn: '12345678901', // Optional prefill
      phone: '+2348012345678', // Optional prefill
    ),
  );

  final result = await ApprovalFlutter.start(config: config);

  switch (result) {
    case SessionResultSuccess(:final sessionId, :final message):
      // Identity verification passed! Send sessionId to your backend for confirmation
      print('Verification passed! Session ID: $sessionId, Message: $message');

    case SessionResultCancelled():
      // User closed or cancelled the verification flow
      print('Verification cancelled by user');

    case SessionResultError(:final code, :final message):
      // Verification or network error
      print('Verification failed ($code): $message');
  }
}
```

---

## 🧪 Testing the Example App

```bash
cd example
flutter pub get

# Run on Android Device / Emulator:
flutter run -d android

# Run on iOS Device / Simulator:
flutter run -d ios-simulator
```
