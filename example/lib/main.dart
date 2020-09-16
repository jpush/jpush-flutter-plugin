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

    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
        setState(() {
          debugLable = "flutter onReceiveNotification: $message";
        });
      }, onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
        setState(() {
          debugLable = "flutter onOpenNotification: $message";
        });
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
        setState(() {
          debugLable = "flutter onReceiveMessage: $message";
        });
      }, onReceiveNotificationAuthorization:
              (Map<String, dynamic> message) async {
        print("flutter onReceiveNotificationAuthorization: $message");
        setState(() {
          debugLable = "flutter onReceiveNotificationAuthorization: $message";
        });
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    jpush.setup(
      appKey: "e58a32cb3e4469ebf31867e5", //你自己应用的 AppKey
      channel: "theChannel",
      production: false,
      debug: true,
    );
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));

    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      print("flutter get registration id : $rid");
      setState(() {
        debugLable = "flutter getRegistrationID: $rid";
      });
    });

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
          title: const Text('Plugin example app'),
        ),
        body: new Center(
            child: new Column(children: [
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            color: Colors.brown,
            child: Text(debugLable ?? "Unknown"),
            width: 350,
            height: 100,
          ),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(" "),
                new CustomButton(
                    title: "发本地推送",
                    onPressed: () {
                      // 三秒后出发本地推送
                      var fireDate = DateTime.fromMillisecondsSinceEpoch(
                          DateTime.now().millisecondsSinceEpoch + 3000);
                      var localNotification = LocalNotification(
                          id: 234,
                          title: 'fadsfa',
                          buildId: 1,
                          content: 'fdas',
                          fireTime: fireDate,
                          subtitle: 'fasf',
                          badge: 5,
                          extra: {"fa": "0"});
                      jpush
                          .sendLocalNotification(localNotification)
                          .then((res) {
                        setState(() {
                          debugLable = res;
                        });
                      });
                    }),
                new Text(" "),
                new CustomButton(
                    title: "getLaunchAppNotification",
                    onPressed: () {
                      jpush.getLaunchAppNotification().then((map) {
                        setState(() {
                          debugLable = "getLaunchAppNotification success: $map";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "getLaunchAppNotification error: $error";
                        });
                      });
                    }),
              ]),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(" "),
                new CustomButton(
                    title: "setTags",
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
                new Text(" "),
                new CustomButton(
                    title: "addTags",
                    onPressed: () {
                      jpush.addTags(["lala", "haha"]).then((map) {
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
                new Text(" "),
                new CustomButton(
                    title: "deleteTags",
                    onPressed: () {
                      jpush.deleteTags(["lala", "haha"]).then((map) {
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
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(" "),
                new CustomButton(
                    title: "getAllTags",
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
                new Text(" "),
                new CustomButton(
                    title: "cleanTags",
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
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(" "),
                new CustomButton(
                    title: "setAlias",
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
                new Text(" "),
                new CustomButton(
                    title: "deleteAlias",
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
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(" "),
              new CustomButton(
                  title: "stopPush",
                  onPressed: () {
                    jpush.stopPush();
                  }),
              new Text(" "),
              new CustomButton(
                  title: "resumePush",
                  onPressed: () {
                    jpush.resumePush();
                  }),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(" "),
              new CustomButton(
                  title: "clearAllNotifications",
                  onPressed: () {
                    jpush.clearAllNotifications();
                  }),
              new Text(" "),
              new CustomButton(
                  title: "setBadge",
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
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(" "),
              new CustomButton(
                  title: "通知授权是否打开",
                  onPressed: () {
                    jpush.isNotificationEnabled().then((bool value) {
                      setState(() {
                        debugLable = "通知授权是否打开: $value";
                      });
                    }).catchError((onError) {
                      setState(() {
                        debugLable = "通知授权是否打开: ${onError.toString()}";
                      });
                    });
                  }),
              new Text(" "),
              new CustomButton(
                  title: "打开系统设置",
                  onPressed: () {
                    jpush.openSettingsForNotification();
                  }),
            ],
          ),
        ])),
      ),
    );
  }
}

/// 封装控件
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const CustomButton({@required this.onPressed, @required this.title});

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      onPressed: onPressed,
      child: new Text("$title"),
      color: Color(0xff585858),
      highlightColor: Color(0xff888888),
      splashColor: Color(0xff888888),
      textColor: Colors.white,
      //padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
    );
  }
}
