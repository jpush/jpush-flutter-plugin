# 鸿蒙本地通知回归验证

Node.js 18+ 和 TypeScript 5.7.3：

```sh
# 使用外部测试工具目录，避免将 Node 依赖写入插件发布包。
npm install --prefix /tmp/jpush-test-tools typescript@5.7.3
TYPESCRIPT_PATH=/tmp/jpush-test-tools/node_modules/typescript node test/harmony_local_notification_test.cjs
flutter test test/jpush_harmony_local_notification_test.dart
```

Node 测试用标准 TypeScript AST 提取真实分发入口和生产方法，转译后观察
`JPushInterface.addLocalNotification` 的参数；不复制序列化算法。
覆盖原问题、中文、多键、转义、特殊键、空 Map、普通对象、null 和缺省。
内存变异覆盖旧空对象缺陷、取错参数、绕过发送和覆盖结果，并检查重排版不影响测试。
Dart 测试检查通道参数及到达/点击回调透传。

这些检查不能替代 ArkTS/HAP 构建和真机验证。有鸿蒙工具链后构建示例 HAP，
按 README_Harmony.md 完成初始化及 onCreate/onNewWant 的 Want 转发，发送
`LocalNotification(extra: {'fa': '0'})`，核对到达和点击回调中的 extras。
覆盖前台、后台及点击冷启动，再验证多键中文、空 Map、缺省。
缺工具或设备的项目须明确记为“未验证”，不能由 Node/Dart 通过推断平台通过。
