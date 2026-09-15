// import 'package:flutter_test/flutter_test.dart';
// import 'package:approval_flutter/approval_flutter.dart';
// import 'package:approval_flutter/approval_flutter_platform_interface.dart';
// import 'package:approval_flutter/approval_flutter_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockApprovalFlutterPlatform
//     with MockPlatformInterfaceMixin
//     implements ApprovalFlutterPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final ApprovalFlutterPlatform initialPlatform = ApprovalFlutterPlatform.instance;

//   test('$MethodChannelApprovalFlutter is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelApprovalFlutter>());
//   });

//   test('getPlatformVersion', () async {
//     ApprovalFlutter approvalFlutterPlugin = ApprovalFlutter();
//     MockApprovalFlutterPlatform fakePlatform = MockApprovalFlutterPlatform();
//     ApprovalFlutterPlatform.instance = fakePlatform;

//     expect(await approvalFlutterPlugin.getPlatformVersion(), '42');
//   });
// }
