part of '../approval_flutter_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Inline error state (main-frame network failure)
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: _kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: _kPrimary,
                size: 38,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message.isNotEmpty
                  ? message
                  : 'Unable to load the page. Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _kTextSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
