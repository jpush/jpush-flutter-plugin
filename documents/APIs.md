[Common API](#common-api)

- [setup](#setup)
- [getRegistrationID](#getregistrationid)
- [stopPush](#stoppush)
- [resumePush](#resumepush)
- [setAlias](#setalias)
- [getAlias](#getAlias)
- [deleteAlias](#deletealias)
- [addTags](#addtags)
- [deleteTags](#deletetags)
- [setTags](#settags)
- [cleanTags](#cleantags)
- [getTags](gettags)


[android ios]()

- [addEventHandler](#addeventhandler)
- [getAllTags](getalltags)
- [sendLocalNotification](#sendlocalnotification)
- [clearAllNotifications](#clearallnotifications)

[iOS Only]()

- [applyPushAuthority](#applypushauthority)
- [setBadge](#setbadge)
- [getLaunchAppNotification](#getlaunchappnotification)
- [pageEnterTo](#pageEnterTo)
- [pageLeave](#pageLeave)
- [setBackgroundEnable](#setbackgroundenable)


[harmony Only]()

- [setCallBackHarmony](#setCallBackHarmony)

**注意：setCallBackHarmony 方法建议放到 setup 之前，其他方法需要在 setup 方法之后调用，**
**注意：addEventHandler 方法建议放到 setup 之前，其他方法需要在 setup 方法之后调用，**

####  setCallBackHarmony

添加事件监听方法(harmony)

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.setCallBackHarmony((eventName, data) async {
    print("flutter_log_MyApp:eventName:$eventName");
    print("flutter_log_MyApp:data:$data");
    setState(() {
      print("flutter_log_MyApp:setState");
      debugLable = "flutter CallBackHarmony: $eventName:$data";
    });
});
```
##### 参数说明
- eventName: 为事件类型
    - "onConnected":长连接状态回调,内容类型为boolean，true为连接
    - "onClickMessage":通知点击事件回调，内容为string JMessage json
    - "onCustomMessage":自定义消息回调，内容为string JCustomMessage json
    - "onJMessageExtra":通知扩展消息回调，内容为string JMessageExtra json
    - "onJMessageVoIP":VoIP呼叫消息回调，内容为string JMessageVoIP json
    - "onCommandResult":交互事件回调，内容为string JCmdMessage json
    - "onArrivedMessage":消息到达回调，内容为string JMessage json
    - "onUnShowMessage":消息未显示回调，内容为string JMessage json
- data: 为对应内容
```
/**
* 操作 tag 接口回调
* @param jTagMessage
* export class JTagMessage {
* sequence?: number //对应操作id，全局不要重复
* code?: number //0成功，JTagMessage.CODE_TIME_OUT超时
* op?: string
* tags?: string[] //对应数据
* curr?: number //数据当前页数，页数从1开始
* total?: number //数据总页数
* msg?: string
* }
  */
```
```
/**
* 操作 Alias 接口回调
* @param jAliasMessage
* export class JAliasMessage {
* sequence?: number //对应操作id，全局不要重复
* code?: number //0成功，JAliasMessage.CODE_TIME_OUT超时
* op?: string
* alias?: string //对应数据
* curr?: number
* total?: number
* msg?: string
* }
  */
```
```
  /**
   * 通知点击事件回调
   * @param jMessage
   *
   * export class JMessage {
   * msgId?: string //通知id
   * title?: string //通知标题
   * content?: string//通知内容
   * extras?: string//自定义数据
   * }
   */
```
```
  /**
   * 自定义信息通知回调
   *  回调一：冷启动调用sdk初始化后回调之前还没有回调的信息
   *  回调二：app存活时会直接回调信息
   * @param jCustomMessage
   *
   * export class JCustomMessage {
   *  msgId?: string //通知id
   *  title?: string //通知标题
   *  content?: string //通知内容
   *  contentType?: string //通知内容类型
   *  extras?: Record<string, Object> //通知自定义键值对
   *  ttl?: number //后台下发的信息过期时间，单位秒
   *  stime?: number //后台下发时间，毫秒
   * }
   */
```
```
  /**
   * 通知扩展消息回调
   * @param jMessageExtra
   *
   * export class JMessageExtra {
   * msgId?: string //通知id
   * title?: string //通知标题
   * content?: string//通知内容
   * extras?: Record<string, Object>//自定义数据
   * extraData?: string//通知扩展消息的自定义数据
   * }
   */
```
```
/**
   * VoIP呼叫消息回调
   * export class JMessageVoIP {
   * msgId?: string //通知id
   * extraData?: string //VoIP自定义数据
   }
   * @param jmVoIP
   */
```
```
  /**
   * 交互事件回调
   * @param cmdMessage
   * export class JCmdMessage {
   * public static CMD_PUSH_STOP = 2007 //通知停止 设置回调
   * public static CMD_PUSH_RESUME = 2006 //  通知恢复 设置回调
   *
   * cmd?: number  //操作事件，2007通知停止，2006恢复通知
   * errorCode?: number //0表示成功，其他为错误
   * msg?: string //内容信息
   * extra?: Record<string, Object>
   * }
   */
```
```
  /**
   * 消息到达回调
   * @param jMessage
   * export class JMessage {
   * msgId?: string //通知id
   * title?: string //通知标题
   * content?: string//通知内容
   * extras?: string//自定义数据
   * }
   */
```
```
  /**
   * 消息未显示回调
   * @param jMessage
   * export class JMessage {
   * msgId?: string //通知id
   * title?: string //通知标题
   * content?: string//通知内容
   * extras?: string//自定义数据
   * }
   */
```


####  addEventHandler

添加事件监听方法。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.addEventHandler(
      // 接收通知回调方法。
      onReceiveNotification: (Map<String, dynamic> message) async {
         print("flutter onReceiveNotification: $message");
      },
      // 点击通知回调方法。
      onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
      },
      // 接收自定义消息回调方法。
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
      },
      onConnected: (Map<String, dynamic> message) async {
        print("flutter onConnected: $message");
      },
      // iOS Only: 接收设备Token回调方法。
      onReceiveDeviceToken: (Map<String, dynamic> message) async {
        print("flutter onReceiveDeviceToken: $message");
        // message 包含 {"deviceToken": "实际的设备deviceToken"}
      },
  );
```


#### setup

添加初始化方法，调用 setup 方法会执行两个操作：

- 初始化 JPush SDK
- 将缓存的事件下发到 dart 环境中。

**注意：** 插件版本 >= 0.0.8 android 端支持在 setup 方法中动态设置 channel，动态设置的 channel 优先级比 manifestPlaceholders 中的 JPUSH_CHANNEL 优先级要高。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.setup(
      appKey: "替换成你自己的 appKey",
      channel: "theChannel",
      production: false,
      debug: false, // 设置是否打印 debug 日志
    );
```

* iOS使用推送功能，需要调用申请通知权限的方法，详情见 [applyPushAuthority](#applyPushAuthority)。

```
jpush.applyPushAuthority(new NotificationSettingsIOS(
      sound: true,
      alert: true,
      badge: true));
```

#### getRegistrationID

获取 registrationId，这个 JPush 运行通过 registrationId 来进行推送.

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.getRegistrationID().then((rid) { });
```

#### stopPush

停止推送功能，调用该方法将不会接收到通知。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.stopPush();
```


####  setChannelAndSound
动态配置 channel 、channel id 及sound，优先级比 AndroidManifest 里配置的高
备注：channel、channel id为必须参数，否则接口调用失败。sound 可选

#### 参数说明
- Object

|参数名称|参数类型|参数说明|
|:-----:|:----:|:-----:|
|channel|string|希望配置的 channel|
|channel_id|string|希望配置的 channel id|
|sound|string|希望配置的 sound(铃声名称，只有铃声名称即可，如AA.mp3,填写AA )|

#### 示例
```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.setChannelAndSound();
```


#### resumePush

调用 stopPush 后，可以通过 resumePush 方法恢复推送。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.resumePush();
```

#### setAlias

设置别名，极光后台可以通过别名来推送，一个 App 应用只有一个别名，一般用来存储用户 id。

```
JPushFlutterInterface jpush = JPush.newJPush();
jpush.setAlias("your alias").then((map) { });
```

#### deleteAlias

可以通过 deleteAlias 方法来删除已经设置的 alias。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.deleteAlias().then((map) {})
```
#### getAlias

获取当前 alias 列表。

```
JPushFlutterInterface jpush = JPush.newJPush();
jpush.getAlias().then((map) { });
```
#### addTags

在原来的 Tags 列表上添加指定 tags。

```
JPushFlutterInterface jpush = JPush.newJPush();
jpush.addTags(["tag1","tag2"]).then((map) {});
```

####  deleteTags

在原来的 Tags 列表上删除指定 tags。

```
JPushFlutterInterface jpush = JPush.newJPush();
jpush.deleteTags(["tag1","tag2"]).then((map) {});
```

#### setTags

重置 tags。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.setTags(["tag1","tag2"]).then((map) {});
```

#### cleanTags

清空所有 tags

```dart
jpush.setTags().then((map) {});
```

#### getAllTags

获取当前 tags 列表。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.getAllTags().then((map) {});
```

#### getTags

获取标签(harmony)

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.getTags(1).then((map) {});
```
##### 参数说明

- curr: 当前分页数，下标1开始

#### sendLocalNotification

指定触发时间，添加本地推送通知。

```dart
// 延时 3 秒后触发本地通知。
JPushFlutterInterface jpush = JPush.newJPush();
var fireDate = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 3000);
var localNotification = LocalNotification(
   id: 234,
   title: 'notification title',
   buildId: 1,
   content: 'notification content',
   fireTime: fireDate,
   subtitle: 'notification subtitle', // 该参数只有在 iOS 有效
   badge: 5, // 该参数只有在 iOS 有效
   extras: {"fa": "0"} // 设置 extras ，extras 需要是 Map<String, String>
  );
jpush.sendLocalNotification(localNotification).then((res) {});
```

#### clearAllNotifications

清楚通知栏上所有通知。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.clearAllNotifications();
```

#### applyPushAuthority

申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。

**注意： iOS10+ 可以通过该方法来设置推送是否前台展示，是否触发声音，是否设置应用角标 badge**

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.applyPushAuthority(new NotificationSettingsIOS(
      sound: true,
      alert: true,
      badge: true));
```

**iOS Only**

#### setBadge

设置应用 badge 值，该方法还会同步 JPush 服务器的的 badge 值，JPush 服务器的 badge 值用于推送 badge 自动 +1 时会用到。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.setBadge(66).then((map) {});
```

#### setBackgroundEnable

设置进入后台是否允许长连接（仅iOS）。默认是NO,进入后台会关闭长连接，回到前台会重新接入。请在初始化函数之前调用。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
// 允许后台长连接
jpush.setBackgroundEnable(enable: true);
// 禁止后台长连接（默认）
jpush.setBackgroundEnable(enable: false);
```

### getLaunchAppNotification

获取 iOS 点击推送启动应用的那条通知。

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.getLaunchAppNotification().then((map) {});
```

### pageEnterTo

进入页面，应用内消息功能需要配置该接口，请与pageLeave函数配套使用

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.pageEnterTo("页面名");
```

### pageLeave

离开页面，应用内消息功能需要配置该接口，请与pageEnterTo函数配套使用

```dart
JPushFlutterInterface jpush = JPush.newJPush();
jpush.pageLeave("页面名");
```

