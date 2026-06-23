# QLaw Markdown 安装与启动指南

> 版本 1.1.0 | 更新日期：2026-06-23

## 环境要求

| 工具 | 最低版本 | 说明 |
| --- | --- | --- |
| Flutter SDK | 3.7.2+ | 跨平台应用框架 |
| Dart SDK | 3.7.2+ | 随 Flutter 一起安装 |
| Git | 任意较新版本 | 版本控制 |
| Windows | 10/11 | 桌面端运行 |
| Linux | Ubuntu 20.04+ / Fedora 36+ | 桌面端运行 |
| macOS | 10.14+ | 桌面端运行 |
| Android | 5.0+ (API 21+) | 移动端运行 |
| iOS | 12.0+ | 移动端运行（需 macOS + Xcode） |
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

```bash
flutter doctor
```

确保以下项目通过：
- Flutter SDK
- Android toolchain（如需 Android 支持）
- Xcode（如需 iOS 支持，仅 macOS）
- Chrome（如需 Web 支持）
- 连接的设备（如需真机调试）

## 2. Android 开发环境配置

### 安装 Android Studio

下载地址：https://developer.android.com/studio

### 配置 Android SDK

1. 打开 Android Studio
2. 进入 Settings > Languages & Frameworks > Android SDK
3. 安装以下组件：
   - Android SDK Platform（API 34 或更高）
   - Android SDK Build-Tools
   - Android Emulator

### 配置环境变量

**Windows：**
```cmd
setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk"
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools\bin"
```

**Linux/macOS：**
```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin"
```

### 接受许可协议

```bash
flutter doctor --android-licenses
```

### 创建模拟器

1. 打开 Android Studio
2. 进入 Tools > Device Manager
3. 点击 Create Device
4. 选择设备类型和系统版本
5. 完成创建后启动模拟器

## 3. iOS 开发环境配置（仅 macOS）

### 安装 Xcode

从 App Store 安装最新版 Xcode。

### 配置 Xcode

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 安装 CocoaPods

```bash
sudo gem install cocoapods
# 或使用 Homebrew
brew install cocoapods
```

### 创建模拟器

1. 打开 Xcode
2. 进入 Window > Devices and Simulators
3. 选择 Simulators 标签
4. 点击 + 创建新模拟器

## 4. 获取项目

```bash
git clone https://github.com/MingQiangChen/markdown_editor55.git
cd markdown_editor55
flutter pub get
```

## 5. 启动应用

### Web 模式（推荐快速体验）

```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

浏览器打开 `http://127.0.0.1:5173`

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

### Android

```bash
# 使用模拟器
flutter run -d android

# 使用真机（需开启 USB 调试）
flutter devices  # 查看已连接设备
flutter run -d <device-id>
```

### iOS（仅 macOS）

```bash
# 使用模拟器
flutter run -d ios

# 使用真机
flutter devices
flutter run -d <device-id>
```

## 6. 构建发布版本

```bash
# Windows
flutter build windows --release
# 产物在 build/windows/x64/runner/Release/

# Linux
flutter build linux --release

# macOS
flutter build macos --release

# Web
flutter build web --release

# Android APK
flutter build apk --release
# 产物在 build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle（Google Play 推荐）
flutter build appbundle --release

# iOS（需要 macOS 和 Xcode）
flutter build ios --release
# 然后在 Xcode 中打开 ios/Runner.xcworkspace 进行归档和发布
```

## 7. 移动端适配说明

v1.1.0 新增 Android 和 iOS 移动端支持，采用响应式布局：

### 界面特点

- **底部工具栏**：格式化按钮固定在屏幕底部，方便单手操作
- **侧边抽屉菜单**：左滑或点击汉堡菜单打开，包含文件操作、设置等功能
- **底部状态栏**：显示字数、字符数和保存状态
- **视图切换**：支持编辑、分屏、预览三种模式
- **底部弹窗面板**：文件树和文档大纲以底部弹窗形式展示

### 断点设计

| 屏幕宽度 | 布局类型 | 特点 |
|----------|----------|------|
| < 600px | 移动端 | 底部工具栏 + 抽屉菜单 |
| 600-1024px | 平板 | 过渡布局 |
| ≥ 1024px | 桌面端 | 侧边面板 + 顶部工具栏 |

### 操作提示

- 点击左上角汉堡菜单打开功能列表
- 左滑屏幕或点击菜单按钮打开抽屉
- 底部工具栏可横向滚动查看所有格式化选项
- 文件树和文档大纲从底部弹出，可上下拖拽调整大小

## 8. 常见问题

### Android 构建失败

```bash
# 清理缓存
flutter clean
flutter pub get

# 检查 Android 配置
flutter doctor -v
```

### iOS 构建失败（macOS）

```bash
# 清理缓存
flutter clean
flutter pub get
cd ios
pod install
cd ..

# 检查 iOS 配置
flutter doctor -v
```

### 模拟器无法启动

- Android：确保已安装 Android SDK 和系统镜像
- iOS：确保已安装 Xcode 和模拟器运行时

### 真机调试无法连接

- Android：开启开发者选项和 USB 调试
- iOS：信任此电脑，并确保已安装开发者证书

## 9. 验证与测试

```bash
# 代码格式化
dart format lib test

# 静态分析
flutter analyze

# 运行测试
flutter test
```

---

如有问题，请访问项目主页：https://github.com/MingQiangChen/markdown_editor55
