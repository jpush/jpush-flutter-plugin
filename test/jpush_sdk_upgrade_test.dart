import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/android_ios/jpush_flutter_a_i.dart';
import 'package:jpush_flutter/harmony/jpush_harmony_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('upgrade-test');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late JPush_A_I android;
  late JPush_A_I ios;

  setUp(() {
    calls = <MethodCall>[];
    android = JPush_A_I.private(channel, isIOS: false);
    ios = JPush_A_I.private(channel, isIOS: true);
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'turnOnPush' || call.method == 'turnOffPush') {
        return <String, dynamic>{'code': 4, 'actionType': call.method};
      }
      return null;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('subscription dispatch preserves the input snapshot and does not await authorization', () async {
    final ids = <String>['a', 'b'];
    await android.requestSubscribeChannels(ids);
    ids.clear();
    expect(calls.single.method, 'requestSubscribeChannels');
    expect(calls.single.arguments, {'channelIds': ['a', 'b']});
  });

  test('invalid subscription lists never call native code', () async {
    for (final ids in <List<String>>[[], [''], [' '], ['a', 'a'], ['a', 'b', 'c', 'd']]) {
      await expectLater(android.requestSubscribeChannels(ids), throwsArgumentError);
    }
    expect(calls, isEmpty);
  });

  test('native dispatch error is not reported as authorization success', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'NO_ACTIVITY');
    });
    await expectLater(android.requestSubscribeChannels(['a']),
        throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'NO_ACTIVITY')));
  });

  test('Android UPS maps preserve native failure codes', () async {
    expect(await android.turnOffPush(), {'code': 4, 'actionType': 'turnOffPush'});
    expect(await android.turnOnPushWithResult(), {'code': 4, 'actionType': 'turnOnPush'});
    android.turnOnPush();
    await Future<void>.delayed(Duration.zero);
    expect(calls.map((c) => c.method), ['turnOffPush', 'turnOnPush', 'turnOnPush']);
  });

  test('crash collection only changes on an explicit call', () async {
    expect(calls, isEmpty);
    await android.initCrashHandler();
    await android.stopCrashHandler();
    expect(calls.map((c) => c.method), ['initCrashHandler', 'stopCrashHandler']);
  });

  test('iOS diagnostic switches send exact boolean values', () async {
    await ios.setLiveActivityTokenReportEnabled(true);
    await ios.setLiveActivityTokenReportEnabled(false);
    expect(calls.map((c) => c.arguments), [{'enabled': true}, {'enabled': false}]);
  });

  test('platform-only APIs explicitly reject unsupported platforms', () async {
    final harmony = JpushHarmonySdk();
    await expectLater(ios.requestSubscribeChannels(['a']), throwsUnsupportedError);
    await expectLater(ios.turnOnPushWithResult(), throwsUnsupportedError);
    await expectLater(ios.initCrashHandler(), throwsUnsupportedError);
    await expectLater(ios.stopCrashHandler(), throwsUnsupportedError);
    await expectLater(android.setLiveActivityTokenReportEnabled(true), throwsUnsupportedError);
    await expectLater(harmony.requestSubscribeChannels(['a']), throwsUnsupportedError);
    await expectLater(harmony.turnOnPushWithResult(), throwsUnsupportedError);
    await expectLater(harmony.initCrashHandler(), throwsUnsupportedError);
    await expectLater(harmony.stopCrashHandler(), throwsUnsupportedError);
    await expectLater(harmony.setLiveActivityTokenReportEnabled(true), throwsUnsupportedError);
    expect(calls, isEmpty);
  });
}
