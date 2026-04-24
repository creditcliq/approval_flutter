# CreditChek Approval Flutter SDK

Embed the CreditChek Approval Widget inside your Flutter app to collect and
verify customer data (income, credit, Recova, identity) through a secure web
experience that runs inside a native `WebView`.

## Features

- Launches the hosted Approval Widget via `ApprovalFlutter.verify`.
- Configurable modules (`income`, `credit`, `recova`, `identity`) to customize verification flows.
- Callbacks for `onSuccess` (returns session ID) and `onError` events.
- Support for pre-filling customer data (BVN, email, phone, etc.) to reduce friction.
- Integrated success and failure dialogs for a cohesive user experience.

## Installation

Until this package is published to pub.dev point directly at the repo:

```yaml
dependencies:
  approval_flutter:
    git:
      url: https://github.com/creditcliq/approval_flutter.git
```

Run `flutter pub get` after updating `pubspec.yaml`.

## Usage

```dart
import 'package:approval_flutter/approval_flutter.dart';

Future<void> startApprovalFlow(BuildContext context) async {
  final config = ApprovalConfig(
    publicKey: 'pk_live_your_key',
    userData: AUserData(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
    ),
    modules: const [
      ApprovalModule.income,
      ApprovalModule.credit,
      ApprovalModule.recova,
      ApprovalModule.identity,
    ],
    onSuccess: (response) {
      debugPrint('Verification success: $response');
    },
    onError: (message) => debugPrint('Approval error: $message'),
  );

  await ApprovalFlutter.verify(context: context, config: config);
}
```

### Configuration options

- `publicKey` (required): Provided by CreditChek.
- `userData`: Optional user details to prefill the widget (e.g., `firstName`, `lastName`, `email`).
- `modules`: Sequence of `ApprovalModule` values to display (defaults to all).
- `onSuccess(String response)`: Fired when the widget returns a successful response.
- `onError(String message)`: Called when the widget reports an error.

## Setup

To use the camera for the identity verification module, you must configure platform-specific settings for both Android and iOS inside your Flutter app's Native folders.

### Android

1.  **AndroidManifest.xml**: Open `android/app/src/main/AndroidManifest.xml` and add the required permissions inside the `<manifest>` tag, above `<application>`:

    ```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <!-- Optional: Add these if video recording requires audio functionality -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.VIDEO_CAPTURE" />
    <uses-permission android:name="android.permission.AUDIO_CAPTURE" />
    ```

2.  **MainActivity.kt**: Open `android/app/src/main/kotlin/.../MainActivity.kt`. Ensure your app's main activity extends `FlutterFragmentActivity` and requests the required permissions at runtime. Replace the contents appropriately:

    ```kotlin
    import android.Manifest
    import android.content.pm.PackageManager
    import android.os.Bundle
    import androidx.core.app.ActivityCompat
    import androidx.core.content.ContextCompat
    import io.flutter.embedding.android.FlutterFragmentActivity

    class MainActivity: FlutterFragmentActivity() {
        private val PERMISSION_REQUEST_CODE = 100

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)

            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {

                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO),
                    PERMISSION_REQUEST_CODE
                )
            }
        }
    }
    ```

### iOS

1.  **Info.plist Permissions**: Open `ios/Runner/Info.plist` and add the mandatory camera usage descriptions inside the main `<dict>` tag:

    ```xml
    <key>NSCameraUsageDescription</key>
    <string>This app requires access to the camera to verify your identity.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>This app requires access to the microphone for video recording during identity verification.</string>
    ```

2.  **Podfile**: Open `ios/Podfile`. Ensure the iOS deployment target is defined. Find the `platform :ios` line, uncomment it (if it's commented out), and ensure it's set to an appropriate minimum version (e.g., `'13.0'`):

    ```ruby
    platform :ios, '13.0' # Uncomment and set version
    ```

## Example project

See `examples/` for a runnable Flutter app that showcases the integration. From
the repo root run:

```bash
cd examples
flutter pub get
flutter run
```

## Support

Please file GitHub issues or reach out to support@creditchek.africa with your
public key, environment, and reproduction steps so we can help quickly.

## License

Distributed under the BSD 3-Clause License. See `LICENSE` for more information.
