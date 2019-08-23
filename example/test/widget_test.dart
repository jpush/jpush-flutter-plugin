// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:jpush_example/main.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

import 'package:test/test.dart';

void main() {
  /*
  testWidgets('Verify Platform version', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(new MyApp());

    // Verify that platform version is retrieved.
    
    // expect(
    //     find.byWidgetPredicate(
    //       (Widget widget) =>
    //           widget is Text && widget.data.startsWith('Running on:'),
    //     ),
    //     findsOneWidget);
  });

  MockMethodChannel mockChannel;

  JPush.setup(
      appKey: "a1703c14b186a68a66ef86c1",
      channel: "theChannel",
      production: false
      );

test('requestNotificationPermissions on ios with custom permissions', () {
  JPush.applyPushAuthority(new NotificationSettingsIOS(
        sound: false,
        alert: false,
        badge: false));

    // firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: false));
    verify(mockChannel.invokeMethod('requestNotificationPermissions',
        <String, bool>{'sound': false, 'badge': true, 'alert': true}));
  });

  */

}
