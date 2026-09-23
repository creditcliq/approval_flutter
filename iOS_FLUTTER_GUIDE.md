# iOS Native SDK & Flutter Integration Guide

> Complete, verified guide for building the native **CreditChek Approval iOS SDK** (`approval_ios`), linking it to the **Flutter Plugin** (`approval_flutter`), and running the Flutter example app with a **seamless, one-time setup**.

---

## ⚡ Quick Summary: The One-Time Setup (Already Completed)

Just like on Android where the plugin is linked once and changes can be tested directly, iOS is now configured for **zero-friction live development**:

| Component | Android Approach | iOS Approach (Configured) |
| :--- | :--- | :--- |
| **Native Project** | `approval_android` (outputs AAR/Maven) | `approval_ios` (Swift Package + `approval_ios.podspec`) |
| **Plugin Bridge** | `ApprovalFlutterPlugin.kt` (MethodChannel) | `ApprovalFlutterPlugin.swift` (MethodChannel) |
| **Dependency Link** | `implementation("com.github.creditcliq:approval_android:...")` | `pod 'approval_ios', :path => '../../../approval_ios'` |
| **Daily Iteration** | Code in Kotlin ➔ `flutter run` | Code in Swift ➔ `flutter run -d <device>` |

**Zero re-exporting required:** Any change you make in `approval_ios/Sources` is picked up and compiled automatically on the next `flutter run`.

---

