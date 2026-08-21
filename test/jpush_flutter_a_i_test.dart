import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/android_ios/jpush_flutter_a_i.dart';
import 'package:jpush_flutter/jpush_interface.dart';

import '../example/lib/main.dart' as example;

class LiveActivityDemoJPush extends JPushFlutterInterface {
  Uint8List? pushToken;

  @override
  Future<Map<dynamic, dynamic>> registerLiveActivityPushToken({
    required String liveActivityId,
    Uint8List? pushToken,
    required int seq,
  }) async {
    this.pushToken = pushToken;
    return <String, dynamic>{
      'code': 0,
      'liveActivityId': liveActivityId,
      'pushToken': pushToken,
      'seq': seq,
    };
  }
}

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

  test('iOS 注册 Live Activity PushToken 并透传回调', () async {
    final token = Uint8List.fromList(<int>[1, 2, 3]);
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'registerLiveActivityPushToken');
      expect(call.arguments, <String, dynamic>{
        'liveActivityId': 'order-1',
        'pushToken': token,
        'seq': 10,
      });
      return <String, dynamic>{
        'code': 0,
        'liveActivityId': 'order-1',
        'pushToken': token,
        'seq': 10,
      };
    });
    final jpush = JPush_A_I.private(channel, isIOS: true);

    final result = await jpush.registerLiveActivityPushToken(
      liveActivityId: 'order-1',
      pushToken: token,
      seq: 10,
    );

    expect(result['code'], 0);
    expect(result['pushToken'], token);
  });

  test('iOS 传 null 解绑 Live Activity PushToken', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'registerLiveActivityPushToken');
      expect(call.arguments['pushToken'], isNull);
      return <String, dynamic>{
        'code': 0,
        'liveActivityId': 'order-1',
        'pushToken': null,
        'seq': 11,
      };
    });
    final jpush = JPush_A_I.private(channel, isIOS: true);

    final result = await jpush.registerLiveActivityPushToken(
      liveActivityId: 'order-1',
      pushToken: null,
      seq: 11,
    );

    expect(result['code'], 0);
    expect(result['pushToken'], isNull);
  });

  test('iOS 注册和解绑 Live Activity Push-to-Start Token', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return <String, dynamic>{
        'code': 0,
        'liveActivityId': call.arguments['activityAttributes'],
        'pushToken': call.arguments['pushToStartToken'],
        'seq': call.arguments['seq'],
      };
    });
    final jpush = JPush_A_I.private(channel, isIOS: true);
    final token = Uint8List.fromList(<int>[4, 5, 6]);

    final registerResult = await jpush.registerLiveActivityPushToStartToken(
      activityAttributes: 'OrderActivityAttributes',
      pushToStartToken: token,
      seq: 20,
    );
    final unbindResult = await jpush.registerLiveActivityPushToStartToken(
      activityAttributes: 'OrderActivityAttributes',
      pushToStartToken: null,
      seq: 21,
    );

    expect(calls, hasLength(2));
    expect(calls.first.method, 'registerLiveActivityPushToStartToken');
    expect(calls.first.arguments['pushToStartToken'], token);
    expect(calls.last.arguments['pushToStartToken'], isNull);
    expect(registerResult['pushToken'], token);
    expect(registerResult['seq'], 20);
    expect(unbindResult['pushToken'], isNull);
    expect(unbindResult['seq'], 21);
  });

  test('非 iOS Live Activity 接口保持未实现兜底', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    final jpush = JPush_A_I.private(channel, isIOS: false);

    expect(
      await jpush.registerLiveActivityPushToken(
        liveActivityId: 'order-1',
        pushToken: null,
        seq: 1,
      ),
      isEmpty,
    );
    expect(
      await jpush.registerLiveActivityPushToStartToken(
        activityAttributes: 'OrderActivityAttributes',
        pushToStartToken: null,
        seq: 2,
      ),
      isEmpty,
    );
    expect(calls, isEmpty);
  });

  testWidgets('Demo 支持 Base64 PushToken 并在面板内显示结果', (tester) async {
    final demoJPush = LiveActivityDemoJPush();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: example.LiveActivityTestPanel(
            jpush: demoJPush,
            isIOS: true,
            onResult: (_) {},
          ),
        ),
      ),
    ));

    await tester.enterText(
      find.byKey(const ValueKey<String>('liveActivityPushTokenInput')),
      'base64:AQIDBA==',
    );
    await tester.tap(find.text('注册 PushToken'));
    await tester.pump();

    expect(demoJPush.pushToken, Uint8List.fromList(<int>[1, 2, 3, 4]));
    expect(find.textContaining('code=0'), findsOneWidget);
    expect(find.textContaining('tokenLength=4'), findsOneWidget);
  });
}
