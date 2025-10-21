import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> event);

abstract class JPushFlutterInterface {
  static const String flutter_log = "| JPUSH | Flutter | error | ";

  void setup({
    String appKey = '',
    bool production = false,
    String channel = '',
    bool debug = false,
  }) {
    print(flutter_log + "setup:has not been implemented.");
  }

  void setChannelAndSound({
    String channel = '',
    String channelID = '',
    String sound = '',
  }) {
    print(flutter_log + "setChannelAndSound:has not been implemented.");
  }

  void setThirdToken({String token = ''}) {
    print(flutter_log + "setThirdToken:has not been implemented.");
  }

  //APP活跃在前台时是否展示通知
  void setUnShowAtTheForeground({bool unShow = false}) {
    print(flutter_log + "setUnShowAtTheForeground:has not been implemented.");
  }

  void setWakeEnable({bool enable = false}) {
    print(flutter_log + "setWakeEnable:has not been implemented.");
  }

  void enableAutoWakeup({bool enable = false}) {
    print(flutter_log + "enableAutoWakeup:has not been implemented.");
  }

  void setAuth({bool enable = true}) {
    print(flutter_log + "setAuth:has not been implemented.");
  }

  void setLinkMergeEnable({bool enable = true}) {
    print(flutter_log + "setLinkMergeEnable:has not been implemented.");
  }

  void setGeofenceEnable({bool enable = true}) {
    print(flutter_log + "setGeofenceEnable:has not been implemented.");
  }

  void setSmartPushEnable({bool enable = true}) {
    print(flutter_log + "setSmartPushEnable:has not been implemented.");
  }

  void setDataInsightsEnable({bool enable = true}) {
    print(flutter_log + "setDataInsightsEnable:has not been implemented.");
  }

/**
 * 启用SDK本地日志，启动用SDK日志缓存本设备
 *
 * @param enable 是否启用日志（true表示启用，false表示禁用）
 * @param uploadJgToServer 是否将日志上传到极光服务器（true表示上传，false表示不上传）
 */
  void enableSDKLocalLog({bool enable = false, bool uploadJgToServer = false}) {
    print(flutter_log + "enableSDKLocalLog:has not been implemented.");
  }

  ///
  /// 获取所有进程的新增SDK日志
  ///
  /// @param {Function} callback = (String) => {}
  ///
  Future<String> readNewLogs() async {
    print(flutter_log + "readNewLogs:has not been implemented.");
    return "";
  }

  void setCollectControl({
    bool imsi = true, // only android
    bool mac = true, // only android
    bool wifi = true, // only android
    bool bssid = true, // only android
    bool ssid = true, // only android
    bool imei = true, // only android
    bool cell = true, // only android
    bool gps = true, // only ios
  }) {
    print(flutter_log + "setCollectControl:has not been implemented.");
  }

  ///
  /// 初始化 JPush 必须先初始化才能执行其他操作(比如接收事件传递)
  ///
  void addEventHandler({
    EventHandler? onReceiveNotification,
    EventHandler? onOpenNotification,
    EventHandler? onReceiveMessage,
    EventHandler? onReceiveNotificationAuthorization,
    EventHandler? onNotifyMessageUnShow,
    EventHandler? onConnected,
    EventHandler? onInAppMessageClick,
    EventHandler? onInAppMessageShow,
    EventHandler? onNotifyButtonClick,
    EventHandler? onCommandResult,
    EventHandler? onReceiveDeviceToken,
  }) {
    print(flutter_log + "addEventHandler:has not been implemented.");
  }

  void setCallBackHarmony(Function(String eventName, dynamic data) callBack) {
    print(flutter_log + "setCallBackHarmony:has not been implemented.");
  }

  ///
  /// iOS Only
  /// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
  ///
  void applyPushAuthority(
      [NotificationSettingsIOS iosSettings = const NotificationSettingsIOS()]) {
    print(flutter_log + "applyPushAuthority:has not been implemented.");
  }

  // iOS Only
  // 进入页面， pageName：页面名  请与pageLeave配套使用
  void pageEnterTo(String pageName) {
    print(flutter_log + "pageEnterTo:has not been implemented.");
  }

  // iOS Only
  // 离开页面，pageName：页面名， 请与pageEnterTo配套使用
  void pageLeave(String pageName) {
    print(flutter_log + "pageLeave:has not been implemented.");
  }

  ///
  /// 设置 Tag （会覆盖之前设置的 tags）
  ///
  /// @param {Array} params = [String]
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> setTags(List<String> tags) async {
    print(flutter_log + "setTags:has not been implemented.");
    return {};
  }

  ///
  /// 清空所有 tags。
  ///
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> cleanTags() async {
    print(flutter_log + "cleanTags:has not been implemented.");
    return {};
  }

