## 3.2.0
更新android Jpush 560+JCore 490, 更新 iOS JPush 5.5.0 +JCore 4.9.0
## 3.1.9
开放本地通知在点击时候能直接进入应用主页
## 3.1.8
更新android JPush 553+ jcore 489
## 3.1.7
修复iOS杀死app点击通知不走回调的问题
## 3.1.6
修复onCommandResult 方法崩溃
## 3.1.5
修复onCommandResult 方法中没有 extra 参数问题，都放到map中
## 3.1.4
删除多余配置
## 3.1.3
修复后台不能获取回调的问题
## 3.1.2
修复在map中且套map不能获取数据问题: 主要由原来的string 类型 修改为 map 类型。
## 3.1.1[google版SDK(1).log](..%2F..%2Flogs%2Fgoogle%E7%89%88SDK%281%29.log)
开放Android setThirdToken 接口
## 3.1.0
开放Android setHBInterval 接口
## 3.0.9
1、升级 iOS SDK JPush 5.4.0 +JCore 4.8.0, 升级 android  JPush 5.5.0 +JCore 4.8.0
## 3.0.8
1、iOS本地通知新增onReceiveNotification回调
## 3.0.7
1、修复BUG
## 3.0.6
1、修复BUG
## 3.0.5
1、修复BUG
## 3.0.4
1、升级 iOS SDK JPush 5.3.0, 升级 android  JPush 5.4.0
2、开放 setLinkMergeEnable、setGeofenceEnable、setSmartPushEnable、setCollectControl 接口设置
3、删除 setLbsEnable 接口设置
## 3.0.3
1、开放onCommandResult 接口回调
2、升级适配gradle 7.5
## 3.0.2
开放支持动态设置appkey
## 3.0.1
升级：升级 android  JPush 5.2.2
## 3.0.0
+ 适配flutter3.x, 
+ 升级：升级 iOS SDK JCore4.6.2， JPush 5.2.4
## 2.5.0
更新JCore 440 JPush 520
## 2.4.9
修复testCountryCode报错问题
## 2.4.8
修复不能清理本地通知问题
## 2.4.7
开放requestRequiredPermission API 
## 2.4.6
开放setChannelAndSound API 
## 2.4.5
+ 修复：onConnected 崩溃问题
+ 升级：升级 Android+IOS JPush 5.0.4
       升级 Android+IOS JCore 4.2.4
+ 新增：setLbsEnable API   
## 2.4.4
+ 修复：优化代码结构
## 2.4.3
+ 升级：升级 Android+IOS JPush 5.0.0
       升级 Android+IOS JCore 4.2.0
 + 新增：enableAutoWakeup API
## 2.4.2 
开放 onConnected 回调
## 2.4.1
+ 升级：升级 Android JPush 4.9.0
       升级 Android JCore 4.1.0
## 2.4.0
+ 升级：升级 Android JPush 4.8.4
## 2.3.9
+ 升级：升级 Android JPush 4.8.3
       升级 Android JCore 3.3.6
## 2.3.8
+ 新增：testCountryCode API
## 2.3.7
+ 升级：升级 Android JPush 4.8.1
       升级 Android JCore 3.3.2
       升级 IOS JPush 4.8.1
       升级 IOS JCore 3.2.5
## 2.3.6
+ 新增：修复崩溃问题
## 2.3.5
+ 新增：iOS新增getAlias接口实现
## 2.3.4
+ 升级：升级 Android JPush 4.7.2
       升级 Android JCore 3.3.0
## 2.3.3
+ 升级：升级 Android JPush 4.7.0
## 2.3.2
+ 新增：修复setAuth()方法问题
## 2.3.1
+ 新增：iOS对外暴露setAuth()方法
## 2.3.0
+ 新增：对外暴露setAuth()方法
  修复：点开通知会默认跳转到主页问题
