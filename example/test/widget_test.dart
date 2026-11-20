import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_example/main.dart';

void main() {
  testWidgets('does not invoke the plugin before explicit privacy consent',
      (tester) async {
    final calls = <MethodCall>[];
    const channel = MethodChannel('jpush');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(MyApp());
    expect(find.text('同意隐私并初始化推送'), findsOneWidget);
    expect(calls, isEmpty);
  });
}
