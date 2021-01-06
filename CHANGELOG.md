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
