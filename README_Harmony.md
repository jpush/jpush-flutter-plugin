# Flutter 鸿蒙集成指南

## 首次集成与构建

### 1. 准备鸿蒙版 Flutter 工程

安装支持鸿蒙的 Flutter SDK 和配套的 DevEco Studio，参考[鸿蒙版 Flutter 环境搭建指导](https://gitee.com/openharmony-sig/flutter_samples/blob/master/ohos/docs/03_environment/%E9%B8%BF%E8%92%99%E7%89%88Flutter%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA%E6%8C%87%E5%AF%BC.md)。以下 `flutter` 命令均需使用鸿蒙版 Flutter SDK，在包含 `pubspec.yaml` 的 Flutter 工程根目录执行。

已有工程需包含 `ohos/` 目录；新工程可以执行：

```bash
flutter create --platforms=ohos jpush_harmony_demo
cd jpush_harmony_demo
```

### 2. 添加插件依赖

在应用的 `pubspec.yaml` 中添加，保留其他已有依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  jpush_flutter: 3.6.1
```

获取依赖：

```bash
flutter pub get
```

### 3. 完成平台配置和初始化

按下文完成[字节码编译配置](#配置字节码编译环境)、[鸿蒙平台和签名配置](#配置-hmos平台信息)、[通知跳转配置](#配置通知跳转页)以及[极光平台信息配置](#设置极光平台信息)。包名、签名、华为推送服务配置及极光 AppKey 需对应同一个应用。自定义消息、通知扩展消息或 VoIP 按需配置对应章节。

在 Dart 应用初始化时创建插件对象，先注册鸿蒙回调，再调用 `setup`，执行一次即可：

```dart
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';

final JPushFlutterInterface jpush = JPush.newJPush();

void initJPush() {
  jpush.setCallBackHarmony((eventName, data) {
    print('JPush: $eventName, $data');
  });

  jpush.setup(
    appKey: 'YOUR_APP_KEY',
    channel: 'developer-default',
    debug: true,
  );
}
```

在 Flutter 页面 `initState` 等初始化位置调用 `initJPush()`。更多接口和回调见 [API 文档](./documents/APIs.md)。

### 4. 先执行 Flutter 鸿蒙构建

完成上述配置后，在 Flutter 工程根目录执行：

```bash
flutter build hap --debug --no-codesign
```

该命令用于无需配置签名的编译检查；未配置签名时会生成未签名 HAP，用于检查 Dart、插件和鸿蒙原生工程能否一起编译。已配置签名的工程以构建实际产物为准。`flutter pub get` 只获取依赖，不能替代完整构建。鸿蒙版 Flutter 会在构建过程中处理插件模块、插件 HAR 及原生依赖；具体配置文件和中间产物随 Flutter 版本的构建流程而不同，以命令实际输出为准。

构建成功后，可使用 DevEco Studio 打开该工程的 `ohos/` 目录继续编译或调试，并沿用 Flutter 构建生成的依赖和模块配置。新增、升级插件或清理中间产物后，重新执行 Flutter 构建，更新对应的原生依赖。

### 5. 签名并运行到鸿蒙手机

未签名 HAP 不能直接安装到手机。先在 DevEco Studio 中配置该应用的签名，确保调试设备包含在调试签名配置中，然后连接手机、开启调试并完成授权。

在 Flutter 工程根目录查看设备并运行：

```bash
flutter devices
flutter run --debug -d <设备ID>
```

将 `<设备ID>` 替换为 `flutter devices` 列出的鸿蒙设备 ID。启动后检查插件初始化日志、`onConnected` 回调和 `getRegistrationID()` 返回值；通知点击等业务场景需在配置完成后单独验证。

### DevEco Studio 构建报 00309001 时的检查顺序

若错误指向插件内部的相对导入，例如 `JpushHelper.ets` 中的 `./JpushHarmonySdkPlugin`，先保留 `useNormalizedOHMUrl: true`，回到 Flutter 工程根目录执行第 4 步的完整构建，再使用 DevEco Studio 编译。

若完整构建后仍报错，检查实际使用的 Flutter 版本及原生依赖配置：

- 直接依赖插件源码时，该源码模块必须在构建过程中被登记，模块路径应指向实际使用的插件 `ohos/` 目录。
- 依赖插件 HAR 时，`dependencies` 和 `overrides` 应指向对应 HAR，避免其中一处又指回另一份插件源码。
- `modules` 中的 `srcPath` 相对于工程级 `build-profile.json5` 所在目录；`file:` 依赖路径相对于声明该依赖的 `oh-package.json5`。使用实际工程路径，不复制其他工程的本地缓存路径。

完整构建后，某些 Flutter 版本会移除临时登记的源码模块并改用生成的 HAR，这是正常的构建流程。应结合依赖形态和报错阶段检查，不能仅凭最终 `modules` 列表是否包含插件判断配置正确与否。

## 配置

#### 配置字节码编译环境
**说明**：现在har为字节码，需升级ide到5.0.3.500以上，并在工程级（最外层）build-profile.json5，配置"useNormalizedOHMUrl": true
```
    "products": [
      {
        "buildOption": {
          "strictMode": {
            "useNormalizedOHMUrl": true//打开
          }
        },
        "name": "default",
        "signingConfig": "default",
        "compileSdkVersion": "5.0.0(12)",
        "compatibleSdkVersion": "5.0.0(12)",
        "runtimeOS": "HarmonyOS"
      }
    ]
```

#### 配置 hmos平台信息

想要推送功能，需要配置 HarmonyOS 平台信息

主要步骤为：
- 在hmos平台开通推送服务
- 配置签署
  > [文档查看配置签署部分](https://docs.jiguang.cn/jpush/client/HarmonyOS/hmos_guide)

#### 配置通知跳转页

发送通知，请选打开应用方式发通知。不然还需要写原生代码

通过打开应用方式来获取通知数据：

- 在flutter自动生成的EntryAbility.ets文件添加JpushHarmonySdkPlugin.setClickWant(want, this.context)代码
- 在onCreate和onNewWant 两个方法里添加，如下代码例子

沿用当前鸿蒙版 Flutter SDK 生成的生命周期签名，加入 `setClickWant` 调用。下面示例适用于 `onCreate` 返回 `void` 的 SDK；若当前模板声明为 `Promise<void>`，保留该声明，并使用 `return super.onCreate(want, launchParam)` 返回父类调用结果。

```

import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import JpushHarmonySdkPlugin from 'jpush_flutter';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'JPUSH-flutter-JLog-EntryAbility'

export default class EntryAbility extends FlutterAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate :' + JSON.stringify(want));
    JpushHarmonySdkPlugin.setClickWant(want, this.context)//这里添加代码
    super.onCreate(want, launchParam)
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onNewWant :' + JSON.stringify(want));
    JpushHarmonySdkPlugin.setClickWant(want, this.context)//这里添加代码
    super.onNewWant(want, launchParams)
  }

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    hilog.info(0x0000, TAG, 'configureFlutterEngine');
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }
}

