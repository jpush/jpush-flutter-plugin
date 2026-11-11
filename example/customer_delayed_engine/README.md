# 保留延迟引擎的完整 iOS 接入示例

通知先到时，SceneDelegate 先保存原始响应；Flutter 控制器延迟创建好后，在展示页面前同步交给 JPush 插件。插件立即存好启动参数，Dart 就能读取；点击事件等监听就绪后回放。不要增加 Main storyboard，也不要再次调用整个 super.willConnect。

适用：单 Scene，Flutter 3.47.5 的隐式引擎接入，基于 3.6.1 的本地未发布补丁。文件均为脱敏完整类；不是已发布 3.6.1 的原有能力。AppDelegate 的业务通道和配置仍归客户保留。

## 安装

1. 将交付的插件源包解压到工程可访问的目录，例如 `vendor/jpush_flutter`，不要直接覆盖 pub 缓存。宿主 pubspec.yaml 使用：

   ```yaml
   dependencies:
     jpush_flutter:
       path: vendor/jpush_flutter
   ```

   路径相对宿主 pubspec.yaml，按解压位置调整。执行 `flutter pub get`。如使用 CocoaPods，再在宿主 `ios/` 执行 `pod install`，用 Runner.xcworkspace 打开。SPM 宿主使用既有 Flutter/SPM 流程重新解析，不修改官方依赖版本。
2. 将本目录完整 `SceneDelegate.swift` 合入 Runner target，替换当前同名类，保留客户需要的占位页视觉。不要同时保留两个 SceneDelegate。它继续在 active 后异步创建引擎；ATT 保留，但在延迟执行前再次核对 Scene active。主队列 async 不保证首帧/原崩溃条件已消失，原稳定性仍需客户验证。
3. 客户原 AppDelegate 已正确实现 FlutterImplicitEngineDelegate：**保持原文件与业务注册**。本目录的 AppDelegate.swift 是最小完整宿主供新工程验证，现有工程无需替换它；不要因替换示例丢失原业务通道。
4. `SceneManifest.plist` 仅为需要合并的 Scene 配置片段，不是完整 Info.plist。客户原配置已经一致，无需增加 UISceneStoryboardFile/Main，也不添加 UIMainStoryboardFile。保留 LaunchScreen、原权限用途说明、APNs entitlement 及业务配置。ATT 用途说明应采用客户真实用途，不使用虚构文案。
5. Swift 使用 `import jpush_flutter`。如现有工程不启用 Swift 模块导入，可在既有 Runner-Bridging-Header.h 增加 `#import <jpush_flutter/JPushPlugin.h>`，并移除该 Swift import；不要替换 GeneratedPluginRegistrant.h 的原导入。

## Dart 侧时序

`main.dart` 是可独立运行的完整参数读取示例，可复制到验证宿主的 lib/main.dart；不含 AppKey，不主动调用 setup，不发送推送。客户工程保留原业务主入口，将相同的监听/读取逻辑合入原启动流程即可。

保持现有 Dart API。在业务启动阶段先注册 `onOpenNotification`，再按原隐私/初始化流程调用 `setup`（不为补通知重复 setup）。启动参数是插件本地缓存，可以在 setup 前读取；原生远程处理会等待 setup。监听晚到时插件也会缓存点击事件；读取启动参数和接收点击回调可能指向同一业务行为，业务跳转需沿现有策略择一消费，不能两边无条件跳转。

原生交接必须发生在 Dart 启动之前：本例在构造 FlutterViewController 后、设置 root 前调用。不得在这两步之间访问 controller.view/loadViewIfNeeded；不要放到 Dart ready 后再写启动缓存，也不要重复创建引擎。

## 失败与去重

原生接口 true 表示该引擎的插件已接收，不表示 APNs/远端统计成功；false 时仍保留响应、同一个控制器和占位错误页。先排查插件源包是否生效、GeneratedPluginRegistrant 是否注册 JPushPlugin，勿静默进入 Flutter。点击重试复用同一控制器，不自动轮询。

初始 Scene/manual/UN 响应按通知 identifier、投递 date、action 和文本输入上下文关联，不依赖 5 秒计时。手动重复交接幂等；进入后台结束本次跨入口配对，后续同通知合法点击继续处理。该接口只接收同一引擎的一份初始启动响应，不用于把前台每次通知都注入启动缓存。若初始关联前累计超过 32 个 UN 响应，或已经结束初始连接，接口返回 false，不猜测来源；不能在这些条件下循环重试解决。

SDK setup 前，启动参数和 Dart 点击事件可以缓存，原生远程处理暂存至 setup 调用结束再处理。它不承诺原生 SDK 的 APNs/统计已验收。不要用原生 handleRemoteNotification 或重复 setup 替代交接。

## 客户验收

在原延迟策略下分别验证：真实 APNs 杀进程点击冷启动，立即及延迟 20 秒读取都有 extras；普通图标启动为空；监听前后点击事件一次；Scene/UN 不同顺序与大于 5 秒交接不重复；后台后同通知合法点击、不同 action/不同投递正常；没有第二引擎；原 URL、业务通道和 ATT 正常。真实服务端点击统计单独核对。模拟器或本地通知通过不能替代这些验收。

回滚：恢复原依赖/锁文件与原 SceneDelegate，重新解析构建；会恢复原延迟引擎下的通知参数缺口。未发布补丁未变更插件或原生 SDK 的版本号。
