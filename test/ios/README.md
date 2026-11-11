# UIScene 原生回归

`JPushSceneTests.m` 仅供隔离 iOS 测试宿主编译，不进入插件发布包（根 `.pubignore` 已排除 `test/`）。

将测试文件加入隔离宿主编译，完成 `GeneratedPluginRegistrant` 注册后，在主线程调用 `JPushRunSceneTests()`。测试输出 `JPUSH_SCENE_TEST PASS/FAIL` 与 `SUMMARY total=10 failed=N`。

测试真实调用 `JPushPlugin` 的 Scene/通知中心/MethodChannel 原生入口；通知与 channel 使用源级替身，`JPUSHService.handleRemoteNotification:` 临时替换为调用计数器并在测试结束恢复。它验证格式、启动缓存、排队/实时事件、两种跨入口顺序、completion、同消息不同投递与去重窗口；不等于真实 APNs 或远端点击统计验收。

系统级回归还应运行官方 Demo：终止进程、发送测试通知、实际点击通知、等待后点 getLaunchAppNotification。分别验证 Scene 返回 extras、普通图标启动为空、未启用 Scene 的 AppDelegate 路径正常。真机、Xcode27/iOS27与真实 APNs 需另外执行。

`JPushDeferredHandoffTests.m` 在同一隔离宿主执行 `JPushRunDeferredHandoffTests(engineRegistry)`，参数为 GeneratedPluginRegistrant 已注册的真实 registry，用于核对 publish。它覆盖同步启动缓存、注册失败/错误实例、setup 前暂存及实际 setup 后冲刷、迟监听/第二引擎、超过 5 秒的两种入口顺序、后台后合法点击与关联溢出。测试用源级响应/channel 替身，临时替换原生 setup/handleRemoteNotification 并恢复；不发 APNs，不证明服务端统计。新初始连接配对取代旧 5 秒窗口，N10 更新为后台后同通知合法点击。
