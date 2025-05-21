import 'jpush_harmony_sdk_platform_interface.dart';

class JpushHarmonySdkImp {

  void setCallBack(Function(String eventName, dynamic data) callBack) {
    JpushHarmonySdkPlatform.instance.setCallBack(callBack);
  }

  void setDebug(bool b) {
    JpushHarmonySdkPlatform.instance.setDebug(b);
  }

  setAppKey(String appKey) {
    JpushHarmonySdkPlatform.instance.setAppKey(appKey);
  }

  setChannel(String channel) {
    JpushHarmonySdkPlatform.instance.setChannel(channel);
  }

  init() {
    JpushHarmonySdkPlatform.instance.init();
  }
  
  Future<String> getRegistrationId() {
    return JpushHarmonySdkPlatform.instance.getRegistrationId();
  }

  Future<Map<dynamic, dynamic>> setTags(int sequence, List<String> tags) {
    return JpushHarmonySdkPlatform.instance.setTags(sequence, tags);
  }

  Future<Map<dynamic, dynamic>> addTags(int sequence, List<String> tags) {
   return JpushHarmonySdkPlatform.instance.addTags(sequence, tags);
  }

  Future<Map<dynamic, dynamic>>  deleteTags(int sequence, List<String> tags) {
   return JpushHarmonySdkPlatform.instance.deleteTags(sequence, tags);
  }

  Future<Map<dynamic, dynamic>>  cleanTags(int sequence) {
   return JpushHarmonySdkPlatform.instance.cleanTags(sequence);
  }

  Future<Map<dynamic, dynamic>> getTags(int sequence, int curr) {
    return JpushHarmonySdkPlatform.instance.getTags(sequence, curr);
  }

  Future<Map<dynamic, dynamic>>  checkTagBindState(int sequence, String tag) {
   return JpushHarmonySdkPlatform.instance.checkTagBindState(sequence, tag);
  }

  Future<Map<dynamic, dynamic>>  setAlias(int sequence, String alias) {
    return JpushHarmonySdkPlatform.instance.setAlias(sequence, alias);
  }

  Future<Map<dynamic, dynamic>> deleteAlias(int sequence) {
   return JpushHarmonySdkPlatform.instance.deleteAlias(sequence);
  }

  Future<Map<dynamic, dynamic>> getAlias(int sequence) {
    return JpushHarmonySdkPlatform.instance.getAlias(sequence);
  }

  stopPush() async {
    await JpushHarmonySdkPlatform.instance.stopPush();
  }

  resumePush() async {
    await JpushHarmonySdkPlatform.instance.resumePush();
  }

  Future<bool?> isPushStopped() {
    return JpushHarmonySdkPlatform.instance.isPushStopped();
  }

  setBadgeNumber(int badgeNumber) {
    JpushHarmonySdkPlatform.instance.setBadgeNumber(badgeNumber);
  }

  setHBInterval(int hbinterval) {
    JpushHarmonySdkPlatform.instance.setHeartbeatTime(hbinterval);
  }


}
