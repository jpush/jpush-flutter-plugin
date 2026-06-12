# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

jpush_flutter：极光推送（JPush）官方 Flutter 插件，支持 Android、iOS、HarmonyOS（ohos）三端。当前为 dev-3.x 分支（Flutter 3.0+）。

## 常用命令

```bash
flutter pub get                # 安装依赖
flutter analyze                # 静态分析

# 运行示例 App（验证插件改动的主要方式，没有单元测试目录）
cd example && flutter pub get && flutter run
```

## 架构

### 入口与平台分发

用户通过工厂方法获取统一接口（README 中的标准用法）：

```dart
final JPushFlutterInterface jpush = JPush.newJPush();
```

- `lib/jpush_flutter.dart` — `JPush.newJPush()` 按 `Platform` 分发：Android/iOS 返回 `JPush_A_I`，其余（鸿蒙）返回 `JpushHarmonySdk`
- `lib/jpush_interface.dart` — 抽象基类 `JPushFlutterInterface`，定义全部对外 API。每个方法都有默认的 "has not been implemented" 兜底实现（不是抽象方法），新增 API 必须先在这里加默认实现，再到各端实现类覆盖。该文件还包含 `LocalNotification`、`NotificationSettingsIOS` 等数据类
- `lib/android_ios/jpush_flutter_a_i.dart` — Android 与 iOS 共用同一个实现类 `JPush_A_I` 和同一个 `MethodChannel('jpush')`
- `lib/harmony/` — 鸿蒙端采用标准 federated plugin 模式（`platform_interface` / `method_channel` / `imp`），channel 名同为 `'jpush'`

### Native 层

| 平台 | 入口 | SDK 版本引用位置 |
|------|------|------------------|
| Android | `android/src/main/java/com/jiguang/jpush/JPushPlugin.java` | `android/build.gradle`（`cn.jiguang.sdk:jpush`） |
| iOS | `ios/Classes/JPushPlugin.m` | `ios/jpush_flutter.podspec`（`JPush`、`JCore`） |
| 鸿蒙 | `ohos/src/main/ets/components/plugin/JpushHarmonySdkPlugin.ets` | `ohos/oh-package.json5`（`@jg/push`） |

Android 端事件回调经 `JPushHelper`（单例，持有 MethodChannel）转发到 Dart；插件支持多 engine 场景，attach/detach 时通过 bindingId 匹配判断是否清理。

### 新增一个 API 的完整链路

1. `lib/jpush_interface.dart` 加默认方法
2. `lib/android_ios/jpush_flutter_a_i.dart`（和/或 `lib/harmony/` 三层）覆盖实现，走 MethodChannel
3. Android `JPushPlugin.java` 的 `onMethodCall` / iOS `JPushPlugin.m` 的 `handleMethodCall` 加分支
4. `example/lib/main.dart` 加示例调用
5. `documents/APIs.md` 补充文档

跨平台原则：Android 和 iOS 功能相同的原生方法合并为同一个 Dart API；确认另一端无等价实现时才标注 Android Only / iOS Only（用注释和方法名后缀标识，如 `isPushStoppedAndroid`）。

## 发布流程（SDK 版本升级）

优先使用 `/update-sdk` skill（`.claude/skills/update-sdk/`），它自动化以下手动流程（也记录在 `cursor.md`）：

1. 更新 `ios/jpush_flutter.podspec` 中 JPush / JCore 版本
2. 更新 `android/build.gradle` 中 JPush 版本
3. 封装原生新增方法（见上面的链路）
4. `pubspec.yaml` 插件版本号 +0.0.1
5. `README.md` 中的集成示例版本号同步为新版本
6. `CHANGELOG.md` 追加本次变更说明（中文）
