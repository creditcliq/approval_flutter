import 'dart:developer';

import 'package:approval_flutter/approval_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
      publicKey: 'your_public_key_here',
      //Module: income, credit, recova, identity
      modules: [ApprovalModule.income, ApprovalModule.credit],
      incomeForm: 'your_income_form_here',

      onSuccess: (data) {
        final sessionId = data['sessionId'];
        log('Verification successful: $data');
        // Handle success
      },
      onError: (error) {
        log('Verification error: $error');
        // Handle error
      },
      onTimeout: () {
        log('Verification timed out');
        // Handle timeout
      },
      onClose: () {
        log('Widget closed');
        // Handle close
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
