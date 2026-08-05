---
name: update-sdk
description: |
  更新 jpush-flutter-plugin 插件的 JPush SDK 版本。自动拉取极光官网 Changelog，分析新增/移除/变更 API，更新 Android（Maven）和 iOS（CocoaPods）版本引用，同步更新 Native 层（Java/ObjC）和 Dart Bridge 层代码，展示变更摘要确认后发布到 pub.dev。
  Use when: 更新 JPush SDK、升级推送 SDK 版本、jpush-flutter-plugin 发布新版本、Flutter 插件 SDK 更新。
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - WebFetch
---

你正在更新 **jpush-flutter-plugin** 插件。

**用户参数：** $ARGUMENTS

---

## 第一步：解析参数

从 `$ARGUMENTS` 中提取版本号：
- `--android X.X.X` → Android JPush SDK 目标版本
- `--ios X.X.X` → iOS JPush SDK 目标版本

如果某端版本号缺失，先询问用户再继续。

---

## 第二步：安装依赖

```bash
pip3 install requests beautifulsoup4 -q 2>&1 | tail -1
```

---

## 第三步：拉取 SDK Changelog

```bash
python3 .claude/skills/update-sdk/scripts/changelog_fetcher.py --android <ANDROID_VERSION> --ios <IOS_VERSION>
```

读取 `.claude/skills/update-sdk/scripts/.changelog_cache.json` 获取 Changelog 内容。

---

## 第四步：AI 分析变更

基于 Changelog，分析并整理：

> **注意**：Changelog 同时包含 JPush 和 JCore 的变更。两者都要关注。

1. **新增 API**：Android 和 iOS 相同功能 → 合并为一个 Dart 对外 API；仅单端有的 → **先检查另一端是否已有等价实现**（见下方说明），确认缺失才标注平台注释
2. **移除/废弃 API**：是否需要从 Dart 层删除或标记 `@Deprecated`
3. **行为变更**：影响现有封装逻辑的改动
4. **新插件版本号**：始终升 patch（如 3.4.9 → 3.5.0，3.9.9 → 4.0.0）

> **跨平台等价检查**：当 Changelog 只在某一端出现新增 API 时，**不要直接标为单端 Only**。先读取另一端的 Native 文件（`android/src/main/java/com/jiguang/jpush/JPushPlugin.java` 或 `ios/jpush_flutter/Sources/jpush_flutter/JPushPlugin.m`）和 Dart Bridge 层（`lib/android_ios/`），搜索功能相同或名称相近的方法。如果另一端已有对应实现，则合并为统一 Dart API；只有确认另一端完全没有等价功能时，才标注 Android Only / iOS Only。

输出结构化变更计划后再执行后续步骤。

---

## 第五步：更新版本号引用

```bash
python3 .claude/skills/update-sdk/scripts/plugin_updater.py \
  --android <ANDROID_VERSION> \
  --ios <IOS_VERSION> \
  --bump-patch \
  --changelog-summary "<ONE_LINE_SUMMARY>"
```

> iOS 版本引用有**两处**（config.json 已配置，脚本会同时更新）：`ios/jpush_flutter.podspec`（CocoaPods）和 `ios/jpush_flutter/Package.swift` 的 `exact: "x.x.x"`（SPM）。执行后检查脚本输出，确认两处都是 UPDATED，漏掉任何一处会导致 SPM 与 CocoaPods 用户的 SDK 版本不一致。JCore 若也升级，podspec 的 `'JCore','>= x.x.x'` 与 Package.swift 的 `from: "x.x.x"` 需手动同步。

---

## 第六步：更新 Native 层代码

**编写代码前，先通过 WebFetch 查询官网 API 文档，确认新增方法的完整签名、参数类型和返回值：**
- Android 文档：`https://docs.jiguang.cn/jpush/client/Android/android_api`
- iOS 文档：`https://docs.jiguang.cn/jpush/client/iOS/ios_api`

在文档中搜索第四步识别出的新增方法名，确认签名后再编写下方代码。

**Android** — `android/src/main/java/com/jiguang/jpush/JPushPlugin.java`
- 在 `onMethodCall` 的 `when` 分支中添加新方法处理
- 内部调用 `JPushInterface.newMethod()`

**iOS** — `ios/jpush_flutter/Sources/jpush_flutter/JPushPlugin.m`
- 在 `handleMethodCall:result:` 方法中添加新的 `if` 分支
- 内部调用 JPush iOS SDK 对应方法

---

## 第七步：更新 Dart Bridge 层

主要编辑 `lib/android_ios/` 目录下的 Dart 文件：
- 添加新的公共方法，通过 `MethodChannel` 调用 Native
- 每个新增 API 同时处理 Android 和 iOS（统一方法名）

---

## 第八步：展示变更摘要并请求确认

```
========== jpush-flutter-plugin 更新摘要 ==========
Android JPush SDK:  旧版本 → 新版本
iOS JPush SDK:      旧版本 → 新版本
插件版本:            旧版本 → 新版本

新增 API（Dart）：
  + Future<void> methodName(params)  // 说明

移除 API：
  - methodName()

行为变更：
  ! 变更说明

修改的文件：
  - android/build.gradle
  - ios/jpush_flutter.podspec
  - ios/jpush_flutter/Package.swift
  - android/src/.../JPushPlugin.java
  - ios/jpush_flutter/Sources/jpush_flutter/JPushPlugin.m
  - lib/android_ios/...
  - pubspec.yaml
  - CHANGELOG.md
===================================================

确认以上变更并发布到 pub.dev? [y/N]
```

---

## 第九步：发布（确认后执行）

用户输入 `y` 后：

```bash
python3 .claude/skills/update-sdk/scripts/publisher.py
```
