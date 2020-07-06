#import "JPushPlugin.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import <JPush/JPUSHService.h>

#define JPLog(fmt, ...) NSLog((@"| JPUSH | Flutter | iOS | " fmt), ##__VA_ARGS__)

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                               message:self.domain
                               details:self.localizedDescription];
}
@end


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface JPushPlugin ()<JPUSHRegisterDelegate>
@end
#endif

static NSMutableArray<FlutterResult>* getRidResults;

@implementation JPushPlugin {
    NSDictionary *_launchNotification;
    NSDictionary *_completeLaunchNotification;
    BOOL _isJPushDidLogin;
    JPAuthorizationOptions notificationTypes;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    getRidResults = @[].mutableCopy;
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"jpush"
                                     binaryMessenger:[registrar messenger]];
    JPushPlugin* instance = [[JPushPlugin alloc] init];
    instance.channel = channel;
    
    
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    notificationTypes = 0;
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter removeObserver:self];
    
    
    [defaultCenter addObserver:self
                      selector:@selector(networkConnecting:)
                          name:kJPFNetworkIsConnectingNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(networkRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    return self;
}

- (void)networkConnecting:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkRegister:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkDidSetup:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkDidClose:(NSNotification *)notification {
    _isJPushDidLogin = false;
}


- (void)networkDidLogin:(NSNotification *)notification {
    _isJPushDidLogin = YES;
    for (FlutterResult result in getRidResults) {
        result([JPUSHService registrationID]);
    }
    [getRidResults removeAllObjects];
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    [_channel invokeMethod:@"onReceiveMessage" arguments: [notification userInfo]];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"handleMethodCall:%@",call.method);
    
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if([@"setup" isEqualToString:call.method]) {
        [self setup:call result: result];
    } else if([@"applyPushAuthority" isEqualToString:call.method]) {
        [self applyPushAuthority:call result:result];
    } else if([@"setTags" isEqualToString:call.method]) {
        [self setTags:call result:result];
    } else if([@"cleanTags" isEqualToString:call.method]) {
        [self cleanTags:call result:result];
    } else if([@"addTags" isEqualToString:call.method]) {
        [self addTags:call result:result];
    } else if([@"deleteTags" isEqualToString:call.method]) {
        [self deleteTags:call result:result];
    } else if([@"getAllTags" isEqualToString:call.method]) {
        [self getAllTags:call result:result];
    } else if([@"setAlias" isEqualToString:call.method]) {
        [self setAlias:call result:result];
    } else if([@"deleteAlias" isEqualToString:call.method]) {
        [self deleteAlias:call result:result];
    } else if([@"setBadge" isEqualToString:call.method]) {
        [self setBadge:call result:result];
    } else if([@"stopPush" isEqualToString:call.method]) {
        [self stopPush:call result:result];
    } else if([@"resumePush" isEqualToString:call.method]) {
        JPLog(@"ios platform not support resume push.");
        //[self applyPushAuthority:call result:result];
    } else if([@"clearAllNotifications" isEqualToString:call.method]) {
        [self clearAllNotifications:call result:result];
    } else if ([@"clearNotification" isEqualToString:call.method]) {
        [self clearNotification:call result:result];
    } else if([@"getLaunchAppNotification" isEqualToString:call.method]) {
        [self getLaunchAppNotification:call result:result];
    } else if([@"getRegistrationID" isEqualToString:call.method]) {
        [self getRegistrationID:call result:result];
    } else if([@"sendLocalNotification"isEqualToString:call.method]) {
        [self sendLocalNotification:call result:result];
    } else if([@"isNotificationEnabled"isEqualToString:call.method]) {
        [self isNotificationEnabled:call result:result];
    } else if([@"openSettingsForNotification"isEqualToString:call.method]) {
        [self openSettingsForNotification];
    } else{
        result(FlutterMethodNotImplemented);
    }
}




- (void)setup:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"setup:");
    NSDictionary *arguments = call.arguments;
    NSNumber *debug = arguments[@"debug"];
    if ([debug boolValue]) {
        [JPUSHService setDebugMode];
    } else {
        [JPUSHService setLogOFF];
    }
    
    [JPUSHService setupWithOption:_completeLaunchNotification
                           appKey:arguments[@"appKey"]
                          channel:arguments[@"channel"]
                 apsForProduction:[arguments[@"production"] boolValue]];
}

