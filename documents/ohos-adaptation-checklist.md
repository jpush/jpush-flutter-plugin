# jpush_google_flutter 鸿蒙适配改动清单

对比基线：`origin/dev-3.x`（国内版 jpush_flutter 3.5.0，已支持鸿蒙） vs `origin/dev-3.x-google`（Google 版 jpush_google_flutter 3.0.6-dev）。

以下为国内版鸿蒙适配的完整文件清单，即本次需移植到 Google 版的范围（已剔除与鸿蒙无关的分支差异，如 update-sdk skill、Android 原生升级、iOS SPM 等）。

## 一、插件本体

### 1. ohos 原生插件模块（整目录移植，两版可完全复用）

鸿蒙端基于 jpush-hmos 原生 SDK（ohpm 包 `@jg/push` 1.4.0），与 Android 端 `jpush` / `jpush-google` 制品差异无关：

- `ohos/.gitignore`
- `ohos/build-profile.json5`
- `ohos/hvigorfile.ts`
- `ohos/index.ets`
- `ohos/oh-package.json5`（依赖 `@jg/push: 1.4.0` + `@ohos/flutter_ohos`；`name` 字段需与插件包名一致，移植时改为 `jpush_google_flutter`）
- `ohos/src/main/module.json5`
- `ohos/src/main/ets/components/plugin/JpushHarmonySdkPlugin.ets`（642 行，MethodChannel 名为 `"jpush"`）
- `ohos/src/main/ets/components/plugin/JpushHelper.ets`
- `ohos/src/main/ets/components/plugin/JLog.ets`
- `ohos/src/main/ets/components/plugin/config/FlutterBase.ets`
- `ohos/src/main/ets/components/plugin/config/FlutterConfig.ets`

### 2. Dart 层（需适配包名后移植）

国内版将 Dart 层重构为「统一接口 + 平台双实现」：

- `lib/jpush_interface.dart` —— 抽象类 `JPushFlutterInterface`（446 行），所有方法带默认「not implemented」空实现，**平台差异接口的降级由此机制天然完成**
- `lib/android_ios/jpush_flutter_a_i.dart` —— `JPush_A_I extends JPushFlutterInterface`，即原单文件实现改名（Google 版对应 `lib/jpush_google_flutter.dart` 现有内容）
- `lib/harmony/jpush_harmony_sdk.dart` —— `JpushHarmonySdk extends JPushFlutterInterface`
- `lib/harmony/jpush_harmony_sdk_imp.dart`
- `lib/harmony/jpush_harmony_sdk_method_channel.dart`（MethodChannel 同名 `'jpush'`，但方法名与 Android/iOS 不同：`init`/`setAppKey`/`setChannel`…，必须按平台路由）
- `lib/harmony/jpush_harmony_sdk_platform_interface.dart`
- `lib/jpush_flutter.dart` —— 入口：`JPush.newJPush()` 按 `Platform.isAndroid/isIOS` 返回 `JPush_A_I`，否则返回 `JpushHarmonySdk`
- 注意：国内版 import 均为 `package:jpush_flutter/...`，移植时需改为 `package:jpush_google_flutter/...`

### 3. pubspec.yaml

`flutter.plugin.platforms` 增加：

```yaml
ohos:
  package: com.jiguang.jpush
  pluginClass: JpushHarmonySdkPlugin
```

同时 `dependencies` 增加 `plugin_platform_interface: ^2.0.2`；description 更新为含 HarmonyOS。

### 4. 文档

- `README_Harmony.md`（422 行，鸿蒙集成文档，整篇移植，包名替换）
- `README.md` 增加鸿蒙说明入口
- `CHANGELOG.md` 增加鸿蒙支持条目

## 二、example 工程

- `example/ohos/` 整目录（AppScope、entry 模块、EntryAbility/PushMessageAbility/RemoteNotificationExtAbility、GeneratedPluginRegistrant.ets、hvigor 配置等，共 30+ 文件）
- `example/oh-package.json5` 中 `jpush_flutter` 依赖名需替换为 `jpush_google_flutter`
- `example/lib/main.dart` 同步国内版写法（`JPush.newJPush()` 返回接口实例）
- `example/pubspec.yaml` 同步

## 三、API 兼容性说明（重要）

国内版 3.5.0 的入口从 `JPush()`（工厂单例）改为 `JPush.newJPush()`（返回 `JPushFlutterInterface`），属 **breaking change**。Google 版移植时保持与国内版一致的结构（便于后续同步维护），并在 CHANGELOG/README 中明确标注迁移方式：

- 旧：`final JPush jpush = JPush();`
- 新：`final JPushFlutterInterface jpush = JPush.newJPush();`

方法签名本身不变，业务调用代码无需改动。

## 四、鸿蒙端降级行为

Android-Only / iOS-Only 接口（如 `requestSubscribeChannel`、`onVoipMessage`、`setCollectControl` 等）在鸿蒙端未覆写时走 `JPushFlutterInterface` 默认实现：打印 `"| JPUSH | Flutter | error | xxx:has not been implemented."` 的安全 no-op，不会崩溃。
