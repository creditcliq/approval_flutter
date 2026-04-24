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

import 'package:approval_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:approval_flutter/approval_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

part 'widgets/dialogs.dart';
part 'widgets/buttons.dart';
part 'widgets/error_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main CreditChek Widget
// ─────────────────────────────────────────────────────────────────────────────
class ApprovalWidget extends StatefulWidget {
  final ApprovalConfig config;

  const ApprovalWidget({super.key, required this.config});

  @override
  State<ApprovalWidget> createState() => _ApprovalWidgetState();
}

class _ApprovalWidgetState extends State<ApprovalWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _handled = false; // prevent double-handling navigation callbacks
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);

    // Receives all fetch/XHR logs from the injected JS interceptor ONLY in debug mode
    if (kDebugMode) {
      controller.addJavaScriptChannel(
        'NetworkLogger',
        onMessageReceived: (JavaScriptMessage msg) {},
      );
    }

    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          setState(() {
            _isLoading = true;
            _hasError = false;
          });
        },
        onPageFinished: (String url) {
          setState(() => _isLoading = false);
          // Inject fetch/XHR interceptors once the page JS context is ready
          if (kDebugMode) {
            controller.runJavaScript(_buildNetworkInterceptorJs());
          }
        },
        onUrlChange: (UrlChange change) {},
        onWebResourceError: (WebResourceError error) {
          if (error.isForMainFrame == true) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
            widget.config.onError?.call(error.description);
          } else {}
        },
        onNavigationRequest: (NavigationRequest request) {
          if (_handled) return NavigationDecision.prevent;

          final url = request.url;
          final uri = Uri.parse(url);
          final lowercaseUrl = url.toLowerCase();

          if (lowercaseUrl.contains('success') ||
              lowercaseUrl.contains('failed')) {
            if (mounted) {
              _handled = true;
              if (lowercaseUrl.contains('success')) {
                final sessionId = uri.queryParameters['sessionId'];
                _showSuccessDialog(sessionId ?? '');
              } else if (lowercaseUrl.contains('failed')) {
                _showFailedDialog();
              }
            }
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ),
    );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);

      (controller.platform as AndroidWebViewController)
          .setOnPlatformPermissionRequest((
            PlatformWebViewPermissionRequest request,
          ) {
            request.grant();
          });
    }

    _controller = controller;
    _controller.loadRequest(Uri.parse(widget.config.buildUrl()));
  }

  // ─── Dialog helpers ────────────────────────────────────────────────────────

  void _showSuccessDialog(String sessionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ApprovalSuccessDialog(
        sessionId: sessionId,
        onContinue: () {
          widget.config.onSuccess?.call(sessionId);
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // close webview
        },
      ),
    );
  }

  void _showFailedDialog() {
    widget.config.onError?.call('Approval verification failed');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ApprovalFailedDialog(
        onRetry: () {
          Navigator.of(context).pop(); // close dialog
          setState(() {
            _handled = false;
            _isLoading = true;
          });
          _controller.reload();
        },
        onClose: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // close webview
        },
      ),
    );
  }

  void _showCloseConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => _ApprovalCloseConfirmDialog(
        onCancel: () => Navigator.of(context).pop(), // stay in verification
        onConfirm: () {
          // widget.config.onClose?.call();
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // close webview
        },
      ),
    );
  }

  void _retryAfterError() {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _handled = false;
    });
    _controller.reload();
  }

  // ─── JS network interceptor ────────────────────────────────────────────────

  /// Returns JavaScript that intercepts all fetch() and XMLHttpRequest calls
  /// inside the WebView and posts log messages back to Dart via [NetworkLogger].
  String _buildNetworkInterceptorJs() {
    return """
      (function() {
        // ── fetch interceptor ──────────────────────────────────────────────
        const _origFetch = window.fetch;
        window.fetch = function(...args) {
          const url = args[0] instanceof Request ? args[0].url : String(args[0]);
          const method = (args[1] && args[1].method) ? args[1].method.toUpperCase() : 'GET';
          NetworkLogger.postMessage('[fetch] ▶ ' + method + ' ' + url);
          return _origFetch.apply(this, args)
            .then(function(res) {
              NetworkLogger.postMessage('[fetch] ✅ ' + method + ' ' + url + ' → ' + res.status);
              return res;
            })
            .catch(function(err) {
              NetworkLogger.postMessage('[fetch] ❌ ' + method + ' ' + url + ' → ' + String(err));
              throw err;
            });
        };

        // ── XMLHttpRequest interceptor ─────────────────────────────────────
        const _origOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function(method, url) {
          this._logMethod = method.toUpperCase();
          this._logUrl   = url;
          this.addEventListener('loadstart', function() {
            NetworkLogger.postMessage('[xhr] ▶ ' + this._logMethod + ' ' + this._logUrl);
          });
          this.addEventListener('load', function() {
            NetworkLogger.postMessage('[xhr] ✅ ' + this._logMethod + ' ' + this._logUrl + ' → ' + this.status);
          });
          this.addEventListener('error', function() {
            NetworkLogger.postMessage('[xhr] ❌ ' + this._logMethod + ' ' + this._logUrl + ' (network error)');
          });
          this.addEventListener('abort', function() {
            NetworkLogger.postMessage('[xhr] ⚠️  ' + this._logMethod + ' ' + this._logUrl + ' (aborted)');
          });
          return _origOpen.apply(this, arguments);
        };

        NetworkLogger.postMessage('[interceptor] ✅ fetch & XHR interceptors active');
      })();
    """;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Approval Verification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: _showCloseConfirmDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            _ErrorStateView(message: _errorMessage, onRetry: _retryAfterError)
          else
            WebViewWidget(controller: _controller),
          if (_isLoading && !_hasError)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ThemeHelper.kPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
