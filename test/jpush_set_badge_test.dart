import 'dart:async';

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
    group('$platform setBadge', () {
      final channel = MethodChannel(
        platform == 'HarmonyOS' ? 'jpush' : 'jpush-set-badge-test',
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

      test('等待原生回复后完成，并保持无业务返回值', () async {
        final received = Completer<void>();
        final reply = Completer<dynamic>();
        messenger.setMockMethodCallHandler(channel, (call) {
          expect(
            call.method,
            platform == 'HarmonyOS' ? 'setBadgeNumber' : 'setBadge',
          );
          expect(
            call.arguments,
            platform == 'HarmonyOS' ? 66 : {'badge': 66},
          );
          received.complete();
          return reply.future;
        });

        var completed = false;
        final operation = jpush.setBadge(66).then((value) {
          completed = true;
          return value;
        });
        await received.future;
        await Future<void>.delayed(Duration.zero);

        try {
          expect(completed, isFalse, reason: '原生未回复前不能提前完成');
        } finally {
          reply.complete(true);
        }
        expect(await operation, isNull);
      });

      test('调用方能捕获原生错误', () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(
            code: 'BADGE_ERROR',
            message: '无法调用角标设置接口',
            details: {'badge': 66},
          );
        });

        await expectLater(
          jpush.setBadge(66),
          throwsA(
            isA<PlatformException>()
                .having((error) => error.code, 'code', 'BADGE_ERROR')
                .having((error) => error.details, 'details', {'badge': 66}),
          ),
        );
      });

      test('未实现原生方法时不会静默完成', () async {
        messenger.setMockMethodCallHandler(channel, (call) async {
          throw MissingPluginException();
        });

        await expectLater(
          jpush.setBadge(66),
          throwsA(isA<MissingPluginException>()),
        );
      });
    });
  }
}
