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
