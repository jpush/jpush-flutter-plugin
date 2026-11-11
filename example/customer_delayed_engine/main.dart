import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

void main() {
  runApp(const MaterialApp(home: HandoffExample()));
}

class HandoffExample extends StatefulWidget {
  const HandoffExample({super.key});

  @override
  State<HandoffExample> createState() => _HandoffExampleState();
}

class _HandoffExampleState extends State<HandoffExample> {
  final _jpush = JPush.newJPush();
  var _openCount = 0;
  var _launchStatus = 'loading';

  @override
  void initState() {
    super.initState();
    _jpush.addEventHandler(onOpenNotification: (message) async {
      if (!mounted) return;
      setState(() => _openCount++);
      debugPrint('stage=handoff_sample open_count=$_openCount');
      // 在此合入客户原点击逻辑。同一通知不要再从启动参数读取处
      // 无条件重复执行页面跳转。
    });
    _readLaunchNotification();
    // setup 保留在客户原初始化和隐私流程中。
    // 本参数读取示例不含 AppKey，也不主动调用 setup。
  }

  Future<void> _readLaunchNotification() async {
    try {
      final notification = await _jpush.getLaunchAppNotification();
      if (!mounted) return;
      final status = notification.isEmpty
          ? 'empty'
          : notification['extras'] is Map
              ? 'extras_present'
              : 'missing_extras';
      setState(() => _launchStatus = status);
      debugPrint('stage=handoff_sample launch_status=$status');
    } catch (_) {
      if (!mounted) return;
      setState(() => _launchStatus = 'read_failed');
      debugPrint('stage=handoff_sample launch_status=read_failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通知接入示例')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('启动参数：$_launchStatus'),
            Text('点击回调次数：$_openCount'),
            TextButton(
              onPressed: _readLaunchNotification,
              child: const Text('再次读取启动参数'),
            ),
          ],
        ),
      ),
    );
  }
}
