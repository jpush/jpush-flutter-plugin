# 更新SDK

根据输入的需要更新的SDK版本号更新插件。

## 更新步骤

### 1. 更新SDK版本依赖

- **iOS**: 在 `ios/jpush_flutter.podspec` 中更新 iOS JPush SDK 的版本依赖，并同步 `ios/jpush_flutter/Package.swift` 中 jpush-sdk（`exact:`）/ jcore-sdk（`from:`）的版本（SPM 与 CocoaPods 两处必须一致）
- **Android**: 在 `android/build.gradle` 中更新 Android JPush SDK 的版本依赖

### 2. 查找SDK新增API

**⚠️ 重要：必须仔细逐项检查更新日志，不要因为看到"更新各厂商SDK"等主要更新内容就忽略新增API的检查！**

**⚠️ 重要：执行本步时按文末「文档内容获取方式」获取下方更新日志页面的内容，逐条阅读，不要仅依赖网页搜索。**

#### Android SDK
- 访问 [Android SDK Changelog](https://docs.jiguang.cn/jpush/jpush_changelog/updates_Android) 查找新版本的新增对外API
- **检查方法**：
  1. 找到目标版本（如 v5.2.0）的更新内容部分
  2. **逐项阅读**更新内容列表中的每一项，不要跳过任何条目
  3. 特别关注包含以下关键词的条目：
     - "新增"、"新增接口"、"新增API"、"新增方法"
     - "public static"、"public void" 等Java方法签名
     - "支持"、"功能"（可能包含新API）
  4. 对于每个疑似新增API的条目，记录：
     - API方法名（如 `setCollectControl`）
     - 完整方法签名（如 `public static void setCollectControl(JPushCollectControl control)`）
     - 功能描述
- 在 [Android SDK API 文档](https://docs.jiguang.cn/jpush/client/Android/android_api) 中查找并确认新增API的详细用法、参数说明和示例代码

#### iOS SDK
- 访问 [iOS SDK Changelog](https://docs.jiguang.cn/jpush/jpush_changelog/updates_iOS) 查找新版本的新增对外API
- **检查方法**：
  1. 找到目标版本（如 v5.2.0）的更新内容部分
  2. **逐项阅读**更新内容列表中的每一项，不要跳过任何条目
  3. 特别关注包含以下关键词的条目：
     - "新增"、"新增接口"、"新增API"、"新增方法"
     - Objective-C方法签名（如 `- (void)setBadge:completion:`）
     - "支持"、"功能"（可能包含新API）
  4. 对于每个疑似新增API的条目，记录：
     - API方法名
     - 完整方法签名
     - 功能描述
- 在 [iOS SDK API 文档](https://docs.jiguang.cn/jpush/client/iOS/ios_api) 中查找并确认新增API的详细用法、参数说明和示例代码

**检查清单**（在完成检查后确认）：
- [ ] 已找到目标版本的更新日志
- [ ] 已逐项阅读所有更新内容条目（包括次要更新）
- [ ] 已识别所有包含"新增"、"API"、"接口"、"方法"等关键词的条目
- [ ] 已记录所有新增API的方法名和签名
- [ ] 已在API文档中查找并确认了每个新增API的详细用法
- [ ] 已区分哪些是新增的对外API（需要封装），哪些是内部更新（不需要封装）

**常见误区**：
- ❌ 错误：看到"更新各厂商SDK"就认为只是版本更新，没有新增API
- ✅ 正确：即使主要更新是版本升级，也要仔细检查是否有新增API
- ❌ 错误：只关注主要更新内容，忽略列表中的其他条目
- ✅ 正确：必须逐项检查更新内容列表中的每一项
- ❌ 错误：依赖搜索结果判断是否有新增API
- ✅ 正确：直接查看官方更新日志，逐项检查
- ❌ 错误：文本识别有问题时（如缺少字母），直接忽略
- ✅ 正确：如果文本识别有问题，需要手动访问官方文档确认

### 3. 封装新增API（如有）

**⚠️ 重要：如果没有新增API，必须明确说明"经检查，该版本无新增对外API"，而不是简单说"没有新增API"。**

如果SDK有新增API，需要在插件中进行封装：
- 在 `lib/android_ios/jpush_flutter_a_i.dart` 中添加Dart方法
- 在 `android/src/main/java/com/jiguang/jpush/JPushPlugin.java` 中实现Android端逻辑
- 在 `ios/jpush_flutter/Sources/jpush_flutter/JPushPlugin.m` 中实现iOS端逻辑

**封装原则**：
- 如果Android和iOS新增的API是同一个功能，封装成一个插件方法
- 如果不是同一个功能，分开封装
- **不要使用反射的方式调用SDK API，直接调用即可**
- 如果没有新增API，**必须明确说明已检查并确认无新增API**，然后跳过此步骤

**封装步骤**：
1. 确定API的完整签名和参数类型
2. 确定API的调用时机（是否需要在init之前调用）
3. 在对应平台实现方法
4. 在Dart层添加方法，保持与现有API风格一致
5. 添加必要的错误处理和日志

### 4. 更新示例代码

在 `example/lib/main.dart` 中添加新增API的示例调用代码（如有新增API）。

### 5. 更新API文档

如果新增了插件方法，需要更新文档：
- 在 `documents/APIs.md` 中补充新增的插件方法

如果没有新增方法，跳过此步骤。

### 6. 更新插件版本号

在 `pubspec.yaml` 中更新插件版本号：

**版本号格式**：`主版本号.次版本号.修订号`（如 `3.4.0`）

**版本号更新规则**：
- **每次更新SDK时，修订号自动 +1**
- **版本号取值范围**：
  - 修订号：0-9（最大值为9）
  - 次版本号：0-9（最大值为9）
  - 主版本号：无限制
- **进位规则**：
  - 当修订号达到 10 时，修订号重置为 0，次版本号 +1
  - 当次版本号达到 10 时，次版本号重置为 0，主版本号 +1

**示例**：
- 当前版本为 `3.4.0`，更新后为 `3.4.1`
- 当前版本为 `3.4.9`，更新后为 `3.5.0`（修订号从9变为10，进位后为3.5.0）
- 当前版本为 `3.9.9`，更新后为 `4.0.0`（修订号从9变为10，进位后次版本号从9变为10，再次进位后为4.0.0）

### 7. 更新README.md

在 `README.md` 中更新示例代码的插件版本号，改为最新的插件版本号：

```yaml
dependencies:
  jpush_flutter: 插件版本号
```

### 8. 更新CHANGELOG.md

在 `CHANGELOG.md` 中记录本次更新的变更内容，包括：
- SDK版本更新
- **新增的API方法（如有，必须列出具体方法名）**
- 其他相关变更

**如果无新增API，也要明确说明**：
```
## 3.4.1
- 更新 Android JPush SDK 到 5.9.0 版本
- 更新 iOS JPush SDK 到 5.9.0 版本
- 经检查，该版本无新增对外API
```

## 文档内容获取方式

文档中的链接（极光更新日志、API 文档、CocoaPods 等）需要获取内容时：用 **curl 拉取对应 URL**，在返回的 HTML 里用 **grep 或搜索** 定位所需段落（极光页面为服务端渲染，内容均在 HTML 中，无需执行 JS）。

## 注意事项

- **必须逐项检查更新日志，不要遗漏任何新增API**
- 确保Android和iOS的SDK版本对应关系正确
- 新增API的封装需要保持与现有API风格一致
- 更新后建议进行测试验证
- **如果更新日志中的文本识别有问题（如缺少字母），需要手动访问官方文档确认**