## 2.2.9
+ 升级：升级 Android JPush 4.6.6
## 2.2.8
+ 升级：使用g版本
## 2.2.7
+ 升级：升级 Android JCore 3.2.4
## 2.2.6
+ 修复：自定义消息解析崩溃问题
## 2.2.5
+ 升级：jpsuh 4.6.4 jcore 3.2.2
## 2.2.4
+ 修复：iOS点击通知冷启动app，不回调onOpenNotification问题
## 2.2.3
+ 升级：jpsuh 4.6.0
## 2.2.2
+ 新增：getAlias接口
## 2.2.1
+ 升级：iOS：jpush3.7.0->jpus4.4.0
## 2.2.0
+ 修复channel为null时,异常崩溃问题
## 2.1.9
+ 升级：新增onNotifyMessageUnShow方法
## 2.1.8
+ 升级： jpush 4.4.5
## 2.1.7
+ 升级： jcore 3.1.0
## 2.1.6
+ 升级：升级 android push 4.4.0 jcore 3.0.0
## 2.1.5
+ 升级：升级 android push 4.2.8 jcore 2.9.0，ios push 3.7.0，jcore 2.7.1。
## 2.1.4
+ 新增：Android push 新增 setWakeEnable 接口
## 2.1.2
+ 升级：升级 android push 4.0.8 jcore 2.8.2，ios push 3.6.1，jcore 2.6.2。
## 2.0.9
+ 适配：处理 demo 运行时报错。
## 2.0.7
+ 适配：适配 null safety
## 2.0.5
+ 升级：android jcore 升级 2.7.8
## 2.0.3
+ 升级：android push 升级4.0.6，ios push 升级 3.5.2
## 2.0.1
+ 适配Flutter 2.0，Flutter 2.0 以下版本请使用 0.6.3版本
## 0.6.3
+ 修复：Android端获取RegistrationID偶现奔溃问题
## 0.6.2
+ 同步更最新版本SDK
## 0.6.1
+ 修复：Android 端 context为空时的crash问题
## 0.6.0
+ 修复：修复已知bug
## 0.5.9
+ 适配最新版本 JPush SDK Android 3.8.0 , IOS 3.3.6
## 0.5.6
+ 修复：iOS点击本地通知的通知栏消息缺少extras 字段
## 0.5.5
+ 适配iOS点击本地通知的通知栏消息响应事件
+ 更新最新Android SDK
## 0.5.3
+ 修复一个可能引起崩溃的日志打印代码
## 0.5.2
+ 内部安全策略优化
+ 同步 JPush SDK 版本
## 0.5.1
+ 修改 minSdkVersion 最小支持 17
## 0.5.0
+ 适配最新版本 JPush SDK
+ 适配新版 SDK 的新功能接口
## 0.3.0
+ 新增：清除通知栏单条通知方法
+ 修复：点击通知栏无法获取消息问题
+ 同步最新版 SDK
## 0.2.0
+ 适配最新版本 JPush SDK
+ Android 支持设置角标 badge
## 0.1.0
+ 修复：调用 sendLocalNotification 接口 crash 问题；
+ 修复：iOS 启动 APP 角标自动消失问题；
+ 修复执行 flutter build apk 打包错误问题;
+ 更新配置

## 0.0.13

featurn:
适配flutter 1.7.8
升级 jpush sdk 版本为3.3.4

## 0.0.12

featurn: 修改LocalNotification的属性名为"extra"

## 0.0.11

iOS: 修复 getLaunchAppNotification 返回 null 的情况。
featurn: APNS 推送字段将 extras 字段移动到 notification.extras 中和 android 保持一致。

## 0.0.9

android: 修复 JPushReceiver 类型转换的错误。

## 0.0.8

更新 setup 方法，android 端现在支持 channel 字段，用于动态设置 channel，和 iOS 保持一致。
注意通过 setup 设置 的 channel 会覆盖 manifestPlaceholders 中的 JPUSH_CHANNEL 字段。

## 0.0.7

修改 setup 方法，添加 boolean debug 参数，如果 debug 为 true 这打印日志，如果为 false 则不打印日志。

## 0.0.6

 增加 swift 工程支持。


## 0.0.3
添加 localnotification api。

## 0.0.2

修复 android 类名文件名不匹配问题。

## 0.0.1

第一个版本。
