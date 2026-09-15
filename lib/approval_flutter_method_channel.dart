import 'package:approval_flutter/models/approval_config.dart';
import 'package:approval_flutter/models/session_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'approval_flutter_platform_interface.dart';

/// An implementation of [ApprovalFlutterPlatform] that uses method channels.
class MethodChannelApprovalFlutter extends ApprovalFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('approval_flutter');


  @override
  Future<SessionResult> startVerification(ApprovalConfig config) async {
    try {
      final Map<dynamic, dynamic>? result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'startVerification',
        config.toMap(),
      );
      if (result == null) {
        return const SessionResultError(
          code: 'NULL_RESPONSE',
          message: 'Received an empty response from the native SDK.',
        );
      }
      final status = result['status'] as String?;
      switch (status) {
        case 'success':
          return SessionResultSuccess(
            sessionId: result['sessionId'] as String? ?? '',
            message: result['message'] as String? ?? 'Verification completed successfully',
          );
        case 'cancelled':
          return const SessionResultCancelled();
        case 'error':
        default:
          return SessionResultError(
            code: result['code'] as String? ?? 'UNKNOWN_ERROR',
            message: result['message'] as String? ?? 'An unexpected error occurred during verification.',
          );
      }
    } on PlatformException catch (e) {
      return SessionResultError(
        code: e.code,
        message: e.message ?? 'Platform exception occurred.',
      );
    } catch (e) {
      return SessionResultError(
        code: 'GENERIC_ERROR',
        message: e.toString(),
      );
    }
  }
}
