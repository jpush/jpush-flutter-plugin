import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_google_flutter/jpush_google_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('country-code-test');
  late List<MethodCall> calls;
  late JPush jpush;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    calls = <MethodCall>[];
    jpush = JPush.private(channel);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('submits normalized country code through the existing channel',
      () async {
    await jpush.setCountryCode(' us ');
    expect(calls, hasLength(1));
    expect(calls.single.method, 'setCountryCode');
    expect(calls.single.arguments, 'US');
  });

  test('invalid and Unicode-folding inputs never invoke native code', () async {
    for (final code in ['', ' ', 'U', 'USA', '12', 'u1', 'ß', '中国', 'ＵＳ']) {
      await expectLater(jpush.setCountryCode(code), throwsArgumentError);
    }
    expect(calls, isEmpty);
  });

  test('native submission errors remain observable', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'NATIVE_ERROR');
    });
    await expectLater(
        jpush.setCountryCode('US'),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'NATIVE_ERROR')));
  });

  test('iOS is explicitly unsupported and does not invoke the channel',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await expectLater(jpush.setCountryCode('US'), throwsUnsupportedError);
    expect(calls, isEmpty);
  });

  test('completion waits for native submission reply', () async {
    var completed = false;
    final reply = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) => reply.future);
    final pending = jpush.setCountryCode('US').then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);
    reply.complete();
    await pending;
    expect(completed, isTrue);
  });

  test('legacy testing method keeps its channel and original argument',
      () async {
    // ignore: deprecated_member_use_from_same_package
    jpush.testCountryCode('us');
    await Future<void>.delayed(Duration.zero);
    expect(calls.single.method, 'testCountryCode');
    expect(calls.single.arguments, 'us');
  });
}
