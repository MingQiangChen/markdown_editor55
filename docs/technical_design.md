# QLaw Markdown Technical Design

## Overview

QLaw Markdown is a Flutter desktop/web Markdown editor. It supports:

- Markdown editing with a formatting toolbar
- Live preview via `flutter_markdown_plus`
- GitHub-Flavored Markdown features such as tables, images, task lists, and nested lists
- Syntax highlighting in fenced code blocks
- File open/save for `.md` files
- Auto-save drafts locally
- Recent documents list
- Export to HTML and PDF
- Save always opening a Save As dialog for explicit filename confirmation
- Responsive layout
- Dark and light themes
- Windows desktop and Web from one codebase

## Runtime Targets

Generated Flutter platforms:

- Windows
- Web

The code is structured so other Flutter-supported targets can be added later with `flutter create --platforms=... .`, but storage, file service, and recent store behavior should be reviewed per platform.

## Source Layout

```text
lib/
  main.dart
  editor/
    editor_screen.dart
    editor_toolbar.dart
    markdown_text_editor.dart
    markdown_preview.dart
    markdown_syntax_highlighter.dart
    document_stats.dart
  file_service/
    file_service.dart
    file_service_base.dart
    file_service_io.dart
    file_service_web.dart
    file_service_stub.dart
  recent_store/
    recent_store.dart
    recent_store_base.dart
    recent_store_io.dart
    recent_store_web.dart
    recent_store_stub.dart
  storage/
    document_store.dart
    document_store_base.dart
    document_store_io.dart
    document_store_web.dart
    document_store_stub.dart
  export/
    export_service.dart
test/
  widget_test.dart
docs/
  technical_design.md
  project_manual.md
  setup_guide.md
```

## Conditional Export Pattern

Cross-platform services use conditional exports:

```dart
export 'base.dart';
export 'stub.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'io.dart'
    show createService;
```

This selects the correct implementation at compile time.

| Layer | IO/Desktop | Web | Stub/Tests |
| --- | --- | --- | --- |
| `storage/` | File in `%APPDATA%` | `localStorage` | In-memory |
| `file_service/` | `file_picker` + `dart:io` | `dart:html` file input + blob download | Returns null |
| `recent_store/` | `recent.json` in `%APPDATA%` | `localStorage` JSON + content cache | In-memory |

## Application Entry

`lib/main.dart` initializes Flutter bindings, creates platform-specific services, loads any saved draft, then starts `MarkdownEditorApp`.

```text
main()
  -> createDocumentStore()
  -> createFileService()
  -> createRecentStore()
  -> loadDraft()
  -> runApp(MarkdownEditorApp)
```

`MarkdownEditorApp` applies Material 3 theming and creates `EditorScreen`.

## UI Architecture

### EditorScreen

`lib/editor/editor_screen.dart` is the central stateful widget. It manages:

- `TextEditingController` lifecycle
- Auto-save debounce via `DocumentStore`
- File open and save-as via `FileService`
- Recent documents via `RecentStore`
- HTML and PDF export
- Preview toggle
- Responsive layout
- External file change checks

### Supporting Widgets

| Widget | File | Purpose |
| --- | --- | --- |
| `EditorToolbar` | `editor_toolbar.dart` | Markdown formatting actions |
| `MarkdownTextEditor` | `markdown_text_editor.dart` | Multiline plain-text editor |
| `MarkdownPreview` | `markdown_preview.dart` | Markdown rendering |
| `MarkdownSyntaxHighlighter` | `markdown_syntax_highlighter.dart` | Code block highlighting |
| `StatusBar` | `document_stats.dart` | File name, stats, save status |
| `DocumentStats` | `document_stats.dart` | Word and character counts |

## Editing Model

The editor uses Flutter's `TextEditingController`. Toolbar actions update the plain text directly. There is no rich text document model; Markdown remains the source of truth.

## File Service

`FileService` abstracts file dialogs and I/O:

```dart
abstract class FileService {
  Future<FileOpenResult?> openFile();
  Future<FileOpenResult?> openFilePath(String path);
  Future<String?> saveFileAs(String content);
  Future<void> saveFile(String content, String path);
  Future<String?> exportFile(
    String content,
    String fileName,
    List<String> allowedExtensions,
  );
  Future<DateTime?> getLastModified(String path);
}
```

Desktop implementation uses `file_picker` and `dart:io`. Web implementation uses browser file input, blob downloads, and `localStorage` where needed.

## Recent Store

`RecentStore` persists up to 10 recently opened documents.

- Desktop: `%APPDATA%\QLawMarkdown\recent.json`
- Web: `localStorage` key `qlaw_markdown.recent`

Web entries include cached content so a recent file can be reopened without direct filesystem access.

## Draft Storage

`DocumentStore` persists drafts:

- Desktop: `%APPDATA%\QLawMarkdown\draft.md`
- Web: `localStorage` key `qlaw_markdown.draft`
- Stub: in-memory storage for tests

Auto-save uses a 500 ms debounce to avoid writing on every keystroke.

## Export

`lib/export/export_service.dart` provides:

- `markdownToHtmlPage()` to convert Markdown into a styled HTML page
- `markdownToPdf()` to convert Markdown to HTML to PDF bytes
- `shareAsPdf()` to open platform PDF share/save handling

## Testing

Current widget test coverage verifies:

- App rendering with fake services
- Initial document rendering
- Toolbar and file operation buttons
- Preview toggle behavior

Run:

```bash
flutter test
```

## Quality Gates

Before committing:

```bash
dart format lib test
flutter analyze
flutter test
```

## Dependencies

| Package | Purpose |
| --- | --- |
| `flutter` | Framework |
| `cupertino_icons` | iOS style icons |
| `file_picker` | Native file dialogs on desktop |
| `flutter_markdown_plus` | GFM Markdown preview |
| `markdown` | Markdown to HTML conversion |
| `pdf` | PDF document generation |
| `printing` | Platform PDF sharing/saving |

## Completed Roadmap

1. Split editor widgets into dedicated files
2. Add file open/save for `.md` files
3. Add recent documents list
4. Replace preview parser with `flutter_markdown_plus`
5. Add syntax highlighting for code blocks
6. Add export to HTML and PDF
7. Make Save open Save As every time
