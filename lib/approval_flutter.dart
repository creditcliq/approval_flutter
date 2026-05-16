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
      'dob': dateOfBirth,
      'bvn': bvn,
      'email': email,
      'phone': phone,
      'gender': gender,
      'country': country,
      'address': address,
    };
  }
}

class ApprovalConfig {
  final String publicKey;
  final List<ApprovalModule> modules;
  final Function(String)? onSuccess;
  final Function(String)? onError;
  final AUserData? userData;

  ApprovalConfig({
    required this.publicKey,
    this.userData,
    this.modules = const [
      ApprovalModule.income,
      ApprovalModule.credit,
      ApprovalModule.recova,
      ApprovalModule.identity,
    ],
    this.onSuccess,
    this.onError,
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
      // 'https://development--securedwidget.netlify.app/',
    ).replace(queryParameters: queryParams);

    log("SDK_URL: ${uri.toString()}");
    debugPrint(uri.toString());

    return uri.toString();
  }
}
