#import <jpush_flutter/JPushPlugin.h>
#import <objc/runtime.h>

@interface JPushPlugin (DeferredHandoffTests)
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completion;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (BOOL)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)options;
- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@end

@interface JPDTestTrigger : NSObject
@end
@implementation JPDTestTrigger
- (BOOL)isKindOfClass:(Class)cls {
    return cls == [UNPushNotificationTrigger class] || [super isKindOfClass:cls];
}
@end

@interface JPDTestResponse : NSObject
@property(nonatomic, strong) UNNotification *notification;
@property(nonatomic, copy) NSString *actionIdentifier;
@property(nonatomic, copy) NSString *userText;
@end
@implementation JPDTestResponse
- (BOOL)isKindOfClass:(Class)cls {
    return (cls == [UNTextInputNotificationResponse class] && self.userText != nil)
        || [super isKindOfClass:cls];
}
@end

@interface JPDTestNotification : NSObject
@property(nonatomic, strong) UNNotificationRequest *request;
@property(nonatomic, strong) NSDate *date;
@end
@implementation JPDTestNotification
@end

@interface JPDTestRequest : NSObject
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, strong) UNNotificationContent *content;
@property(nonatomic, strong) id trigger;
@end
@implementation JPDTestRequest
@end

@interface JPDTestOptions : NSObject
@property(nonatomic, strong) UNNotificationResponse *notificationResponse;
@end
@implementation JPDTestOptions
@end

@interface JPDTestRegistry : NSObject <FlutterPluginRegistry>
@property(nonatomic, strong) NSObject *published;
@end
@implementation JPDTestRegistry
- (NSObject<FlutterPluginRegistrar> *)registrarForPlugin:(NSString *)key { return nil; }
- (BOOL)hasPlugin:(NSString *)key { return self.published != nil && [key isEqualToString:@"JPushPlugin"]; }
- (NSObject *)valuePublishedByPlugin:(NSString *)key {
    return [key isEqualToString:@"JPushPlugin"] ? self.published : nil;
}
@end

@interface JPDTestChannel : NSObject
@property(nonatomic, strong) NSMutableArray *events;
@end
@implementation JPDTestChannel
- (instancetype)init {
    if ((self = [super init])) { _events = [NSMutableArray new]; }
    return self;
}
- (void)invokeMethod:(NSString *)method arguments:(id)arguments {
    [self.events addObject:@{@"name": method, @"msg": arguments ?: @{}}];
}
@end

static NSUInteger JPDStatistics;
static NSUInteger JPDSetupCalls;
static void JPDHandle(id target, SEL selector, NSDictionary *payload) { JPDStatistics++; }
static void JPDSetup(id target, SEL selector, NSDictionary *options, NSString *appKey, NSString *channel, BOOL production) {
    JPDSetupCalls++;
}
static void JPDRegister(id target, SEL selector, id entity, id delegate) {}

static JPDTestRegistry *JPDRegistry(JPushPlugin *plugin) {
    JPDTestRegistry *registry = [JPDTestRegistry new];
    registry.published = plugin;
    return registry;
}

static UNNotificationResponse *JPDResponse(NSString *requestID, NSTimeInterval time, NSString *action, BOOL remote) {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"handoff-test";
    content.body = @"test-body";
    content.userInfo = @{@"_j_msgid": @123456789, @"route": @"details", @"aps": @{@"alert": @"test"}};
    JPDTestRequest *request = [JPDTestRequest new];
    request.identifier = requestID;
    request.content = content;
    request.trigger = remote ? [JPDTestTrigger new] : nil;
    JPDTestNotification *notification = [JPDTestNotification new];
    notification.request = (id)request;
    notification.date = [NSDate dateWithTimeIntervalSince1970:time];
    JPDTestResponse *response = [JPDTestResponse new];
    response.notification = (id)notification;
    response.actionIdentifier = action;
    return (id)response;
}

static NSDictionary *JPDLaunch(JPushPlugin *plugin) {
    __block NSDictionary *value;
    [plugin handleMethodCall:[FlutterMethodCall methodCallWithMethodName:@"getLaunchAppNotification" arguments:nil]
                      result:^(id result) { value = result; }];
    return value;
}

static NSUInteger JPDQueue(JPushPlugin *plugin) { return [[plugin valueForKey:@"storedCallBackMessage"] count]; }
static void JPDUN(JPushPlugin *plugin, UNNotificationResponse *response) {
    [plugin jpushNotificationCenter:nil didReceiveNotificationResponse:response withCompletionHandler:^{}];
}
static void JPDListen(JPushPlugin *plugin) {
    [plugin handleMethodCall:[FlutterMethodCall methodCallWithMethodName:@"addEventHandler" arguments:@{}]
                      result:^(id result) {}];
}

