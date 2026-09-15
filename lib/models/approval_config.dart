import 'user_data.dart';

/// Target environment for the verification API
enum ApprovalEnvironment { sandbox, production }

/// Verification modules supported by CreditChek Approval
enum ApprovalModule { identity, liveliness, income, recova, credit }

class ApprovalConfig {
  /// Your CreditChek public API key
  final String publicKey;

  /// Environment mode (defaults to [ApprovalEnvironment.sandbox])
  final ApprovalEnvironment environment;

  /// List of verification modules (defaults to `[ApprovalModule.identity]`)
  final List<ApprovalModule> modules;

  /// Optional pre-fill data for the user
  final AUserData? userData;

  /// Optional session Id to continue an existing session (works with liveliness module)
  final String? sessionId;

  const ApprovalConfig({
    required this.publicKey,
    this.environment = ApprovalEnvironment.sandbox,
    this.modules = const [ApprovalModule.identity],
    this.userData,
    this.sessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'publicKey': publicKey,
      'environment': environment == ApprovalEnvironment.production
          ? 'PRODUCTION'
          : 'SANDBOX',
      'modules': modules.map((m) => m.name.toUpperCase()).toList(),
      'userData': userData?.toMap(),
      'sessionId': sessionId,
    };
  }
}
