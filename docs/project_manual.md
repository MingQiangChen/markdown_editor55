# QLaw Markdown 使用说明

## 项目用途

QLaw Markdown 是一个本地优先的 Markdown 编辑器。它可以编辑 Markdown、实时预览、打开和保存 `.md` 文件，并导出 HTML 或 PDF。

主要功能：

- Markdown 编辑和格式化工具栏
- GitHub-Flavored Markdown 实时预览
- 代码块语法高亮
- 打开、保存、另存为 `.md` 文件
- 最近文件列表
- 草稿自动保存和恢复
- HTML 和 PDF 导出
- 外部文件变更检测
- 响应式布局
- 深色和浅色主题

## 打开项目

项目目录：

```text
E:\markdown\markdown_editor
```

推荐编辑器：

- VS Code + Flutter extension
- Android Studio + Flutter plugin

## 运行应用

Web：

```bash
flutter pub get
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

打开：

```text
http://127.0.0.1:5173
```

Windows 桌面：

```bash
flutter run -d windows
```

## 使用编辑器

### 主界面

宽屏下（>= 600px）编辑器和预览区并排显示。窄屏下会使用分页布局。

### 工具栏

| 按钮 | 行为 |
| --- | --- |
| Heading | 在当前行插入 `## ` |
| Bold | 用 `**` 包裹选中文本 |
| Italic | 用 `*` 包裹选中文本 |
| Inline code | 用反引号包裹选中文本 |
| Link | 插入 Markdown 链接 |
| Quote | 在当前行插入 `> ` |
| List | 在当前行插入 `- ` |
| Code block | 插入 fenced code block |

如果没有选中文本，格式标记会插入到光标位置。

### 顶部操作

| 操作 | 行为 |
| --- | --- |
| Open | 打开 `.md` 文件 |
| Save | 打开 Save As 对话框并保存 |
| Export | 导出 HTML 或 PDF |
| Recent | 打开最近文件列表 |
| New | 新建文档 |
| Preview | 显示或隐藏预览 |

### 状态栏

状态栏显示文件名、字数、字符数、保存状态和预览模式。

示例：

```text
filename.md · 150 words · 1200 characters · Saved · Edit + preview
```

## 文件操作

### 打开文件

点击 Open，或从最近文件列表打开。文件选择器只显示 `.md` 文件。

### 保存文件

点击 Save 会打开 Save As 对话框，让用户确认文件名和保存位置。当前版本不会静默覆盖文件。

Web 模式下保存会触发浏览器下载。

### 最近文件

最近文件最多保留 10 条，按最近打开时间排序。

- 桌面端：从磁盘直接重新读取
- Web 端：缓存文件内容到浏览器存储

## 导出

### HTML

Export -> Export as HTML 会保存一个带内嵌样式的完整 HTML 页面。

### PDF

Export -> Export as PDF 会打开平台的分享或保存流程。

## 自动保存

编辑时会以 500 ms 防抖自动保存草稿。

草稿位置：

```text
Windows: %APPDATA%\QLawMarkdown\draft.md
Web: localStorage key qlaw_markdown.draft
```

最近文件位置：

```text
Windows: %APPDATA%\QLawMarkdown\recent.json
Web: localStorage key qlaw_markdown.recent
```

## 验证项目

```bash
dart format lib test
flutter analyze
flutter test
```

## 已知限制

- 编辑区本身仍是纯文本，不做编辑器内 Markdown 高亮
- 暂不支持云同步
- 暂不支持多文档标签页
- 暂不支持拖拽打开文件
- 暂不支持自定义导出模板

## 后续方向

- 编辑区语法高亮
- 多文档标签页
- 拖拽打开文件
- 云同步和冲突处理
- 自定义 CSS 导出模板
