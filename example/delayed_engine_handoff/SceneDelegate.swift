import Flutter
import UIKit
import UserNotifications
import jpush_flutter

// 通用单 Scene 示例：先展示原生页面，在 active 后才创建 Flutter 隐式引擎。
class SceneDelegate: FlutterSceneDelegate {
    private var launchResponse: UNNotificationResponse?
    private var flutterPage: FlutterViewController?
    private var attachmentQueued = false
    private var attached = false

    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                        options connectionOptions: UIScene.ConnectionOptions) {
        // 引擎尚未创建，先保存系统完整响应，避免丢失通知 action 等上下文。
        launchResponse = connectionOptions.notificationResponse
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let waiting = UIViewController()
        waiting.view.backgroundColor = .systemBackground
        window.rootViewController = waiting
        self.window = window
        window.makeKeyAndVisible()
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)
        attachFlutter(to: scene)
    }

    private func attachFlutter(to scene: UIScene) {
        guard !attached, !attachmentQueued else { return }
        attachmentQueued = true
        DispatchQueue.main.async { [weak self, weak scene] in
            guard let self = self else { return }
            defer { self.attachmentQueued = false }
            guard let scene = scene, scene.activationState == .foregroundActive,
                  let window = self.window, !self.attached else { return }
            if self.flutterPage == nil {
                self.flutterPage = FlutterViewController(project: nil, nibName: nil, bundle: nil)
            }
            guard let page = self.flutterPage else { return }
            if let response = self.launchResponse {
                // 新接口：在插件注册后、Dart 启动前同步交接。
                // registry 使用即将挂载的 page，确保缓存属于同一个引擎。
                // 此前不要访问 page.view / loadViewIfNeeded，也不要重放 super.willConnect。
                let accepted = JPushPlugin.acceptSceneLaunchNotification(response, registry: page)
                guard accepted else {
                    // false 未接收：保留响应和控制器，显示错误，排查插件版本/注册后重试。
                    self.presentRetry()
                    return
                }
                // true 已同步写入启动缓存；此时才清理宿主缓存并允许挂载。
                self.launchResponse = nil
            }
            self.attached = true
            window.rootViewController = page
        }
    }

    private func presentRetry() {
        let page = UIViewController()
        page.view.backgroundColor = .systemBackground
        let button = UIButton(type: .system)
        button.setTitle("Notification handoff failed. Retry", for: .normal)
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        page.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: page.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: page.view.centerYAnchor)
        ])
        window?.rootViewController = page
    }

    @objc private func retry() {
        guard let scene = window?.windowScene else { return }
        attachFlutter(to: scene)
    }
}
