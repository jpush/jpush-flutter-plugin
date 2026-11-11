import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

void main() => runApp(const MaterialApp(home: HandoffDemo()));

class HandoffDemo extends StatefulWidget {
  const HandoffDemo({super.key});
  @override
  State<HandoffDemo> createState() => _HandoffDemoState();
}

class _HandoffDemoState extends State<HandoffDemo> {
  final _push = JPush.newJPush();
  int _clicks = 0;
  String _launch = 'Reading launch cache';

  @override
  void initState() {
    super.initState();
    // 先注册监听；原生交接早于监听时，插件会排队交付点击事件。
    _push.addEventHandler(onOpenNotification: (notification) async {
      if (mounted) setState(() => _clicks++);
    });
    _readLaunch();
    // 此演示不含 AppKey、不调用 setup。真实应用保留原隐私/SDK初始化流程。
  }

  Future<void> _readLaunch() async {
    final notification = await _push.getLaunchAppNotification();
    if (mounted) {
      setState(() => _launch = notification.isEmpty ? 'No launch notification' : 'Launch notification available');
    }
    // 可按现有业务读取 notification['extras']；启动缓存和点击回调不要重复导航。
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Delayed engine handoff')),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(_launch), Text('Notification clicks: $_clicks'),
      TextButton(onPressed: _readLaunch, child: const Text('Read launch cache')),
    ])),
  );
}
