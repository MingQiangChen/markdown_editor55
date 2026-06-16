# QLaw Markdown 使用说明

## 项目用途
QLaw Markdown 是一个本地优先的 Markdown 编辑器。它可以编辑 Markdown、实时预览、打开和保存 `.md` 文件，并导出 HTML 或 PDF。

主要功能：
- Markdown 编辑和格式化工具栏
- 编辑区 Markdown 语法高亮
- GitHub-Flavored Markdown 实时预览
- 代码块语法高亮
- 打开、保存、另存为 `.md` 文件
- 多文档标签页
- 最近文件列表
- 草稿自动保存
- HTML 和 PDF 导出（支持中文字体）
- 查找和替换
- 文件拖拽打开
- 外部文件变更检测
- 响应式布局
- 深色和浅色主题
- 视图模式切换（编辑/分屏/预览）
- 自动换行开关
- 数学公式支持（行内和块级）
- Mermaid 图表支持
- 导出选项对话框（CSS 模板选择）
- 设置面板（字体、视图模式、自动保存）
- 文档大纲面板
- 全屏模式
- 增强的状态栏（显示行号、列号）
- 键盘快捷键
- 云同步支持（WebDAV + 本地备份）
- 拼写检查与建议

## 打开项目

项目目录：
```
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
| Inline math | 用 $ 包裹选中文本 |
| Math block | 插入 $$... 块 |
| Mermaid diagram | 插入 mermaid 代码块 |
| Spell Check | 开启/关闭拼写检查 |

如果没有选中文本，格式标记会插入到光标位置。

### 键盘快捷键

#### 格式化
| 快捷键 | 行为 |
| --- | --- |
| `Ctrl+B` | 加粗 |
| `Ctrl+I` | 斜体 |
| `Ctrl+`` ` | 行内代码 |
| `Ctrl+K` | 插入链接 |

#### 文件操作
| 快捷键 | 行为 |
| --- | --- |
| `Ctrl+S` | 保存（打开 Save As 对话框） |
| `Ctrl+O` | 打开文件 |
| `Ctrl+N` | 新建文档 |

#### 编辑
| 快捷键 | 行为 |
| --- | --- |
| `Ctrl+F` | 查找和替换 |

#### 视图
| 快捷键 | 行为 |
| --- | --- |
| `Ctrl+Shift+P` | 切换预览显示 |
| `Ctrl+Shift+V` | 循环切换视图模式（编辑/分屏/预览） |
| `Alt+Z` | 切换自动换行 |

#### 标签页
| 快捷键 | 行为 |
| --- | --- |
| `Ctrl+Tab` | 下一个标签页 |
| `Ctrl+Shift+Tab` | 上一个标签页 |
| `Ctrl+W` | 关闭当前标签页 |

### 查找和替换

点击工具栏的搜索图标或按 `Ctrl+F` 打开查找和替换栏。

功能：
- 实时查找并显示匹配数量
- 大小写敏感切换
- 上/下导航匹配项
- 展开替换行进行替换
- 替换当前匹配或全部替换

### 顶部操作

| 操作 | 行为 |
| --- | --- |
| Open | 打开 `.md` 文件 |
| Save | 打开 Save As 对话框并保存 |
| Export | 导出 HTML 或 PDF |
| Recent | 打开最近文件列表 |
| Find | 打开查找和替换栏 |
| Settings | 打开设置面板 |
| Sync Settings | 打开云同步设置面板 |
| Spell Check | 开启/关闭拼写检查 |
| New | 新建文档 |
| View Mode | 循环切换视图模式（编辑/分屏/预览） |
| Word Wrap | 切换自动换行 |

### 状态栏

状态栏显示文件名、字数、字符数、保存状态和预览模式。
示例：
```text
filename.md · 150 words · 1200 characters · Saved · Edit + preview · Wrap
```

## 设置

点击工具栏的设置图标打开设置面板。

可配置项：
- **字体大小**：10-24 号
- **字体**：默认、Consolas、Courier New、Monaco、Source Code Pro
- **Tab 缩进**：2 或 4 个空格
- **默认视图模式**：编辑 / 分屏 / 预览
- **自动换行**：开/关
- **自动保存间隔**：200-2000 毫秒

设置会立即生效并自动保存。

## 云同步设置

点击工具栏的云同步图标打开同步设置面板。

### 同步方式
- **WebDAV**：同步到支持 WebDAV 协议的云服务（如坚果云、Nextcloud 等）
- **本地备份**：同步到本地指定目录

### WebDAV 配置
- **服务器地址**：WebDAV 服务器 URL
- **用户名/密码**：认证凭据
- **远程路径**：云端存储路径
- **自动同步**：启用后按设定间隔自动同步

### 本地备份配置
- **备份目录**：可通过输入框手动输入，或点击右侧文件夹图标选择目录

### 同步状态
面板底部显示同步状态、上次同步时间和同步历史记录。

## 拼写检查

点击工具栏的拼写检查图标开启拼写检查功能。

功能：
- 实时检测英文拼写错误
- 在编辑器下方显示拼写错误列表
- 提供拼写建议
- 点击建议即可自动替换错误单词

## 文件操作

### 打开文件
点击 Open，或从最近文件列表打开。文件选择器只显示 `.md` 文件。
也可以直接拖拽 `.md` 文件到编辑器窗口打开。

### 保存文件
点击 Save 或按 `Ctrl+S` 会打开 Save As 对话框，让用户确认文件名和保存位置。当前版本不会静默覆盖文件。
Web 模式下保存会触发浏览器下载。

### 最近文件
最近文件最多保留 10 条，按最近打开时间排序。
- 桌面端：从磁盘直接重新读取
- Web 端：缓存文件内容到浏览器存储

## 标签页

编辑器支持多文档标签页：
- 点击 `+` 或按 `Ctrl+N` 新建标签页
- 点击标签页切换文档
- `Ctrl+Tab` / `Ctrl+Shift+Tab` 在标签页间导航
- `Ctrl+W` 关闭当前标签页
- 关闭有未保存更改的标签页时会弹出确认对话框

## 文档大纲

点击工具栏的列表图标打开文档大纲面板。

功能：
- 自动解析 Markdown 标题（H1-H6）
- 按层级缩进显示
- 点击标题跳转到对应位置

## 全屏模式

点击工具栏的全屏图标进入全屏模式。

特点：
- 隐藏工具栏和标签栏
- 只保留编辑区域和最小状态栏
- 点击退出全屏图标或按 Esc 退出

## 状态栏增强

状态栏现在显示：
- **光标位置**：当前行号和列号
- **词数**：文档总词数
- **字符数**：文档总字符数
- **保存状态**：已保存/保存中/保存失败
- **视图模式**：仅编辑/编辑+预览/仅预览
- **换行状态**：自动换行/不换行

## 导出

导出时会弹出选项对话框，可以选择：
- CSS 模板：Default、Dark、Minimal、GitHub、Solarized、Nord、Dracula、Academic、Technical、Newspaper、Presentation、Notion
- 启用 KaTeX 数学公式渲染
- 启用 Mermaid 图表渲染

### HTML
Export -> Export as HTML 会保存一个带内嵌样式的完整 HTML 页面。

### PDF
Export -> Export as PDF 会打开平台的分享或保存流程。

PDF 导出特性：
- 支持中文字体（使用 SimHei 黑体）
- 支持标题、列表、引用、代码块等 Markdown 元素
- 支持任务列表和有序列表
- A4 页面格式，32pt 页边距

## 自动保存

编辑时会以 500 ms 防抖自动保存草稿。

**注意**：每次启动程序时会清除草稿缓存，显示全新的空白编辑界面。

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
- 数学公式和 Mermaid 图表已支持实时预览（需要网络连接加载 CDN 资源）
- 拼写检查仅支持英文

## 后续方向
- 更多 CSS 导出模板
- 大文件性能优化
- 移动端适配