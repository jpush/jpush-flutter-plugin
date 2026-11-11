#import <Flutter/Flutter.h>
#import <UserNotifications/UserNotifications.h>

@interface JPushPlugin : NSObject<FlutterPlugin>
@property FlutterMethodChannel *channel;

/// 在主线程、目标插件注册完成后且 Dart 启动前调用。
/// YES 表示该引擎已接收响应，重复交接同一启动响应也返回 YES。
/// NO 表示未接收；调用方应保留响应并报告失败。
+ (BOOL)acceptSceneLaunchNotificationResponse:(nonnull UNNotificationResponse *)response
                                    registry:(nonnull NSObject<FlutterPluginRegistry> *)registry
    NS_SWIFT_NAME(acceptSceneLaunchNotification(_:registry:))
    API_AVAILABLE(ios(13.0));
@end
