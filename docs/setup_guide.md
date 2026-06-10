# QLaw Markdown 安装与启动指南

## 环境要求

| 工具 | 最低版本 | 说明 |
| --- | --- | --- |
| Flutter SDK | 3.7.2+ | 跨平台应用框架 |
| Dart SDK | 3.7.2+ | 随 Flutter 一起安装 |
| Git | 任意较新版本 | 版本控制 |
| Windows | 10/11 | 桌面端运行 |
| 浏览器 | Chrome / Edge | Web 端运行 |

## 1. 安装 Flutter

Windows 安装参考：

```text
https://docs.flutter.dev/get-started/install/windows
```

安装后运行：

```bash
flutter doctor
```

本项目只需要 Windows desktop 或 Chrome/Web 环境。Android toolchain 不是必需项。

## 2. 获取项目代码

```bash
git clone https://github.com/MingQiangChen/markdown_editor55.git
cd markdown_editor55
```

如果已经在本机项目目录中：

```bash
cd E:\markdown\markdown_editor
```

## 3. 安装依赖

```bash
flutter pub get
```

主要依赖：

| 包 | 用途 |
| --- | --- |
| `file_picker` | 桌面端原生文件对话框 |
| `flutter_markdown_plus` | Markdown 实时预览 |
| `markdown` | HTML 导出 |
| `pdf` | PDF 生成 |
| `printing` | PDF 分享/保存 |

## 4. 验证项目

```bash
dart format lib test
flutter analyze
flutter test
```

预期结果：

```text
No issues found!
All tests passed!
```

## 5. 启动应用

### Web 浏览器

```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

打开：

```text
http://127.0.0.1:5173
```

### Windows 桌面

```bash
flutter run -d windows
```

桌面模式会使用原生文件选择和保存对话框。

### Chrome 直接运行

```bash
flutter run -d chrome
```

## 6. 构建发布版本

Web：

```bash
flutter build web
```

输出目录：

```text
build\web
```

Windows：

```bash
flutter build windows
```

输出目录：

```text
build\windows\x64\runner\Release
```

## 常见问题

**Q: `flutter doctor` 提示 Android toolchain 未安装怎么办？**

A: 本项目只需要 Windows desktop 或 Chrome/Web，Android toolchain 可以暂时忽略。

**Q: 端口 5173 被占用怎么办？**

A: 换一个端口，例如：

```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5174
```

**Q: Web 模式保存时为什么不是系统文件对话框？**

A: Web 端受浏览器限制，保存会走浏览器下载流程。需要原生文件对话框时请使用 Windows 桌面模式。

**Q: `flutter pub get` 下载超时怎么办？**

A: 可以配置镜像后重试：

```bash
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get
```

## 项目结构

```text
E:\markdown\markdown_editor\
├── lib/
│   ├── main.dart
│   ├── editor/
│   ├── file_service/
│   ├── recent_store/
│   ├── storage/
│   └── export/
├── test/
│   └── widget_test.dart
├── docs/
├── pubspec.yaml
└── README.md
```
