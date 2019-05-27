import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String debugLable = 'Unknown';
  final JPush jpush = new JPush();
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      setState(() {
        debugLable = "flutter getRegistrationID: $rid";
      });
    });

    jpush.setup(
      appKey: "085680000000056ef2a14902",
      channel: "theChannel",
      production: false,
      debug: true,
    );
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));

    try {
      jpush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          print("flutter onReceiveNotification: $message");
          setState(() {
            debugLable = "flutter onReceiveNotification: $message";
          });
        },
        onOpenNotification: (Map<String, dynamic> message) async {
          print("flutter onOpenNotification: $message");
          setState(() {
            debugLable = "flutter onOpenNotification: $message";
          });
        },
        onReceiveMessage: (Map<String, dynamic> message) async {
          print("flutter onReceiveMessage: $message");
          setState(() {
            debugLable = "flutter onReceiveMessage: $message";
          });
        },
      );
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      debugLable = platformVersion;
    });
  }

// 编写视图
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
      appBar: new AppBar(
        title: const Text("Plugin example app"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: new Table(
              children: [
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('sendLocalNotification\n'),
                      onPressed: () {
                        // 三秒后出发本地推送
                        var fireDate = DateTime.fromMillisecondsSinceEpoch(
                            DateTime.now().millisecondsSinceEpoch + 3000);
                        var localNotification = LocalNotification(
                            id: 234,
                            title: 'Test',
                            buildId: 1,
                            content: 'Test Local Push Service',
                            fireTime: fireDate,
                            subtitle: 'Welcome to test',
                            badge: 5,
                            extras: {"ab": "0"});
                        jpush
                            .sendLocalNotification(localNotification)
                            .then((res) {
                          setState(() {
                            debugLable = res;
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('getLaunchAppNotification\n'),
                      onPressed: () {
                        jpush.getLaunchAppNotification().then((map) {
                          setState(() {
                            debugLable =
                                "getLaunchAppNotification success: $map";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable =
                                "getLaunchAppNotification error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('applyPushAuthority\n'),
                      onPressed: () {
                        jpush.applyPushAuthority(NotificationSettingsIOS(
                            badge: true, alert: true, sound: true));
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('setTags\n'),
                      onPressed: () {
                        jpush.setTags(["lala", "haha"]).then((map) {
                          var tags = map['tags'];
                          setState(() {
                            debugLable = "set tags success: $map $tags";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "set tags error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('cleanTags\n'),
                      onPressed: () {
                        jpush.cleanTags().then((map) {
                          var tags = map['tags'];
                          setState(() {
                            debugLable = "cleanTags success: $map $tags";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "cleanTags error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('addTags\n'),
                      onPressed: () {
                        jpush.addTags(["def", "fun"]).then((map) {
                          var tags = map['tags'];
                          setState(() {
                            debugLable = "addTags success: $map $tags";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "addTags error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('deleteTags\n'),
                      onPressed: () {
                        jpush.deleteTags(["def", "fun"]).then((map) {
                          var tags = map['tags'];
                          setState(() {
                            debugLable = "deleteTags success: $map $tags";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "deleteTags error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('getAllTags\n'),
                      onPressed: () {
                        jpush.getAllTags().then((map) {
                          setState(() {
                            debugLable = "getAllTags success: $map";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "getAllTags error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('setAlias\n'),
                      onPressed: () {
                        jpush.setAlias("thealias11").then((map) {
                          setState(() {
                            debugLable = "setAlias success: $map";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "setAlias error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('deleteAlias\n'),
                      onPressed: () {
                        jpush.deleteAlias().then((map) {
                          setState(() {
                            debugLable = "deleteAlias success: $map";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "deleteAlias error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('setBadge\n'),
                      onPressed: () {
                        jpush.setBadge(66).then((map) {
                          setState(() {
                            debugLable = "setBadge success: $map";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "setBadge error: $error";
                          });
                        });
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('stopPush\n'),
                      onPressed: () {
                        jpush.stopPush();
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('resumePush\n'),
                      onPressed: () {
                        jpush.resumePush();
                      }),
                ]),
                new TableRow(children: [
                  FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      child: new Text('clearAllNotifications\n'),
                      onPressed: () {
                        jpush.clearAllNotifications();
                      }),
                ]),
                new TableRow(children: [
                  new Container(
                    child: new Text('result: $debugLable\n'),
                    alignment: Alignment.center,
                  )
                ]),
              ],
            ),
          )),
    ));
  }
}
