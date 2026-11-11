import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        // 隐式引擎创建时注册插件；交接接口从这个 registry 查找插件实例。
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
}
