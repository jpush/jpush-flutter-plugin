import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/harmony/jpush_harmony_sdk_method_channel.dart';
import 'package:jpush_flutter/jpush_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('jpush');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    channel.setMethodCallHandler(null);
  });

  test('本地通知字符串 extra 经 Dart 通道保持完整', () async {
    final inputs = <Map<String, String>?>[
      {'fa': '0'},
      {'城市': '重庆', '__proto__': 'value', '转义': '"\\\n'},
      {},
      null,
    ];
    for (final extra in inputs) {
      final notification = LocalNotification(
        id: 234,
        title: '标题',
        content: '正文',
        fireTime: DateTime.fromMillisecondsSinceEpoch(123456789),
        extra: extra,
      );
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        expect(call.method, 'sendLocalNotification');
        expect(call.arguments['id'], 234);
        expect(call.arguments['fireTime'], 123456789);
        if (extra == null) {
          expect(call.arguments.containsKey('extra'), isFalse);
        } else {
          expect(call.arguments['extra'], extra);
        }
        return true;
      });
      await MethodChannelJpushHarmonySdk()
          .sendLocalNotification(notification.toMap());
      expect(calls, 1);
    }
  });

  test('到达和点击回调透传原生 extras', () async {
    final received = <String, dynamic>{};
    MethodChannelJpushHarmonySdk().setCallBack((String event, dynamic data) {
      received[event] = data;
    });
    final payload = <String, dynamic>{
      'extras': <String, String>{'fa': '0', '城市': '重庆'},
    };
    for (final event in ['onArrivedMessage', 'onClickMessage']) {
      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(MethodCall(event, payload)),
        (_) {},
      );
      expect(received[event], payload);
    }
  });
}
