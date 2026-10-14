import 'package:flutter_test/flutter_test.dart';
import 'package:approval_flutter/approval_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApprovalConfig & AUserData Tests', () {
    test('ApprovalConfig serialization includes widgetId and required fields', () {
      const config = ApprovalConfig(
        publicKey: 'pk_test_123',
        sessionId: 'session_abc',
        widgetId: 'widget_xyz',
      );

      final map = config.toMap();
      expect(map['publicKey'], 'pk_test_123');
      expect(map['sessionId'], 'session_abc');
      expect(map['widgetId'], 'widget_xyz');
      expect(map.containsKey('userData'), isFalse);
    });

    test('ApprovalConfig with userData includes NIN and full pre-fill fields', () {
      const userData = AUserData(
        firstName: 'John',
        lastName: 'Doe',
        bvn: '12345678901',
        nin: '98765432109',
        email: 'john@example.com',
        dob: '2000-01-01',
        phone: '+2348012345678',
      );

      const config = ApprovalConfig(
        publicKey: 'pk_test_123',
        sessionId: 'session_abc',
        widgetId: 'widget_xyz',
        userData: userData,
      );

      final map = config.toMap();
      expect(map['widgetId'], 'widget_xyz');
      expect(map['userData'], isNotNull);
      final userMap = map['userData'] as Map<String, dynamic>;
      expect(userMap['firstName'], 'John');
      expect(userMap['bvn'], '12345678901');
      expect(userMap['nin'], '98765432109');
      expect(userMap['dob'], '2000-01-01');
      expect(userMap['dateOfBirth'], '2000-01-01');
    });
  });
}
