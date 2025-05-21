import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jpush_harmony_sdk_platform_interface.dart';

/// An implementation of [JpushHarmonySdkPlatform] that uses method channels.
class MethodChannelJpushHarmonySdk extends JpushHarmonySdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('jpush');

  final String flutter_log = "| Harmony-Flutter | ";
  void Function(String eventName, dynamic data)? callBack = null;
  bool debug = true;

  @override
  void setCallBack(Function(String eventName, dynamic data) callBack) {
    this.callBack = callBack;
    methodChannel.setMethodCallHandler((call) async {
      if (null != call) {
        if (null != this.callBack) {
          printMy("callBack, call:" + call.toString());
          this.callBack?.call(call.method, call.arguments);
        } else {
          printMy("no has callBack, method:" + call.method);
        }
      } else {
        printMy("call null");
      }
    });
  }

  void setDebug(bool b) {
    this.debug = b;
    methodChannel.invokeMethod("setDebug", b);
  }

  setAppKey(String appKey) {
    methodChannel.invokeMethod("setAppKey", appKey);
  }

  setChannel(String channel) {
    methodChannel.invokeMethod("setChannel", channel);
  }

  init() {
    methodChannel.invokeMethod("init");
  }
  
  Future<String> getRegistrationId() async {
    return await methodChannel.invokeMethod("getRegistrationId");
  }

  Future<Map<dynamic, dynamic>> setTags(int sequence, List<String> tags) async {
   return await methodChannel.invokeMethod("setTags", {"sequence": sequence, "tags": tags});
  }

  Future<Map<dynamic, dynamic>>  addTags(int sequence, List<String> tags) async {
    return await methodChannel.invokeMethod("addTags", {"sequence": sequence, "tags": tags});
  }

  Future<Map<dynamic, dynamic>>  deleteTags(int sequence, List<String> tags) async {
    return await  methodChannel.invokeMethod(
        "deleteTags", {"sequence": sequence, "tags": tags});
  }

  Future<Map<dynamic, dynamic>> cleanTags(int sequence) async {
    return await methodChannel.invokeMethod("cleanTags", sequence);
  }

  Future<Map<dynamic, dynamic>> getTags(int sequence, int curr) async {
    return await  methodChannel.invokeMethod("getTags", {"sequence": sequence, "curr": curr});
  }

  Future<Map<dynamic, dynamic>> checkTagBindState(int sequence, String tag) async {
    return await  methodChannel.invokeMethod(
        "checkTagBindState", {"sequence": sequence, "tag": tag});
  }

  Future<Map<dynamic, dynamic>> setAlias(int sequence, String alias) async {
    return await methodChannel.invokeMethod(
        "setAlias", {"sequence": sequence, "alias": alias});
  }

  Future<Map<dynamic, dynamic>> deleteAlias(int sequence) async {
    return await methodChannel.invokeMethod("deleteAlias", sequence);
  }

  Future<Map<dynamic, dynamic>> getAlias(int sequence) async {
    return await methodChannel.invokeMethod("getAlias", sequence);
  }

  stopPush() {
    methodChannel.invokeMethod("stopPush");
  }

  resumePush() {
    methodChannel.invokeMethod("resumePush");
  }

  Future<bool?> isPushStopped() async{
    return await methodChannel.invokeMethod<bool>('isPushStopped');
  }

  setBadgeNumber(int badgeNumber) {
    methodChannel.invokeMethod("setBadgeNumber", badgeNumber);
  }

  setHeartbeatTime(int heartbeatTime) {
    methodChannel.invokeMethod("setHeartbeatTime", heartbeatTime);
  }

  void printMy(msg) {
    if (debug) {
      print(flutter_log + "::" + msg);
    }
  }
}
