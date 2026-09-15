import Flutter
import UIKit
import approval_ios

public class ApprovalFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "approval_flutter", binaryMessenger: registrar.messenger())
    let instance = ApprovalFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startVerification":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Arguments must be a map", details: nil))
        return
      }

      guard let publicKey = args["publicKey"] as? String, !publicKey.isEmpty else {
        result(FlutterError(code: "INVALID_CONFIG", message: "publicKey is required", details: nil))
        return
      }

      let envString = (args["environment"] as? String ?? "SANDBOX").uppercased()
      let environment: ApprovalEnv = (envString == "PRODUCTION") ? .production : .sandbox

      // Parse user data if present
      var userData: AUserData? = nil
      if let userDict = args["userData"] as? [String: Any] {
        userData = AUserData(
          firstName: userDict["firstName"] as? String ?? "",
          lastName: userDict["lastName"] as? String ?? "",
          bvn: userDict["bvn"] as? String ?? "",
          email: userDict["email"] as? String ?? "",
          dateOfBirth: (userDict["dob"] as? String) ?? (userDict["dateOfBirth"] as? String),
          phone: userDict["phone"] as? String
        )
      }

      // Parse modules
      let rawModules = args["modules"] as? [String] ?? ["IDENTITY"]
      let modules: [ApprovalModule] = rawModules.compactMap { key in
        ApprovalModule(rawValue: key.lowercased())
      }
      let finalModules = modules.isEmpty ? [.identity] : modules

      // Parse optional session ID
      let sessionId = args["sessionId"] as? String

      let config = ApprovalConfig(
        publicKey: publicKey,
        modules: finalModules,
        userData: userData,
        sessionId: sessionId,
        environment: environment
      )

      DispatchQueue.main.async {
        CreditChekApproval.start(config: config) { sessionResult in
          switch sessionResult {
          case .success(let sessionId):
            result([
              "status": "success",
              "sessionId": sessionId,
              "message": "Verification completed successfully"
            ])
          case .cancelled:
            result([
              "status": "cancelled"
            ])
          case .error(let code, let message):
            result([
              "status": "error",
              "code": code,
              "message": message
            ])
          }
        }
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
