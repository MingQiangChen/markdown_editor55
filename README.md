# QLaw Markdown

A Flutter Markdown editor for desktop and web.

## Features

- Plain-text Markdown editing with a formatting toolbar
- Live preview with GitHub-Flavored Markdown support, including tables, images, task lists, and nested lists
- Syntax highlighting in fenced code blocks
- Open, save, and save-as for `.md` files
- Recent documents list, capped at 10 entries
- Draft auto-save and restore
- Export to styled HTML and PDF
- External file change detection with conflict dialog
- Responsive layout: split editor/preview on wide screens (>= 600px), paged layout on compact screens
- Document word and character counts
- Dark and light themes

## Storage

| Data | Desktop (Windows) | Web |
| --- | --- | --- |
| Draft | `%APPDATA%\QLawMarkdown\draft.md` | `localStorage` |
| Recent files | `%APPDATA%\QLawMarkdown\recent.json` | `localStorage` |

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
  editor/                          Editor widgets (screen, toolbar, preview, stats)
  file_service/                    File open/save/export (IO + Web)
  recent_store/                    Recent documents persistence
  storage/                         Draft auto-save persistence
  export/                          HTML and PDF export service
```

Cross-platform code uses conditional exports (`dart.library.io` / `dart.library.html`).

## Dependencies

| Package | Purpose |
| --- | --- |
| `file_picker` | Native file dialogs on desktop |
| `flutter_markdown_plus` | Markdown preview with GFM |
| `markdown` | Markdown to HTML conversion for export |
| `pdf` + `printing` | PDF generation and sharing |
