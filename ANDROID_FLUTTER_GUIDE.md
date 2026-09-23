# Android Native AAR & Flutter Integration Guide

> Comprehensive guide for building the native **CreditChek Approval Android SDK** (`approval_android`), packaging it as an **AAR** / **Maven artifact**, linking it to the **Flutter Plugin** (`approval_flutter`), and continuously testing new features in the Flutter example app using both **Android Studio** and the **Terminal**.

---

## Table of Contents
1. [Architecture & Project Layout](#1-architecture--project-layout)
2. [Understanding AAR & Transitive Dependencies](#2-understanding-aar--transitive-dependencies)
3. [Workflow 1: GitHub & JitPack Distribution (Recommended & Deployed)](#3-workflow-1-github--jitpack-distribution-recommended--deployed)
   - [A. Publishing a Release via Git Tag](#a-publishing-a-release-via-git-tag)
   - [B. Verifying Build on JitPack](#b-verifying-build-on-jitpack)
   - [C. Consuming in Flutter Plugin](#c-consuming-in-flutter-plugin)
4. [Workflow 2: Local Maven (`publishToMavenLocal`) for Fast Local Development](#4-workflow-2-local-maven-publishtomavenlocal-for-fast-local-development)
5. [Workflow 3: Composite Build (`includeBuild`) — Instant Live Iteration](#5-workflow-3-composite-build-includebuild--instant-live-iteration)
6. [Step-by-Step Continuous Testing Cycle](#6-step-by-step-continuous-testing-cycle)
7. [Hot Reload vs. Native Recompilation](#7-hot-reload-vs-native-recompilation)
8. [Troubleshooting & Common Pitfalls](#8-troubleshooting--common-pitfalls)

---

## 1. Architecture & Project Layout

The repository contains distinct layers that communicate through Gradle and Flutter Platform Channels:

```
approval/
├── approval_android/             <-- Native Android Library Project (deployed to GitHub & JitPack)
│   ├── approval_android/         <-- Core SDK module (:approval_android) -> outputs AAR via JitPack
│   │   ├── src/main/kotlin/      <-- Jetpack Compose, CameraX, ML Kit Face Detection
│   │   └── build.gradle.kts      <-- maven-publish & JitPack config
│   └── app/                      <-- Native Android sample app for testing
│
└── approval_flutter/             <-- Flutter Plugin Project
    ├── android/                  <-- Flutter Android bridge (:approval_flutter)
    │   ├── src/main/kotlin/.../ApprovalFlutterPlugin.kt  <-- MethodChannel implementation
    │   └── build.gradle.kts      <-- Depends on com.github.creditcliq:approval_android (JitPack)
    ├── lib/                      <-- Dart Plugin API
    └── example/                  <-- Flutter Host Application for end-to-end testing
        ├── android/              <-- Host Android App (loads Flutter + Plugins)
        └── lib/main.dart         <-- UI test harness
```

---

## 2. Understanding AAR & Transitive Dependencies

> [!IMPORTANT]
> **Why JitPack / Maven Publishing is Critical:**
> A raw `.aar` file only bundles compiled classes and resources of the *immediate* module. It does **NOT** bundle third-party libraries that the SDK depends on (such as CameraX, Google ML Kit Face Detection, Retrofit, and Jetpack Compose).
> 
> - By publishing to **GitHub + JitPack**, JitPack automatically runs the `maven-publish` Gradle task to produce a complete `.aar` and corresponding `pom.xml`.
> - The POM file tells Gradle in the Flutter plugin and host app exactly which dependencies to download automatically.

---

## 3. Workflow 1: GitHub & JitPack Distribution (Recommended & Deployed)

The native SDK is actively deployed to GitHub at `https://github.com/creditcliq/approval_android` and served via JitPack.

### A. Publishing a Release via Git Tag

1. In `approval_android/approval_android/build.gradle.kts`, ensure the publication version is updated:
```kotlin
publishing {
    publications {
        create<MavenPublication>("release") {
            from(components["release"])
            groupId = "com.github.creditcliq"
            artifactId = "approval_android"
            version = "1.0.0+1" // Set your release version / tag
        }
    }
}
```

2. Commit and push your changes to GitHub:
```bash
cd /Users/marvel/Documents/flutter/approval/approval_android
git add .
git commit -m "feat: release 1.0.0+1 with backend session support"
git push origin main
```

3. Tag the commit and push the tag:
```bash
git tag 1.0.0+1
git push origin 1.0.0+1
```

### B. Verifying Build on JitPack

1. Open **[https://jitpack.io/#creditcliq/approval_android](https://jitpack.io/#creditcliq/approval_android)**.
2. Look for tag `1.0.0+1`.
3. If the status icon is green (Log/Report), the AAR and POM were built successfully and are ready for download.

### C. Consuming in Flutter Plugin

In `approval_flutter/android/build.gradle.kts`:

1. Ensure `https://jitpack.io` is listed under repositories:
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}
```

2. Reference the published JitPack coordinates:
```kotlin
dependencies {
    // CreditChek Approval Android Native SDK from GitHub via JitPack
    implementation("com.github.creditcliq:approval_android:1.0.0+1")

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}
```

---

## 4. Workflow 2: Local Maven (`publishToMavenLocal`) for Fast Local Development

When iterating locally without wanting to push git tags on every tweak, you can publish to your machine's local Maven cache (`~/.m2/repository`).

### A. Using Terminal (CLI)
From the root of `approval_android`:
```bash
cd /Users/marvel/Documents/flutter/approval/approval_android
./gradlew :approval_android:publishToMavenLocal
```

### B. Consuming Locally in Flutter Plugin
Temporarily add `mavenLocal()` at the top of repositories in `approval_flutter/android/build.gradle.kts`:
```kotlin
repositories {
    mavenLocal() // <--- Check local machine first
    google()
    mavenCentral()
    maven { url = uri("https://jitpack.io") }
}
```
        }
    }
}
```
In `approval_flutter/android/build.gradle.kts`:
```kotlin
implementation("com.github.creditcliq:approval_android:1.0.1-SNAPSHOT")
```
Gradle automatically checks for updated snapshots.

#### Strategy 2: Force Gradle cache refresh from terminal
Whenever you re-publish:
```bash
# 1. Re-publish the native library
cd /Users/marvel/Documents/flutter/approval/approval_android
./gradlew :approval_android:publishToMavenLocal

# 2. In the Flutter example app, refresh dependencies and run
cd /Users/marvel/Documents/flutter/approval/approval_flutter/example
flutter clean
flutter pub get
flutter run -d <device_or_emulator_id>
```

---

## 4. Workflow 2: Direct AAR Binary Drop (`libs/approval_android.aar`)

If you specifically need a standalone `.aar` file without using local Maven:

### A. Build AAR via Studio or Terminal

#### Via Android Studio:
1. Open `approval_android` in Android Studio.
2. In the **Build Variants** panel (bottom-left), ensure the variant for `:approval_android` is set to **release**.
3. From the menu bar, select: **Build** ➔ **Make Project** or run Gradle task `:approval_android:assembleRelease`.

#### Via Terminal:
```bash
cd /Users/marvel/Documents/flutter/approval/approval_android
./gradlew :approval_android:assembleRelease
```

The generated AAR file will be located at:
```
approval_android/approval_android/build/outputs/aar/approval_android-release.aar
```

### B. Copy to Flutter Plugin & Configure Gradle

1. Create a `libs` directory inside `approval_flutter/android/`:
```bash
mkdir -p /Users/marvel/Documents/flutter/approval/approval_flutter/android/libs
cp /Users/marvel/Documents/flutter/approval/approval_android/approval_android/build/outputs/aar/approval_android-release.aar \
   /Users/marvel/Documents/flutter/approval/approval_flutter/android/libs/approval_android.aar
```

2. Update `approval_flutter/android/build.gradle.kts`:
```kotlin
repositories {
    google()
    mavenCentral()
    flatDir {
        dirs("libs")
    }
}

dependencies {
    // Direct file reference:
    implementation(files("libs/approval_android.aar"))
    // or:
    // implementation(name = "approval_android", ext = "aar")
}
```

### C. Handling Transitive Dependencies

Because the raw `.aar` does not bring its dependencies with it, you must add the native library's dependencies inside `approval_flutter/android/build.gradle.kts`:

```kotlin
dependencies {
    implementation(files("libs/approval_android.aar"))

    // CameraX
    val cameraxVersion = "1.3.4"
    implementation("androidx.camera:camera-core:$cameraxVersion")
    implementation("androidx.camera:camera-camera2:$cameraxVersion")
    implementation("androidx.camera:camera-lifecycle:$cameraxVersion")
    implementation("androidx.camera:camera-view:$cameraxVersion")

    // ML Kit Face Detection
    implementation("com.google.mlkit:face-detection:16.1.7")

    // Retrofit & Coroutines
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

    // Jetpack Compose
    implementation(platform("androidx.compose:compose-bom:2024.09.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.activity:activity-compose:1.9.2")
}
```

---

## 5. Workflow 3: Composite Build (`includeBuild`) — Instant Live Iteration

For the ultimate development speed without building AAR files on every change, you can link the native Android project directly into the Flutter example app using Gradle composite builds:

In `/Users/marvel/Documents/flutter/approval/approval_flutter/example/android/settings.gradle.kts`:

```kotlin
pluginManagement {
    // ...
}

include(":app")

// Directly include the native Android project:
includeBuild("../../../approval_android") {
    dependencySubstitution {
        substitute(module("com.github.creditcliq:approval_android"))
            .using(project(":approval_android"))
    }
}
```

Now, every change you make to Kotlin files in `approval_android` is immediately compiled when running `flutter run` in `approval_flutter/example`!

---

## 6. Step-by-Step Continuous Testing Cycle

Here is the recommended day-to-day workflow when implementing new features:

```
┌───────────────────────────────────────────────────────────┐
│ 1. Implement Feature in approval_android (Android Studio) │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│ 2. Test locally in native app (app module or Unit tests)  │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│ 3. Run: ./gradlew :approval_android:publishToMavenLocal   │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│ 4. Update ApprovalFlutterPlugin.kt (MethodChannel bridge) │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│ 5. Update Flutter Dart API & models (approval_flutter)    │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│ 6. Run Flutter Example: cd example && flutter run         │
└───────────────────────────────────────────────────────────┘
```

### Command Cheat Sheet

```bash
# Terminal Tab 1: Build & Publish Native Android SDK
cd /Users/marvel/Documents/flutter/approval/approval_android
./gradlew :approval_android:test
./gradlew :approval_android:publishToMavenLocal

# Terminal Tab 2: Test in Flutter Example App
cd /Users/marvel/Documents/flutter/approval/approval_flutter/example

# Clean Flutter cache if you made major native changes:
flutter clean
flutter pub get

# Check connected Android devices/emulators:
flutter devices

# Run on your Android device/emulator:
flutter run -d <device_id>
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

> [!TIP]
> Whenever you update native code or re-publish an AAR, stop the running Flutter session (`q` in terminal), re-publish the AAR, and run `flutter run` again.

---

## 8. Troubleshooting & Common Pitfalls

### 1. `Could not find com.github.creditcliq:approval_android`
- **Cause:** Gradle cannot find your locally published artifact.
- **Fix:** 
  1. Verify the file exists in `~/.m2/repository/com/github/creditcliq/approval_android/`.
  2. Verify `mavenLocal()` is added to `repositories` in `approval_flutter/android/build.gradle.kts`.

### 2. Gradle is using an old cached AAR
- **Cause:** Gradle caches release artifacts unless instructed otherwise.
- **Fix:**
  - Run with `--refresh-dependencies`:
    ```bash
    cd approval_flutter/example/android
    ./gradlew app:assembleDebug --refresh-dependencies
    ```
  - Or switch to a new version (e.g., bump to `1.0.1-SNAPSHOT`).

### 3. `ClassNotFoundException: com.creditchek.approval_android.CreditChekApproval`
- **Cause:** Using direct AAR drop without declaring transitive dependencies.
- **Fix:** Follow Workflow 1 (`publishToMavenLocal`) or add the missing runtime dependencies manually to `approval_flutter/android/build.gradle.kts`.

### 4. Camera Permission Denied on Android
- Ensure the host app (`approval_flutter/example/android/app/src/main/AndroidManifest.xml`) declares:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-feature android:name="android.hardware.camera" android:required="false" />
  ```

### 5. Java / Kotlin Version Incompatibility
- `approval_android` compiles with **Java 11 / Java 17** and **Kotlin 2.0+**.
- Ensure your Android Studio JDK is configured to **JDK 17** (Settings ➔ Build, Execution, Deployment ➔ Build Tools ➔ Gradle ➔ Gradle JDK).
