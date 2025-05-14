import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'android_ios/jpush_flutter_a_i.dart';
import 'harmony/jpush_harmony_sdk.dart';
import 'jpush_interface.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> event);

class JPush {
  static const String flutter_log = "| JPUSH | Flutter | ";

  static JPushFlutterInterface newJPush() {
    if (Platform.isIOS || Platform.isAndroid) {
      return JPush_A_I();
    } else {
      return JpushHarmonySdk();
    }
  }
}
