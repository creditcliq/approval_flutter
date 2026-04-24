// Copyright (c) 2026 CreditChek Africa. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

part of '../approval_flutter_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared dialog shell
// ─────────────────────────────────────────────────────────────────────────────
class _ApprovalDialog extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget? extra;

  const _ApprovalDialog({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actions,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _kTextSecondary,
                height: 1.6,
              ),
            ),
            if (extra != null) ...[const SizedBox(height: 14), extra!],
            const SizedBox(height: 28),
            Row(
              children: actions
                  .expand(
                    (w) => [
                      w,
                      if (w != actions.last) const SizedBox(width: 12),
                    ],
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Success dialog
// ─────────────────────────────────────────────────────────────────────────────
class _ApprovalSuccessDialog extends StatelessWidget {
  final String sessionId;
  final VoidCallback onContinue;

  const _ApprovalSuccessDialog({
    required this.sessionId,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return _ApprovalDialog(
      icon: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: _kPrimaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: _kPrimary,
          size: 42,
        ),
      ),
      title: 'Verification Successful',
      subtitle: 'Your identity has been verified successfully.',
      extra: sessionId.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    'Session ID: ',
                    style: TextStyle(fontSize: 12, color: _kTextSecondary),
                  ),
                  Flexible(
                    child: Text(
                      sessionId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          : null,
      actions: [_PrimaryButton(label: 'Continue', onPressed: onContinue)],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Failed dialog
// ─────────────────────────────────────────────────────────────────────────────
class _ApprovalFailedDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ApprovalFailedDialog({required this.onRetry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return _ApprovalDialog(
      icon: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.cancel_rounded, color: Colors.red, size: 42),
      ),
      title: 'Verification Failed',
      subtitle: 'We could not complete your verification. Please try again.',
      actions: [
        _OutlineButton(label: 'Close', onPressed: onClose),
        _PrimaryButton(label: 'Retry', onPressed: onRetry),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Close / exit confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────
class _ApprovalCloseConfirmDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ApprovalCloseConfirmDialog({
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _ApprovalDialog(
      icon: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: _kPrimaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.info_outline_rounded,
          color: _kPrimary,
          size: 42,
        ),
      ),
      title: 'Exit Verification?',
      subtitle:
          'Your verification progress will be lost. Are you sure you want to exit?',
      actions: [
        _OutlineButton(label: 'Continue', onPressed: onCancel),
        _OutlineButton(
          label: 'Exit',
          onPressed: onConfirm,
          borderColor: Colors.red,
          textColor: Colors.red,
        ),
      ],
    );
  }
}
