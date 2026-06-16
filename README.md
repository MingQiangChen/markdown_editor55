# QLaw Markdown

A Flutter Markdown editor for desktop and web.

## Features

- Plain-text Markdown editing with a formatting toolbar
- Live preview with GitHub-Flavored Markdown support, including tables, images, task lists, and nested lists
- Syntax highlighting in fenced code blocks
- Open, save, and save-as for `.md` files
- Recent documents list, capped at 10 entries
- Draft auto-save
- Export to styled HTML and PDF (with Chinese font support)
- External file change detection with conflict dialog
- Responsive layout: split editor/preview on wide screens (>= 600px), paged layout on compact screens
- Document word and character counts
- Dark and light themes
- Math formula support (inline $...$ and block $...$) with KaTeX rendering in export
- Mermaid diagram support with Mermaid.js rendering in export
- Export options dialog with 12 CSS templates (Default, Dark, Minimal, GitHub, Solarized, Nord, Dracula, Academic, Technical, Newspaper, Presentation, Notion)
- Settings panel with font, view mode, and auto-save preferences
- Document outline panel for navigation
- Full-screen mode for distraction-free editing
- Enhanced status bar with line and column numbers
- Cloud sync support (WebDAV) with local backup option
- Spell check with suggestions and auto-replacement
- Fresh start on each launch (no draft restore)

## Supported Platforms

- Windows 10/11
- Linux (Ubuntu 20.04+, Fedora 36+)
- macOS 10.14+
- Web (Chrome / Edge)

## Storage

| Data | Desktop (Windows) | Desktop (Linux) | Desktop (macOS) | Web |
| --- | --- | --- | --- | --- |
| Draft | `%APPDATA%\QLawMarkdown\draft.md` | `~/.config/QLawMarkdown/draft.md` | `~/Library/Application Support/QLawMarkdown/draft.md` | `localStorage` |
| Recent files | `%APPDATA%\QLawMarkdown\recent.json` | `~/.config/QLawMarkdown/recent.json` | `~/Library/Application Support/QLawMarkdown/recent.json` | `localStorage` |

## Run

```bash
flutter pub get
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

Open:

```text
http://127.0.0.1:5173
```

For Windows desktop:

```bash
flutter run -d windows
```

For Linux desktop (requires GTK 3 dev libraries):

```bash
# Ubuntu/Debian: sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
# Fedora: sudo dnf install clang cmake ninja-build gtk3-devel
flutter run -d linux
```

For macOS desktop:

```bash
flutter run -d macos
```

## Verify

```bash
dart format lib test
flutter analyze
flutter test
```

## Documentation

- [Setup guide](docs/setup_guide.md) - 安装与启动步骤
- [Project manual](docs/project_manual.md) - 使用说明
- [Technical design](docs/technical_design.md) - 技术设计

## Architecture

```text
lib/
  main.dart                        App entry point
  settings/                        Settings persistence and panel
  editor/                          Editor widgets (screen, toolbar, preview, stats)
    markdown_extensions/           Custom Markdown syntax extensions (math, mermaid)
  file_service/                    File open/save/export (IO + Web)
  recent_store/                    Recent documents persistence
  storage/                         Draft auto-save persistence
  export/                          HTML and PDF export service (with Chinese font)
  cloud_sync/                      Cloud sync service (WebDAV + local backup)
  spell_check/                     Spell check with suggestions
```

Cross-platform code uses conditional exports (`dart.library.io` / `dart.library.html`).

## Dependencies

| Package | Purpose |
| --- | --- |
| `file_picker` | Native file dialogs on desktop |
| `flutter_markdown_plus` | Markdown preview with GFM |
| `markdown` | Markdown to HTML conversion for export |
| `pdf` + `printing` | PDF generation and sharing |