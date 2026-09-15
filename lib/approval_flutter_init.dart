
import 'approval_flutter_platform_interface.dart';
import 'models/approval_config.dart';
import 'models/session_result.dart';

class ApprovalFlutter {
  /// Launches the CreditChek Approval verification flow.
  ///
  /// Takes an [ApprovalConfig] containing your public key and configuration,
  /// and returns a [SessionResult] (`SessionResultSuccess`, `SessionResultCancelled`, or `SessionResultError`).
  static Future<SessionResult> start({
    required ApprovalConfig config,
  }) {
    return ApprovalFlutterPlatform.instance.startVerification(config);
  }
}
