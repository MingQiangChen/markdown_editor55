# QLaw Markdown Technical Design

## Overview

QLaw Markdown is a Flutter desktop/web Markdown editor. It supports:

- Markdown editing with a formatting toolbar
- Live preview via `flutter_markdown_plus` (full GFM: tables, images, task lists, nested lists)
- Syntax highlighting in fenced code blocks
- File open/save with `.md` files
- Auto-save drafts locally
- Recent documents list
- Export to HTML and PDF
- Save always opens Save As dialog for explicit filename confirmation
- Responsive layout (side-by-side on wide screens, paged on compact)
- Dark and light themes
- Cross-platform: Windows desktop and Web from one codebase

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
```

## Conditional Export Pattern

All cross-platform services follow the same pattern established by `storage/`:

```dart
export 'base.dart';
export 'stub.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'io.dart'
    show createService;
```

This selects the correct implementation at compile time without runtime branching:

| Layer | IO (Desktop) | Web | Stub (Tests) |
|-------|:---:|:---:|:---:|
| `storage/` | file in `%APPDATA%` | `localStorage` | in-memory |
| `file_service/` | `file_picker` + `dart:io` | `dart:html` file input + blob download | returns null |
| `recent_store/` | `recent.json` in `%APPDATA%` | `localStorage` JSON + content cache | in-memory |

## Application Entry

`lib/main.dart` initializes Flutter bindings, creates three platform-specific services, loads any saved draft, then starts `MarkdownEditorApp`.

```text
main()
  -> createDocumentStore()     // storage layer
  -> createFileService()       // file dialogs + I/O
  -> createRecentStore()       // recent documents
  -> loadDraft()
  -> runApp(MarkdownEditorApp)
