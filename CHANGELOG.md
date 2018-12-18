## 0.0.8

更新 setup 方法，android 端现在支持 channel 字段，用于动态设置 channel，和 iOS 保持一致。
注意通过 setup 设置 的 channel 会覆盖 manifestPlaceholders 中的 JPUSH_CHANNEL 字段。

## 0.0.7

修改 setup 方法，添加 boolean debug 参数，如果 debug 为 true 这打印日志，如果为 false 则不打印日志。

## 0.0.2

修复 android 类名文件名不匹配问题。

## 0.0.1

第一个版本。
