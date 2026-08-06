# jpush_google_ohos_flutter 3.0.7 — 推送与发布清单（需人工执行）

本会话已完成全部代码与文档改动并本地提交，但 `git push` 与 pub 发布命令（含 `--dry-run`）被权限系统拦截，须由人工执行以下步骤。

## 当前状态

- 仓库：`github.com/jpush/jpush-flutter-plugin`
- 本地分支：`dev-3.x-google-ohos`（基于 `origin/dev-3.x-google`，领先 7 个提交）
- 包名：`jpush_google_ohos_flutter`，版本 `3.0.7`
- 远端尚无 `dev-3.x-google-ohos` 分支，pub.dev 尚无 `jpush_google_ohos_flutter` 包

## 一、推送分支

```bash
cd <仓库目录>
git checkout dev-3.x-google-ohos
git push -u origin dev-3.x-google-ohos
```

该分支独立维护，**不要合入 `dev-3.x-google`**（后者继续发 `jpush_google_flutter`，不含鸿蒙）。

## 二、打 tag

```bash
git tag v3.0.7-google-ohos
git push origin v3.0.7-google-ohos
```

## 三、发布 pub.dev

前置确认：

1. `jpush_google_ohos_flutter` 在 pub.dev 上是**全新包名**，需确认包名未被占用、且当前账号有发布权限（新包首次发布由发布者账号自动成为 owner）。
2. 干净克隆后再发布，避免带入本地构建产物：

```bash
git clone -b dev-3.x-google-ohos https://github.com/jpush/jpush-flutter-plugin.git /tmp/pub-release
cd /tmp/pub-release
flutter pub get
flutter pub publish --dry-run   # 先校验
flutter pub publish             # 确认无误后发布
```

### 发布前已完成的本地校验

| 项 | 结果 |
|---|---|
| `name` / `version` / `homepage` | `jpush_google_ohos_flutter` / `3.0.7` / https://www.jiguang.cn |
| `description` 长度 | 154 字符（pub.dev 建议 60–180） |
| `LICENSE` / `README.md` / `CHANGELOG.md` | 均存在 |
| 跟踪文件总体积 | 920 KB（远低于 100 MB 上限） |
| 依赖 | `plugin_platform_interface: ^2.0.2`（已发布包），无本地路径依赖 |
| `.pubignore` | 已添加，排除 4 个含本机绝对路径/内部材料的文件，插件本体 + example 完整保留 |
| `flutter analyze lib example/lib` | 0 error |

> `--dry-run` 在本会话中被权限系统拦截，未实际执行；上表为手工核验结果，人工发布前请务必先跑一次 `--dry-run`。

## 四、发布后

1. TAPD 回复客户【二三四五】（AppKey `b541e598ef4c7ce598a82450`）：
   - 定制 SDK：`jpush-google` 制品本身无安装卸载感知与热更新逻辑，升级新版后无需定制版 jcore，客户现有集成方式（剔除 jcore-google、指定 `jcore:5.5.0`）可行；
   - 鸿蒙适配：依赖改为 `jpush_google_ohos_flutter: 3.0.7`（替换原 `jpush_google_flutter`，两者不可并存，原生 MethodChannel 同名 `jpush`），按 `README_Harmony.md` 集成；
   - 入口 API 变更：`JPush()` → `JPush.newJPush()`，需额外 `import 'package:jpush_google_ohos_flutter/jpush_interface.dart';`，其余调用不变。
2. 补鸿蒙真机验证（本会话无真机、example 已移除内置签名证书）：`getRegistrationID`、收推送、通知点击回调。
3. 建议同步修复国内版 `dev-3.x` 的三个问题：5 个空实现死 API、`EntryAbility.onCreate` 在 flutter_ohos 3.35.8 下编译不过、example 硬编码签名证书路径与密码密文。
