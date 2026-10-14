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

      guard let publicKey = args["publicKey"] as? String,
            !publicKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        result(FlutterError(code: "INVALID_CONFIG", message: "publicKey is required", details: nil))
        return
      }

      guard let sessionId = args["sessionId"] as? String,
            !sessionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        result(FlutterError(code: "INVALID_CONFIG", message: "sessionId is required", details: nil))
        return
      }

      guard let widgetId = args["widgetId"] as? String,
            !widgetId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        result(FlutterError(code: "INVALID_CONFIG", message: "widgetId is required", details: nil))
        return
      }

      // Parse user data if present
      var userData: AUserData? = nil
      if let userDict = args["userData"] as? [String: Any] {
        let firstName = (userDict["firstName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = (userDict["lastName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bvn = (userDict["bvn"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nin = (userDict["nin"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = (userDict["email"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let dob = ((userDict["dob"] as? String) ?? (userDict["dateOfBirth"] as? String))?.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = (userDict["phone"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)

        let hasData = !firstName.isEmpty || !lastName.isEmpty || !bvn.isEmpty || !nin.isEmpty ||
          !email.isEmpty || !(dob?.isEmpty ?? true) || !(phone?.isEmpty ?? true)

        if hasData {
          userData = AUserData(
            firstName: firstName,
            lastName: lastName,
            bvn: bvn,
            nin: nin,
            email: email,
            dateOfBirth: dob,
            phone: phone
          )
        }
      }

      let config = ApprovalConfig(
        publicKey: publicKey.trimmingCharacters(in: .whitespacesAndNewlines),
        sessionId: sessionId.trimmingCharacters(in: .whitespacesAndNewlines),
        widgetId: widgetId.trimmingCharacters(in: .whitespacesAndNewlines),
        userData: userData
      )

      DispatchQueue.main.async {
        CreditChekApproval.start(config: config) { sessionResult in
          switch sessionResult {
          case .success(let sessionId, let message):
            result([
              "status": "success",
              "sessionId": sessionId,
              "message": message
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
