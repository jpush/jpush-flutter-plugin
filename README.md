# JPush Google Flutter Plugin

极光 Google Play 推送 Flutter 插件，支持 Android 和 iOS。Flutter 2.x 请使用对应旧维护分支。

## 安装与版本

```yaml
dependencies:
  jpush_google_flutter: 3.0.8
```

源码集成使用 `https://github.com/jpush/jpush-flutter-plugin.git` 的 `dev-3.x-google` 分支。
Android 仅声明 JPush Google 6.3.1，由其 POM 传递解析 JCore Google，最低 Android 5.0（API 21）。
JCore 实际版本受 POM 范围、宿主约束/force、锁文件、仓库元数据与 Gradle 缓存影响，
不保证每次构建都获取最新发布版本。
旧版插件曾声明 minSdk 19，但所用 JPush Google 6.2.0 已要求 API 21；本版对齐声明。
iOS 依赖保持不变；Swift Package Manager 需 Flutter 3.24+ 并启用 SPM，CocoaPods 集成继续支持。

## Android Maven 仓库

从 JPush Android 6.3.1 起请加入极光官方 SDK 仓库，依赖坐标不变，无需下载账号：

`https://maven.jiguang.cn/nexus/content/repositories/releases/`

极光源仅配置仓库地址，不限制模块或版本类型，放在 Maven Central 前；保留 Google 与
Central 解析其它依赖。插件不再通过 `rootProject.allprojects` 给宿主其它项目注入仓库。

### settings 集中管理（推荐）

若宿主使用 `PREFER_SETTINGS` 或 `FAIL_ON_PROJECT_REPOS`，插件不会声明项目级仓库。
必须在宿主**已有** `dependencyResolutionManagement.repositories` 中加入源，不要重复创建
配置块，也不要改宿主现有 repositoriesMode。以下同时适用于 `settings.gradle`（Groovy）
和 `settings.gradle.kts`（Kotlin）：

```groovy
dependencyResolutionManagement {
    // 保留工程现有 repositoriesMode 配置。
    repositories {
        maven {
            name = "JiguangReleases"
            url = uri("https://maven.jiguang.cn/nexus/content/repositories/releases/")
        }
        google()
        mavenCentral()
        // 保留其它必要仓库，检查是否有更早仓库解析相同坐标。
    }
}
```

### 旧式工程 / PREFER_PROJECT

插件只在自身项目的依赖仓库中加入并优先使用极光源，保留 Google/Central。
宿主其它模块若直接依赖 SDK，可在其现有 `allprojects.repositories` 中加入与上例
`repositories` 内相同的配置。Groovy/Kotlin 均可使用上述方法调用写法。
不要在 `FAIL_ON_PROJECT_REPOS` 工程中添加 allprojects/project repositories；它会报错。
SDK 源不是 Gradle 插件源，只添加到 `buildscript.repositories` 或 `pluginManagement`
不能保证 SDK 下载生效。

仓库模式读取兼容说明：当前构建脚本通过 Gradle 的 `settings` 对象读取公开
`repositoriesMode`。该对象访问不属于公共 `Gradle` Java 接口，存在工具版本兼容边界；
访问不可用时明确报错，不静默修改模式或忽略源。沿用现有 AGP 8.6.0 / Gradle 8.7 wrapper
要求，不因本版无声提高工具链版本。集中配置不能由插件自动写入宿主 settings 文件。

Central 保留为后续候选，不代表超时、TLS、5xx 或选定元数据来源后的 AAR 缺失会自动切源。
遇到源故障请保留错误并核网络/配置；临时切源时确认精确坐标和产物，不关闭 TLS 校验。
插件不显式声明或严格锁定 JCore；宿主存在版本约束时，请检查实际依赖图和所选 SDK 组合。

## Android 配置

在应用 `android/app/build.gradle` 配置自己的应用信息：

```groovy
android {
    defaultConfig {
        minSdk = 21
        manifestPlaceholders = [
            JPUSH_PKGNAME: applicationId,
            JPUSH_APPKEY: "替换成自己的 AppKey",
            JPUSH_CHANNEL: "developer-default"
        ]
    }
}
```

SDK 核心组件随 AAR Manifest 自动合并。FCM/应用后台及自定义 Receiver/Service 仍需符合
[官方 Android 集成指南](https://docs.jiguang.cn/jpush/client/Android/android_guide) 和应用实际配置。

## 正式国家码（Android Only）

```dart
import 'dart:io' show Platform;
import 'package:jpush_google_flutter/jpush_google_flutter.dart';

// 在用户同意隐私、满足 SDK 授权条件后执行，而非无条件在启动时调用。
final jpush = JPush();
jpush.setAuth(enable: true);
if (Platform.isAndroid) {
  await jpush.setCountryCode('us'); // 去首尾空格，提交大写 US。
}
jpush.setup(appKey: '替换成自己的 AppKey', channel: 'developer-default');
```

`setCountryCode` 复用 Android SDK 的正式持久化接口，不依赖每次创建 FlutterEngine 重设。
参数必须为两个 ASCII 字母（格式校验不代表服务端支持该国家码）；非法输入抛出
`ArgumentError`，非 Android 抛出 `UnsupportedError`；原生参数错误为 `INVALID_ARGUMENT`，
缺少引擎上下文为 `NOT_ATTACHED`，同步 SDK 异常为 `NATIVE_ERROR`。

**Future 成功只表示向原生接口提交了调用**，不确认授权/IPC/磁盘持久化/首次登录/服务端生效。
`setAuth` 等调用可能提前初始化；以上调用顺序和 await 不构成首次登录前的屏障。
“返回后立即杀进程仍可靠”需要 SDK 的真实完成确认能力，本接口不提供此保证。

旧 `testCountryCode` 保持临时测试接口语义，已标记废弃；迁移后停止混用，因为测试值可能
优先覆盖正式值。验证需区分首次安装、保存后重启/主子进程恢复、FCM 无 Activity/Engine
唤起及清数据；清数据不保证保留国家码。消息验收还须核服务端实际字段、FCM 选路和收发。

## iOS 与其它 API

iOS 在 Xcode 的 Signing & Capabilities 启用 Push Notifications，并按应用需要申请通知权限。
国家码接口不支持 iOS；其它 API 见 [接口文档](documents/APIs.md)。
事件监听可在 setup 前注册，正式国家码按上述隐私/授权约束尽早提交，其它业务操作按 SDK
初始化要求执行。示例的同意按钮仅演示调用时机，业务应用必须接入自己的真实隐私政策流程。

## 本地验证

```sh
flutter pub get
flutter test
flutter analyze
flutter pub publish --dry-run
# 在配置好 Android SDK / JDK 及 Flutter 的环境运行示例 Gradle 测试：
cd example/android
./gradlew :jpush_google_flutter:testDebugUnitTest
```

仓库策略回归：`python3 test/gradle/repositories_test.py --gradle <Gradle 可执行文件> --work-dir <隔离目录>`。
它使用独立依赖缓存和真实 SDK 下载验证三种模式及内容过滤；无设备测试不能代替 FCM 真机验收。
