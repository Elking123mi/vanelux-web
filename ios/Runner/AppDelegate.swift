import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.vanelux/config",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      guard call.method == "getOpenAiKey" else {
        result(FlutterMethodNotImplemented)
        return
      }

      let arguments = call.arguments as? [String: Any]
      let persona = (arguments?["persona"] as? String) ?? "client"

      let env = ProcessInfo.processInfo.environment
      let clientKey = env["OPENAI_API_KEY_CLIENT"] ?? Bundle.main.string(forKey: "OpenAIClientKey")
      let driverKey = env["OPENAI_API_KEY_DRIVER"] ?? Bundle.main.string(forKey: "OpenAIDriverKey")

      let selectedKey = persona == "driver" ? driverKey : clientKey

      guard let apiKey = selectedKey, !apiKey.isEmpty else {
        result(FlutterError(code: "NO_KEY", message: "OpenAI API key not configured for \(persona)", details: nil))
        return
      }

      result(apiKey)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
