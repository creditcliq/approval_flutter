import 'package:flutter_test/flutter_test.dart';
import 'package:approval_flutter/approval_flutter.dart';

void main() {
  group('ApprovalModule', () {
    test('should have all expected enum values', () {
      expect(
        ApprovalModule.values.length,
        3,
      ); // Based on source code: income, credit, recova. Identity is commented out.
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
      expect(config.onClose, isNull);
    });

    test('should have default modules', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);

      expect(config.modules.length, 3); // income, credit, recova
      expect(config.modules, contains(ApprovalModule.income));
      expect(config.modules, contains(ApprovalModule.credit));
      expect(config.modules, contains(ApprovalModule.recova));
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

    test('should accept all optional parameters', () {
      const publicKey = 'test-public-key';
      bool onSuccessCalled = false;
      bool onErrorCalled = false;
      bool onCloseCalled = false;

      final config = ApprovalConfig(
        publicKey: publicKey,
        onSuccess: (_) => onSuccessCalled = true,
        onError: (_) => onErrorCalled = true,
        onClose: () => onCloseCalled = true,
      );

      expect(config.publicKey, publicKey);
      expect(config.onSuccess, isNotNull);
      expect(config.onError, isNotNull);
      expect(config.onClose, isNotNull);

      // Test callbacks
      config.onSuccess?.call({'test': 'data'});
      config.onError?.call('test error');
      config.onClose?.call();

      expect(onSuccessCalled, isTrue);
      expect(onErrorCalled, isTrue);
      expect(onCloseCalled, isTrue);
    });
  });

  group('ApprovalConfig.buildUrl', () {
    test('should build URL with minimal required parameters', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, contains('https://securedwidget.creditchek.africa/?'));
      expect(url, contains('publicKey=$publicKey'));
      expect(url, contains('module=income,credit,recova'));
    });

    test('should build URL with custom modules', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(
        publicKey: publicKey,
        modules: [ApprovalModule.income, ApprovalModule.credit],
      );
      final url = config.buildUrl();

      expect(url, contains('module=income,credit'));
      // expect(url, contains('publicKey=$publicKey')); // Already verified ordering isn't strictly enforced by general verification but explicit content is good.
    });

    test('should include publicKey when provided', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, contains('publicKey=$publicKey'));
    });

    test('should handle single module correctly', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(
        publicKey: publicKey,
        modules: [ApprovalModule.credit],
      );
      final url = config.buildUrl();

      expect(url, contains('module=credit'));
      expect(url, isNot(contains('module=credit,')));
    });
  });
}
