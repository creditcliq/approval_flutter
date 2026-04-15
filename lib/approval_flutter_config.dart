import 'package:flutter/material.dart';
import 'package:approval_flutter/approval_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
            _controller.runJavaScript("""
              window.handleRequestErrors = function(error) {
                try {
                  const message = error.message || String(error);
                  ApprovalChannel.postMessage(JSON.stringify({
                    type: 'error',
                    message: message
                  }));
                } catch(e) {
                  console.error("Error in handleRequestErrors:", e);
                }
              };
            """);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            widget.config.onError?.call(error.description);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            final uri = Uri.parse(url);
            final lowercaseUrl = url.toLowerCase();

            if (lowercaseUrl.contains('successful') ||
                lowercaseUrl.contains('failed')) {
              if (mounted) {
                if (lowercaseUrl.contains('successful')) {
                  final sessionId = uri.queryParameters['sessionid'];
                  widget.config.onSuccess?.call(sessionId ?? '');
                } else if (lowercaseUrl.contains('failed')) {
                  widget.config.onError?.call('Approval verification failed');
                } else {
                  widget.config.onClose?.call();
                }
                Navigator.of(context).pop();
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    // ..addJavaScriptChannel(
    //   'ApprovalChannel',
    //   onMessageReceived: (JavaScriptMessage message) {
    //     // _handleMessage(message.message);
    //   },
    // );

    _controller.loadRequest(Uri.parse(widget.config.buildUrl()));
  }

  // void _handleMessage(String message) {
  //   try {
  //     final data = jsonDecode(message);
  //     final type = data['type'] as String?;

  //     switch (type) {
  //       case 'success':
  //         widget.config.onSuccess?.call(data['data']);
  //         if (mounted) Navigator.of(context).pop();
  //         break;
  //       case 'error':
  //         widget.config.onError?.call(data['message'] ?? 'Unknown error');
  //         if (mounted) Navigator.of(context).pop();
  //         break;
  //       case 'close':
  //         widget.config.onClose?.call();
  //         if (mounted) Navigator.of(context).pop();
  //         break;
  //     }
  //     log('Message received: $message');
  //   } catch (e) {
  //     widget.config.onError?.call('Failed to parse message: $e');
  //   }
  // }

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



