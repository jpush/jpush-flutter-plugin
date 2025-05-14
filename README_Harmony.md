# 鸿蒙版Flutter环境搭建指导
[鸿蒙版Flutter环境搭建指导](https://gitee.com/openharmony-sig/flutter_samples/blob/master/ohos/docs/03_environment/%E9%B8%BF%E8%92%99%E7%89%88Flutter%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA%E6%8C%87%E5%AF%BC.md)



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

```

import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import JpushHarmonySdkPlugin from 'jpush_harmony_sdk';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'JPUSH-flutter-JLog-EntryAbility'

export default class EntryAbility extends FlutterAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, TAG, 'onCreate :' + JSON.stringify(want));
    JpushHarmonySdkPlugin.setClickWant(want, this.context)//这里添加代码
    return super.onCreate(want, launchParam)
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
import JpushHarmonySdkPlugin from 'jpush_harmony_sdk';

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
import JpushHarmonySdkPlugin from 'jpush_harmony_sdk';

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
import JpushHarmonySdkPlugin from 'jpush_harmony_sdk';

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
      appKey: "b266cd5c8544ba09b23733e3", //你自己应用的 AppKey
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
      appKey: "b266cd5c8544ba09b23733e3", //你自己应用的 AppKey
      channel: "theChannel",
      production: false,
      debug: true, //debug log
    );
```




### APIs

[参考](./documents/APIs.md)