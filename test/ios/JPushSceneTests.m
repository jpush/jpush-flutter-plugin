// 在隔离的 iOS 测试宿主中编译并调用 JPushRunSceneTests；不进入插件发布包。
#import <jpush_flutter/JPushPlugin.h>
#import <UserNotifications/UserNotifications.h>
#import <objc/runtime.h>

@interface JPushPlugin (SceneTests)
- (BOOL)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)options;
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completion;
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;
@end

@interface JPTestRemoteTrigger : NSObject
@end
@implementation JPTestRemoteTrigger
- (BOOL)isKindOfClass:(Class)cls { return cls == [UNPushNotificationTrigger class] || [super isKindOfClass:cls]; }
@end
@interface JPTestRequest : NSObject
@property NSString *identifier;
@property UNNotificationContent *content;
@property id trigger;
@end
@implementation JPTestRequest
@end
@interface JPTestNotification : NSObject
@property UNNotificationRequest *request;
@property NSDate *date;
@end
@implementation JPTestNotification
@end
@interface JPTestResponse : NSObject
@property JPTestNotification *notification;
@property NSString *actionIdentifier;
@end
@implementation JPTestResponse
@end
@interface JPTestOptions : NSObject
@property JPTestResponse *notificationResponse;
@end
@implementation JPTestOptions
@end
@interface JPTestChannel : NSObject
@property NSMutableArray *events;
@end
@implementation JPTestChannel
- (instancetype)init { if ((self = [super init])) _events = [NSMutableArray new]; return self; }
- (void)invokeMethod:(NSString *)method arguments:(id)arguments { [_events addObject:@{@"name": method, @"msg": arguments ?: @{}}]; }
- (void)invokeMethod:(NSString *)method arguments:(id)arguments result:(FlutterResult)result {
    [self invokeMethod:method arguments:arguments]; if (result) result(nil);
}
@end

static NSUInteger JPTestStatistics;
static void JPTestHandleRemote(id self, SEL cmd, NSDictionary *payload) { JPTestStatistics++; }
static NSDictionary *JPTestLaunch(JPushPlugin *plugin) {
    __block NSDictionary *launch;
    [plugin handleMethodCall:[FlutterMethodCall methodCallWithMethodName:@"getLaunchAppNotification" arguments:nil]
                      result:^(id result) { launch = result; }];
    return launch;
}
static JPTestOptions *JPTestMake(NSString *identifier, BOOL remote, NSTimeInterval date) {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"scene-test";
    content.body = @"test-body";
    content.userInfo = @{@"_j_msgid": @"same-message", @"route": @"test-detail", @"aps": @{@"alert": @"test"}};
    id trigger = remote ? [JPTestRemoteTrigger new] : nil;
    JPTestRequest *request = [JPTestRequest new];
    request.identifier = identifier; request.content = content; request.trigger = trigger;
    JPTestNotification *notification = [JPTestNotification new];
    notification.request = (id)request;
    notification.date = [NSDate dateWithTimeIntervalSince1970:date];
    JPTestResponse *response = [JPTestResponse new];
    response.notification = notification;
    response.actionIdentifier = UNNotificationDefaultActionIdentifier;
    JPTestOptions *options = [JPTestOptions new];
    options.notificationResponse = response;
    return options;
}
static BOOL JPTestScene(JPushPlugin *plugin, JPTestOptions *options) {
    return [plugin scene:nil willConnectToSession:nil options:(id)options];
}
static NSUInteger JPTestQueue(JPushPlugin *plugin) { return [[plugin valueForKey:@"storedCallBackMessage"] count]; }

