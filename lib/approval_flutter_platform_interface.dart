import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'approval_flutter_method_channel.dart';
import 'models/approval_config.dart';
import 'models/session_result.dart';

abstract class ApprovalFlutterPlatform extends PlatformInterface {
  /// Constructs a ApprovalFlutterPlatform.
  ApprovalFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static ApprovalFlutterPlatform _instance = MethodChannelApprovalFlutter();

  /// The default instance of [ApprovalFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelApprovalFlutter].
  static ApprovalFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ApprovalFlutterPlatform] when
  /// they register themselves.
  static set instance(ApprovalFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  /// Starts the CreditChek Approval verification flow.
  Future<SessionResult> startVerification(ApprovalConfig config) {
    throw UnimplementedError('startVerification() has not been implemented.');
  }
}
