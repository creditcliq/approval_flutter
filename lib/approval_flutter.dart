import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:approval_flutter/approval_flutter_config.dart';

class ApprovalFlutter {
  static Future<void> verify({
    required BuildContext context,
    required ApprovalConfig config,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApprovalWidget(config: config),
        fullscreenDialog: true,
      ),
    );
  }
}

enum ApprovalModule { income, credit, recova, identity }

class ApprovalConfig {
  final String publicKey;
  final List<ApprovalModule> modules;
  final String? incomeForm;
  final Function(Map<String, dynamic>)? onSuccess;
  final Function(String)? onError;
  final Function()? onClose;
  final Function()? onTimeout;

  ApprovalConfig({
    required this.publicKey,
    this.modules = const [
      ApprovalModule.income,
      ApprovalModule.credit,
      ApprovalModule.recova,
      ApprovalModule.identity,
    ],
    this.incomeForm,
    this.onSuccess,
    this.onError,
    this.onClose,
    this.onTimeout,
  });

  String buildUrl() {
    final moduleStr = modules.map((module) => module.name).join(',');
    log('moduleStr: $moduleStr');
    var url =
        'https://securedwidget.creditchek.africa/?'
        'module=$moduleStr&';
    url += '&publicKey=$publicKey';

    if (incomeForm != null && incomeForm!.isNotEmpty) {
      url += '&incomeForm=$incomeForm';
    }
    if (onTimeout != null) {
      url += '&onTimeout=$onTimeout';
    }
    return url;
  }
}
