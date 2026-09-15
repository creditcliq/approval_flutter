sealed class SessionResult {
  const SessionResult();
}

/// Verification succeeded with live liveness and identity check passed
class SessionResultSuccess extends SessionResult {
  /// The unique session ID of the completed verification
  final String sessionId;

  /// Success message returned by the SDK
  final String message;

  const SessionResultSuccess({
    required this.sessionId,
    this.message = 'Verification completed successfully',
  });

  @override
  String toString() => 'SessionResultSuccess(sessionId: $sessionId, message: $message)';
}

/// The user dismissed or cancelled the verification flow
class SessionResultCancelled extends SessionResult {
  const SessionResultCancelled();

  @override
  String toString() => 'SessionResultCancelled()';
}

/// An error occurred during the verification flow (e.g. network failure, invalid key)
class SessionResultError extends SessionResult {
  /// Error code
  final String code;

  /// Human-readable error description
  final String message;

  const SessionResultError({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'SessionResultError(code: $code, message: $message)';
}