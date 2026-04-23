import 'dart:developer';

import 'package:approval_flutter/approval_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ExampleUsage(),
    );
  }
}

class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  void _startVerification(BuildContext context) {
    final config = ApprovalConfig(
      publicKey: dotenv.env['PUBLIC_KEY'] ?? '',
      modules: [ApprovalModule.identity, ApprovalModule.credit],
      userData: AUserData(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
      ),
      onSuccess: (sessionId) {
        log('Verification successful: $sessionId');
        // Handle success
      },
      onError: (error) {
        log('Verification error: $error');
        // Handle error
      },
    );

    ApprovalFlutter.verify(context: context, config: config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CreditChek Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startVerification(context),
          child: const Text('Start Verification'),
        ),
      ),
    );
  }
}