```

#### 配置自定义信息

如果有自定义信息需求，需以下配置

主要步骤为：

##### 步骤一

- 在项目模块级目录的 src/main/resources/base/profile/ 下创建 PushMessage.json 文件，文件内容如下：

```
{
  "path": "pushmessage/t_push_message",
  "type": "rdb",
  "scope": "application"
}

```

- path：固定值为 pushmessage/t_push_message，表示数据库和表名称。
- type：固定值为 rdb，表示关系型数据库。
- scope：表示数据库的范围，可填 application（应用级）或module（hap模块级）。

- 并且，在项目模块级目录的 src/main/module.json5 文件添加 proxyData 如下配置：

```
{
  "module": {
    "proxyData":[{
      "uri": "datashareproxy://{bundleName}/PushMessage",
      "requiredWritePermission": "ohos.permission.WRITE_PRIVACY_PUSH_DATA",
      "metadata":{
        "name": "dataProperties",
        "resource": "$profile:PushMessage"
      }
    }]
  }
}
```

- uri：固定格式为 datashareproxy://{bundleName}/PushMessage，请将{bundleName}替换为您应用的bundleName，PushMessage为固定名称，请勿随意更改。
- requiredWritePermission：固定值为 ohos.permission.WRITE_PRIVACY_PUSH_DATA，推送服务需要使用该权限往数据库里写入BACKGROUND消息数据。
- metadata：扩展配置，name固定值为dataProperties，resource固定格式为$profile:文件名称，文件名称固定为PushMessage。

##### 步骤二

- 在您项目的ability（下以PushMessageAbility为例）内导入push模块，
- 注意，您仅能使用UIAbility接收BACKGROUND消息。

```
import { UIAbility } from '@kit.AbilityKit';
import { pushCommon, pushService } from '@kit.PushKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import JpushHarmonySdkPlugin from 'jpush_flutter';

