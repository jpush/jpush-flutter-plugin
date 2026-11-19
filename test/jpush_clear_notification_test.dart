import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/android_ios/jpush_flutter_a_i.dart';
import 'package:jpush_flutter/harmony/jpush_harmony_sdk.dart';
import 'package:jpush_flutter/harmony/jpush_harmony_sdk_method_channel.dart';
import 'package:jpush_flutter/harmony/jpush_harmony_sdk_platform_interface.dart';
import 'package:jpush_flutter/jpush_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  for (final platform in ['Android', 'iOS', 'HarmonyOS']) {
    group('$platform clearNotification', () {
      final channel = MethodChannel(
        platform == 'HarmonyOS' ? 'jpush' : 'jpush-clear-notification-test',
      );
      late JPushFlutterInterface jpush;
      late JpushHarmonySdkPlatform previousHarmonyPlatform;

      setUp(() {
        previousHarmonyPlatform = JpushHarmonySdkPlatform.instance;
        if (platform == 'HarmonyOS') {
          JpushHarmonySdkPlatform.instance = MethodChannelJpushHarmonySdk();
          jpush = JpushHarmonySdk();
        } else {
          jpush = JPush_A_I.private(channel, isIOS: platform == 'iOS');
        }
      });

      tearDown(() {
        messenger.setMockMethodCallHandler(channel, null);
        JpushHarmonySdkPlatform.instance = previousHarmonyPlatform;
      });

      for (final reply in [true, false]) {
        test('原生返回 $reply 时不产生异步类型错误，并透传通知 ID', () async {
          final calls = <MethodCall>[];
          messenger.setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return reply;
          });
          jpush.clearNotification(notificationId: 12345);
          // void API 的回包在异步处理；等待解码完成，让类型异常被测试捕获。
          await Future<void>.delayed(Duration.zero);

          expect(calls, hasLength(1));
          expect(calls.single.method, 'clearNotification');
          expect(calls.single.arguments, 12345);
        });
      }

      test('省略通知 ID 时保持默认值 0', () async {
        final calls = <MethodCall>[];
        messenger.setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
        jpush.clearNotification();
        await Future<void>.delayed(Duration.zero);

        expect(calls, hasLength(1));
        expect(calls.single.method, 'clearNotification');
        expect(calls.single.arguments, 0);
      });
    });
  }
}
