[![QQ Group](https://img.shields.io/badge/QQ%20Group-862401307-red.svg)]()
# JPush Flutter Plugin
> flutter 3.0 请切换至 dev-3.x 分支。
### 安装

在工程 pubspec.yaml 中加入 dependencies

```
  
//github  集成
dependencies:
  jpush_flutter:
    git:
      url: git://github.com/jpush/jpush-flutter-plugin.git
      ref: dev-3.x
      
// pub 集成
dependencies:
  jpush_flutter: 3.6.0
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

**注意（Flutter 3.29+ 厂商通道点击白屏问题）**：Flutter 3.29 起 `FlutterActivity` 默认开启深链接（`flutter_deeplinking_enabled` 默认值变为 true）。App 进程被杀后点击厂商通道（如华为）离线推送时，拉起应用的 intent 携带的 URI（含 `n_extra` 参数）会被 Flutter 当作深链接路由解析，路由表中无对应页面导致打开后白屏。若未使用 Flutter 官方深链接功能，请在 `AndroidManifest.xml` 的主 Activity 中显式关闭：

方式一（推荐）：在 `MainActivity` 中重写 `shouldHandleDeeplinking()`：

```kotlin
class MainActivity : FlutterActivity() {
    // 禁用 Flutter 自动 deep link 处理，避免厂商通道推送点击时
    // intent.data 被误当成 Flutter 路由导致打开 App 白屏
    override fun shouldHandleDeeplinking(): Boolean {
        return false
    }
}
```

方式二：在 `AndroidManifest.xml` 的主 Activity 中配置（与方式一等价，`shouldHandleDeeplinking()` 默认实现读取的就是该配置）：

```xml
<activity android:name=".MainActivity" ...>
    <meta-data
        android:name="flutter_deeplinking_enabled"
        android:value="false" />
</activity>
```

##### iOS:

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

- [Harmony](./README_Harmony.md)

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
| Android | 6.3.0 | 显式声明 5.6.0 | requestSubscribeChannels、turnOffPush、turnOnPush、turnOnPushWithResult、initCrashHandler、stopCrashHandler |
| iOS CocoaPods | 6.3.0 | 保留 >5.5.0；建议宿主明确选择 5.6.0 或 5.6.0-noidfa | setLiveActivityTokenReportEnabled |
| iOS SPM | exact 6.3.0 | from 5.6.0（标准版） | 同上 |
| HarmonyOS | @jg/push 1.5.0 | 无独立依赖 | 保持既有接口，通知覆盖/撤回由原生 SDK 处理 |

依赖声明范围不等于宿主最终解析版本，请核对 Gradle、Podfile.lock、Package.resolved 和 OHPM 锁文件。平台专有新增方法在其他平台抛出 UnsupportedError。最低平台与工具约束保持原设置。

Android 新订阅接口必须由前台 Activity 调用且已完成 SDK/厂商注册。Future 完成仅代表发起，授权结果由 `onCommandResult` 的 `cmd=2013` 返回。旧单数接口保留原来的 `cmd=2012` 格式；迁移详见 [API 文档](documents/APIs.md#requestsubscribechannels)。

崩溃采集仅在业务显式调用 `initCrashHandler` 后开启。iOS 诊断开关不影响 Live Activity Token 的绑定或解绑，且本地关闭不覆盖服务端开启状态。
