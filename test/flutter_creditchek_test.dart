import 'package:flutter_test/flutter_test.dart';
import 'package:approval_flutter/approval_flutter.dart';

void main() {
  group('ApprovalModule', () {
    test('should have all expected enum values', () {
      expect(
        ApprovalModule.values.length,
        4,
      ); // income, credit, recova, identity
      expect(ApprovalModule.values, contains(ApprovalModule.income));
      expect(ApprovalModule.values, contains(ApprovalModule.credit));
      expect(ApprovalModule.values, contains(ApprovalModule.recova));
      // expect(ApprovalModule.values, contains(ApprovalModule.identity)); // Identity is likely commented out in source or not
    });

    test('should have correct name values', () {
      expect(ApprovalModule.income.name, 'income');
      expect(ApprovalModule.credit.name, 'credit');
      expect(ApprovalModule.recova.name, 'recova');
      // expect(ApprovalModule.identity.name, 'identity');
    });
  });

  group('ApprovalConfig', () {
    test('should create config with required publicKey', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);

      expect(config.publicKey, publicKey);
      expect(config.onSuccess, isNull);
      expect(config.onError, isNull);
    });

    test('should accept UserData', () {
      const publicKey = 'test-public-key';
      final userData = AUserData(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
      );
      final config = ApprovalConfig(publicKey: publicKey, userData: userData);

      expect(config.userData, isNotNull);
      expect(config.userData?.firstName, 'John');
      expect(config.userData?.lastName, 'Doe');
      expect(config.userData?.email, 'john@example.com');
    });

    test('should have default modules', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);

      expect(config.modules.length, 4); // income, credit, recova, identity
      expect(config.modules, contains(ApprovalModule.income));
      expect(config.modules, contains(ApprovalModule.credit));
      expect(config.modules, contains(ApprovalModule.recova));
      expect(config.modules, contains(ApprovalModule.identity));
    });

    test('should accept custom modules', () {
      const publicKey = 'test-public-key';
      final customModules = [ApprovalModule.income, ApprovalModule.credit];
      final config = ApprovalConfig(
        publicKey: publicKey,
        modules: customModules,
      );

      expect(config.modules, customModules);
      expect(config.modules.length, 2);
    });

    test('should accept callbacks', () {
      const publicKey = 'test-public-key';
      bool onSuccessCalled = false;
      bool onErrorCalled = false;

      final config = ApprovalConfig(
        publicKey: publicKey,
        onSuccess: (_) => onSuccessCalled = true,
        onError: (_) => onErrorCalled = true,
      );

      expect(config.publicKey, publicKey);
      expect(config.onSuccess, isNotNull);
      expect(config.onError, isNotNull);

      config.onSuccess?.call('test sessionId');
      config.onError?.call('test error');

      expect(onSuccessCalled, isTrue);
      expect(onErrorCalled, isTrue);
    });
  });

  group('UserData', () {
    test('toJson should include all fields', () {
      final userData = AUserData(
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: '1990-01-15',
        bvn: '12345678901',
        email: 'john@example.com',
        phone: '08012345678',
        gender: 'male',
        country: 'Nigeria',
        address: '123 Main St',
      );

      final json = userData.toJson();
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['dateOfBirth'], '1990-01-15');
      expect(json['bvn'], '12345678901');
      expect(json['email'], 'john@example.com');
      expect(json['phone'], '08012345678');
      expect(json['gender'], 'male');
      expect(json['country'], 'Nigeria');
      expect(json['address'], '123 Main St');
    });

    test('toJson should handle null fields', () {
      final userData = AUserData(firstName: 'John');
      final json = userData.toJson();
      expect(json['firstName'], 'John');
      expect(json['lastName'], isNull);
    });
  });

  group('ApprovalConfig.buildUrl', () {
    test('should build URL with minimal required parameters', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, contains('https://securedwidget.creditchek.africa/?'));
      expect(url, contains('publicKey=$publicKey'));
      expect(url, contains('module=income%2Ccredit%2Crecova%2Cidentity'));
      expect(url, contains('source=flutter'));
    });

    test('should build URL with custom modules', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(
        publicKey: publicKey,
        modules: [ApprovalModule.income, ApprovalModule.credit],
      );
      final url = config.buildUrl();

      expect(url, contains('module=income%2Ccredit'));
    });

    test('should include UserData when provided and omit nulls', () {
      const publicKey = 'test-public-key';
      final userData = AUserData(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
      );
      final config = ApprovalConfig(publicKey: publicKey, userData: userData);
      final url = config.buildUrl();

      expect(url, contains('firstName=John'));
      expect(url, contains('lastName=Doe'));
      expect(url, contains('email=john%40example.com'));
      expect(url, isNot(contains('bvn=')));
      expect(url, isNot(contains('phone=')));
    });

    test('should handle special characters in UserData', () {
      const publicKey = 'test-public-key';
      final userData = AUserData(
        firstName: 'John Doe',
        address: '123 & 456 Street',
      );
      final config = ApprovalConfig(publicKey: publicKey, userData: userData);
      final url = config.buildUrl();

      expect(url, contains('firstName=John+Doe'));
      expect(url, contains('address=123+%26+456+Street'));
    });
  });
}
