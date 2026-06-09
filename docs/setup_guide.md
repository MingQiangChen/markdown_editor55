# QLaw Markdown 安装与启动指南

## 环境要求

| 工具 | 最低版本 | 说明 |
|------|---------|------|
| Flutter SDK | 3.7.2+ | 跨平台框架 |
| Dart SDK | 3.7.2+ | 随 Flutter 一起安装 |
| Git | 任意 | 版本控制 |
| Windows | 10/11 | 桌面运行 |
| 浏览器 | Chrome / Edge | Web 运行 |

## 1. 安装 Flutter

### Windows

```powershell
# 下载 Flutter SDK
# https://docs.flutter.dev/get-started/install/windows

# 解压到指定目录，例如：
C:\flutter

# 添加到系统环境变量 PATH：
C:\flutter\bin
```

### 验证安装

```bash
flutter doctor
```

确保 `Flutter` 和 `Chrome` 两项打勾即可。Android / Visual Studio 非必需。

## 2. 获取项目代码

```bash
git clone https://github.com/MingQiangChen/markdown_editor55.git
cd markdown_editor55
```

或直接进入已有目录：

```bash
cd E:\markdown\markdown_editor
```

## 3. 安装依赖

```bash
flutter pub get
```

这将自动下载以下包：

| 包 | 用途 |
|---|------|
| `file_picker` | 桌面端原生文件对话框 |
| `flutter_markdown_plus` | Markdown 实时预览 |
| `markdown` | HTML 导出 |
| `pdf` | PDF 生成 |
| `printing` | PDF 分享/保存 |

## 4. 验证项目完整性

```bash
# 格式化检查
dart format lib test

# 静态分析
flutter analyze

# 运行测试
flutter test
```

预期输出：

```text
No issues found!
All tests passed!
```

## 5. 启动应用

### 方式一：Web 浏览器（推荐开发调试）

```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

启动后打开浏览器访问：

```text
http://127.0.0.1:5173
```

- 支持热重启：在终端按 `r`
- 退出：在终端按 `q`

### 方式二：Windows 桌面

```bash
flutter run -d windows
```

直接弹出桌面窗口，享受原生文件对话框体验。

### 方式三：Chrome 直接运行

```bash
flutter run -d chrome
```

## 6. 构建发布版本

### Web 发布

```bash
flutter build web
```

输出目录：`build/web/`

部署到任意静态文件服务器即可。

### Windows 桌面发布

```bash
flutter build windows
```

输出目录：`build/windows/x64/runner/Release/`

## 快速启动脚本

### Windows (PowerShell)

创建 `run.ps1`：

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

### Windows (CMD)

创建 `run.bat`：

```batch
@echo off
call flutter pub get
call dart format lib test
call flutter analyze
call flutter test
call flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

## 常见问题

**Q: `flutter doctor` 显示 Android toolchain 未安装？**

A: 本项目只需 Windows (desktop) 或 Chrome (web)，Android 非必需。忽略该警告即可。

**Q: 启动时提示端口 5173 被占用？**

A: 修改 `--web-port=` 参数为其他端口号，如 `5174`。

**Q: Web 模式下保存文件没有对话框？**

A: Web 模式使用浏览器 prompt 输入文件名。如需原生保存对话框，请使用桌面模式（`flutter run -d windows`）。

**Q: `flutter pub get` 下载超时？**

A: 配置国内镜像：

```bash
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get
```

## 项目结构速览

```text
E:\markdown\markdown_editor\
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── editor/                      # 编辑器组件
│   ├── file_service/                # 文件操作
│   ├── recent_store/                # 最近文档
│   ├── storage/                     # 草稿存储
│   └── export/                      # 导出服务
├── test/
│   └── widget_test.dart             # 组件测试
├── docs/                            # 项目文档
├── pubspec.yaml                     # 依赖配置
└── README.md                        # 项目说明
```