```

`MarkdownEditorApp` applies Material 3 theming (light + dark) and creates `EditorScreen`.

## UI Architecture

### EditorScreen (`lib/editor/editor_screen.dart`)

Central stateful widget managing:
- `TextEditingController` lifecycle
- Auto-save debounce (500 ms) via `DocumentStore`
- File open (`FileService.openFile`) and save as (`FileService.saveFileAs`)
- Recent documents list (`RecentStore`)
- HTML and PDF export
- Preview toggle and responsive layout

### Supporting widgets

| Widget | File | Purpose |
|--------|------|---------|
| `EditorToolbar` | `editor_toolbar.dart` | Markdown formatting actions |
| `MarkdownTextEditor` | `markdown_text_editor.dart` | Multiline `TextField` with monospace font |
| `MarkdownPreview` | `markdown_preview.dart` | Renders Markdown via `flutter_markdown_plus` |
| `MarkdownSyntaxHighlighter` | `markdown_syntax_highlighter.dart` | Regex-based code block highlighting |
| `StatusBar` | `document_stats.dart` | Word/character counts, save status, filename, preview mode |
| `DocumentStats` | `document_stats.dart` | Derived text metrics |

### Toolbar actions

| Action | Method | Behavior |
|--------|--------|----------|
| Bold | `_wrapSelection('**', '**')` | Wraps selection or inserts at cursor |
| Italic | `_wrapSelection('*', '*')` | Same |
| Inline code | `_wrapSelection('`', '`')` | Same |
| Link | `_wrapSelection('[', '](https://...)')` | Same |
| Heading | `_prefixCurrentLine('## ')` | Prefixes current line |
| Quote | `_prefixCurrentLine('> ')` | Same |
| List | `_prefixCurrentLine('- ')` | Same |
| Code block | `_insertBlock('```...```')` | Inserts fenced code block |

Selection handling is defensive: if the current selection is invalid, actions insert at the end of the document.

## Preview Model

`MarkdownPreview` uses the `flutter_markdown_plus` package with a `MarkdownStyleSheet` customized for the app's theme:

- Headings: bold, matching Material 3 text theme sizes
- Paragraphs: `bodyLarge` with 1.55 line height
- Code blocks: Consolas 14px, `surfaceContainerHighest` background, rounded corners
- Blockquotes: left primary-color border, `surfaceContainerHighest` background
- Syntax highlighting: keywords (primary/bold), strings (tertiary), comments (muted/italic), numbers (error), annotations (secondary)

The `MarkdownSyntaxHighlighter` is a custom `SyntaxHighlighter` implementation using regex tokenization — zero additional dependencies beyond `flutter_markdown_plus`.

## Editing Model

The editor uses Flutter's `TextEditingController`. All toolbar actions update the controller value directly through text manipulation methods. There is no rich text model — the editor is plain text with Markdown syntax.

## File Service (`lib/file_service/`)

Abstracts file dialogs and I/O behind `FileService`:

```dart
abstract class FileService {
  Future<FileOpenResult?> openFile();           // file picker dialog
  Future<FileOpenResult?> openFilePath(String); // direct path read (desktop)
  Future<String?> saveFileAs(String content);   // save dialog
  Future<void> saveFile(String, String);        // direct path write
  Future<String?> exportFile(String, String, List<String>); // export dialog
  Future<DateTime?> getLastModified(String);    // check file timestamp
}
```

`FileOpenResult` carries `content`, `path`, `name`, and `lastModified` (for conflict detection).

### Desktop (`file_service_io.dart`)

- `openFile()` / `saveFileAs()` / `exportFile()`: use `file_picker` package for native dialogs
- `openFilePath()` / `saveFile()`: use `dart:io File` for direct read/write
- `getLastModified()`: returns `File.lastModified()`

### Web (`file_service_web.dart`)

- `openFile()`: hidden `<input type="file">` element with `FileReader`
- `saveFileAs()` / `saveFile()` / `exportFile()`: Blob + anchor download
- `openFilePath()` / `getLastModified()`: return null (no filesystem access)

## Recent Store (`lib/recent_store/`)

Persists a list of recently opened files (max 10 entries, ordered by `lastOpened` desc):

```dart
abstract class RecentStore {
  Future<List<RecentDocument>> loadAll();
  Future<void> add(RecentDocument doc);
  Future<void> remove(String path);
}
```

`RecentDocument` has `path`, `name`, `content?` (for web cache), and `lastOpened`.

- **IO**: JSON file `%APPDATA%\QLawMarkdown\recent.json`
- **Web**: `localStorage` key `qlaw_markdown.recent` — stores content alongside metadata so files can be reopened without filesystem access

## Draft Storage (`lib/storage/`)

Storage is abstracted behind `DocumentStore`:

```dart
abstract class DocumentStore {
  Future<String?> loadDraft();
  Future<void> saveDraft(String content);
}
```

### Windows/Desktop

Draft path: `%APPDATA%\QLawMarkdown\draft.md`

Fallbacks: `HOME` → current working directory.

### Web

Draft key: `qlaw_markdown.draft` in `window.localStorage`.

### Stub

In-memory only, used in tests and when neither `dart.library.io` nor `dart.library.html` is available.

## Auto-Save

`EditorScreen` listens to `TextEditingController` changes and uses a 500 ms debounce timer.

Save states shown in the status bar:

- `Saving...`
- `Saved`
- `Save failed`

This design avoids writing to disk/localStorage on every keystroke while still keeping drafts current.

## Save Behavior

The **Save** button always opens a **Save As** dialog so the user can confirm or change the filename before writing. This is a deliberate UX choice — the editor never silently overwrites a file.

## Export (`lib/export/`)

`export_service.dart` provides:

- `markdownToHtmlPage()` — converts Markdown to a styled HTML5 page using the `markdown` package and GFM extension set
- `markdownToPdf()` — converts Markdown → HTML → PDF bytes via `Printing.convertHtml`
- `shareAsPdf()` — opens platform share/save dialog for PDF

The HTML template includes embedded CSS for typography, code blocks, blockquotes, tables, and responsive images.

## Testing

Current test:

- Renders the app with fake `DocumentStore`, `FileService`, and `RecentStore`
- Verifies initial document content renders
- Verifies toolbar buttons (bold) are present
- Verifies file operation buttons (open, save, history) are present
- Verifies preview toggle changes state

Run:

```bash
flutter test
```

## Build And Run

Install dependencies:

```bash
flutter pub get
```

Run web:

```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

Open:

```text
http://127.0.0.1:5173
```

Run Windows:

```bash
flutter run -d windows
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
|---------|---------|
| `flutter` (SDK) | Framework |
| `cupertino_icons` | iOS style icons |
| `file_picker` | Native file open/save dialogs (desktop) |
| `flutter_markdown_plus` | Full GFM Markdown preview |
| `markdown` | Markdown → HTML conversion for export |
| `pdf` | PDF document generation |
| `printing` | Platform PDF sharing/saving |

## Roadmap (Completed)

1. ✅ Split editor widgets into dedicated files (`lib/editor/`)
2. ✅ File open/save for `.md` files (`lib/file_service/`)
3. ✅ Recent documents list (`lib/recent_store/`)
4. ✅ Replace preview parser with `flutter_markdown_plus`
5. ✅ Syntax highlighting for code blocks
6. ✅ Export to HTML and PDF (`lib/export/`)
7. ✅ Save As dialog on every save (explicit filename confirmation)