  ///
  /// 在原有 tags 的基础上添加 tags
  ///
  /// @param {Array} tags = [String]
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///

  Future<Map<dynamic, dynamic>> addTags(List<String> tags) async {
    print(flutter_log + "addTags:has not been implemented.");
    return {};
  }

  ///
  /// 删除指定的 tags
  ///
  /// @param {Array} tags = [String]
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> deleteTags(List<String> tags) async {
    print(flutter_log + "deleteTags:has not been implemented.");
    return {};
  }

  ///
  /// 获取所有当前绑定的 tags
  ///
  /// @param {Function} success = ({"tags":[String]}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> getAllTags() async {
    print(flutter_log + "getAllTags:has not been implemented.");
    return {};
  }

  Future<Map<dynamic, dynamic>> getTags(int curr) async {
    print(flutter_log + "getTags:has not been implemented.");
    return {};
  }

  ///
  /// 获取所有当前绑定的 alias
  ///
  /// @param {Function} success = ({"alias":String}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> getAlias() async {
    print(flutter_log + "getAlias:has not been implemented.");
    return {};
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
    print(flutter_log + "setAlias:has not been implemented.");
    return {};
  }

  void testCountryCode(String code) {
    print(flutter_log + "testCountryCode:has not been implemented.");
  }

  ///
  /// 删除原有 alias
  ///
  /// @param {Function} success = ({"alias":String}) => {  }
  /// @param {Function} fail = ({"errorCode":int}) => {  }
  ///
  Future<Map<dynamic, dynamic>> deleteAlias() async {
    print(flutter_log + "deleteAlias:has not been implemented.");
    return {};
  }

  ///
  /// 设置应用 Badge（小红点）
  ///
  /// @param {Int} badge
  ///
  /// 注意：如果是 Android 手机，目前仅支持华为手机
  ///
  Future setBadge(int badge) async {
    print(flutter_log + "setBadge:has not been implemented.");
  }

  Future setHBInterval(int hbinterval) async {
    print(flutter_log + "setHBInterval:has not been implemented.");
  }

  ///
  /// 停止接收推送，调用该方法后应用将不再受到推送，如果想要重新收到推送可以调用 resumePush。
  ///
  Future stopPush() async {
    print(flutter_log + "stopPush:has not been implemented.");
  }

  ///
  /// 恢复推送功能。
  ///
  Future resumePush() async {
    print(flutter_log + "resumePush:has not been implemented.");
  }

  ///
  /// 清空通知栏上的所有通知。
  ///
  Future clearAllNotifications() async {
    print(flutter_log + "clearAllNotifications:has not been implemented.");
  }

  Future clearLocalNotifications() async {
    print(flutter_log + "clearLocalNotifications:has not been implemented.");
  }

  ///
  /// 清空通知栏上某个通知
  /// @param notificationId 通知 id，即：LocalNotification id
  ///
  void clearNotification({int notificationId = 0}) {
    print(flutter_log + "clearNotification:has not been implemented.");
  }

  ///
  /// iOS Only
  /// 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
  /// 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
  /// 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 @{}。
  /// @param {Function} callback = (Object) => {}
  ///
  Future<Map<dynamic, dynamic>> getLaunchAppNotification() async {
    print(flutter_log + "getLaunchAppNotification:has not been implemented.");
    return {};
  }

  ///
  /// 获取 RegistrationId, JPush 可以通过制定 RegistrationId 来进行推送。
  ///
  /// @param {Function} callback = (String) => {}
  ///
  Future<String> getRegistrationID() async {
    print(flutter_log + "getRegistrationID:has not been implemented.");
    return "";
  }

  ///
  /// 发送本地通知到调度器，指定时间出发该通知。
  /// @param {Notification} notification
  ///
  Future<String> sendLocalNotification(LocalNotification notification) async {
    print(flutter_log + "sendLocalNotification:has not been implemented.");
    return "";
  }

  /// 调用此 API 检测通知授权状态是否打开
  Future<bool> isNotificationEnabled() async {
    print(flutter_log + "isNotificationEnabled:has not been implemented.");
    return false;
  }

  /// 调用此 API 跳转至系统设置中应用设置界面
  void openSettingsForNotification() {
    print(
        flutter_log + "openSettingsForNotification:has not been implemented.");
  }

  void requestRequiredPermission() {
    print(flutter_log + "requestRequiredPermission:has not been implemented.");
  }

  /// iOS Only
  /// 设置进入后台是否允许长连接。默认是NO,进入后台会关闭长连接，回到前台会重新接入。请在初始化函数之前调用。
  /// @param enable 是否允许后台长连接
  void setBackgroundEnable({bool enable = false}) {
    print(flutter_log + "setBackgroundEnable:has not been implemented.");
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
