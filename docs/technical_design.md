# QLaw Markdown Technical Design

## Overview

QLaw Markdown is a Flutter desktop/web Markdown editor. It supports:

- Markdown editing with inline syntax highlighting (overlay technique)
- Live preview via `flutter_markdown_plus`
- GitHub-Flavored Markdown features such as tables, images, task lists, and nested lists
- Syntax highlighting in fenced code blocks (both editor and preview)
- Multi-document tab interface
- File open/save for `.md` files
- Drag-and-drop file opening
- Auto-save drafts locally
- Recent documents list
- Find and replace with case-sensitive toggle
- Export to HTML and PDF
- Save always opening a Save As dialog for explicit filename confirmation
- Keyboard shortcuts for formatting, file operations, and navigation
- Responsive layout
- Dark and light themes
- Windows desktop and Web from one codebase

## Runtime Targets

Generated Flutter platforms:

- Windows
- Web

The code is structured so other Flutter-supported targets can be added later with `flutter create --platforms=... .`, but storage, file service, and recent store behavior should be reviewed per platform.

## Source Layout

`	ext
lib/
  main.dart
  editor/
    editor_screen.dart
    editor_toolbar.dart
    editor_shortcuts.dart
    find_replace_bar.dart
    highlighted_editor.dart
    markdown_text_editor.dart
    markdown_preview.dart
    markdown_editor_highlighter.dart
    markdown_syntax_highlighter.dart
    document_stats.dart
    document_tab.dart
    document_tab_bar.dart
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
`

## Conditional Export Pattern

Cross-platform services use conditional exports:

`dart
export 'base.dart';
export 'stub.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'io.dart'
    show createService;
`

This selects the correct implementation at compile time.

| Layer | IO/Desktop | Web | Stub/Tests |
| --- | --- | --- | --- |
| `storage/` | File in `%APPDATA%` | `localStorage` | In-memory |
| `file_service/` | `file_picker` + `dart:io` | `dart:html` file input + blob download | Returns null |
| `recent_store/` | `recent.json` in `%APPDATA%` | `localStorage` JSON + content cache | In-memory |

## Application Entry

`lib/main.dart` initializes Flutter bindings, creates platform-specific services, loads any saved draft, then starts `MarkdownEditorApp`.

`	ext
main()
  -> createDocumentStore()
  -> createFileService()
  -> createRecentStore()
  -> loadDraft()
  -> runApp(MarkdownEditorApp)
`

`MarkdownEditorApp` applies Material 3 theming and creates `EditorScreen`.

## UI Architecture

### EditorScreen

`lib/editor/editor_screen.dart` is the central stateful widget. It manages:

- `TextEditingController` lifecycle
- Auto-save debounce via `DocumentStore`
- File open and save-as via `FileService`
- Recent documents via `RecentStore`
- HTML and PDF export
- Find and replace
- Preview toggle
- Responsive layout
- External file change checks
- Multi-document tab management
- Keyboard shortcuts
- Drag-and-drop file opening

### Supporting Widgets

| Widget | File | Purpose |
| --- | --- | --- |
| `EditorToolbar` | `editor_toolbar.dart` | Markdown formatting actions |
| `EditorShortcuts` | `editor_shortcuts.dart` | Keyboard shortcut definitions |
| `FindReplaceBar` | `find_replace_bar.dart` | Find and replace UI |
| `HighlightedMarkdownEditor` | `highlighted_editor.dart` | Editor with syntax highlighting overlay |
| `MarkdownTextEditor` | `markdown_text_editor.dart` | Wrapper that delegates to HighlightedMarkdownEditor |
| `MarkdownPreview` | `markdown_preview.dart` | Markdown rendering |
| `MarkdownSyntaxHighlighter` | `markdown_syntax_highlighter.dart` | Code block syntax highlighting in preview |
| `MarkdownEditorHighlighter` | `markdown_editor_highlighter.dart` | Inline Markdown syntax highlighting in editor |
| `StatusBar` | `document_stats.dart` | File name, stats, save status |
| `DocumentStats` | `document_stats.dart` | Word and character counts |
| `DocumentTab` | `document_tab.dart` | Tab data model |
| `DocumentTabBar` | `document_tab_bar.dart` | Tab bar UI |

## Editing Model

The editor uses an overlay technique for syntax highlighting: a transparent `TextField` sits on top of a highlighted `Text.rich` widget. Both share the same scroll controller and text metrics so the highlighting aligns with the editable text.

`MarkdownEditorHighlighter` (`markdown_editor_highlighter.dart`) highlights:
- Headings (with colored markers)
- Bold, italic, inline code
- Links and images
- Blockquotes
- Lists (ordered, unordered, task lists)
- Fenced code blocks (with background)
- Horizontal rules

Toolbar actions update the plain text directly. There is no rich text document model; Markdown remains the source of truth.

## Keyboard Shortcuts

`EditorShortcuts` (`editor_shortcuts.dart`) uses Flutter's `Shortcuts` + `Actions` pattern:

| Shortcut | Action |
| --- | --- |
| `Ctrl+B` | Bold |
| `Ctrl+I` | Italic |
| `Ctrl+` ` | Inline code |
| `Ctrl+K` | Insert link |
| `Ctrl+S` | Save As |
| `Ctrl+O` | Open file |
| `Ctrl+N` | New document |
| `Ctrl+F` | Find and replace |
| `Ctrl+Shift+P` | Toggle preview |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+W` | Close tab |

## Find and Replace

`FindReplaceBar` (`find_replace_bar.dart`) provides:
- Real-time search with match count display
- Case-sensitive toggle
- Previous/next match navigation
- Expandable replace row
- Replace current or replace all
- Selects matched text in the editor

## Multi-Document Tabs

`DocumentTab` holds per-tab state:
- `TextEditingController` and `FocusNode`
- File path (if opened from disk)
- Dirty flag for unsaved changes
- Title

`DocumentTabBar` renders a horizontal scrollable tab strip with close buttons. Closing a dirty tab shows a confirmation dialog. The last remaining tab cannot be closed; it resets instead.

## File Service

`FileService` abstracts file dialogs and I/O:

`dart
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
`

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

`ash
flutter test
`

## Quality Gates

Before committing:

`ash
dart format lib test
flutter analyze
flutter test
`

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
| `desktop_drop` | Drag-and-drop file opening |

## Completed Roadmap

1. Split editor widgets into dedicated files
2. Add file open/save for `.md` files
3. Add recent documents list
4. Replace preview parser with `flutter_markdown_plus`
5. Add syntax highlighting for code blocks in preview
6. Add export to HTML and PDF
7. Make Save open Save As every time
8. Add external file change detection and conflict dialog
9. Add multi-document tab interface
10. Add drag-and-drop file opening
11. Add editor inline syntax highlighting (overlay technique)
12. Add keyboard shortcuts for formatting, file ops, and navigation
13. Add find and replace bar
