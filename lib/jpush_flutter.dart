import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> event);

class JPush {
  static const String flutter_log = "| JPUSH | Flutter | ";

  factory JPush() => _instance;

  final MethodChannel _channel;
  final Platform _platform;

  @visibleForTesting
  JPush.private(MethodChannel channel, Platform platform)
      : _channel = channel,
        _platform = platform;

  static final JPush _instance =
      new JPush.private(const MethodChannel('jpush'), const LocalPlatform());

  EventHandler? _onReceiveNotification;
  EventHandler? _onOpenNotification;
  EventHandler? _onReceiveMessage;
  EventHandler? _onReceiveNotificationAuthorization;

  void setup({
    String appKey = '',
    bool production = false,
    String channel = '',
    bool debug = false,
  }) {
    print(flutter_log + "setup:");

    _channel.invokeMethod('setup', {
      'appKey': appKey,
      'channel': channel,
      'production': production,
      'debug': debug
    });
  }

  void setWakeEnable({bool enable = false}) {
    _channel.invokeMethod('setWakeEnable', {'enable': enable});
  }

  ///
  /// 初始化 JPush 必须先初始化才能执行其他操作(比如接收事件传递)
  ///
  void addEventHandler({
    EventHandler? onReceiveNotification,
    EventHandler? onOpenNotification,
    EventHandler? onReceiveMessage,
    EventHandler? onReceiveNotificationAuthorization,
  }) {
    print(flutter_log + "addEventHandler:");

    _onReceiveNotification = onReceiveNotification;
    _onOpenNotification = onOpenNotification;
    _onReceiveMessage = onReceiveMessage;
    _onReceiveNotificationAuthorization = onReceiveNotificationAuthorization;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print(flutter_log + "_handleMethod:");

    switch (call.method) {
      case "onReceiveNotification":
        return _onReceiveNotification!(call.arguments.cast<String, dynamic>());
      case "onOpenNotification":
        return _onOpenNotification!(call.arguments.cast<String, dynamic>());
      case "onReceiveMessage":
        return _onReceiveMessage!(call.arguments.cast<String, dynamic>());
      case "onReceiveNotificationAuthorization":
        return _onReceiveNotificationAuthorization!(
            call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }

  ///
  /// iOS Only
  /// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
  ///
  void applyPushAuthority(
      [NotificationSettingsIOS iosSettings = const NotificationSettingsIOS()]) {
    print(flutter_log + "applyPushAuthority:");

    if (!_platform.isIOS) {
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
  Future<Map<dynamic, dynamic>> setTags(List<String> tags) async {
    print(flutter_log + "setTags:");

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('setTags', tags);
    return result;
  }

  ///
  /// 清空所有 tags。
  ///
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> cleanTags() async {
    print(flutter_log + "cleanTags:");

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('cleanTags');
    return result;
  }

  ///
  /// 在原有 tags 的基础上添加 tags
  ///
  /// @param {Array} tags = [String]
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///

  Future<Map<dynamic, dynamic>> addTags(List<String> tags) async {
    print(flutter_log + "addTags:");

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('addTags', tags);
    return result;
  }

  ///
  /// 删除指定的 tags
  ///
  /// @param {Array} tags = [String]
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> deleteTags(List<String> tags) async {
    print(flutter_log + "deleteTags:");

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('deleteTags', tags);
    return result;
  }

  ///
  /// 获取所有当前绑定的 tags
  ///
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> getAllTags() async {
    print(flutter_log + "getAllTags:");

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('getAllTags');
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
  Future<Map<dynamic, dynamic>> setAlias(String alias) async {
    print(flutter_log + "setAlias:");

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('setAlias', alias);
    return result;
  }

  ///
  /// 删除原有 alias
  ///
  /// @param {Function} success = ({"alias":String}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> deleteAlias() async {
    print(flutter_log + "deleteAlias:");

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('deleteAlias');
    return result;
  }

  ///
  /// 设置应用 Badge（小红点）
  ///
  /// @param {Int} badge
  ///
  /// 注意：如果是 Android 手机，目前仅支持华为手机
  ///
  Future setBadge(int badge) async {
    print(flutter_log + "setBadge:");

    await _channel.invokeMethod('setBadge', {"badge": badge});
  }

  ///
  /// 停止接收推送，调用该方法后应用将不再受到推送，如果想要重新收到推送可以调用 resumePush。
  ///
  Future stopPush() async {
    print(flutter_log + "stopPush:");

    await _channel.invokeMethod('stopPush');
  }

  ///
  /// 恢复推送功能。
  ///
  Future resumePush() async {
    print(flutter_log + "resumePush:");

    await _channel.invokeMethod('resumePush');
  }

  ///
  /// 清空通知栏上的所有通知。
  ///
  Future clearAllNotifications() async {
    print(flutter_log + "clearAllNotifications:");

    await _channel.invokeMethod('clearAllNotifications');
  }

  ///
  /// 清空通知栏上某个通知
  /// @param notificationId 通知 id，即：LocalNotification id
  ///
  void clearNotification({int notificationId = 0}) {
    print(flutter_log + "clearNotification:");
    _channel.invokeListMethod("clearNotification", notificationId);
  }

  ///
  /// iOS Only
  /// 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
  /// 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
  /// 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 @{}。
  /// @param {Function} callback = (Object) => {}
  ///
  Future<Map<dynamic, dynamic>> getLaunchAppNotification() async {
    print(flutter_log + "getLaunchAppNotification:");

    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('getLaunchAppNotification');
    return result;
  }

  ///
  /// 获取 RegistrationId, JPush 可以通过制定 RegistrationId 来进行推送。
  ///
  /// @param {Function} callback = (String) => {}
  ///
  Future<String> getRegistrationID() async {
    print(flutter_log + "getRegistrationID:");

    final String rid = await _channel.invokeMethod('getRegistrationID');
    return rid;
  }

  ///
  /// 发送本地通知到调度器，指定时间出发该通知。
  /// @param {Notification} notification
  ///
  Future<String> sendLocalNotification(LocalNotification notification) async {
    print(flutter_log + "sendLocalNotification:");

    await _channel.invokeMethod('sendLocalNotification', notification.toMap());

    return notification.toMap().toString();
  }

  /// 调用此 API 检测通知授权状态是否打开
  Future<bool> isNotificationEnabled() async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('isNotificationEnabled');
    bool isEnabled = result["isEnabled"];
    return isEnabled;
  }

  /// 调用此 API 跳转至系统设置中应用设置界面
  void openSettingsForNotification() {
    _channel.invokeMethod('openSettingsForNotification');
  }
}

class NotificationSettingsIOS {
  final bool sound;
  final bool alert;
  final bool badge;

  const NotificationSettingsIOS({
    this.sound = true,
    this.alert = true,
    this.badge = true,
  });

  Map<String, dynamic> toMap() {
    return <String, bool>{'sound': sound, 'alert': alert, 'badge': badge};
  }
}

/// @property {number} [buildId] - 通知样式：1 为基础样式，2 为自定义样式（需先调用 `setStyleCustom` 设置自定义样式）
/// @property {number} [id] - 通知 id, 可用于取消通知
/// @property {string} [title] - 通知标题
/// @property {string} [content] - 通知内容
/// @property {object} [extra] - extra 字段
/// @property {number} [fireTime] - 通知触发时间（毫秒）
/// // iOS Only
/// @property {number} [badge] - 本地推送触发后应用角标值
/// // iOS Only
/// @property {string} [soundName] - 指定推送的音频文件
/// // iOS 10+ Only
/// @property {string} [subtitle] - 子标题
class LocalNotification {
  final int? buildId; //?
  final int? id;
  final String? title;
  final String? content;
  final Map<String, String>? extra; //?
  final DateTime? fireTime;
  final int? badge; //?
  final String? soundName; //?
  final String? subtitle; //?

  const LocalNotification(
      {@required this.id,
      @required this.title,
      @required this.content,
      @required this.fireTime,
      this.buildId,
      this.extra,
      this.badge = 0,
      this.soundName,
      this.subtitle})
      : assert(id != null),
        assert(title != null),
        assert(content != null),
        assert(fireTime != null);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'fireTime': fireTime?.millisecondsSinceEpoch,
      'buildId': buildId,
      'extra': extra,
      'badge': badge,
      'soundName': soundName,
      'subtitle': subtitle
    }..removeWhere((key, value) => value == null);
  }
}