const TAG: string = 'JPUSH-JLog-PushMessageAbility'

export default class PushMessageAbility extends UIAbility {
  onCreate(): void {
    try { // receiveMessage中的参数固定为BACKGROUND-------后台自定义信息接收
      pushService.receiveMessage('BACKGROUND', this, async (data: pushCommon.PushPayload) => {
        let jg = await JpushHarmonySdkPlugin.customMessageBackgroundData(data)
        if (jg) { //如果是true为已经处理
          return
        }
      });
    } catch (e) {
      hilog.info(0x0000, TAG, '%{public}s', 'BACKGROUND fail:' + JSON.stringify(e));
    }
  }
}
```

- 并且，在项目工程的
  src/main/module.json5文件的abilities模块中配置skills中actions内容为action.ohos.push.listener（有且只能有一个ability定义该action，若同时添加uris参数，则uris内容需为空）。

```
"abilities": [
      {
        "name": "PushMessageAbility",
        "srcEntry": "./ets/entryability/PushMessageAbility.ets",
        "launchType": "singleton",
        "startWindowIcon": "$media:icon",
        "startWindowBackground": "$color:start_window_background",
        "skills": [
          {
            "actions": [
              "action.ohos.push.listener"
            ]
          }
        ]
      }
]

```

#### 配置通知扩展消息

如果有通知扩展消息需求，需以下配置

主要步骤为：

##### 步骤一

- 进程不存在会走这个流程（通知扩展进程），您在该进程中自行完成语音播报业务处理，并返回特定的消息内容（例如title、body等）覆盖当前消息内容后，Push
  Kit将弹出通知提醒。
- 在您的工程内创建一个ExtensionAbility类型的组件并且继承RemoteNotificationExtensionAbility，完成onReceiveMessage()
  方法的覆写，调用JPushInterface.receiveExtraDataMessage方法获取数据，代码示例如下：

```
import { UIAbility } from '@kit.AbilityKit';
import { pushCommon, pushService } from '@kit.PushKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import JpushHarmonySdkPlugin from 'jpush_flutter';

const TAG: string = 'JPUSH-JLog-PushMessageAbility'

export default class PushMessageAbility extends UIAbility {
  onCreate(): void {
    try { // receiveMessage中的参数固定为IM-------拓展通知接收
      pushService.receiveMessage('IM', this, async (data) => {
        let jg = await JpushHarmonySdkPlugin.extraMessageBackgroundData(data)
        if (jg) { //如果是true为已经处理
          return
        }
      });
    } catch (e) {
      hilog.info(0x0000, TAG, '%{public}s', 'IM fail:' + JSON.stringify(e));
    }

  }
}

