import AppTrackingTransparency
import Flutter
import UIKit
import UserNotifications
import jpush_flutter

// 单 Scene 宿主；延迟创建引擎，交接成功后再替换原生占位页。
class SceneDelegate: FlutterSceneDelegate {
    private var hasRequestedATT = false
    private var hasSetupFlutter = false
    private var isMountScheduled = false
    private var pendingLaunchResponse: UNNotificationResponse?
    private var flutterController: FlutterViewController?

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let response = connectionOptions.notificationResponse {
            pendingLaunchResponse = response
        }
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = .white
        window.rootViewController = placeholder
        self.window = window
        window.makeKeyAndVisible()
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)
        mountFlutterIfNeeded(in: scene)
        requestATTIfNeeded()
    }

    // 报告并修正交接失败原因后，宿主可以再次调用。
    // 重试复用原控制器，避免创建第二个引擎。
    private func mountFlutterIfNeeded(in scene: UIScene) {
        guard !hasSetupFlutter, !isMountScheduled else { return }
        isMountScheduled = true
        DispatchQueue.main.async { [weak self, weak scene] in
            guard let self = self else { return }
            defer { self.isMountScheduled = false }
            guard let scene = scene,
                  scene.activationState == .foregroundActive,
                  !self.hasSetupFlutter,
                  let window = self.window else { return }

            let controller: FlutterViewController
            if let existing = self.flutterController {
                controller = existing
            } else {
                controller = FlutterViewController(project: nil, nibName: nil, bundle: nil)
                self.flutterController = controller
            }

            // 交接前不要访问 controller.view 或调用 loadViewIfNeeded。
            if let response = self.pendingLaunchResponse {
                guard JPushPlugin.acceptSceneLaunchNotification(
                    response, registry: controller
                ) else {
                    self.reportStartupFailure()
                    return
                }
                self.pendingLaunchResponse = nil
            }
            self.hasSetupFlutter = true
            window.rootViewController = controller
        }
    }

    private func reportStartupFailure() {
        NSLog("stage=scene_launch_handoff reason=not_accepted")
        // 保留通知和控制器，在原生页面提供重试入口。
        let failure = UIViewController()
        failure.view.backgroundColor = .white
        let button = UIButton(type: .system)
        button.setTitle("启动失败，点击重试", for: .normal)
        button.addTarget(self, action: #selector(retryFlutterStartup), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        failure.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: failure.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: failure.view.centerYAnchor)
        ])
        window?.rootViewController = failure
    }

    @objc private func retryFlutterStartup() {
        guard let scene = window?.windowScene else { return }
        mountFlutterIfNeeded(in: scene)
    }

    private func requestATTIfNeeded() {
        guard #available(iOS 14.0, *) else { return }
        guard !hasRequestedATT else { return }
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        hasRequestedATT = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            guard self.window?.windowScene?.activationState == .foregroundActive else {
                self.hasRequestedATT = false
                return
            }
            guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
            Task { @MainActor in
                let status = await ATTrackingManager.requestTrackingAuthorization()
                switch status {
                case .authorized:
                    NSLog("stage=att status=authorized")
                case .denied:
                    NSLog("stage=att status=denied")
                case .notDetermined:
                    self.hasRequestedATT = false
                    NSLog("stage=att status=not_determined")
                case .restricted:
                    NSLog("stage=att status=restricted")
                @unknown default:
                    self.hasRequestedATT = false
                }
            }
        }
    }
}
