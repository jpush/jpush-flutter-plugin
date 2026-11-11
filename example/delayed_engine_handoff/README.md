# 延迟启动 Flutter 的通知交接示例

独立、通用的单 Scene 示例：原生占位页面先显示，Scene active 后才创建 Flutter 隐式引擎。系统启动通知先到时，保存原始 UNNotificationResponse，在挂载页面前调用新增接口。示例无业务SDK、追踪请求、图片或业务通道。

## 使用

1. 宿主依赖包含本补丁的 jpush_flutter 源码（例如 pubspec.yaml 的 path: vendor/jpush_flutter），执行 flutter pub get；CocoaPods 宿主在 ios/ 执行 pod install。此入口自插件3.6.2提供，不属于3.6.1。
2. 将本目录 AppDelegate.swift、SceneDelegate.swift 加入一个支持 FlutterImplicitEngineDelegate / FlutterSceneDelegate 的 Swift Runner target；合并 SceneManifest.plist 片段，移除该配置的 UISceneStoryboardFile 及 UIMainStoryboardFile，保留 LaunchScreen。已有应用按相同位置合入，不覆盖自己的业务注册。
3. Swift 采用 import jpush_flutter。若宿主使用桥接头，改为在原桥接头加入 #import <jpush_flutter/JPushPlugin.h> 并移除该 import；保留 GeneratedPluginRegistrant.h。
4. main.dart 仅为可选的独立验证入口，不需替换实际应用代码。现有 getLaunchAppNotification / onOpenNotification 保持不变，本次接入只需新插件和原生 Scene 交接；保留原 setup、隐私流程及业务导航策略。演示不含凭据、不调用 setup。

## 接口时序

在主线程、控制器构造完成且插件注册后、首次访问控制器 view / 设置 root 前调用 JPushPlugin.acceptSceneLaunchNotification(response, registry: page)。registry 必须来自即将挂载的同一个引擎，不用全局单例寻找其他引擎。true 表示同步接收并写入启动缓存，此时才能清宿主响应并挂载；false 保留响应和控制器，显示错误、排查注册/版本再重试。不要重复创建引擎或重放整个 super.willConnect。

只用于同一引擎的一份初始通知，不要将前台每次点击注入启动缓存。初始Scene/UN/manual按identifier、投递date、action和输入文本关联；后台结束初始配对。初始UN来源超过32条或连接已结束会返回false，不能靠循环重试解决。原生远程处理等待setup；返回true不表示APNs或服务端统计成功。异步推迟构造不保证系统首帧完成或消除其他启动问题。

## 验证范围

本例使用现有Flutter3.47.9工具链编译；需要支持上述Scene/隐式引擎API的Flutter。真实通知验收应包括普通启动为空、点击冷启首次/延迟读取有extras、监听前后事件一次、后台存活点击一次、自然Scene/UN双入口去重及后续合法点击；真实APNs/点击统计单独验证。本地通知或模拟响应不能代替远端验收。SPM原生插件保持现有包配置，此示例的宿主构建仅验证CocoaPods，未额外完成SPM宿主构建。
