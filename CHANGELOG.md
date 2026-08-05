## 3.0.6 (2026-08-05)

- iOS 插件支持 Swift Package Manager 集成方式（需 Flutter 3.24+，CocoaPods 集成不受影响）。

## 3.0.5
android升级到jpush 6.2.0
ios升级到jpush 6.2.0 jcore 5.5.0
新增getPushStatus获取推送状态
新增setBackgroundEnable设置退后台是否维持长连接
新增requestSubscribeChannel小米订阅消息（Android Only）
新增onNotifyButtonClick通知按钮点击回调（Android Only）
新增onVoipMessage回调（Android Only）
新增onReceiveDeviceToken回调（iOS Only）
iOS的stopPush/resumePush改为走推送开关setPushEnable，与getPushStatus状态一致
## 3.0.4
android升级到jpush 5.8.0
ios升级到jpush 5.7.0
## 3.0.3
修复安卓第一次运行getRegistrationID方法偶现获取不到rid的问题
## 3.0.2
同步dev-3.x iOS部分
## 3.0.1
更新android jcore-google 490
## 3.0.0
更新iOS jpush550
更新android jpush560
适配flutter 3.0.0
# 1.1.2
修复onCommandResult 方法崩溃
## 1.1.1
修复后台不能获取回调的问题
修复onCommandResult 方法中没有 extra 参数问题，都放到map中
修复在map中且套map不能获取数据问题: 主要由原来的string 类型 修改为 map 类型。
## 1.1.0
1、升级 iOS SDK JPush 5.3.0, 升级 android  JPush 5.4.0
2、开放 setLinkMergeEnable、setGeofenceEnable、setSmartPushEnable、setCollectControl 接口设置
3、删除 setLbsEnable 接口设置
## 1.0.9
开放支持动态设置appkey
## 1.0.8
更新JPush 523
## 1.0.7
修复iOS编译报错问题
## 1.0.6
更新JPush 520和 JCore 440
## 1.0.5
修复testCountryCode 报错
## 1.0.4
开放clearLocalNotifications和requestRequiredPermission
## 1.0.3
开放setChannelAndSound 
## 1.0.2
开放setLbsEnable接口
升级JPush 5.0.4+JCore 4.2.4
## 1.0.1

新增IOS 更新
## 1.0.0

第一个版本。

