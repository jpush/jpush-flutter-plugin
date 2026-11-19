[![QQ Group](https://img.shields.io/badge/QQ%20Group-862401307-red.svg)]()
# JPush Flutter Plugin
> flutter 3.0 请切换至 dev-3.x 分支。

### iOS 延迟创建 Flutter 引擎（3.6.2）

手动 Scene 窗口、active 后才创建 Flutter 引擎的宿主，需先保存原始通知响应，再在同一引擎插件注册完成后、展示 Flutter 页面前同步交接。通用 Swift/Dart 示例、安装步骤、Scene 配置及接口调用说明见 [延迟引擎接入示例](https://github.com/jpush/jpush-flutter-plugin/tree/dev-3.x/example/delayed_engine_handoff)。该新增原生入口自 3.6.2 提供；原生 SDK 依赖不变。现有 Dart `getLaunchAppNotification()` 和 `onOpenNotification` 逻辑保持不变，本次接入只需使用新插件并在 SceneDelegate 交接通知。

### 安装

在工程 pubspec.yaml 中加入 dependencies：

```
  
//github  集成
dependencies:
  jpush_flutter:
    git:
      url: git://github.com/jpush/jpush-flutter-plugin.git
      ref: dev-3.x
      
// pub 集成
dependencies:
  jpush_flutter: 3.6.4
```

### 配置

##### Android:

在 `/android/app/build.gradle` 中添加下列代码：

```groovy
android: {
  ....
  defaultConfig {
    applicationId "替换成自己应用 ID"
    ...
    manifestPlaceholders = [
        JPUSH_PKGNAME : applicationId,
        JPUSH_APPKEY : "appkey", // NOTE: JPush 上注册的包名对应的 Appkey.
        JPUSH_CHANNEL : "developer-default", //暂时填写默认值即可.
    ]
  }    
```

#### 通知点击与 Flutter 路由

Flutter 3.27 起默认开启深链接。华为通知通过极光 SDK 拉起原生目标页或首页时，目标 Intent 的 `data` 和 `JMessageExtra` 可能携带相同的推送 JSON；Flutter 把 JSON 作为路由交给 GetX 等路由框架后，可能出现 `FormatException`、黑屏或白屏。版本边界见 [Flutter 官方说明](https://docs.flutter.dev/release/breaking-changes/deep-links-flag-change)。

jpush_flutter 3.6.3 起提供以下自动适配：

- 初始化 Provider 随插件 Manifest 合并，在标准 Flutter 宿主选择初始路由前处理冷启动 Intent；插件的新 Intent 监听处理热启动。
- 仅处理存在 `JMessageExtra` 字段、且 `data` 去除首尾空白后以 `{` 开头的通知数据；不校验消息 ID、标题等业务字段，也不要求两处内容完全相同。`JMessageExtra` 原值保持不变，只移除用于自动路由解析的 JSON `data`。
- 正常业务 URI 保留，Flutter 全局深链接开关保持原有配置；通知点击继续走 `onOpenNotification`，不会因过滤再产生一次点击事件。
- 自行在宿主读取推送数据时，请使用 `intent.getStringExtra("JMessageExtra")`。仅有 data、缺少此标记或无法识别的载荷不自动修改。

**标准 FlutterActivity 接入时，客户无需修改 MainActivity，插件会自动处理冷启动和热启动。**

##### 可选：自定义宿主

以下方法供特殊宿主复用，不是标准接入的必填配置。自定义宿主可在 `shouldHandleDeeplinking()` 中决定是否处理；热启动先更新宿主 Intent，确保判断读取本次传入的数据：

```kotlin
import android.content.Intent
import com.jiguang.jpush.JPushNotificationIntent
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun shouldHandleDeeplinking(): Boolean {
        if (JPushNotificationIntent.isJPushNotificationData(intent)) {
            return false
        }
        return super.shouldHandleDeeplinking()
    }

    override fun onNewIntent(intent: Intent) {
        setIntent(intent)
        super.onNewIntent(intent)
    }
}
```

Provider 默认在声明所在进程运行。独立进程、自定义 embedding 或宿主在标准生命周期之前自行选择路由的场景，需要单独验证，必要时采用上述宿主判断方式。

Android 的 SDK 依赖仓库需包含极光 Maven 地址，插件和 Demo 已添加。宿主若在 `settings.gradle` 中集中管理依赖仓库，也请在 `dependencyResolutionManagement.repositories` 添加：

```groovy
maven { url 'https://maven.jiguang.cn/nexus/content/repositories/releases/' }
```

保留项目其它依赖需要的 `google()`、`mavenCentral()` 等仓库。

##### iOS:

- 使用 UIScene 生命周期时，`jpush_flutter 3.6.1` 起支持从 Scene 连接通知读取冷启动参数，`getLaunchAppNotification()` 的 `extras` 格式不变。宿主仍需按 [Flutter 官方迁移说明](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate) 接入 `FlutterSceneDelegate`，或正确转发 Scene 生命周期，并在实际引擎初始化点注册插件。
- 插件继续支持旧 Flutter / AppDelegate 路径。Scene API 使用编译期可用性判断，最低 Flutter 要求不变；仅更换插件不能自动迁移宿主。
- 同一次点击经 Scene 与通知中心重复投递时，插件在相邻跨入口的 5 秒窗口内合并处理，避免重复点击回调和统计；不会按消息 ID 永久屏蔽后续点击。


- 在 xcode8 之后需要点开推送选项： TARGETS -> Capabilities -> Push Notification 设为 on 状态

如需使用 no-IDFA 版本，请使用 `jpush_flutter 3.5.5` 或更高版本，并在 Flutter 工程的
`ios/Podfile` 中显式指定 JCore：

```ruby
target 'Runner' do
  pod 'JCore', '5.6.0-noidfa'
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```


##### Harmony:

- 按 [Flutter 鸿蒙集成指南](./README_Harmony.md)完成平台配置，并先在 Flutter 工程根目录使用鸿蒙版 Flutter 执行完整构建，再使用 DevEco Studio 编译或运行 `ohos` 工程。

### 使用

```dart
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';

final JPushFlutterInterface jpush = JPush.newJPush();
```

### APIs

**注意** : 需要先调用 JPush.setup 来初始化插件，才能保证其他功能正常工作。

 [参考](./documents/APIs.md)


### 3.6.0 原生版本与新增接口

| 平台 | JPush | JCore | 新增或补齐接口 |
| --- | --- | --- | --- |
| Android | 6.3.1 | 显式声明 5.6.0 | requestSubscribeChannels、turnOffPush、turnOnPush、turnOnPushWithResult、initCrashHandler、stopCrashHandler |
| iOS CocoaPods | 6.3.0 | 保留 >5.5.0；建议宿主明确选择 5.6.0 或 5.6.0-noidfa | setLiveActivityTokenReportEnabled |
| iOS SPM | exact 6.3.0 | from 5.6.0（标准版） | 同上 |
| HarmonyOS | @jg/push 1.5.0 | 无独立依赖 | 保持既有接口，通知覆盖/撤回由原生 SDK 处理 |

依赖声明范围不等于宿主最终解析版本，请核对 Gradle、Podfile.lock、Package.resolved 和 OHPM 锁文件。平台专有新增方法在其他平台抛出 UnsupportedError。最低平台与工具约束保持原设置。

Android 新订阅接口必须由前台 Activity 调用且已完成 SDK/厂商注册。Future 完成仅代表发起，授权结果由 `onCommandResult` 的 `cmd=2013` 返回。旧单数接口保留原来的 `cmd=2012` 格式；迁移详见 [API 文档](documents/APIs.md#requestsubscribechannels)。

崩溃采集仅在业务显式调用 `initCrashHandler` 后开启。iOS 诊断开关不影响 Live Activity Token 的绑定或解绑，且本地关闭不覆盖服务端开启状态。
