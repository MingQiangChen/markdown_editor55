# QLaw Markdown 安装与启动指南

## 环境要求

| 工具 | 最低版本 | 说明 |
| --- | --- | --- |
| Flutter SDK | 3.7.2+ | 跨平台应用框架 |
| Dart SDK | 3.7.2+ | 随 Flutter 一起安装 |
| Git | 任意较新版本 | 版本控制 |
| Windows | 10/11 | 桌面端运行 |
| Linux | Ubuntu 20.04+ / Fedora 36+ | 桌面端运行 |
| macOS | 10.14+ | 桌面端运行 |
| 浏览器 | Chrome / Edge | Web 端运行 |

## 1. 安装 Flutter

### Windows

安装参考：

```text
https://docs.flutter.dev/get-started/install/windows
```

### Linux（Ubuntu/Debian）

先安装系统依赖：

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

然后安装 Flutter：

```bash
# 方式一：snap（推荐）
sudo snap install flutter --classic

# 方式二：手动安装
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
```

### Linux（Fedora/RHEL）

```bash
sudo dnf install clang cmake ninja-build gtk3-devel pkgconf-pkg-config libstdc++-devel
sudo snap install flutter --classic
# 或手动安装（同上）
```

### macOS

先安装 Xcode Command Line Tools：

```bash
xcode-select --install
```

首次安装后需要同意 Xcode 许可协议并完成初始化：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

如果没有安装完整的 Xcode，可以跳过上面两行，只保留 `xcode-select --install`。

然后安装 Flutter：

```bash
# 方式一：Homebrew（推荐）
brew install --cask flutter

# 方式二：手动安装
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
```

安装参考：

```text
https://docs.flutter.dev/get-started/install/macos
```

### 验证安装

安装后运行：

```bash
flutter doctor
```

本项目需要 Windows/Linux/macOS desktop 或 Chrome/Web 环境。Android toolchain 不是必需项。

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

### Linux 桌面

```bash
flutter run -d linux
```

### macOS 桌面

```bash
flutter run -d macos
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

Linux：

```bash
flutter build linux --release
```

输出目录：

```text
build/linux/x64/release/bundle
```

macOS：

```bash
flutter build macos --release
```

输出目录：

```text
build/macos/Build/Products/Release
```

构建完成后可直接将 `.app` 拷贝到 `/Applications` 使用：

```bash
cp -r build/macos/Build/Products/Release/markdown_editor.app /Applications/
```

## 数据存储位置

| 数据 | Windows | Linux | macOS | Web |
| --- | --- | --- | --- | --- |
| 草稿 | `%APPDATA%\QLawMarkdown\draft.md` | `~/.config/QLawMarkdown/draft.md` | `~/Library/Application Support/QLawMarkdown/draft.md` | `localStorage` |
| 最近文件 | `%APPDATA%\QLawMarkdown\recent.json` | `~/.config/QLawMarkdown/recent.json` | `~/Library/Application Support/QLawMarkdown/recent.json` | `localStorage` |

## 常见问题

**Q: `flutter doctor` 提示 Android toolchain 未安装怎么办？**

A: 本项目只需要 Windows/Linux/macOS desktop 或 Chrome/Web，Android toolchain 可以暂时忽略。

**Q: Linux 下 `flutter doctor` 提示缺少 Linux toolchain 怎么办？**

A: 安装 GTK 3 开发库和构建工具：

```bash
# Ubuntu/Debian
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev

# Fedora
sudo dnf install clang cmake ninja-build gtk3-devel
```

安装后重新运行 `flutter doctor` 确认 Linux toolchain 显示 ✓。

**Q: Linux 构建时报错找不到 GTK 头文件？**

A: 确保已安装 `libgtk-3-dev`（Debian/Ubuntu）或 `gtk3-devel`（Fedora）。可以用以下命令验证：

```bash
pkg-config --modversion gtk+-3.0
```

应输出版本号（如 3.24.x）。

**Q: macOS 下 `flutter doctor` 提示 Xcode 未安装？**

A: 安装 Xcode Command Line Tools 并完成初始化：

```bash
xcode-select --install
# 如果安装了完整 Xcode，还需执行：
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

完成后重新运行 `flutter doctor`，确认 macOS toolchain 显示 ✓。

**Q: macOS 打开应用时提示"无法验证开发者"或"已损坏"？**

A: 移除应用的隔离属性：

```bash
xattr -cr build/macos/Build/Products/Release/markdown_editor.app
```

或者在"系统设置 → 隐私与安全性"中点击"仍要打开"。

**Q: macOS 构建时报错 CocoaPods 未安装？**

A: 安装 CocoaPods：

```bash
sudo gem install cocoapods
# 或使用 Homebrew：
brew install cocoapods
```

然后在项目目录执行：

```bash
cd macos && pod install && cd ..
flutter build macos --release
```

**Q: 端口 5173 被占用怎么办？**

A: 换一个端口，例如：

```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5174
```

**Q: Web 模式保存时为什么不是系统文件对话框？**

A: Web 端受浏览器限制，保存会走浏览器下载流程。需要原生文件对话框时请使用桌面模式。

**Q: `flutter pub get` 下载超时怎么办？**

A: 可以配置镜像后重试：

```bash
# Windows
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# Linux / macOS
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

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