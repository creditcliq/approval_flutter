# CreditChek Approval Flutter SDK

Embed the CreditChek Approval Widget inside your Flutter app to collect and
verify customer data (income, credit, Recova, identity) through a secure web
experience that runs inside a native `WebView`.

## Features

- Launches the hosted Approval Widget via `ApprovalFlutter.verify`.
- Configurable modules so you can enable specific verification flows.
- Flexible callbacks for success, error, timeout, and close events.
- Minimal UI: renders a Material `AppBar`, progress indicator, and the widget.

## Installation

Until this package is published to pub.dev point directly at the repo:

```yaml
dependencies:
  approval_flutter: <version>
```

Run `flutter pub get` after updating `pubspec.yaml`.

## Usage

```dart
import 'package:approval_flutter/approval_flutter.dart';

Future<void> startApprovalFlow(BuildContext context) async {
  final config = ApprovalConfig(
    publicKey: 'pk_live_your_key',
    modules: const [
      ApprovalModule.income,
      ApprovalModule.credit,
      ApprovalModule.recova,
      ApprovalModule.identity,
    ],
    incomeForm: 'FORM_ID',
    onSuccess: (payload) {
      final sessionId = payload['sessionId'];
      debugPrint('Verification success: $sessionId');
    },
    onError: (message) => debugPrint('Approval error: $message'),
    onTimeout: () => debugPrint('Approval timed out'),
    onClose: () => debugPrint('Approval widget closed'),
  );

  await ApprovalFlutter.verify(context: context, config: config);
}
```

### Configuration options

- `publicKey` (required): Provided by CreditChek.
- `modules`: Sequence of `ApprovalModule` values to display (defaults to all).
- `incomeForm`: Optional form identifier for income workflows.
- `onSuccess(Map data)`: Fired when the widget returns a successful response.
- `onError(String message)`: Called when the widget reports an error.
- `onClose()`: Triggered when the user dismisses the widget or it emits a close
  event.
- `onTimeout()`: Optional callback if you choose to set a timeout.

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

Distributed under the MIT License. See `LICENSE` for more information.