## Table of Contents
1. [Architecture & Project Layout](#1-architecture--project-layout)
2. [What Was Configured (The Foundation)](#2-what-was-configured-the-foundation)
   - [A. Native Podspec & Resource Support (`approval_ios.podspec` & `BundleFinder.swift`)](#a-native-podspec--resource-support)
   - [B. Flutter Plugin Podspec (`approval_flutter.podspec`)](#b-flutter-plugin-podspec)
   - [C. Swift Plugin Bridge (`ApprovalFlutterPlugin.swift`)](#c-swift-plugin-bridge)
   - [D. Example App Podfile Linking](#d-example-app-podfile-linking)
   - [E. Camera Permissions (`Info.plist`)](#e-camera-permissions)
3. [Running & Testing](#3-running--testing)
   - [A. Terminal Commands](#a-terminal-commands)
   - [B. Xcode GUI](#b-xcode-gui)
4. [Workflow 2: Standalone XCFramework (Distribution / Release)](#4-workflow-2-standalone-xcframework-distribution--release)
   - [A. Automated One-Click Script (`build_xcframework.sh`)](#a-automated-one-click-script)
   - [B. Vendored Framework for Zero-Touch Distribution](#b-vendored-framework-for-zero-touch-distribution)
5. [Troubleshooting & Gotchas](#5-troubleshooting--gotchas)

---

## 1. Architecture & Project Layout

```
approval/
├── approval_ios/                     <-- Native iOS SDK (Swift Package + CocoaPod)
│   ├── Package.swift                 <-- SPM definition (iOS 15.0+)
│   ├── approval_ios.podspec          <-- CocoaPods definition for local/remote linking
│   ├── Sources/approval_ios/         <-- Native Swift code (CreditChekApproval, screens, engines)
│   │   └── core/shared/BundleFinder.swift <-- CocoaPods + SPM resource compatibility
│   └── Example/                      <-- Standalone iOS native test app
│
└── approval_flutter/                 <-- Flutter Plugin
    ├── ios/
    │   ├── approval_flutter.podspec  <-- Depends on 'approval_ios'
    │   └── Classes/
    │       └── ApprovalFlutterPlugin.swift <-- MethodChannel bridge
    ├── lib/                          <-- Dart API (CreditChekApproval.startVerification)
    └── example/                      <-- Flutter Host Application
        └── ios/
            ├── Podfile               <-- Links :path => '../../../approval_ios'
            ├── Runner.xcworkspace    <-- Open in Xcode for device signing/debugging
            └── Runner/Info.plist     <-- NSCameraUsageDescription configured
```

---

## 2. What Was Configured (The Foundation)

### A. Native Podspec & Resource Support
Flutter on iOS uses CocoaPods by default. To make `approval_ios` consumable by Flutter without building binaries, we added:

1. **`approval_ios/approval_ios.podspec`**:
   ```ruby
   Pod::Spec.new do |s|
     s.name             = 'approval_ios'
     s.version          = '1.0.0'
     s.summary          = 'CreditChek Approval Native iOS SDK'
     s.homepage         = 'https://creditchek.africa'
     s.license          = { :type => 'MIT' }
     s.author           = { 'CreditChek' => 'dev@creditchek.africa' }
     s.source           = { :path => '.' }
     s.source_files     = 'Sources/approval_ios/**/*.swift'
     s.resources        = ['Sources/approval_ios/Resources/**/*']
     s.platform         = :ios, '15.0'
     s.swift_version    = '5.9'
     s.frameworks       = 'UIKit', 'AVFoundation', 'Vision', 'CoreML', 'Combine', 'SwiftUI'
   end
   ```

2. **`approval_ios/Sources/approval_ios/core/shared/BundleFinder.swift`**:
   Swift Package Manager automatically creates `Bundle.module` for internal assets, but CocoaPods does not. `BundleFinder.swift` provides a polyfill so code accessing `Bundle.module` (such as `WelcomeScreen` and `SplashScreen`) compiles flawlessly in both environments:
   ```swift
   #if !SWIFT_PACKAGE
   extension Bundle {
       static var module: Bundle {
           return Bundle(for: BundleToken.self)
       }
   }
   private final class BundleToken {}
   #endif
   ```

### B. Flutter Plugin Podspec
In `approval_flutter/ios/approval_flutter.podspec`:
```ruby
Pod::Spec.new do |s|
  s.name             = 'approval_flutter'
  s.version          = '0.0.1'
  s.summary          = 'CreditChek Approval Flutter Plugin'
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.vendored_frameworks = 'Frameworks/approval_ios.xcframework'
  s.platform         = :ios, '15.0'
  s.frameworks       = 'UIKit', 'AVFoundation', 'Vision', 'CoreML', 'Combine', 'SwiftUI'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '$(inherited) -framework approval_ios'
  }
  s.swift_version    = '5.9'
end
```

### C. Swift Plugin Bridge
In `approval_flutter/ios/Classes/ApprovalFlutterPlugin.swift`:
```swift
import Flutter
import UIKit
import approval_ios

public class ApprovalFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "approval_flutter", binaryMessenger: registrar.messenger())
    let instance = ApprovalFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startVerification":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Arguments must be a map", details: nil))
        return
      }

      guard let publicKey = args["publicKey"] as? String, !publicKey.isEmpty else {
        result(FlutterError(code: "INVALID_CONFIG", message: "publicKey is required", details: nil))
        return
      }

      let envString = (args["environment"] as? String ?? "SANDBOX").uppercased()
      let environment: ApprovalEnv = (envString == "PRODUCTION") ? .production : .sandbox

      var userData: AUserData? = nil
      if let userDict = args["userData"] as? [String: Any] {
        userData = AUserData(
          firstName: userDict["firstName"] as? String ?? "",
          lastName: userDict["lastName"] as? String ?? "",
          bvn: userDict["bvn"] as? String ?? "",
          email: userDict["email"] as? String ?? "",
          dateOfBirth: (userDict["dob"] as? String) ?? (userDict["dateOfBirth"] as? String),
          phone: userDict["phone"] as? String
        )
      }
      
      // Parse optional session ID generated by backend
      let sessionId = args["sessionId"] as? String ?? ""

      let config = ApprovalConfig(
        publicKey: publicKey,
        modules: [.identity],
        userData: userData,
        sessionId: sessionId,
        environment: environment
      )

      DispatchQueue.main.async {
        CreditChekApproval.start(config: config) { sessionResult in
          switch sessionResult {
          case .success(let sessionId):
            result([
              "status": "success",
              "sessionId": sessionId,
              "message": "Verification completed successfully"
            ])
          case .cancelled:
            result([
              "status": "cancelled"
            ])
          case .error(let code, let message):
            result([
              "status": "error",
              "code": code,
              "message": message
            ])
          }
        }
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
```

### D. Example App Podfile Linking
In `approval_flutter/example/ios/Podfile`:
```ruby
platform :ios, '15.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Direct local path link to native SDK (3 directories up: ios -> example -> approval_flutter -> root)
  pod 'approval_ios', :path => '../../../approval_ios'
end
```

### E. Camera Permissions
In `approval_flutter/example/ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to verify your identity with live face detection.</string>
```

---

## 3. Running & Testing

### A. Terminal Commands

> [!NOTE]
> When using `flutter run`, specify the device with the `-d` flag. (Do **not** run `flutter run ios` as Flutter interprets that as running a file named `ios`).

```bash
cd /Users/marvel/Documents/flutter/approval/approval_flutter/example

# 1. Check connected devices and simulators:
flutter devices

# 2. Run on a connected physical iPhone (required for real camera testing):
flutter run -d <device-id>

# 3. Or run on an iOS Simulator:
flutter run -d "iPhone 16"
# (or simply: flutter run -d ios-simulator)

# 4. To build release binaries:
flutter build ios --no-codesign --simulator # For Simulator
flutter build ios                          # For Physical iPhone (automatically signed)
```

### B. Xcode GUI
If you prefer running and debugging from Xcode:
1. Open `/Users/marvel/Documents/flutter/approval/approval_flutter/example/ios/Runner.xcworkspace`.
2. Select your physical iPhone or Simulator from the top destination dropdown.
3. Click the **Run** button (or press `Cmd + R`).
4. Set breakpoints in Swift (`ApprovalFlutterPlugin.swift` or `approval_ios` files) as needed!

---

## 4. Workflow 2: Standalone XCFramework (Distribution / Release)

If you want to distribute `approval_flutter` to external developers so they don't need the local `approval_ios` source directory:

### A. Automated One-Click Script (`build_xcframework.sh`)
Run this in `approval_ios`:
```bash
cd /Users/marvel/Documents/flutter/approval/approval_ios
chmod +x build_xcframework.sh
./build_xcframework.sh
```
This builds a universal binary (`approval_ios.xcframework`) supporting both physical iOS devices (`arm64`) and Simulators (`arm64` + `x86_64`).

### B. Vendored Framework for Zero-Touch Distribution
1. Copy the `.xcframework` to the plugin:
   ```bash
   mkdir -p /Users/marvel/Documents/flutter/approval/approval_flutter/ios/Frameworks
   cp -R /Users/marvel/Documents/flutter/approval/approval_ios/build/approval_ios.xcframework \
         /Users/marvel/Documents/flutter/approval/approval_flutter/ios/Frameworks/
   ```
2. In `approval_flutter/ios/approval_flutter.podspec`, uncomment:
   ```ruby
   s.vendored_frameworks = 'Frameworks/approval_ios.xcframework'
   ```
   and remove `s.dependency 'approval_ios'`.
3. In client apps, developers only need to add `approval_flutter` to their `pubspec.yaml` — zero Podfile configuration needed.

---

## 5. Troubleshooting & Gotchas

### 1. `Target file "ios" not found`
- **Cause:** Running `flutter run ios`.
- **Fix:** Use `flutter run -d ios` or `flutter run -d <device_name>`.

### 2. Simulator vs Physical Device Camera
- **Symptom:** Camera feed is blank or black on Simulator.
- **Cause:** iOS Simulators have no real camera sensor.
- **Fix:** Always test liveness sessions on a real physical iPhone.

### 3. CocoaPods Cache Issues
If you ever switch between local path and xcframework:
```bash
cd /Users/marvel/Documents/flutter/approval/approval_flutter/example/ios
rm -rf Pods Podfile.lock
pod install --repo-update
```
