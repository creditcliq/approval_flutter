# iOS Native SDK & Flutter Integration Guide

> Complete guide for building the native **CreditChek Approval iOS SDK** (`approval_ios`), linking it to the **Flutter Plugin** (`approval_flutter`), and running the Flutter example app with dynamic backend-driven orchestration.

---

## ⚡ Architecture & Dynamic Orchestration

The iOS SDK architecture aligns 1:1 with Android:

| Feature | Android (Jetpack Compose) | iOS (Swift / SwiftUI) |
| :--- | :--- | :--- |
| **Public Config** | `ApprovalConfig(publicKey, sessionId, widgetId, userData)` | `ApprovalConfig(publicKey, sessionId, widgetId, userData)` |
| **Dynamic Setup API** | `GET auth/sdk-setup/{widgetId}` | `GET auth/sdk-setup/{widgetId}` |
| **Orchestrator** | `ApprovalFlowCoordinator` Composable | `ApprovalFlowCoordinator` View |
| **Universal Splash** | `SplashScreen` Composable | `SplashScreen` View |
| **Session Context** | `SharedSessionContext` Data Class | `SharedSessionContext` Struct |
| **Dynamic Theme** | `LocalApprovalThemeConfig` | `@Environment(\.approvalTheme)` |
| **Brand Logo** | `BrandLogo` (Coil + Base64) | `BrandLogo` (AsyncImage + Base64 UIImage) |

---

## Table of Contents
1. [Architecture & Project Layout](#1-architecture--project-layout)
2. [What Was Configured](#2-what-was-configured)
   - [A. Native Podspec & Resources](#a-native-podspec--resources)
   - [B. Flutter Plugin Podspec (`approval_flutter.podspec`)](#b-flutter-plugin-podspec)
   - [C. Swift Plugin Bridge (`ApprovalFlutterPlugin.swift`)](#c-swift-plugin-bridge)
   - [D. Camera Permissions (`Info.plist`)](#d-camera-permissions)
3. [Universal XCFramework Build Script](#3-universal-xcframework-build-script)
4. [Running & Testing](#4-running--testing)
5. [Troubleshooting & Gotchas](#5-troubleshooting--gotchas)

---

## 1. Architecture & Project Layout

```
approval/
├── approval_ios/                     <-- Native iOS SDK (Swift Package + CocoaPod)
│   ├── Package.swift                 <-- SPM definition (iOS 15.0+)
│   ├── approval_ios.podspec          <-- CocoaPods definition for local/remote linking
│   ├── Sources/approval_ios/         <-- Native Swift code (ApprovalFlowCoordinator, screens, engines)
│   └── Example/                      <-- Standalone iOS native test app
│
└── approval_flutter/                 <-- Flutter Plugin
    ├── ios/
    │   ├── Frameworks/
    │   │   └── approval_ios.xcframework <-- Universal XCFramework binary
    │   ├── approval_flutter.podspec  <-- Podspec declaring vendored framework
    │   └── Classes/
    │       └── ApprovalFlutterPlugin.swift <-- MethodChannel bridge
    ├── lib/                          <-- Dart API (ApprovalConfig, AUserData, SessionResult)
    └── example/                      <-- Flutter Host Application
        └── ios/
            ├── Podfile               <-- Host Podfile
            └── Runner.xcworkspace    <-- Open in Xcode for device signing/debugging
```

---

## 2. What Was Configured

### A. Native Podspec & Resources
The native SDK includes `approval_ios.podspec` and `BundleFinder.swift` ensuring resources (such as `accessory_classifier.mlmodelc` and icons) load reliably across CocoaPods, Swift Package Manager, and XCFramework installations.

### B. Flutter Plugin Podspec (`approval_flutter.podspec`)
```ruby
Pod::Spec.new do |s|
  s.name             = 'approval_flutter'
  s.version          = '1.0.1'
  s.summary          = 'CreditChek Approval Flutter Plugin'
  s.homepage         = 'https://creditchek.africa'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CreditChek' => 'support@creditchek.africa' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '15.0'

  # Vendored XCFramework
  s.vendored_frameworks = 'Frameworks/approval_ios.xcframework'
  s.swift_version    = '5.9'
end
```

### C. Swift Plugin Bridge (`ApprovalFlutterPlugin.swift`)
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

      guard let publicKey = args["publicKey"] as? String,
            !publicKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        result(FlutterError(code: "INVALID_CONFIG", message: "publicKey is required", details: nil))
        return
      }

      guard let sessionId = args["sessionId"] as? String,
            !sessionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        result(FlutterError(code: "INVALID_CONFIG", message: "sessionId is required", details: nil))
        return
      }

      guard let widgetId = args["widgetId"] as? String,
            !widgetId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        result(FlutterError(code: "INVALID_CONFIG", message: "widgetId is required", details: nil))
        return
      }

      var userData: AUserData? = nil
      if let userDict = args["userData"] as? [String: Any] {
        let firstName = (userDict["firstName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = (userDict["lastName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bvn = (userDict["bvn"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nin = (userDict["nin"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = (userDict["email"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let dob = ((userDict["dob"] as? String) ?? (userDict["dateOfBirth"] as? String))?.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = (userDict["phone"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)

        let hasData = !firstName.isEmpty || !lastName.isEmpty || !bvn.isEmpty || !nin.isEmpty ||
          !email.isEmpty || !(dob?.isEmpty ?? true) || !(phone?.isEmpty ?? true)

        if hasData {
          userData = AUserData(
            firstName: firstName,
            lastName: lastName,
            bvn: bvn,
            nin: nin,
            email: email,
            dateOfBirth: dob,
            phone: phone
          )
        }
      }

      let config = ApprovalConfig(
        publicKey: publicKey.trimmingCharacters(in: .whitespacesAndNewlines),
        sessionId: sessionId.trimmingCharacters(in: .whitespacesAndNewlines),
        widgetId: widgetId.trimmingCharacters(in: .whitespacesAndNewlines),
        userData: userData
      )

      DispatchQueue.main.async {
        CreditChekApproval.start(config: config) { sessionResult in
          switch sessionResult {
          case .success(let sessionId, let message):
            result([
              "status": "success",
              "sessionId": sessionId,
              "message": message
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

### D. Camera Permissions (`Info.plist`)
In `approval_flutter/example/ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to verify your identity with live face detection.</string>
```

---

## 3. Universal XCFramework Build Script

When you make changes to `approval_ios`, rebuild the XCFramework using the automated script:

```bash
cd /Users/marvel/Documents/flutter/approval/approval_ios
./build_xcframework.sh
```

This compiles both Device (`arm64`) and Simulator (`arm64`/`x86_64`) slices, embeds resource bundles, and automatically copies the updated `approval_ios.xcframework` to:
- `approval_flutter/ios/Frameworks/approval_ios.xcframework`
- `approval_react_native/ios/Frameworks/approval_ios.xcframework`

---

## 4. Running & Testing

```bash
cd /Users/marvel/Documents/flutter/approval/approval_flutter/example

flutter clean
flutter pub get

# Run on iOS Simulator
flutter run -d ios-simulator

# Run on Physical iOS Device
flutter run -d <device_id>
```

---

## 5. Troubleshooting & Gotchas

### 1. `Camera permission denied`
- The camera is required for live face detection. Make sure `NSCameraUsageDescription` is present in `Runner/Info.plist`.

### 2. `Invalid Configuration (widgetId required)`
- Ensure `widgetId` is provided in `ApprovalConfig`. The SDK queries `GET /auth/sdk-setup/{widgetId}` to fetch the layout, environment, and theme color.
