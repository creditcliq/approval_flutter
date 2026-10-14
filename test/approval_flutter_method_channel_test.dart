import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:approval_flutter/approval_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelApprovalFlutter();
  const channel = MethodChannel('approval_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'startVerification') {
        final args = methodCall.arguments as Map<dynamic, dynamic>;
        return {
          'status': 'success',
          'sessionId': args['sessionId'],
          'message': 'Verification completed successfully',
        };
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('startVerification returns SessionResultSuccess', () async {
    const config = ApprovalConfig(
      publicKey: 'pk_test_sample',
      sessionId: 'session_123',
      widgetId: 'widget_456',
    );

    final result = await platform.startVerification(config);
    expect(result, isA<SessionResultSuccess>());
    final success = result as SessionResultSuccess;
    expect(success.sessionId, 'session_123');
    expect(success.message, 'Verification completed successfully');
  });
}