- (void)applyPushAuthority:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"applyPushAuthority:%@",call.arguments);
    notificationTypes = 0;
    NSDictionary *arguments = call.arguments;
    if ([arguments[@"sound"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionSound;
    }
    if ([arguments[@"alert"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionAlert;
    }
    if ([arguments[@"badge"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionBadge;
    }
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = notificationTypes;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
}

- (void)setTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"setTags:%@",call.arguments);
    NSSet *tagSet;
    
    if (call.arguments != NULL) {
        tagSet = [NSSet setWithArray: call.arguments];
    }
    
    [JPUSHService setTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            result(@{@"tags": [iTags allObjects] ?: @[]});
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"JPush.Flutter" code:iResCode userInfo:nil];
            result([error flutterError]);
        }
    } seq: 0];
}

- (void)cleanTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"cleanTags:");
    [JPUSHService cleanTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            result(@{@"tags": iTags ? [iTags allObjects] : @[]});
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"JPush.Flutter" code:iResCode userInfo:nil];
            result([error flutterError]);
        }
    } seq: 0];
}

- (void)addTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"addTags:%@",call.arguments);
    NSSet *tagSet;
    
    if (call.arguments != NULL) {
        tagSet = [NSSet setWithArray:call.arguments];
    }
    
    [JPUSHService addTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            result(@{@"tags": [iTags allObjects] ?: @[]});
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"JPush.Flutter" code:iResCode userInfo:nil];
            result([error flutterError]);
        }
    } seq: 0];
}

- (void)deleteTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"deleteTags:%@",call.arguments);
    NSSet *tagSet;
    
    if (call.arguments != NULL) {
        tagSet = [NSSet setWithArray:call.arguments];
    }
    
    [JPUSHService deleteTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            result(@{@"tags": [iTags allObjects] ?: @[]});
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"JPush.Flutter" code:iResCode userInfo:nil];
            result([error flutterError]);
        }
    } seq: 0];
}

- (void)getAllTags:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"getAllTags:");
    [JPUSHService getAllTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            result(@{@"tags": iTags ? [iTags allObjects] : @[]});
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"JPush.Flutter" code:iResCode userInfo:nil];
            result([error flutterError]);
        }
    } seq: 0];
}

- (void)setAlias:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"setAlias:%@",call.arguments);
    NSString *alias = call.arguments;
    [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        if (iResCode == 0) {
            result(@{@"alias": iAlias ?: @""});
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"JPush.Flutter" code:iResCode userInfo:nil];
            result([error flutterError]);
        }
    } seq: 0];
}

- (void)deleteAlias:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"deleteAlias:%@",call.arguments);
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        if (iResCode == 0) {
            result(@{@"alias": iAlias ?: @""});
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"JPush.Flutter" code:iResCode userInfo:nil];
            result([error flutterError]);
        }
    } seq: 0];
}

- (void)setBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"setBadge:%@",call.arguments);
    NSInteger badge = [call.arguments[@"badge"] integerValue];
    if (badge < 0) {
        badge = 0;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: badge];
    [JPUSHService setBadge: badge];
}

- (void)stopPush:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"stopPush:");
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}
- (void)clearAllNotifications:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"clearAllNotifications:");
    
    if (@available(iOS 10.0, *)) {
        //iOS 10 以上支持
        JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
        identifier.identifiers = nil;
        identifier.delivered = YES;  //等于 YES 则移除所有在通知中心显示的，等于 NO 则为移除所有待推送的
        [JPUSHService removeNotification:identifier];
    } else {
        // iOS 10 以下移除所有推送；iOS 10 以上移除所有在通知中心显示推送和待推送请求
        [JPUSHService removeNotification:nil];
    }
}
- (void)clearNotification:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"clearNotification:");
    
    NSNumber *notificationId = call.arguments;
    if (!notificationId) {
        return ;
    }
    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
    identifier.identifiers = @[notificationId.stringValue];
    
    if (@available(iOS 10.0, *)) {
        //iOS 10 以上有效，等于 YES 则在通知中心显示的里面移除，等于 NO 则为在待推送的里面移除；iOS 10 以下无效
        identifier.delivered = YES;
    } else {
        // Fallback on earlier versions
    }
    [JPUSHService removeNotification:identifier];
}

- (void)getLaunchAppNotification:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"getLaunchAppNotification");
    result(_launchNotification == nil ? @{}: _launchNotification);
}

- (void)getRegistrationID:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"getRegistrationID:");
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSLog(@"simulator can not get registrationid");
    result(@"");
#elif TARGET_OS_IPHONE//真机
    
    
    if ([JPUSHService registrationID] != nil && ![[JPUSHService registrationID] isEqualToString:@""]) {
        // 如果已经成功获取 registrationID，从本地获取直接缓存
        result([JPUSHService registrationID]);
        return;
    }
    
    if (_isJPushDidLogin) {// 第一次获取未登录情况
        result(@[[JPUSHService registrationID]]);
    } else {
        [getRidResults addObject:result];
    }