BOOL JPushRunSceneTests(void) {
    __block NSUInteger failures = 0;
    void (^check)(NSString *, BOOL) = ^(NSString *name, BOOL passed) {
        NSLog(@"JPUSH_SCENE_TEST %@ %@", passed ? @"PASS" : @"FAIL", name);
        if (!passed) failures++;
    };
    Method method = class_getClassMethod(NSClassFromString(@"JPUSHService"), NSSelectorFromString(@"handleRemoteNotification:"));
    IMP original = method_setImplementation(method, (IMP)JPTestHandleRemote);
    JPushPlugin *plugin = [JPushPlugin new];
    check(@"N01-no-notification", !JPTestScene(plugin, nil) && JPTestLaunch(plugin).count == 0);
    JPTestOptions *options = JPTestMake(@"request-one", YES, 100);
    JPTestStatistics = 0;
    check(@"N02-remote-cache-and-deferred-event", !JPTestScene(plugin, options) &&
          [JPTestLaunch(plugin)[@"extras"][@"route"] isEqual:@"test-detail"] && JPTestQueue(plugin) == 1 && JPTestStatistics == 1);
    JPTestScene(plugin, nil);
    check(@"N03-empty-connection-preserves-cache", [JPTestLaunch(plugin)[@"extras"][@"route"] isEqual:@"test-detail"]);
    __block NSUInteger completions = 0;
    [plugin jpushNotificationCenter:nil didReceiveNotificationResponse:(id)options.notificationResponse withCompletionHandler:^{ completions++; }];
    check(@"N04-scene-then-un-deduplicated", JPTestQueue(plugin) == 1 && JPTestStatistics == 1 && completions == 1);
    JPushPlugin *reverse = [JPushPlugin new];
    JPTestStatistics = 0;
    [reverse jpushNotificationCenter:nil didReceiveNotificationResponse:(id)options.notificationResponse withCompletionHandler:^{}];
    JPTestScene(reverse, options);
    check(@"N05-un-then-scene-deduplicated", JPTestQueue(reverse) == 1 && JPTestStatistics == 1 && JPTestLaunch(reverse).count > 0);
    JPTestScene(plugin, JPTestMake(@"request-two", YES, 100));
    JPTestScene(plugin, JPTestMake(@"request-two", YES, 101));
    check(@"N06-same-msgid-different-delivery", JPTestQueue(plugin) == 3);
    [plugin jpushNotificationCenter:nil didReceiveNotificationResponse:(id)options.notificationResponse withCompletionHandler:^{}];
    [plugin jpushNotificationCenter:nil didReceiveNotificationResponse:(id)options.notificationResponse withCompletionHandler:^{}];
    check(@"N07-subsequent-same-source-click", JPTestQueue(plugin) == 5);
    JPushPlugin *local = [JPushPlugin new];
    JPTestStatistics = 0;
    JPTestScene(local, JPTestMake(@"local-one", NO, 100));
    check(@"N08-local-format-no-remote-statistics", [JPTestLaunch(local)[@"body"] isEqual:@"test-body"] &&
          [JPTestLaunch(local)[@"extras"][@"route"] isEqual:@"test-detail"] && JPTestStatistics == 0);
    JPushPlugin *live = [JPushPlugin new];
    JPTestChannel *channel = [JPTestChannel new];
    live.channel = (id)channel;
    [live setValue:@YES forKey:@"hasAddEventHandle"];
    JPTestScene(live, options);
    check(@"N09-live-event", channel.events.count == 1 && [channel.events.firstObject[@"name"] isEqual:@"onOpenNotification"] && JPTestQueue(live) == 0);
    [live setValue:@([NSDate timeIntervalSinceReferenceDate] - 6.0) forKey:@"lastNotificationResponseTime"];
    [live jpushNotificationCenter:nil didReceiveNotificationResponse:(id)options.notificationResponse withCompletionHandler:^{}];
    check(@"N10-expired-cross-source-not-suppressed", channel.events.count == 2);
    method_setImplementation(method, original);
    NSLog(@"JPUSH_SCENE_TEST SUMMARY total=10 failed=%lu", (unsigned long)failures);
    return failures == 0;
}
