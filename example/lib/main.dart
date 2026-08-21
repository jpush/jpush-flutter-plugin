import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? debugLable = 'Unknown';
  final JPushFlutterInterface jpush = JPush.newJPush();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;

    try {
      jpush.setCallBackHarmony((eventName, data) async {
        print("flutter_log_MyApp:eventName:$eventName");
        print("flutter_log_MyApp:data:$data");
        setState(() {
          print("flutter_log_MyApp:setState");
          debugLable = "flutter CallBackHarmony: $eventName:$data";
        });
      });

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
      }, onNotifyMessageUnShow: (Map<String, dynamic> message) async {
        print("flutter onNotifyMessageUnShow: $message");
        setState(() {
          debugLable = "flutter onNotifyMessageUnShow: $message";
        });
      }, onInAppMessageShow: (Map<String, dynamic> message) async {
        print("flutter onInAppMessageShow: $message");
        setState(() {
          debugLable = "flutter onInAppMessageShow: $message";
        });
      }, onCommandResult: (Map<String, dynamic> message) async {
        print("flutter onCommandResult: $message");
        setState(() {
          debugLable = "flutter onCommandResult: $message";
        });
      }, onInAppMessageClick: (Map<String, dynamic> message) async {
        print("flutter onInAppMessageClick: $message");
        setState(() {
          debugLable = "flutter onInAppMessageClick: $message";
        });
      }, onNotifyButtonClick: (Map<String, dynamic> message) async {
        print("flutter onNotifyButtonClick: $message");
        setState(() {
          debugLable = "flutter onNotifyButtonClick: $message";
        });
      }, onConnected: (Map<String, dynamic> message) async {
        print("flutter onConnected: $message");
        setState(() {
          debugLable = "flutter onConnected: $message";
        });
      }, onReceiveDeviceToken: (Map<String, dynamic> message) async {
        print("flutter onReceiveDeviceToken: $message");
        setState(() {
          debugLable = "flutter onReceiveDeviceToken: $message";
        });
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    jpush.setAuth(enable: true);
    // HarmonyOS Only：设置为 true 后 SDK 不再自动申请通知权限，需自行申请，必须在 setup 之前调用
    // jpush.setUserRequestNotificationPermission(enable: true);
    jpush.setup(
      appKey: "b266cd5c8544ba09b23733e3", //你自己应用的 AppKey
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

    // iOS要是使用应用内消息，请在页面进入离开的时候配置pageEnterTo 和  pageLeave 函数，参数为页面名。
    jpush.pageEnterTo("HomePage"); // 在离开页面的时候请调用 jpush.pageLeave("HomePage");

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
        body: new SingleChildScrollView(
            child: new Center(
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
                        print("flutter getLaunchAppNotification:$map");
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
                    title: "requestSubscribeChannel",
                    onPressed: () {
                      if (Platform.isAndroid) {
                        jpush.requestSubscribeChannel(["your_channel_id"]);
                      }
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
                      if (Platform.isIOS || Platform.isAndroid) {
                        jpush.getAllTags().then((map) {
                          setState(() {
                            debugLable = "getAllTags success: $map";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "getAllTags error: $error";
                          });
                        });
                      } else {
                        jpush.getTags(1).then((map) {
                          setState(() {
                            debugLable = "getTags success: $map";
                          });
                        }).catchError((error) {
                          setState(() {
                            debugLable = "getTags error: $error";
                          });
                        });
                      }
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
                new Text(" "),
                new CustomButton(
                    title: "getAlias",
                    onPressed: () {
                      jpush.getAlias().then((map) {
                        setState(() {
                          debugLable = "getAlias success: $map";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "getAlias error: $error";
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
                  title: "turnOffPush",
                  onPressed: () {
                    jpush.turnOffPush().then((result) {
                      setState(() {
                        debugLable = "turnOffPush: ${result['code']}";
                      });
                    }).catchError((error) {
                      setState(() {
                        debugLable = "turnOffPush error: $error";
                      });
                    });
                  }),
              new Text(" "),
              new CustomButton(
                  title: "turnOnPush",
                  onPressed: () {
                    jpush.turnOnPush();
                  }),
            ],
          ),
          LiveActivityTestPanel(
            jpush: jpush,
            onResult: (message) {
              setState(() {
                debugLable = message;
              });
            },
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(" "),
              new CustomButton(
                  title: "getPushStatus",
                  onPressed: () {
                    jpush.getPushStatus().then((result) {
                      int code = result['code'] ?? -1;
                      bool isStopped = result['isStopped'] ?? false;
                      String statusText = isStopped ? "已停止" : "未停止";
                      setState(() {
                        debugLable =
                            "getPushStatus: code=$code, isStopped=$isStopped ($statusText)";
                      });
                    }).catchError((error) {
                      setState(() {
                        debugLable = "getPushStatus error: $error";
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
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(" "),
              new CustomButton(
                  title: "getRegistrationID",
                  onPressed: () {
                    jpush.getRegistrationID().then((rid) {
                      setState(() {
                        debugLable = "getRegistrationID: $rid";
                      });
                    }).catchError((onError) {
                      setState(() {
                        debugLable = "getRegistrationID: ${onError.toString()}";
                      });
                    });
                  }),
            ],
          ),
        ]))),
      ),
    );
  }
}

/// iOS Live Activity Token 注册与解绑测试面板。
class LiveActivityTestPanel extends StatefulWidget {
  final JPushFlutterInterface jpush;
  final ValueChanged<String> onResult;
  final bool? isIOS;

  const LiveActivityTestPanel({
    required this.jpush,
    required this.onResult,
    this.isIOS,
  });

  @override
  State<LiveActivityTestPanel> createState() => _LiveActivityTestPanelState();
}

class _LiveActivityTestPanelState extends State<LiveActivityTestPanel> {
  final TextEditingController _liveActivityIdController =
      TextEditingController(text: 'jpush_flutter_live_activity_demo');
  final TextEditingController _activityAttributesController =
      TextEditingController(text: 'OrderActivityAttributes');
  final TextEditingController _pushTokenController = TextEditingController();
  final TextEditingController _pushToStartTokenController =
      TextEditingController();
  int _seq = 1000;
  bool _isSubmitting = false;
  String _resultText = '等待操作';

  @override
  void dispose() {
    _liveActivityIdController.dispose();
    _activityAttributesController.dispose();
    _pushTokenController.dispose();
    _pushToStartTokenController.dispose();
    super.dispose();
  }

  Uint8List _parseToken(String input) {
    var normalized = input.replaceAll(RegExp(r'\s'), '');
    if (normalized.isEmpty) {
      throw const FormatException('请先粘贴 ActivityKit Token');
    }

    final lowerCase = normalized.toLowerCase();
    final hasHexPrefix =
        lowerCase.startsWith('hex:') || lowerCase.startsWith('0x');
    final hasBase64Prefix = lowerCase.startsWith('base64:');
    if (hasHexPrefix) {
      normalized = normalized.substring(lowerCase.startsWith('hex:') ? 4 : 2);
      return _decodeHexToken(normalized);
    }
    if (hasBase64Prefix) {
      normalized = normalized.substring(7);
      return _decodeBase64Token(normalized);
    }

    final hexWithoutSeparators = normalized.replaceAll(':', '');
    if (hexWithoutSeparators.length.isEven &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexWithoutSeparators)) {
      return _decodeHexToken(hexWithoutSeparators);
    }
    return _decodeBase64Token(normalized);
  }

  Uint8List _decodeHexToken(String input) {
    final normalized = input.replaceAll(':', '');
    if (normalized.isEmpty ||
        normalized.length.isOdd ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(normalized)) {
      throw const FormatException('hex Token 必须是偶数位十六进制字符串');
    }
    return Uint8List.fromList(<int>[
      for (var index = 0; index < normalized.length; index += 2)
        int.parse(normalized.substring(index, index + 2), radix: 16),
    ]);
  }

  Uint8List _decodeBase64Token(String input) {
    try {
      final token = base64.decode(base64.normalize(input));
      if (token.isEmpty) {
        throw const FormatException('Base64 Token 不能为空');
      }
      return token;
    } on FormatException {
      throw const FormatException('Token 必须是有效的 hex 或 Base64 字符串');
    }
  }

  String _formatResult(String action, Map<dynamic, dynamic> result) {
    final token = result['pushToken'];
    final tokenLength = token is Uint8List ? token.length : 0;
    return '$action: code=${result['code']}, '
        'liveActivityId=${result['liveActivityId']}, '
        'seq=${result['seq']}, tokenLength=$tokenLength';
  }

  void _report(String message) {
    if (mounted) {
      setState(() {
        _resultText = message;
      });
      widget.onResult(message);
    }
  }

  Future<void> _registerPushToken({required bool unbind}) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _resultText = unbind ? '正在解绑 PushToken…' : '正在注册 PushToken…';
    });
    try {
      final liveActivityId = _liveActivityIdController.text.trim();
      if (liveActivityId.isEmpty || utf8.encode(liveActivityId).length > 64) {
        throw const FormatException('Live Activity ID 必须为 1～64 字节');
      }
      final result = await widget.jpush.registerLiveActivityPushToken(
        liveActivityId: liveActivityId,
        pushToken: unbind ? null : _parseToken(_pushTokenController.text),
        seq: _seq++,
      );
      _report(_formatResult(
        unbind ? '解绑 Live Activity PushToken' : '注册 Live Activity PushToken',
        result,
      ));
    } catch (error) {
      _report('Live Activity PushToken 测试失败: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _registerPushToStartToken({required bool unbind}) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _resultText =
          unbind ? '正在解绑 Push-to-Start Token…' : '正在注册 Push-to-Start Token…';
    });
    try {
      final activityAttributes = _activityAttributesController.text.trim();
      if (activityAttributes.isEmpty) {
        throw const FormatException('ActivityAttributes 标识不能为空');
      }
      final result = await widget.jpush.registerLiveActivityPushToStartToken(
        activityAttributes: activityAttributes,
        pushToStartToken:
            unbind ? null : _parseToken(_pushToStartTokenController.text),
        seq: _seq++,
      );
      _report(_formatResult(
        unbind
            ? '解绑 Live Activity Push-to-Start Token'
            : '注册 Live Activity Push-to-Start Token',
        result,
      ));
    } catch (error) {
      _report('Live Activity Push-to-Start Token 测试失败: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.isIOS ?? Platform.isIOS)) {
      return const SizedBox.shrink();
    }
    return Container(
      width: 350,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'iOS Live Activity Token 测试',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text('支持 Base64 或 hex Token；解绑无需填写 Token。'),
          if (_isSubmitting) const LinearProgressIndicator(),
          Text(
            _resultText,
            style: const TextStyle(color: Colors.blueGrey),
          ),
          TextField(
            controller: _liveActivityIdController,
            decoration: const InputDecoration(labelText: 'Live Activity ID'),
          ),
          TextField(
            key: const ValueKey<String>('liveActivityPushTokenInput'),
            controller: _pushTokenController,
            autocorrect: false,
            decoration:
                const InputDecoration(labelText: 'PushToken（Base64 / hex）'),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: <Widget>[
              CustomButton(
                title: '注册 PushToken',
                onPressed: _isSubmitting
                    ? null
                    : () => _registerPushToken(unbind: false),
              ),
              CustomButton(
                title: '解绑 PushToken',
                onPressed: _isSubmitting
                    ? null
                    : () => _registerPushToken(unbind: true),
              ),
            ],
          ),
          TextField(
            controller: _activityAttributesController,
            decoration:
                const InputDecoration(labelText: 'ActivityAttributes 标识'),
          ),
          TextField(
            key: const ValueKey<String>('liveActivityPushToStartTokenInput'),
            controller: _pushToStartTokenController,
            autocorrect: false,
            decoration: const InputDecoration(
                labelText: 'Push-to-Start Token（Base64 / hex）'),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: <Widget>[
              CustomButton(
                title: '注册 Push-to-Start',
                onPressed: _isSubmitting
                    ? null
                    : () => _registerPushToStartToken(unbind: false),
              ),
              CustomButton(
                title: '解绑 Push-to-Start',
                onPressed: _isSubmitting
                    ? null
                    : () => _registerPushToStartToken(unbind: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 封装控件
class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? title;

  const CustomButton({@required this.onPressed, @required this.title});

  @override
  Widget build(BuildContext context) {
    return new TextButton(
      onPressed: onPressed,
      child: new Text("$title"),
      style: new ButtonStyle(
        // ignore: deprecated_member_use
        foregroundColor: MaterialStateProperty.all(Colors.white),
        // ignore: deprecated_member_use
        overlayColor: MaterialStateProperty.all(Color(0xff888888)),
        // ignore: deprecated_member_use
        backgroundColor: MaterialStateProperty.all(Color(0xff585858)),
        // ignore: deprecated_member_use
        padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(10, 5, 10, 5)),
      ),
    );
  }
}
