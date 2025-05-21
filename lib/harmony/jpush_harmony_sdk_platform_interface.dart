import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jpush_harmony_sdk_method_channel.dart';

abstract class JpushHarmonySdkPlatform extends PlatformInterface {
  /// Constructs a JpushHarmonySdkPlatform.
  JpushHarmonySdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static JpushHarmonySdkPlatform _instance = MethodChannelJpushHarmonySdk();

  /// The default instance of [JpushHarmonySdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelJpushHarmonySdk].
  static JpushHarmonySdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JpushHarmonySdkPlatform] when
  /// they register themselves.
  static set instance(JpushHarmonySdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void setCallBack(Function(String eventName, dynamic data) callBack) {
    throw UnimplementedError('setCallBack() has not been implemented.');
  }

  void setDebug(bool b) {
    throw UnimplementedError('setDebug() has not been implemented.');
  }

  setAppKey(String appKey) {
    throw UnimplementedError('setAppKey() has not been implemented.');
  }

  setChannel(String channel) {
    throw UnimplementedError('setChannel() has not been implemented.');
  }

  init() {
    throw UnimplementedError('init() has not been implemented.');
  }
  
  Future<String> getRegistrationId() {
    throw UnimplementedError('getRegistrationId() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>> setTags(int sequence, List<String> tags) {
    throw UnimplementedError('setTags() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>> addTags(int sequence, List<String> tags) {
    throw UnimplementedError('addTags() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>> deleteTags(int sequence, List<String> tags) {
    throw UnimplementedError('deleteTags() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>>  cleanTags(int sequence) {
    throw UnimplementedError('cleanTags() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>> getTags(int sequence, int curr) {
    throw UnimplementedError('getTags() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>>  checkTagBindState(int sequence, String tag) {
    throw UnimplementedError('checkTagBindState() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>>  setAlias(int sequence, String alias) {
    throw UnimplementedError('setAlias() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>>  deleteAlias(int sequence) {
    throw UnimplementedError('deleteAlias() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>>  getAlias(int sequence) {
    throw UnimplementedError('getAlias() has not been implemented.');
  }

  stopPush() {
    throw UnimplementedError('stopPush() has not been implemented.');
  }

  resumePush() {
    throw UnimplementedError('resumePush() has not been implemented.');
  }

  Future<bool?> isPushStopped() {
    throw UnimplementedError('isPushStopped() has not been implemented.');
  }

  setBadgeNumber(int badgeNumber) {
    throw UnimplementedError('setBadgeNumber() has not been implemented.');
  }

  setHeartbeatTime(int heartbeatTime) {
    throw UnimplementedError('setHeartbeatTime() has not been implemented.');
  }
}
