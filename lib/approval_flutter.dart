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
  final UserData? userData;
  // final Function()? onClose;
  // final Function()? onTimeout;
  // final Map<String, dynamic>? data;

  ApprovalConfig({
    required this.publicKey,
    this.userData,
    this.modules = const [
      ApprovalModule.income,
      ApprovalModule.credit,
      ApprovalModule.recova,
      ApprovalModule.identity,
    ],
    // this.data,
    this.onSuccess,
    this.onError,
    // this.onClose,
    // this.onTimeout,
  });

  String buildUrl() {
    final moduleStr = modules.map((module) => module.name).join(',');

    final queryParams = <String, String>{
      'publicKey': publicKey,
      'module': moduleStr,
      'source': 'flutter',
    };

    if (userData != null) {
      userData!.toJson().forEach((key, value) {
        if (value != null) {
          queryParams[key] = value.toString();
        }
      });
    }

    final uri = Uri.parse(
      'https://securedwidget.creditchek.africa/',
    ).replace(queryParameters: queryParams);

    log(uri.toString(), name: 'ApprovalConfigURL');
    return uri.toString();
  }
}

class AUserData {
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? bvn;
  final String? email;
  final String? phone;
  final String? gender;
  final String? country;
  final String? address;

  AUserData({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.bvn,
    this.email,
    this.phone,
    this.gender,
    this.country,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'bvn': bvn,
      'email': email,
      'phone': phone,
      'gender': gender,
      'country': country,
      'address': address,
    };
  }
}