BOOL JPushRunDeferredHandoffTests(NSObject<FlutterPluginRegistry> *actualRegistry) {
    __block NSUInteger failures = 0;
    __block NSUInteger total = 0;
    void (^check)(NSString *, BOOL) = ^(NSString *name, BOOL passed) {
        total++;
        if (!passed) { failures++; }
        NSLog(@"JPUSH_HANDOFF_TEST %@ %@", passed ? @"PASS" : @"FAIL", name);
    };
    Class service = NSClassFromString(@"JPUSHService");
    Method handle = class_getClassMethod(service, NSSelectorFromString(@"handleRemoteNotification:"));
    Method setup = class_getClassMethod(service, NSSelectorFromString(@"setupWithOption:appKey:channel:apsForProduction:"));
    Method registerConfig = class_getClassMethod(service, NSSelectorFromString(@"registerForRemoteNotificationConfig:delegate:"));
    IMP oldHandle = method_setImplementation(handle, (IMP)JPDHandle);
    IMP oldSetup = method_setImplementation(setup, (IMP)JPDSetup);
    IMP oldRegister = method_setImplementation(registerConfig, (IMP)JPDRegister);
    UNNotificationResponse *response = JPDResponse(@"initial", 100, UNNotificationDefaultActionIdentifier, YES);
    check(@"D01-real-registrar-publishes-instance",
          [[actualRegistry valuePublishedByPlugin:@"JPushPlugin"] isKindOfClass:[JPushPlugin class]]);
    JPushPlugin *plugin = [JPushPlugin new];
    JPDTestRegistry *registry = JPDRegistry(plugin);
    JPDTestRegistry *missing = [JPDTestRegistry new];
    check(@"D02-missing-plugin-fails", ![JPushPlugin acceptSceneLaunchNotificationResponse:response registry:missing]);
    missing.published = [NSNull null];
    check(@"D03-wrong-published-object-fails", ![JPushPlugin acceptSceneLaunchNotificationResponse:response registry:missing]);
    JPDStatistics = 0;
    check(@"D04-sync-cache-before-setup-and-listener",
          [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:registry]
          && [JPDLaunch(plugin)[@"extras"][@"route"] isEqualToString:@"details"]
          && JPDQueue(plugin) == 1 && JPDStatistics == 0);
    check(@"D05-repeated-handoff-idempotent",
          [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:registry] && JPDQueue(plugin) == 1);
    __block BOOL setupResult = NO;
    [plugin handleMethodCall:[FlutterMethodCall methodCallWithMethodName:@"setup"
        arguments:@{@"appKey": @"test-not-a-credential", @"channel": @"test", @"production": @NO, @"debug": @NO}]
        result:^(id result) { setupResult = [result boolValue]; }];
    check(@"D06-setup-flushes-native-once", setupResult && JPDSetupCalls == 1 && JPDStatistics == 1);
    JPDTestChannel *channel = [JPDTestChannel new];
    plugin.channel = (id)channel;
    JPDListen(plugin);
    JPDListen(plugin);
    check(@"D07-late-listener-flushes-once", channel.events.count == 1 && JPDQueue(plugin) == 0);
    JPDUN(plugin, response);
    check(@"D08-un-counterpart-not-repeated", channel.events.count == 1 && JPDStatistics == 1);
    JPDUN(plugin, response);
    check(@"D09-later-same-source-click-allowed", channel.events.count == 2 && JPDStatistics == 2);

    JPushPlugin *earlyUN = [JPushPlugin new];
    JPushPlugin *earlyManual = [JPushPlugin new];
    [earlyUN setValue:@YES forKey:@"hasSetup"];
    [earlyManual setValue:@YES forKey:@"hasSetup"];
    JPDStatistics = 0;
    JPDUN(earlyUN, response);
    [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(earlyManual)];
    [NSThread sleepForTimeInterval:6.1];
    BOOL lateAccepted = [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(earlyUN)];
    JPDUN(earlyManual, response);
    check(@"D10-un-before-manual-over-five-seconds", lateAccepted && JPDQueue(earlyUN) == 1 && JPDLaunch(earlyUN).count > 0);
    check(@"D11-manual-before-un-over-five-seconds", JPDQueue(earlyManual) == 1 && JPDStatistics == 2);
    [earlyManual applicationDidEnterBackground:nil];
    JPDUN(earlyManual, response);
    check(@"D12-background-ends-startup-correlation", JPDQueue(earlyManual) == 2);

    JPushPlugin *other = [JPushPlugin new];
    JPDTestChannel *otherChannel = [JPDTestChannel new];
    other.channel = (id)otherChannel;
    [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(other)];
    JPDListen(other);
    check(@"D13-second-engine-listener-independent", otherChannel.events.count == 1 && channel.events.count == 2);
    check(@"D14-ordinary-start-empty", JPDLaunch([JPushPlugin new]).count == 0);
    check(@"D15-different-second-manual-launch-rejected",
          ![JPushPlugin acceptSceneLaunchNotificationResponse:JPDResponse(@"other", 101, @"open", YES) registry:registry]);
    JPushPlugin *local = [JPushPlugin new];
    JPDStatistics = 0;
    [JPushPlugin acceptSceneLaunchNotificationResponse:JPDResponse(@"local", 100, @"open", NO) registry:JPDRegistry(local)];
    check(@"D16-local-format-no-native-remote-call", [JPDLaunch(local)[@"body"] isEqualToString:@"test-body"] && JPDStatistics == 0);
    JPDUN(local, JPDResponse(@"local", 100, @"other-action", NO));
    JPDUN(local, JPDResponse(@"local", 101, @"open", NO));
    check(@"D17-distinct-action-and-delivery-allowed", JPDQueue(local) == 3);
    JPushPlugin *noSetup = [JPushPlugin new];
    [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(noSetup)];
    [noSetup handleMethodCall:[FlutterMethodCall methodCallWithMethodName:@"getLaunchAppNotification" arguments:nil]
                      result:^(id result) {}];
    check(@"D18-reading-does-not-consume-native-pending", [[noSetup valueForKey:@"pendingRemoteNotificationPayloads"] count] == 1);
    [noSetup applicationDidEnterBackground:nil];
    check(@"D19-same-manual-retry-after-background-idempotent",
          [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(noSetup)] && JPDQueue(noSetup) == 1);
    JPushPlugin *closed = [JPushPlugin new];
    [closed applicationDidEnterBackground:nil];
    check(@"D20-new-handoff-after-initial-connection-closed-fails",
          ![JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(closed)]);
    JPushPlugin *overflow = [JPushPlugin new];
    for (NSUInteger index = 0; index < 33; index++) {
        JPDUN(overflow, JPDResponse([NSString stringWithFormat:@"early-%lu", (unsigned long)index], index, @"open", NO));
    }
    check(@"D21-provenance-overflow-fails-without-cache-write",
          ![JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(overflow)] && JPDLaunch(overflow).count == 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL backgroundAccepted = YES;
    [NSThread detachNewThreadWithBlock:^{
        backgroundAccepted = [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:registry];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    check(@"D22-off-main-fails", !backgroundAccepted);
    [plugin application:nil didFinishLaunchingWithOptions:@{}];
    check(@"D23-empty-app-launch-preserves-accepted-cache", [JPDLaunch(plugin)[@"extras"][@"route"] isEqualToString:@"details"]);
    JPushPlugin *detached = [JPushPlugin new];
    [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(detached)];
    [detached detachFromEngineForRegistrar:nil];
    JPDUN(detached, response);
    check(@"D24-detached-engine-rejects-and-releases-pending",
          ![JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(detached)]
          && JPDQueue(detached) == 0 && [[detached valueForKey:@"pendingRemoteNotificationPayloads"] count] == 0
          && JPDLaunch(detached).count == 0);
    JPushPlugin *textPlugin = [JPushPlugin new];
    UNNotificationResponse *textOne = JPDResponse(@"text", 100, @"reply", NO);
    UNNotificationResponse *textTwo = JPDResponse(@"text", 100, @"reply", NO);
    [(JPDTestResponse *)textOne setUserText:@"one"];
    [(JPDTestResponse *)textTwo setUserText:@"two"];
    [JPushPlugin acceptSceneLaunchNotificationResponse:textOne registry:JPDRegistry(textPlugin)];
    JPDUN(textPlugin, textTwo);
    check(@"D25-different-text-input-not-merged", JPDQueue(textPlugin) == 2);
    JPushPlugin *automatic = [JPushPlugin new];
    JPDTestOptions *options = [JPDTestOptions new];
    options.notificationResponse = response;
    [automatic scene:nil willConnectToSession:nil options:(id)options];
    BOOL autoAccepted = [JPushPlugin acceptSceneLaunchNotificationResponse:response registry:JPDRegistry(automatic)];
    JPDUN(automatic, response);
    check(@"D26-scene-manual-and-un-one-click", autoAccepted && JPDQueue(automatic) == 1);
    method_setImplementation(handle, oldHandle);
    method_setImplementation(setup, oldSetup);
    method_setImplementation(registerConfig, oldRegister);
    NSLog(@"JPUSH_HANDOFF_TEST SUMMARY total=%lu failed=%lu", (unsigned long)total, (unsigned long)failures);
    return failures == 0;
}

// Source-level fixture for the separate Swift -> native API -> Dart smoke path.
UNNotificationResponse *JPushMakeDeferredHandoffFixture(void) {
    return JPDResponse(@"swift-fixture", 200, UNNotificationDefaultActionIdentifier, YES);
}
