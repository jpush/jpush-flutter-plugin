# jpush_example

Demonstrates how to use the jpush plugin.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## iOS Live Activity Token 测试

Demo 页面包含 Live Activity PushToken 与 Push-to-Start Token 的注册和解绑测试面板，仅在 iOS 显示。

1. 使用 ActivityKit 获取真实 Token。测试面板同时接受 Base64 和十六进制格式；如需转换可使用：

   ```swift
   let tokenBase64 = token.base64EncodedString()
   let tokenHex = token.map { String(format: "%02x", $0) }.joined()
   ```

2. 将 Token 粘贴到对应输入框。可选使用 `base64:`、`hex:` 或 `0x` 前缀明确格式：
   - 普通 Live Activity 使用相同的 `Live Activity ID` 注册、更新和解绑；
   - Push-to-Start 使用相同的 `ActivityAttributes` 标识注册、更新和解绑。
3. 点击注册按钮，确认页面顶部结果中的 `code` 为 `0`，并检查 `seq` 和 `tokenLength`。
4. 点击对应解绑按钮。解绑时 Token 输入框可以留空，Demo 会向插件传入 `null`。

PushToken 测试需要 iOS 16.1+；Push-to-Start Token 测试需要 iOS 17.2+。Demo 仅负责调用 JPush Flutter 接口，不创建 Live Activity，也不监听 ActivityKit Token 更新。