```

-

并且，在项目工程的src/main/module.json5文件的extensionAbilities模块中配置RemoteNotificationExtAbility的type和actions信息（有且仅有一个ExtensionAbility，配置如下，若同时添加uris参数，则uris内容需为空）：

```
"extensionAbilities": [
  {
    "name": "RemoteNotificationExtAbility",
    "type": "remoteNotification",
    "srcEntry": "./ets/entryability/RemoteNotificationExtAbility.ets",
    "description": "RemoteNotificationExtAbility test",
    "exported": false,
    "skills": [
      {
        "actions": ["action.hms.push.extension.remotenotification"]
      }
    ]
  }
]

```

- type：固定值为remoteNotification，表示通知扩展的ExtensionAbility类型。
- actions：固定值为action.hms.push.extension.remotenotification，用于接收通知扩展消息。

##### 步骤二

- 进程存在时会走这个流程，若您的应用进程存在，无论应用在前台或者在后台均不弹出通知提醒
- 您可以通过receiveMessage()方法实时获取通知扩展消息数据，示例代码如下：

```
import { UIAbility } from '@kit.AbilityKit';
import { JPushInterface } from '@jg/push';
import { pushCommon, pushService } from '@kit.PushKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'JPUSH-JLog-PushMessageAbility'
export default class PushMessageAbility extends UIAbility {
  onCreate(): void {
    try { // receiveMessage中的参数固定为IM-------拓展通知接收
      pushService.receiveMessage('IM', this, async (data) => {
        let jg = await JPushInterface.extraMessageBackgroundData(data)
        if (jg) { //如果是true为已经处理
          return
        }
      });
    } catch (e) {
      hilog.info(0x0000, TAG, '%{public}s', 'IM fail:'+JSON.stringify(e));
    }
}

```

- 并且在项目模块的src/main/module.json5中的skills里配置actions内容为
  action.ohos.push.listener（有且只能有一个ability定义该action，若同时添加uris参数，则uris内容需为空）：

```
"abilities": [
      {
        "name": "PushMessageAbility",
        "srcEntry": "./ets/entryability/PushMessageAbility.ets",
        "launchType": "singleton",
        "startWindowIcon": "$media:icon",
        "startWindowBackground": "$color:start_window_background",
        "skills": [
          {
            "actions": [
              "action.ohos.push.listener"
            ]
          }
        ]
      }
]

```

#### 配置推送VoIP呼叫消息

如果有推送VoIP呼叫消息需求，需以下配置

主要步骤为：

##### 步骤一

- 在您的工程内创建一个UIAbility类型的组件，如PushMessageAbility.ets（在项目工程的src/main/ets/entryability目录下），负责处理VoIP呼叫消息接收，代码示例如下：

```
import { UIAbility } from '@kit.AbilityKit';
import { pushCommon, pushService } from '@kit.PushKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import JpushHarmonySdkPlugin from 'jpush_flutter';

const TAG: string = 'JPUSH-JLog-PushMessageAbility'

export default class PushMessageAbility extends UIAbility {
  onCreate(): void {
    try {
      pushService.receiveMessage('VoIP', this, async (data) => {
        let jg = await JpushHarmonySdkPlugin.voIPMessageBackgroundData(data)
        if (jg) { //如果是true为已经处理
          return
        }
      });
    } catch (e) {
      hilog.info(0x0000, TAG, '%{public}s', 'VoIP fail:' + JSON.stringify(e));
    }
  }
}
```

-

并且，在项目工程的 src/main/module.json5 文件的 abilities 模块中配置PushMessageAbility的actions信息。

```
"abilities": [ 
  { 
    "name": "PushMessageAbility", 
    "srcEntry": "./ets/entryability/PushMessageAbility.ets", 
    "launchType": "singleton",
    "description": "PushMessageAbility test", 
    "startWindowIcon": "$media:startIcon",
    "startWindowBackground": "$color:start_window_background",
    "exported": false, 
    "skills": [ 
      { 
        "actions": ["action.ohos.push.listener"]
      }
    ]
  } 
]
```

- actions：内容为action.ohos.push.listener，有且只能有一个ability定义该action，若同时添加uris参数，则uris内容需为空。



#### 设置极光平台信息

上述步骤完成后，还需要配置极光平台信息

主要步骤为：

- 在极光平台创建应用，并确保如下两个信息：包名和 appKey，与极光平台一致。
> 说明1：
>
> 在本地工程配置包名，方式：在 AppScope 工程下的 app.json5 文件添加
```
{
  "app": {
    "bundleName": "你的包名",
  }
}
```
> 说明2：
>
> 在本地工程配置极光appKey（极光控制台创建应用后自动生成的应用标识），代码配置 如：
```
  jpush.setup(
      appKey: "YOUR_APP_KEY", //你自己应用的 AppKey
      channel: "theChannel",
      production: false,
      debug: true, //debug log
    );
```
> 说明3：
>
> 在本地工程配置接收回调信息， 代码配置 如：
```
      jpush.setCallBackHarmony((eventName, data) async {
        print("flutter_log_MyApp:eventName:$eventName");
        print("flutter_log_MyApp:data:$data");
        setState(() {
          print("flutter_log_MyApp:setState");
          debugLable = "flutter CallBackHarmony: $eventName:$data";
        });
      });
```

#### 启用推送业务功能

主要步骤为：

- 在 init 之前要先设置 appKey
- 在 init 之前要先设置接收回调信息类

```
      jpush.setCallBackHarmony((eventName, data) async {
        print("flutter_log_MyApp:eventName:$eventName");
        print("flutter_log_MyApp:data:$data");
        setState(() {
          print("flutter_log_MyApp:setState");
          debugLable = "flutter CallBackHarmony: $eventName:$data";
        });
      });
      
