import 'package:flutter/material.dart';
import 'package:approval_flutter/approval_flutter.dart';

void main() {
  runApp(const ApprovalExampleApp());
}

class ApprovalExampleApp extends StatelessWidget {
  const ApprovalExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CreditChek Approval Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF064BEF)),
        useMaterial3: true,
      ),
      home: const VerificationHomeScreen(),
    );
  }
}

class VerificationHomeScreen extends StatefulWidget {
  const VerificationHomeScreen({super.key});

  @override
  State<VerificationHomeScreen> createState() => _VerificationHomeScreenState();
}

class _VerificationHomeScreenState extends State<VerificationHomeScreen> {
  final TextEditingController _apiKeyController = TextEditingController(
    text: "vy6LZWI/l/pOc868z8LAgEBCdvsSomPev2TxLqIdlNZIueMM0Agl8G88zxyE65LN" //'test_pk_live_or_sandbox_key_here',
  );

  ApprovalEnvironment _selectedEnvironment = ApprovalEnvironment.sandbox;
  String _statusMessage = 'Ready to verify';
  Color _statusColor = Colors.grey.shade700;
  String? _lastSessionId;
  bool _isLoading = false;

  Future<void> _startVerification() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your CreditChek public key')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Launching verification...';
      _statusColor = const Color(0xFF064BEF);
    });

    try {
      final config = ApprovalConfig(
        publicKey: apiKey,
        environment: _selectedEnvironment,
        userData: const AUserData(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          // Optional prefilled BVN:
          // bvn: '12345678901',
        ),
      );

      final result = await ApprovalFlutter.start(config: config);

      if (!mounted) return;

      switch (result) {
        case SessionResultSuccess(:final sessionId, :final message):
          setState(() {
            _statusMessage = 'Success: $message';
            _lastSessionId = sessionId;
            _statusColor = const Color(0xFF12A84A);
          });
        case SessionResultCancelled():
          setState(() {
            _statusMessage = 'Verification was cancelled by the user.';
            _statusColor = Colors.orange.shade800;
          });
        case SessionResultError(:final code, :final message):
          setState(() {
            _statusMessage = 'Error ($code): $message';
            _statusColor = const Color(0xFFFF2543);
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Exception: $e';
        _statusColor = const Color(0xFFFF2543);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('CreditChek Approval'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E8EA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identity Verification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Test the CreditChek active face liveness and BVN verification module.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E8EA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Public Key',
                      hintText: 'Enter your CreditChek public key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Environment:'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<ApprovalEnvironment>(
                          title: const Text('Sandbox'),
                          value: ApprovalEnvironment.sandbox,
                          groupValue: _selectedEnvironment,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedEnvironment = val);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<ApprovalEnvironment>(
                          title: const Text('Production'),
                          value: ApprovalEnvironment.production,
                          groupValue: _selectedEnvironment,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedEnvironment = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064BEF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Start Verification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Result Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E8EA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Result Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _statusColor,
                    ),
                  ),
                  if (_lastSessionId != null) ...[
                    const SizedBox(height: 12),
                    SelectableText(
                      'Session ID: $_lastSessionId',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}