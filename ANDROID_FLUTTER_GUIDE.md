# Android Native AAR & Flutter Integration Guide

> Comprehensive guide for building the native **CreditChek Approval Android SDK** (`approval_android`), releasing it via **GitHub Git tags & JitPack**, linking it to the **Flutter Plugin** (`approval_flutter`), and continuously testing in the Flutter example app.

---

## Table of Contents
1. [Architecture & Project Layout](#1-architecture--project-layout)
2. [Dynamic Backend-Driven Orchestration & Setup](#2-dynamic-backend-driven-orchestration--setup)
3. [Understanding AAR & Transitive Dependencies](#3-understanding-aar--transitive-dependencies)
4. [GitHub & JitPack Release Workflow](#4-github--jitpack-release-workflow)
   - [A. Version Bumping in build.gradle.kts](#a-version-bumping-in-buildgradlekts)
   - [B. Testing & Local Verification](#b-testing--local-verification)
   - [C. Tagging & Pushing Release](#c-tagging--pushing-release)
   - [D. JitPack Verification](#d-jitpack-verification)
5. [Connecting Android Native SDK to Flutter Plugin](#5-connecting-android-native-sdk-to-flutter-plugin)
   - [A. Gradle Dependency](#a-gradle-dependency)
   - [B. MethodChannel Bridge (ApprovalFlutterPlugin.kt)](#b-methodchannel-bridge-approvalflutterpluginkt)
   - [C. Dart API (ApprovalConfig & ApprovalFlutter)](#c-dart-api-approvalconfig--approvalflutter)
6. [Step-by-Step Continuous Testing Cycle](#6-step-by-step-continuous-testing-cycle)
7. [Hot Reload vs. Native Recompilation](#7-hot-reload-vs-native-recompilation)
8. [Troubleshooting & Common Pitfalls](#8-troubleshooting--common-pitfalls)

---

## 1. Architecture & Project Layout

The repository contains distinct layers that communicate through Gradle and Flutter Platform Channels:

```
approval/
├── approval_android/             <-- Native Android Library Project (GitHub & JitPack)
│   ├── approval_android/         <-- Core SDK module (:approval_android) -> outputs AAR via JitPack
│   │   ├── src/main/kotlin/      <-- Jetpack Compose, CameraX, ML Kit Face Detection, Navigators
│   │   └── build.gradle.kts      <-- maven-publish & JitPack publication config
│   └── app/                      <-- Native Android sample app for testing
│
└── approval_flutter/             <-- Flutter Plugin Project
    ├── android/                  <-- Flutter Android bridge (:approval_flutter)
    │   ├── src/main/kotlin/.../ApprovalFlutterPlugin.kt  <-- MethodChannel implementation
    │   └── build.gradle.kts      <-- Depends on com.github.creditcliq:approval_android (JitPack)
    ├── lib/                      <-- Dart Plugin API (ApprovalConfig, AUserData, SessionResult)
    └── example/                  <-- Flutter Host Application for end-to-end testing
        ├── android/              <-- Host Android App (loads Flutter + Plugins)
        └── lib/main.dart         <-- UI test harness
```

---

## 2. Dynamic Backend-Driven Orchestration & Setup

Starting with the latest architectural update:
- **`ApprovalConfig`**:
  Takes `publicKey`, `sessionId`, and **`widgetId`** (required), with optional `userData`.
  Host applications **no longer supply `modules` or `environment`**.
- **Dynamic Config API**:
  The SDK queries `GET /auth/sdk-setup/{widgetId}` to fetch the environment (`development` / `production`), module sequence (`order`), primary theme color (`color`), custom brand logo (`logo`), and business display name.
- **Universal Splash Screen**:
  A single pulsing splash screen at the coordinator level performs validation, queries current session status, skips already-completed steps (e.g. BVN, NIN, Liveness), and pre-fetches completed identity data.

---

## 3. Understanding AAR & Transitive Dependencies

> [!IMPORTANT]
> **Why JitPack / Maven Publishing is Critical:**
> A raw `.aar` file only bundles compiled classes and resources of the *immediate* module. It does **NOT** bundle third-party libraries that the SDK depends on (such as CameraX, Google ML Kit Face Detection, Retrofit, and Jetpack Compose).
> 
> - By publishing to **GitHub + JitPack**, JitPack automatically runs the `maven-publish` Gradle task to produce a complete `.aar` and corresponding `pom.xml`.
> - The POM file tells Gradle in the Flutter plugin and host app exactly which dependencies to download automatically.

---

## 4. GitHub & JitPack Release Workflow

### A. Version Bumping in `build.gradle.kts`
In `approval_android/approval_android/build.gradle.kts`, increment the release version number (e.g. `1.0.6`):

```kotlin
afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                from(components["release"])
                groupId = "com.github.creditcliq"
                artifactId = "approval_android"
                version = "1.0.6" // Increment version here
            }
        }
    }
}
```

### B. Testing & Local Verification
Verify unit tests and release assembly locally before tagging:
```bash
cd /Users/marvel/Documents/flutter/approval/approval_android

# Run unit tests
./gradlew test

# Assemble release AAR
./gradlew :approval_android:assembleRelease
```

### C. Tagging & Pushing Release
Commit changes, push to GitHub, and create a matching Git tag:
```bash
cd /Users/marvel/Documents/flutter/approval/approval_android

git add .
git commit -m "chore(release): bump version to 1.0.6"
git push origin main

git tag 1.0.6
git push origin 1.0.6
```

### D. JitPack Verification
1. Open **[https://jitpack.io/#creditcliq/approval_android](https://jitpack.io/#creditcliq/approval_android)**.
2. Locate the new tag (e.g. `1.0.6`).
3. Click **Get it** to trigger the build.
4. When the log icon turns green, the release is live and downloadable by Gradle worldwide.

---

## 5. Connecting Android Native SDK to Flutter Plugin

### A. Gradle Dependency
In `approval_flutter/android/build.gradle.kts`:
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

dependencies {
    implementation("com.github.creditcliq:approval_android:1.0.6")
}
```

### B. MethodChannel Bridge (`ApprovalFlutterPlugin.kt`)
`ApprovalFlutterPlugin.kt` receives `publicKey`, `sessionId`, `widgetId`, and optional `userData` from Dart:

```kotlin
val publicKey = call.argument<String>("publicKey") ?: ""
val sessionId = call.argument<String>("sessionId") ?: ""
val widgetId = call.argument<String>("widgetId") ?: ""

val config = ApprovalConfig(
    publicKey = publicKey,
    userData = userData,
    sessionId = sessionId,
    widgetId = widgetId
)

CreditChekApproval.start(
    context = currentActivity,
    config = config
) { sessionResult ->
    when (sessionResult) {
        is SessionResult.Success -> result.success(mapOf("status" to "success", "sessionId" to sessionResult.sessionId))
        is SessionResult.Cancelled -> result.success(mapOf("status" to "cancelled"))
        is SessionResult.Error -> result.success(mapOf("status" to "error", "code" to sessionResult.code, "message" to sessionResult.message))
    }
}
```

### C. Dart API (`ApprovalConfig` & `ApprovalFlutter`)
```dart
final config = ApprovalConfig(
  publicKey: 'YOUR_PUBLIC_KEY',
  sessionId: backendSessionId,
  widgetId: 'YOUR_WIDGET_ID',
  userData: const AUserData(
    firstName: 'John',
    lastName: 'Doe',
    bvn: '12345678901',
    nin: '12345678901',
  ),
);

final result = await ApprovalFlutter.start(config: config);
```

---

## 6. Step-by-Step Continuous Testing Cycle

```
┌───────────────────────────────────────────────────────────┐
│ 1. Make Changes in approval_android                       │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│ 2. Assemble Release & Tag: git tag 1.0.x && git push      │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│ 3. Update approval_flutter dependency to 1.0.x            │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│ 4. Run Flutter Example: cd example && flutter run         │
└───────────────────────────────────────────────────────────┘
```

---

## 7. Hot Reload vs. Native Recompilation

| Change Type | Hot Reload (`r`) | Hot Restart (`R`) | Full Recompile (`flutter run`) |
| :--- | :---: | :---: | :---: |
| Dart UI / State changes in `example/lib` | ✅ Yes | ✅ Yes | Not needed |
| Dart changes in `approval_flutter/lib` | ✅ Yes | ✅ Yes | Not needed |
| Kotlin changes in `ApprovalFlutterPlugin.kt` | ❌ No | ❌ No | ✅ Required |
| Changes in native `approval_android` (AAR) | ❌ No | ❌ No | ✅ Required |
| Changes to `AndroidManifest.xml` (Permissions) | ❌ No | ❌ No | ✅ Required |

---

## 8. Troubleshooting & Common Pitfalls

### 1. `Could not find com.github.creditcliq:approval_android:1.0.6`
- **Cause:** JitPack has not finished building the tag yet, or the tag was not pushed.
- **Fix:** Check `https://jitpack.io/#creditcliq/approval_android/1.0.6` and wait for the green build badge.

### 2. Gradle is using an old cached AAR
- **Cause:** Gradle caches resolved artifacts locally.
- **Fix:** Run with `--refresh-dependencies`:
  ```bash
  cd approval_flutter/example/android
  ./gradlew app:assembleDebug --refresh-dependencies
  ```

### 3. Camera Permission Denied on Android
- Ensure the host app (`AndroidManifest.xml`) declares:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-feature android:name="android.hardware.camera" android:required="false" />
  ```
