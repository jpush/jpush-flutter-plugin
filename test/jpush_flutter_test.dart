import 'package:flutter/services.dart';

import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';
import 'package:jpush_flutter/jpush_flutter.dart';


void main() {
  MockMethodChannel mockChannel;
  JPush jpush;

  setUp(() {
    mockChannel = new MockMethodChannel();
    jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
  });

    jpush.setup(
      appKey: "a1703c14b186a68a66ef86c1",
      channel: "theChannel",
      production: false
      );

  test('applyPushAuthority on ios with params', () {
    jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
    jpush.applyPushAuthority(new NotificationSettingsIOS(
      sound: true,
      alert: true,
      badge: true));
    verify(mockChannel.invokeMethod('applyPushAuthority',
        <String, bool>{'sound': true, 'badge': true, 'alert': true}));
  });

  test('addEventHandler', () {
// TODO:
  });

    test('setAlias', () {
      jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
      jpush.setAlias('alias').then((map) {
        expect(map, contains('alias'));
      }).catchError((error) {});
    });

    test('deleteAlias', () {
      jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
      jpush.deleteAlias().then((map) {
        expect(map, contains('alias'));
      }).catchError((error) {});
    });

    test('deleteAlias', () {
      jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
      jpush.deleteAlias().then((map) {
        expect(map, contains('alias'));
      }).catchError((error) {});
    });

    test('addTags', () {
      jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
      jpush.addTags(["tag1","tag2"]).then((map) {
        expect(map, contains('tags'));
      }).catchError((error) {});
    });
    
    test('deleteTags', () {
      jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
      jpush.deleteTags(["tag1","tag2"]).then((map) {
        expect(map, contains('tags'));
      }).catchError((error) {});
    });

    test('setTags', () {
      jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
      jpush.setTags(["tag1","tag2"]).then((map) {
        expect(map, contains('tags'));
      }).catchError((error) {});
    });

    test('getAllTags', () {
      jpush = new JPush.private(mockChannel, FakePlatform(operatingSystem: 'ios'));
      jpush.getAllTags().then((map) {
        expect(map, contains('tags'));
      }).catchError((error) {});
    });  
}

class MockMethodChannel extends Mock implements MethodChannel {}