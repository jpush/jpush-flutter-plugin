import 'package:jpush_flutter/harmony/jpush_harmony_sdk_imp.dart';

import '../jpush_interface.dart';

class JpushHarmonySdk extends JPushFlutterInterface {
  static const String flutter_log = "| JPUSH | Flutter | harmony | ";

  final _jpushHarmonySdkPlugin = JpushHarmonySdkImp();

  void setCallBackHarmony(Function(String eventName, dynamic data) callBack) {
    print(flutter_log + "setCallBackHarmony");
    _jpushHarmonySdkPlugin.setCallBack(callBack);
  }

  void setup({
    String appKey = '',
    bool production = false,
    String channel = '',
    bool debug = false,
  }) {
    print(flutter_log + "setup");
    _jpushHarmonySdkPlugin.setDebug(debug);
    if (channel.isNotEmpty) {
      _jpushHarmonySdkPlugin.setChannel(channel);
    }
    if (appKey.isNotEmpty) {
      _jpushHarmonySdkPlugin.setAppKey(appKey);
    } else {
      print(flutter_log + "appKey is empty");
    }
    _jpushHarmonySdkPlugin.init();
  }

  Future<String> getRegistrationID() async {
    print(flutter_log + "getRegistrationID");
    final String registrationId =
        await _jpushHarmonySdkPlugin.getRegistrationId();
    return registrationId;
  }

  Future<Map<dynamic, dynamic>> setTags(List<String> tags) async {
    print(flutter_log + "setTags");
    return await _jpushHarmonySdkPlugin.setTags(0, tags);
  }

  Future<Map<dynamic, dynamic>> addTags(List<String> tags) async {
    print(flutter_log + "addTags");
    return await _jpushHarmonySdkPlugin.addTags(0, tags);
    ;
  }

  Future<Map<dynamic, dynamic>> deleteTags(List<String> tags) async {
    print(flutter_log + "deleteTags");
    return await _jpushHarmonySdkPlugin.deleteTags(0, tags);
    ;
  }

  Future<Map<dynamic, dynamic>> cleanTags() async {
    print(flutter_log + "cleanTags");
    return await _jpushHarmonySdkPlugin.cleanTags(0);
  }

  Future<Map<dynamic, dynamic>> getTags(int curr) async {
    print(flutter_log + "getTags");
    return await _jpushHarmonySdkPlugin.getTags(0, curr);
  }

  //todo weiry
  Future<Map<dynamic, dynamic>> checkTagBindState(String tag) async {
    return await _jpushHarmonySdkPlugin.checkTagBindState(0, tag);
  }

  Future<Map<dynamic, dynamic>> setAlias(String alias) async {
    print(flutter_log + "setAlias");
    return await _jpushHarmonySdkPlugin.setAlias(0, alias);
  }

  Future<Map<dynamic, dynamic>> deleteAlias() async {
    print(flutter_log + "deleteAlias");
    return await _jpushHarmonySdkPlugin.deleteAlias(0);
  }

  Future<Map<dynamic, dynamic>> getAlias() async {
    print(flutter_log + "getAlias");
    return await _jpushHarmonySdkPlugin.getAlias(0);
  }

  Future stopPush() async {
    print(flutter_log + "stopPush");
    await _jpushHarmonySdkPlugin.stopPush();
  }

  Future resumePush() async {
    print(flutter_log + "resumePush");
    await _jpushHarmonySdkPlugin.resumePush();
  }

//todo weiry
  Future<bool?> isPushStopped() {
    return _jpushHarmonySdkPlugin.isPushStopped();
  }

  Future setBadge(int badge) async {
    print(flutter_log + "setBadge");
    await _jpushHarmonySdkPlugin.setBadgeNumber(badge);
  }

  Future setHBInterval(int hbinterval) async {
    print(flutter_log + "setHBInterval");
    await _jpushHarmonySdkPlugin.setHBInterval(hbinterval);
  }
}
