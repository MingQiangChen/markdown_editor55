# QLaw Markdown

A Flutter Markdown editor for desktop, web, and mobile.

## Features

- Plain-text Markdown editing with a formatting toolbar
- Live preview with GitHub-Flavored Markdown support, including tables, images, task lists, and nested lists
- Syntax highlighting in fenced code blocks
- Multi-tab document editing
- Open, save, and save-as for .md files
- Recent documents list, capped at 10 entries
- Draft auto-save
- Export to styled HTML and PDF (with Chinese font support)
- Responsive layout: split editor/preview on wide screens (>= 600px), paged layout on compact screens
- Document word and character counts
- Dark and light themes with custom theme picker
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
- File tree panel for project browsing
- Image insert dialog with local file picker
- Visual table editor with add/remove rows and columns
- Task list with interactive checkboxes in preview
- Find and replace with match highlighting
- Code snippet templates (tables, formulas, diagrams, etc.)
- Undo/redo support via built-in text editing

## Supported Platforms

- Windows 10/11
- Linux (Ubuntu 20.04+, Fedora 36+)
- macOS 10.14+
- Web (Chrome / Edge)

## Storage

| Data | Desktop (Windows) | Desktop (Linux) | Desktop (macOS) | Web |
| --- | --- | --- | --- | --- |
| Draft | %APPDATA%\\QLawMarkdown\\draft.md | ~/.config/QLawMarkdown/draft.md | ~/Library/Application Support/QLawMarkdown/draft.md | localStorage |
| Recent files | %APPDATA%\\QLawMarkdown\\recent.json | ~/.config/QLawMarkdown/recent.json | ~/Library/Application Support/QLawMarkdown/recent.json | localStorage |

## Run

`ash
flutter pub get
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
`

Open:

    http://127.0.0.1:5173

For Windows desktop:

`ash
flutter run -d windows
`

For Linux desktop (requires GTK 3 dev libraries):

`ash
# Ubuntu/Debian: sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
# Fedora: sudo dnf install clang cmake ninja-build gtk3-devel
flutter run -d linux
`

For macOS desktop:

`ash
flutter run -d macos
`

## Build Release

`ash
flutter build windows --release
flutter build linux --release
flutter build macos --release
flutter build web --release
`

## Verify

`ash
dart format lib test
flutter analyze
flutter test
`

## Documentation

- [Setup guide](docs/setup_guide.md) - Installation and launch instructions
- [Project manual v2](docs/project_manual_v2.md) - Complete user guide (Chinese)
- [Technical design](docs/technical_design.md) - Technical design

## Architecture

    lib/
      main.dart                        App entry point
      settings/                        Settings persistence and panel
      editor/                          Editor widgets
        editor_screen.dart             Main editor screen
        editor_toolbar.dart            Formatting toolbar
        editor_shortcuts.dart          Keyboard shortcuts
        markdown_preview.dart          Live preview
        markdown_text_editor.dart      Text editing widget
        document_outline.dart          Document outline panel
        document_stats.dart            Word/char count
        document_tab.dart              Tab content
        document_tab_bar.dart          Tab bar
        find_replace_bar.dart          Find and replace
        insert_image_dialog.dart       Image insert dialog
        markdown_extensions/           Custom Markdown syntax
          math_builder.dart            Math formula builder
          math_inline_syntax.dart      Inline math syntax
          math_block_syntax.dart       Block math syntax
          mermaid_builder.dart         Mermaid diagram builder
          mermaid_syntax.dart         Mermaid syntax
      file_tree/                       Project file tree panel
        file_tree_node.dart
        file_tree_panel.dart
      image_service/                   Image handling service
        image_service.dart
        image_service_base.dart
      table_editor/                    Visual table editor
        table_editor.dart
      task_list/                       Task list editor
        task_list_editor.dart
      file_service/                    File open/save (IO + Web)
      recent_store/                    Recent documents
      storage/                         Draft auto-save
      export/                          HTML and PDF export
        export_service.dart
        export_options_dialog.dart
        css_templates.dart             12 CSS templates
      cloud_sync/                      WebDAV + local backup
        cloud_sync_service.dart
        webdav_client.dart
        local_backup.dart
        sync_settings_panel.dart
      spell_check/                     Spell checker
        spell_checker.dart
        spell_check_overlay.dart
      custom_theme/                    Theme picker
        custom_theme.dart
        theme_picker.dart
      templates/                       Document templates
        document_templates.dart

Cross-platform code uses conditional exports (dart.library.io / dart.library.html).

## Dependencies

| Package | Purpose |
| --- | --- |
| flutter_markdown_plus | Markdown preview with GFM |
| markdown | Markdown to HTML conversion |
| file_picker | Native file dialogs |
| pdf + printing | PDF generation and sharing |
| desktop_drop | Drag and drop files |
| webview_flutter | WebView component |
| http | HTTP requests |
| crypto | Hashing for sync |
