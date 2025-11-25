import 'package:flutter/material.dart';
import 'package:approval_flutter/approval_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

// Main CreditChek Widget
class ApprovalWidget extends StatefulWidget {
  final ApprovalConfig config;

  const ApprovalWidget({super.key, required this.config});

  @override
  State<ApprovalWidget> createState() => _ApprovalWidgetState();
}

class _ApprovalWidgetState extends State<ApprovalWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            widget.config.onError?.call(error.description);
          },
        ),
      )
      ..addJavaScriptChannel(
        'ApprovalChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse(widget.config.buildUrl()));
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'] as String?;

      switch (type) {
        case 'success':
          widget.config.onSuccess?.call(data['data']);
          break;
        case 'error':
          widget.config.onError?.call(data['message'] ?? 'Unknown error');
          break;
        case 'close':
          widget.config.onClose?.call();
          Navigator.of(context).pop();
          break;
      }
    } catch (e) {
      widget.config.onError?.call('Failed to parse message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Approval Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.config.onClose?.call();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// On click on accept and continue, pass the device fingerprint to the server


//https://securedwidget.creditchek.africa/?
//module=income,credit,recova,identity&businessId=630c8be89131cd442344e790&
//incomeForm=&appId=&publicKey=

//TODO: 
//app id isn't needed.
//add device fingerprint to the url