#endif
}

- (void)sendLocalNotification:(FlutterMethodCall*)call result:(FlutterResult)result {
    JPLog(@"sendLocalNotification:%@",call.arguments);
    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    NSDictionary *params = call.arguments;
    if (params[@"title"]) {
        content.title = params[@"title"];
    }
    
    if (params[@"subtitle"] && ![params[@"subtitle"] isEqualToString:@"<null>"]) {
        content.subtitle = params[@"subtitle"];
    }
    
    if (params[@"content"]) {
        content.body = params[@"content"];
    }
    
    if (params[@"badge"]) {
        content.badge = params[@"badge"];
    }
    
    if (params[@"action"] && ![params[@"action"] isEqualToString:@"<null>"]) {
        content.action = params[@"action"];
    }
    
    if ([params[@"extra"] isKindOfClass:[NSDictionary class]]) {
        content.userInfo = params[@"extra"];
    }
    
    if (params[@"sound"] && ![params[@"sound"] isEqualToString:@"<null>"]) {
        content.sound = params[@"sound"];
    }
    
    JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        if (params[@"fireTime"]) {
            NSNumber *date = params[@"fireTime"];
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval interval = [date doubleValue]/1000 - currentInterval;
            interval = interval>0?interval:0;
            trigger.timeInterval = interval;
        }
    }
    
    else {
        if (params[@"fireTime"]) {
            NSNumber *date = params[@"fireTime"];
            trigger.fireDate = [NSDate dateWithTimeIntervalSince1970: [date doubleValue]/1000];
        }
    }
    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
    request.content = content;
    request.trigger = trigger;
    
    if (params[@"id"]) {
        NSNumber *identify = params[@"id"];
        request.requestIdentifier = [identify stringValue];
    }
    request.completionHandler = ^(id result) {
        NSLog(@"result");
    };
    
    [JPUSHService addNotification:request];
    
    result(@[@[]]);
}

/// 检查当前应用的通知开关是否开启
- (void)isNotificationEnabled:(FlutterMethodCall*)call result:(FlutterResult)result  {
    JPLog(@"isNotificationEnabled:");
    [JPUSHService requestNotificationAuthorization:^(JPAuthorizationStatus status) {
        BOOL isEnabled = NO;
        if (status == JPAuthorizationStatusAuthorized) {
            isEnabled = YES;
        }
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isEnabled],@"isEnabled", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            result(dict);
        });
    }];
   
    
}
- (void)openSettingsForNotification {
    JPLog(@"openSettingsForNotification:");
    [JPUSHService openSettingsForNotification:^(BOOL success) {
        JPLog(@"openSettingsForNotification: %@",@(success));
    }];
}



- (void)dealloc {
    _isJPushDidLogin = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _completeLaunchNotification = launchOptions;
    if (launchOptions != nil) {
        _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        _launchNotification = [self jpushFormatAPNSDic:_launchNotification.copy];
    }
    
    if ([launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification *localNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        NSMutableDictionary *localNotificationEvent = @{}.mutableCopy;
        localNotificationEvent[@"content"] = localNotification.alertBody;
        localNotificationEvent[@"badge"] = @(localNotification.applicationIconBadgeNumber);
        localNotificationEvent[@"extras"] = localNotification.userInfo;
        localNotificationEvent[@"fireTime"] = [NSNumber numberWithLong:[localNotification.fireDate timeIntervalSince1970] * 1000];
        localNotificationEvent[@"soundName"] = [localNotification.soundName isEqualToString:UILocalNotificationDefaultSoundName] ? @"" : localNotification.soundName;
        
        if (@available(iOS 8.2, *)) {
            localNotificationEvent[@"title"] = localNotification.alertTitle;
        }
        _launchNotification = localNotificationEvent;
    }
    //[self performSelector:@selector(addNotificationWithDateTrigger) withObject:nil afterDelay:2];
    return YES;
}
- (void)addNotificationWithDateTrigger {
  
    JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
    
    if (@available(iOS 10.0, *)) {
        trigger.timeInterval = 10;
    } else {
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
        trigger.fireDate = fireDate;
    }
    
    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    content.title = @"title";
    content.subtitle = @"subtitle";
    content.body = @"body";
    content.badge = @(1);
    content.action = @"action";
    content.categoryIdentifier = @"categoryIdentifier";
    content.threadIdentifier = @"threadIdentifier";
    
  JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
  request.content = content;
  request.trigger = trigger;
  request.completionHandler = ^(id result) {
    // iOS10以上成功则result为UNNotificationRequest对象，失败则result为nil
    // iOS10以下成功result为UILocalNotification对象，失败则result为nil
    if (result) {
      NSLog(@"添加日期通知成功 --- %@", result);
    }
  };
  request.requestIdentifier = @"123";
  [JPUSHService addNotification:request];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //  _resumingFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //  application.applicationIconBadgeNumber = 1;
    //  application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSDictionary *settingsDictionary = @{
        @"sound" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeSound],
        @"badge" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeBadge],
        @"alert" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeAlert],
    };
    [_channel invokeMethod:@"onIosSettingsRegistered" arguments:settingsDictionary];
}

- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    JPLog(@"application:didReceiveRemoteNotification:fetchCompletionHandler");
    
    [JPUSHService handleRemoteNotification:userInfo];
    [_channel invokeMethod:@"onReceiveNotification" arguments:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    return YES;
}

// iOS 10 以下点击本地通知
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    JPLog(@"application:didReceiveLocalNotification:");
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *title = @"";
    if (@available(iOS 8.2, *)) {
        title = notification.alertTitle;
    } else {
        // Fallback on earlier versions
    }
    
    NSString *body = notification.alertBody;
    NSString *action = notification.alertAction;
    
    [dic setValue:title?:@"" forKey:@"title"];
    [dic setValue:body?:@"" forKey:@"body"];
    [dic setValue:action?:@"" forKey:@"action"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.channel invokeMethod:@"onOpenNotification" arguments:dic];
    });
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    JPLog(@"jpushNotificationCenter:willPresentNotification::");
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [_channel invokeMethod:@"onReceiveNotification" arguments: [self jpushFormatAPNSDic:userInfo]];
    }else{
        JPLog(@"iOS10 前台收到本地通知:userInfo：%@",userInfo);
    }
    
    completionHandler(notificationTypes);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler  API_AVAILABLE(ios(10.0)){
    JPLog(@"jpushNotificationCenter:didReceiveNotificationResponse::");
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [_channel invokeMethod:@"onOpenNotification" arguments: [self jpushFormatAPNSDic:userInfo]];
    }else{
        // iOS 10 以上点击本地通知
        JPLog(@"iOS10 点击本地通知");
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *identifier = response.notification.request.identifier;
        NSString *body = response.notification.request.content.body;
        NSString *categoryIdentifier = response.notification.request.content.categoryIdentifier;
        NSString *title = response.notification.request.content.title;
        NSString *subtitle = response.notification.request.content.subtitle;
        NSString *threadIdentifier = response.notification.request.content.threadIdentifier;
        
        [dic setValue:body?:@"" forKey:@"body"];
        [dic setValue:title?:@"" forKey:@"title"];
        [dic setValue:subtitle?:@"" forKey:@"subtitle"];
        [dic setValue:identifier?:@"" forKey:@"identifier"];
        [dic setValue:threadIdentifier?:@"" forKey:@"threadIdentifier"];
        [dic setValue:categoryIdentifier?:@"" forKey:@"categoryIdentifier"];
        if (userInfo && userInfo.count) {
            NSMutableDictionary *extras = [NSMutableDictionary dictionary];
            for (NSString *key in userInfo) {
                extras[key] = userInfo[key];
            }
            dic[@"extras"] = extras;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.channel invokeMethod:@"onOpenNotification" arguments:dic];
        });
    }
    completionHandler();
}

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
   JPLog(@"");
    BOOL isEnabled = NO;
    if (status == JPAuthorizationStatusAuthorized) {
        isEnabled = YES;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isEnabled],@"isEnabled", nil];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongself = weakself;
        [strongself.channel invokeMethod:@"onReceiveNotificationAuthorization" arguments: dict];
    });
}
- (NSMutableDictionary *)jpushFormatAPNSDic:(NSDictionary *)dic {
    NSMutableDictionary *extras = @{}.mutableCopy;
    for (NSString *key in dic) {
        if([key isEqualToString:@"_j_business"]      ||
           [key isEqualToString:@"_j_msgid"]         ||
           [key isEqualToString:@"_j_uid"]           ||
           [key isEqualToString:@"actionIdentifier"] ||
           [key isEqualToString:@"aps"]) {
            continue;
        }
        extras[key] = dic[key];
    }
    NSMutableDictionary *formatDic = dic.mutableCopy;
    formatDic[@"extras"] = extras;
    return formatDic;
}

@end
