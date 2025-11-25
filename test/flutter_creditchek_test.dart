import 'package:flutter_test/flutter_test.dart';
import 'package:approval_flutter/approval_flutter.dart';

void main() {
  group('ApprovalModule', () {
    test('should have all expected enum values', () {
      expect(ApprovalModule.values.length, 4);
      expect(ApprovalModule.values, contains(ApprovalModule.income));
      expect(ApprovalModule.values, contains(ApprovalModule.credit));
      expect(ApprovalModule.values, contains(ApprovalModule.recova));
      expect(ApprovalModule.values, contains(ApprovalModule.identity));
    });

    test('should have correct name values', () {
      expect(ApprovalModule.income.name, 'income');
      expect(ApprovalModule.credit.name, 'credit');
      expect(ApprovalModule.recova.name, 'recova');
      expect(ApprovalModule.identity.name, 'identity');
    });
  });

  group('ApprovalConfig', () {
    test('should create config with required businessId', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);

      expect(config.publicKey, publicKey);
      expect(config.incomeForm, isNull);
      expect(config.onSuccess, isNull);
      expect(config.onError, isNull);
      expect(config.onClose, isNull);
      expect(config.onTimeout, isNull);
    });

    test('should have default modules', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);

      expect(config.modules.length, 4);
      expect(config.modules, contains(ApprovalModule.income));
      expect(config.modules, contains(ApprovalModule.credit));
      expect(config.modules, contains(ApprovalModule.recova));
      expect(config.modules, contains(ApprovalModule.identity));
    });

    test('should accept custom modules', () {
      const publicKey = 'test-public-key';
      final customModules = [ApprovalModule.credit, ApprovalModule.identity];
      final config = ApprovalConfig(
        publicKey: publicKey,
        modules: customModules,
      );

      expect(config.modules, customModules);
      expect(config.modules.length, 2);
    });

    test('should accept all optional parameters', () {
      const publicKey = 'test-public-key';
      const incomeForm = 'test-income-form';
      bool onSuccessCalled = false;
      bool onErrorCalled = false;
      bool onCloseCalled = false;
      bool onTimeoutCalled = false;

      final config = ApprovalConfig(
        publicKey: publicKey,
        incomeForm: incomeForm,
        onSuccess: (_) => onSuccessCalled = true,
        onError: (_) => onErrorCalled = true,
        onClose: () => onCloseCalled = true,
        onTimeout: () => onTimeoutCalled = true,
      );

      expect(config.publicKey, publicKey);
      expect(config.incomeForm, incomeForm);
      expect(config.onSuccess, isNotNull);
      expect(config.onError, isNotNull);
      expect(config.onClose, isNotNull);
      expect(config.onTimeout, isNotNull);

      // Test callbacks
      config.onSuccess?.call({'test': 'data'});
      config.onError?.call('test error');
      config.onClose?.call();
      config.onTimeout?.call();

      expect(onSuccessCalled, isTrue);
      expect(onErrorCalled, isTrue);
      expect(onCloseCalled, isTrue);
      expect(onTimeoutCalled, isTrue);
    });
  });

  group('CreditChekConfig.buildUrl', () {
    test('should build URL with minimal required parameters', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, contains('https://securedwidget.creditchek.africa/?'));
      expect(url, contains('module=income,credit,recova,identity'));
      expect(url, contains('publicKey=$publicKey'));
    });

    test('should build URL with custom modules', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(
        publicKey: publicKey,
        modules: [ApprovalModule.credit, ApprovalModule.identity],
      );
      final url = config.buildUrl();

      expect(url, contains('module=credit,identity'));
      expect(url, contains('publicKey=$publicKey'));
    });

    test('should include incomeForm when provided', () {
      const publicKey = 'test-public-key';
      const incomeForm = 'form-123';
      final config = ApprovalConfig(
        publicKey: publicKey,
        incomeForm: incomeForm,
      );
      final url = config.buildUrl();

      expect(url, contains('incomeForm=$incomeForm'));
    });

    test('should not include incomeForm when null', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, isNot(contains('incomeForm=')));
    });

    test('should not include incomeForm when empty', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey, incomeForm: '');
      final url = config.buildUrl();

      expect(url, isNot(contains('incomeForm=')));
    });

    test('should include appId when provided', () {
      const publicKey = 'test-public-key';
      const appId = 'app-123';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, contains('appId=$appId'));
    });

    test('should not include appId when null', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, isNot(contains('appId=')));
    });

    test('should not include appId when empty', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, isNot(contains('appId=')));
    });

    test('should include publicKey when provided', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, contains('publicKey=$publicKey'));
    });

    test('should not include publicKey when null', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, isNot(contains('publicKey=')));
    });

    test('should not include publicKey when empty', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(publicKey: publicKey);
      final url = config.buildUrl();

      expect(url, isNot(contains('publicKey=')));
    });
    test('should build URL with all optional parameters', () {
      const publicKey = 'test-public-key';
      const incomeForm = 'form-456';
      final config = ApprovalConfig(
        publicKey: publicKey,
        incomeForm: incomeForm,
        modules: [ApprovalModule.income, ApprovalModule.credit],
        onTimeout: () {},
      );
      final url = config.buildUrl();

      expect(url, contains('https://securedwidget.creditchek.africa/?'));
      expect(url, contains('module=income,credit'));
      expect(url, contains('publicKey=$publicKey'));
      expect(url, contains('incomeForm=$incomeForm'));
      expect(url, contains('onTimeout='));
    });

    test('should handle single module correctly', () {
      const publicKey = 'test-public-key';
      final config = ApprovalConfig(
        publicKey: publicKey,
        modules: [ApprovalModule.credit],
      );
      final url = config.buildUrl();

      expect(url, contains('module=credit'));
      expect(url, isNot(contains(',')));
    });
  });

  // Note: Widget tests for CreditChekWidget require WebView platform implementation
  // These should be tested using integration tests or with a mocked WebViewPlatform
  // For unit testing, we focus on CreditChekConfig which contains the core business logic
}