      jpush.setup(
      appKey: "YOUR_APP_KEY", //你自己应用的 AppKey
      channel: "theChannel",
      production: false,
      debug: true, //debug log
    );
```

#### 控制通知权限申请方式（可选）

> 鸿蒙 Only，对应原生接口 `setUserRequestNotificationPermission`（JPush HarmonyOS SDK v1.3.0 起支持）

设置是否由开发者自己调用通知申请权限：

- `enable` 为 `true`：极光 SDK 不会主动申请通知权限，需要开发者在自己的代码中手动申请；
- `enable` 为 `false`（默认，即不调用该接口时的行为）：极光 SDK 会在初始化时自动申请通知权限。

注意：必须在 `setup` 之前调用。

```
jpush.setUserRequestNotificationPermission(enable: true);

jpush.setup(
  appKey: "YOUR_APP_KEY", //你自己应用的 AppKey
  channel: "theChannel",
  production: false,
  debug: true, //debug log
);
```

如需更早设置（例如在 `AbilityStage#onCreate` 或 `UIAbility#onCreate` 中），也可以直接调用原生静态接口：

```
import JpushHarmonySdkPlugin from 'jpush_flutter';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    JpushHarmonySdkPlugin.setUserRequestNotificationPermission(this.context, true)
    super.onCreate(want, launchParam)
  }
```

### APIs

[参考](./documents/APIs.md)

### Flutter 插件 3.6.0

原生依赖更新为 `@jg/push 1.5.0`，保持既有权限、异步 RID、停恢复和通知回调契约。通知覆盖及撤回由 SDK 处理，不新增虚构客户端 API。Android 专属的复数订阅、恢复结果、崩溃开关和 iOS 诊断开关在鸿蒙调用时明确返回 UnsupportedError。


## 1.5.0 状态查询兼容

`await jpush.getPushStatus()` 查询后台推送开关，成功返回 `{code: 0, isStopped: bool}`。此版本支持 cmd2008 状态组合（0 / `not stop`、1 / `stopped`），不拿2006/2007操作回调或本地缓存代替查询。未知、缺失或矛盾回应通过 Future 抛出 `PlatformException(PUSH_STATUS_UNAVAILABLE)`；details 保留可用 `nativeCode` / `nativeMessage`。请按异常路径处理，不能假定所有回应都是业务Map。该状态解码规则适用于 `@jg/push 1.5.0`，详见 documents/APIs.md。
