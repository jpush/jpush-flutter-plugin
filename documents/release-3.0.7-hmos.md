# jpush_google_flutter 3.0.7 鸿蒙适配 — 发布材料（转人工执行发布）

## 背景（TAPD：二三四五 Google 版 SDK 不适配鸿蒙）

客户【二三四五】（AppKey `b541e598ef4c7ce598a82450`）为弃用定制版 jcore-custom 4.8.4（关闭安装卸载权限 + 热更新），已改用 `jpush_google_flutter: 3.0.5` + `cn.jiguang.sdk:jcore:5.5.0`，Android 端集成成功；但 Google 版插件不支持鸿蒙。本次将国内版 `jpush_flutter` 3.5.0（dev-3.x）的鸿蒙实现移植到 Google 版（dev-3.x-google）。

## 版本信息

- 插件：`jpush_google_flutter` 3.0.7（工作分支 `feature/ohos-google`，基于 `dev-3.x-google`）
- 鸿蒙原生 SDK：ohpm `@jg/push` 1.4.0（jpush-hmos）
- Android：`cn.jiguang.sdk:jpush-google:6.2.0`（不变）；iOS：jpush 6.2.0 / jcore 5.5.0（不变）
- 鸿蒙构建环境：鸿蒙版 Flutter 3.35.8-ohos-1.0.1 + DevEco Studio（`DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk`）

## 变更内容

1. 新增 `ohos/` 插件模块（ETS，MethodChannel `"jpush"`，模块名 `jpush_google_flutter`）。
2. Dart 层重构为「统一接口 + 平台实现」：`lib/jpush_interface.dart`（接口 + 默认降级实现）、`lib/android_ios/jpush_flutter_a_i.dart`（原 Google 实现改造）、`lib/harmony/`（4 个文件）、入口 `JPush.newJPush()` 按平台路由。**breaking：入口由 `JPush()` 改为 `JPush.newJPush()`。**
3. `pubspec.yaml` 增加 `ohos` 平台声明与 `plugin_platform_interface` 依赖。
4. `example/ohos/` 完整鸿蒙示例工程；`example/lib/main.dart` 同步新入口写法。
5. `README_Harmony.md` 鸿蒙集成文档；README/CHANGELOG 更新。
6. 兼容性修复：`EntryAbility.onCreate` 返回类型 `Promise<void>` → `void`（适配 flutter_ohos 3.35.8；国内版 dev-3.x 示例在新版鸿蒙 Flutter 下也需要同样修复）。

## 已完成验证

- `flutter analyze lib`（官方版 Flutter 3.44.6）：0 error（仅存量 `required` 注解 deprecation info）。
- example Dart 层 analyze：0 error。
- 鸿蒙全链路构建：`flutter build hap --debug`（鸿蒙版 Flutter）完成 Dart AOT + `@jg/push` 解析 + ETS 编译 + 插件 HAR + HAP 打包，产出 `entry-default-unsigned.hap`（COMPILE RESULT: 0 error）。签名因本机无证书跳过（原证书路径 `/Users/weiruiyang/DevEcoStudioProjects/harmony_push_sdk/tttt/` 已不存在）。
- 过渡方案编译级验证：国内版 dev-3.x 插件 Android Java 源码用 `jpush-google-6.2.0` + `jcore-5.5.0` javac 编译 0 错误 → 客户在等待本版发布期间，可临时用 `jpush_flutter: 3.5.0` + `android/app/build.gradle` 中 exclude `cn.jiguang.sdk:jpush` 改配 `jpush-google:6.2.0` + `jcore:5.5.0` 获得鸿蒙能力（建议真机回归后再给客户）。

## 待人工执行

1. 补真机验证：鸿蒙真机 + 有效签名证书，跑 example 验证 getRegistrationID、收推送、通知点击回调（可用测试 AppKey 或客户 AppKey）。
2. 代码评审后合入 `dev-3.x-google` 并 push（本次未 push）。
3. 打 tag `v3.0.7-google`（沿用仓库既有 tag 规范），干净克隆做 `flutter pub publish --dry-run` 校验后发布 pub.dev（流程参照 wry-flutter-publish-sdk，将分支替换为 dev-3.x-google）。
4. TAPD 回复客户：
   - 定制 SDK 问题：`jpush-google` 制品本身无安装卸载感知与热更新逻辑，升级新版后无需定制版 jcore，客户现有集成方式（剔除 jcore-google、指定 jcore:5.5.0）可行；
   - 鸿蒙适配：3.0.7 发布后按 README_Harmony.md 集成，注意入口 API 变更为 `JPush.newJPush()`。
