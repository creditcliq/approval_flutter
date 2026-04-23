# CreditChek Approval Flutter Example

This example app demonstrates how to embed the CreditChek Approval Widget in a
Flutter project. It loads the secure CreditChek web experience inside a native
`WebView` so that you can trigger identity, income, credit, or Recova checks
inside your own app.

## Project structure

- `lib/main.dart`: boots a tiny demo UI and wires up `ApprovalFlutter.verify`.
- `lib/approval_flutter.dart`: exposes the `ApprovalConfig` and helpers shipped
  by the SDK (consumed via a path dependency in `pubspec.yaml`).

## Running the example

```bash
flutter pub get
flutter run
```

By default the button on the home screen uses placeholder values. Replace them
with your live credentials before shipping to production.

## Using the SDK

Add the dependency (path for local testing or git when published):

```yaml
dependencies:
  approval_flutter:
    path: ../.. # or git: https://github.com/creditcliq/approval_flutter_int.git
```

Then configure and launch the widget:

```dart
final config = ApprovalConfig(
  publicKey: 'pk_live_your_key',
  userData: UserData(
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@example.com',
  ),
  modules: [
    ApprovalModule.income,
    ApprovalModule.credit,
    ApprovalModule.recova,
    ApprovalModule.identity,
  ],
  onSuccess: (response) => debugPrint('Session: $response'),
  onError: (message) => debugPrint('Error: $message'),
);

await ApprovalFlutter.verify(context: context, config: config);
```

### Available callbacks

- `onSuccess(String response)`: Fired when the workflow finishes successfully. Grab the
  `sessionId` and continue your flow.
- `onError(String message)`: Triggered for validation or network issues.

### Modules you can enable

Pass a subset of `ApprovalModule` values via `modules` to control which product
surface loads in the widget. If you omit the field, all four modules load by
default in this order: income, credit, recova, identity.

## Support

Need help integrating? Reach out to the CreditChek team via your assigned
customer-success channel or email support@creditchek.africa. We are happy to
review logs, walk through implementation details, or provide updated keys.
