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
  final Function(String)? onSuccess;
  final Function(String)? onError;
  final Function()? onClose;
  // final Function()? onTimeout;
  // final Map<String, dynamic>? data;

  ApprovalConfig({
    required this.publicKey,
    this.modules = const [
      ApprovalModule.income,
      ApprovalModule.credit,
      ApprovalModule.recova,
      // ApprovalModule.identity,
    ],
    // this.data,
    this.onSuccess,
    this.onError,
    this.onClose,
    // this.onTimeout,
  });

  String buildUrl() {
    final moduleStr = modules.map((module) => module.name).join(',');
    var url = 'https://securedwidget.creditchek.africa/?publicKey=$publicKey';
    url += '&module=$moduleStr';

    // if (data != null) {
    //   data!.forEach((key, value) {
    //     url += '&$key=$value';
    //   });
    // }

    // if (onTimeout != null) {
    //   url += '&onTimeout=$onTimeout';
    // }
    log(url, name: 'ApprovalConfigURL');
    return url;
  }
}
