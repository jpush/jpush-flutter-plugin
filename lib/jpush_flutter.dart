import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;


typedef Future<dynamic> EventHandler(Map<String, dynamic> event);

class JPush {
    static const MethodChannel _channel =
        const MethodChannel('jpush');

    static Future<String> get platformVersion async {
      final String version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    }

    static EventHandler _onReceiveNotification;
    static EventHandler _onOpenNotification;
    static EventHandler _onReceiveMessage;

    static void setup({
      String appKey,
      String channel,
      bool production,
      }) {
      _channel.invokeMethod('setup', { 'appKey': appKey, 'channel': channel, 'production': production });
    }
    ///
    /// 初始化 JPush 必须先初始化才能执行其他操作(比如接收事件传递)
    ///
    static void addEventHandler({
      EventHandler onReceiveNotification,
      EventHandler onOpenNotification,
      EventHandler onReceiveMessage,
    }) {
      _onReceiveNotification = onReceiveNotification;
      _onOpenNotification = onOpenNotification;
      _onReceiveMessage = onReceiveMessage;
      _channel.setMethodCallHandler(_handleMethod);
    }

    static Future<Null> _handleMethod(MethodCall call) async {
      switch (call.method) {
        case "onReceiveNotification":
          return _onReceiveNotification(call.arguments.cast<String, dynamic>());
        case "onOpenNotification":
          return _onOpenNotification(call.arguments.cast<String, dynamic>());
        case "onReceiveMessage":
          return _onReceiveMessage(call.arguments.cast<String, dynamic>());
        default:
          throw new UnsupportedError("Unrecognized Event");
      }
    }

    ///
    /// 申请推送权限当，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
    ///
    static Future applyPushAuthority([NotificationSettingsIOS iosSettings = const NotificationSettingsIOS()]) {

        if (!Platform.isIOS) {
          return;
        }

        _channel.invokeMethod('applyPushAuthority', iosSettings.toMap());
    }
    
    ///
    /// 设置 Tag （会覆盖之前设置的 tags）
    /// 
    /// @param {Array} params = [String]
    /// @param {Function} success = ({"tags":[String]}) => {  }
    /// @param {Function} fail = ({"errorCode":int}) => {  }
    ///
    static Future<Map<dynamic, dynamic>> setTags(List<String> tags) async {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('setTags', tags);
      return result;
    }

    ///
    /// 清空所有 tags。
    /// 
    /// @param {Function} success = ({"tags":[String]}) => {  }
    /// @param {Function} fail = ({"errorCode":int}) => {  }
    ///
    static Future<Map<dynamic, dynamic>> cleanTags() async {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('cleanTags');
      return result;
    }
    
    ///
    /// 在原有 tags 的基础上添加 tags
    /// 
    /// @param {Array} tags = [String]
    /// @param {Function} success = ({"tags":[String]}) => {  }
    /// @param {Function} fail = ({"errorCode":int}) => {  }
    ///

    static Future<Map<dynamic, dynamic>> addTags(List<String> tags) async {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('addTags', tags);
      return result;
    }
    
    ///
    /// 删除指定的 tags
    /// 
    /// @param {Array} tags = [String]
    /// @param {Function} success = ({"tags":[String]}) => {  }
    /// @param {Function} fail = ({"errorCode":int}) => {  }
    ///
    static Future<Map<dynamic, dynamic>> deleteTags(List<String> tags) async {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('deleteTags', tags);
      return result;
    }
    
    ///
    /// 获取所有当前绑定的 tags
    /// 
    /// @param {Function} success = ({"tags":[String]}) => {  }
    /// @param {Function} fail = ({"errorCode":int}) => {  }
    ///
    static Future<Map<dynamic, dynamic>> getAllTags() async {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getAllTags');
      return result;
    }
    
    ///
    /// 重置 alias.
    /// 
    /// @param {String} alias
    /// 
    /// @param {Function} success = ({"alias":String}) => {  }
    /// @param {Function} fail = ({"errorCode":int}) => {  }
    ///
    static Future<Map<dynamic, dynamic>> setAlias(String alias) async {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('setAlias', alias);
      return result;
    }

    ///
    /// 删除原有 alias
    /// 
    /// @param {Function} success = ({"alias":String}) => {  }
    /// @param {Function} fail = ({"errorCode":int}) => {  }
    ///
    static Future<Map<dynamic, dynamic>> deleteAlias() async {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('deleteAlias');
      return result;
    }
    
    ///
    /// iOS Only
    /// 设置应用 Badge（小红点）
    /// 
    /// @param {Int} badge
    ///
    static Future setBadge(int badge) async {
      await _channel.invokeMethod('setBadge', badge);
    }

    ///
    /// 停止接收推送，调用该方法后应用将不再受到推送，如果想要重新收到推送可以调用 resumePush。
    ///
    static Future stopPush() async {
      await _channel.invokeMethod('stopPush');
    }
    
    ///
    /// 恢复推送功能。
    ///
    static Future resumePush() async {
      await _channel.invokeMethod('resumePush');
    }
    
    ///
    /// 清空通知栏上的所有通知。
    ///
    static Future clearAllNotifications() async {
      await _channel.invokeMethod('clearAllNotifications');
    }
    
    ///
    /// iOS Only
    /// 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
    /// 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
    /// 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 @{}。
    /// @param {Function} callback = (Object) => {}
    ///
    static Future<Map<dynamic, dynamic>> getLaunchAppNotification() async {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getLaunchAppNotification');
      return result;
    }

    ///
    /// 获取 RegistrationId, JPush 可以通过制定 RegistrationId 来进行推送。
    /// 
    /// @param {Function} callback = (String) => {}
    ///
    static Future<String> getRegistrationID() async {
      final String rid = await _channel.invokeMethod('getRegistrationID');
      return rid;
    }
}

class NotificationSettingsIOS {
  final bool sound;
  final bool alert;
  final bool badge;

  const NotificationSettingsIOS ({
    this.sound = true,
    this.alert = true,
    this.badge = true,
  });

  Map<String, dynamic> toMap() {
    return <String, bool>{'sound': sound, 'alert': alert, 'badge': badge};
  }
}

