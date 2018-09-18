import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jpush/jpush.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // JPush.getRegistrationID().then((rid) {
    //   setState(() {
    //       _platformVersion = "flutter getRegistrationID: $rid";
    //     });
    // });
    JPush.setup(
      appKey: "a1703c14b186a68a66ef86c1",
      channel: "theChannel",
      production: false
      );
    JPush.applyPushAuthority(new NotificationSettingsIOS(
      sound: false,
      alert: false,
      badge: false));

    try {
      
      JPush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
        // print("flutter onReceiveNotification: $message");
        setState(() {
            _platformVersion = "setAlias error: $message";
          });
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
        
      },
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
        
      },
      );
      print("lalallalalal");

      // platformVersion = await JPush.platformVersion;
      // platformVersion = "$platformVersion fadfa";
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
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
          child: new Column(
            children:[
              new Text('result: $_platformVersion\n'), 
              
              new FlatButton(
              child: new Text('applyPushAuthority\n'), 
              onPressed: () {
                
              }),
              new FlatButton(
                child: new Text('setTags\n'), 
                onPressed: () {
                  JPush.setTags(["lala","haha"]).then((map) {
                    var tags = map['tags'];
                    setState(() {
                      _platformVersion = "set tags success: $map $tags";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "set tags error: $error";
                    });
                  }) ;
                }),
              new FlatButton(
              child: new Text('cleanTags\n'), 
              onPressed: () {
                    JPush.cleanTags().then((map) {
                    var tags = map['tags'];
                    setState(() {
                      _platformVersion = "cleanTags success: $map $tags";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "cleanTags error: $error";
                    });
                  }) ;
              }),
              new FlatButton(
                child: new Text('addTags\n'), 
                onPressed: () {
                  
                    JPush.addTags(["lala","haha"]).then((map) {
                    var tags = map['tags'];
                    setState(() {
                      _platformVersion = "addTags success: $map $tags";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "addTags error: $error";
                    });
                  }) ;

                }),
              new FlatButton(
                child: new Text('deleteTags\n'), 
                onPressed: () {
                  
                  JPush.deleteTags(["lala","haha"]).then((map) {
                    var tags = map['tags'];
                    setState(() {
                      _platformVersion = "deleteTags success: $map $tags";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "deleteTags error: $error";
                    });
                  }) ;

                }),
              new FlatButton(
                child: new Text('getAllTags\n'), 
                onPressed: () {
                  
                  JPush.getAllTags().then((map) {
                    setState(() {
                      _platformVersion = "getAllTags success: $map";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "getAllTags error: $error";
                    });
                  }) ;

                }),
              new FlatButton(
                child: new Text('setAlias\n'), 
                onPressed: () {
                  
                  JPush.setAlias("thealias11").then((map) {
                    setState(() {
                      _platformVersion = "setAlias success: $map";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "setAlias error: $error";
                    });
                  }) ;

                }),
              new FlatButton(
                child: new Text('deleteAlias\n'), 
                onPressed: () {
                  
                  JPush.deleteAlias().then((map) {
                    setState(() {
                      _platformVersion = "deleteAlias success: $map";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "deleteAlias error: $error";
                    });
                  }) ;

                }),
              new FlatButton(
                child: new Text('setBadge\n'), 
                onPressed: () {
                  
                  JPush.setBadge(66).then((map) {
                    setState(() {
                      _platformVersion = "setBadge success: $map";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "setBadge error: $error";
                    });
                  }) ;

                }),
              new FlatButton(
                child: new Text('stopPush\n'), 
                onPressed: () {
                  
                  JPush.stopPush();

                }),
              new FlatButton(
                child: new Text('resumePush\n'), 
                onPressed: () {
                  
                  JPush.resumePush();

                }),
              new FlatButton(
                child: new Text('clearAllNotifications\n'), 
                onPressed: () {
                  
                  JPush.clearAllNotifications();

                }),
              new FlatButton(
                child: new Text('getLaunchAppNotification\n'), 
                onPressed: () {
                  
                  JPush.getLaunchAppNotification().then((map) {
                    setState(() {
                      _platformVersion = "getLaunchAppNotification success: $map";
                    });
                  })
                  .catchError((error) {
                    setState(() {
                      _platformVersion = "getLaunchAppNotification error: $error";
                    });
                  });

                }),
                
            ]
          )
          // new Text('Running on: $_platformVersion\n'),
          // child: new FlatButton(onPressed: () => {

          // }),
        ),
      ),
    );
  }
}
