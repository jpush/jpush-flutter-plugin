import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/android_ios/jpush_flutter_a_i.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('jpush-test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('turnOffPush 在 iOS 透传原生错误码', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'turnOffPush');
      return <String, dynamic>{'code': 6002};
    });
    final jpush = JPush_A_I.private(channel, isIOS: true);

    final result = await jpush.turnOffPush();

    expect(result, <String, dynamic>{'code': 6002});
  });

  test('turnOnPush 在 iOS 调用原生恢复方法', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    final jpush = JPush_A_I.private(channel, isIOS: true);

    jpush.turnOnPush();
    await Future<void>.delayed(Duration.zero);

    expect(calls, hasLength(1));
    expect(calls.single.method, 'turnOnPush');
  });

  test('Android 保持未实现兜底且不调用 MethodChannel', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    final jpush = JPush_A_I.private(channel, isIOS: false);

    expect(await jpush.turnOffPush(), isEmpty);
    jpush.turnOnPush();
    await Future<void>.delayed(Duration.zero);

    expect(calls, isEmpty);
  });
}
