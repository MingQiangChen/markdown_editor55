# QLaw Markdown Technical Design

## Overview

QLaw Markdown is a Flutter desktop/web Markdown editor prototype. The current implementation focuses on a usable local editing loop:

- edit Markdown as plain text
- preview common Markdown blocks live
- auto-save drafts locally
- run on Windows and Web from one codebase

The project intentionally avoids third-party editor or storage packages in the MVP. This keeps startup simple and makes the current code easy to audit before adding richer editor engines such as CodeMirror, Vditor, or native file picker plugins.

## Runtime Targets

Generated Flutter platforms:

- Windows
- Web

The code is structured so other Flutter-supported targets can be added later with `flutter create --platforms=... .`, but storage behavior should be reviewed per platform.

## Source Layout

```text
lib/
  main.dart
  storage/
    document_store.dart
    document_store_base.dart
    document_store_io.dart
    document_store_stub.dart
    document_store_web.dart
test/
  widget_test.dart
docs/
  technical_design.md
  project_manual.md
```

## Application Entry

[lib/main.dart](../lib/main.dart) initializes Flutter bindings, creates a platform-specific `DocumentStore`, loads any saved draft, then starts `MarkdownEditorApp`.

Key flow:

```text
main()
  -> createDocumentStore()
  -> loadDraft()
  -> runApp(MarkdownEditorApp)
```

## UI Architecture

The UI is currently implemented in one file for MVP speed:

- `MarkdownEditorApp`: Material app, theme, root routing
- `EditorScreen`: screen state, controller lifecycle, toolbar commands, auto-save debounce
- `EditorToolbar`: horizontal Markdown action bar
- `MarkdownTextEditor`: multiline editor based on `TextField`
- `MarkdownPreview`: lightweight Markdown block renderer
- `StatusBar`: word count, character count, save state, preview mode
- `DocumentStats`: derived text metrics

As the project grows, split `main.dart` into feature files:

```text
lib/editor/
  editor_screen.dart
  editor_toolbar.dart
  markdown_preview.dart
  markdown_text_editor.dart
  document_stats.dart
```

## Editing Model

The editor uses Flutter's `TextEditingController`. Toolbar actions update the controller value directly:

- wrap selection: bold, italic, inline code, link
- prefix current line: heading, quote, list
- insert block: fenced code block

Selection handling is defensive: if the current selection is invalid, actions insert at the end of the document.

## Preview Model

`MarkdownPreview` uses a small internal parser, not a full Markdown implementation. It supports:

- headings: `#` through `######`
- paragraphs
- unordered list items: `- item` and `* item`
- blockquotes: `> quote`
- dividers: `---` and `***`
- fenced code blocks

Known limitations:

- no nested lists
- no ordered lists
- no tables
- no images
- no inline emphasis rendering inside preview text
- no GitHub-Flavored Markdown extensions

Recommended next step: replace the internal parser with `flutter_markdown` or a richer editor/preview package once dependency policy is settled.

## Draft Storage

Storage is abstracted behind `DocumentStore`.

```dart
abstract class DocumentStore {
  Future<String?> loadDraft();
  Future<void> saveDraft(String content);
}
```

Platform implementation is selected with conditional exports in `document_store.dart`.

### Windows/Desktop

Implementation: `document_store_io.dart`

Draft path:

```text
%APPDATA%\QLawMarkdown\draft.md
```

Fallbacks:

- `HOME`
- current working directory

### Web

Implementation: `document_store_web.dart`

Draft key:

```text
qlaw_markdown.draft
```

Storage backend:

```text
window.localStorage
```

### Stub

Implementation: `document_store_stub.dart`

Used when neither `dart.library.io` nor `dart.library.html` is available. It stores draft content in memory only.

## Auto-Save

`EditorScreen` listens to `TextEditingController` changes and uses a 500 ms debounce timer.

Save states:

- `Saving...`
- `Saved`
- `Save failed`

This design avoids writing to disk/localStorage on every keystroke while still keeping drafts current.

## Testing

Current test:

- renders the app with a fake `DocumentStore`
- verifies initial document content
- verifies toolbar presence
- verifies preview toggle state

Run:

```bash
flutter test
```

Recommended additional tests:

- toolbar insertion behavior
- `DocumentStats.fromText`
- preview block parsing
- IO and Web document store behavior through platform-specific tests

## Build And Run

Install dependencies:

```bash
flutter pub get
```

Run web:

```bash
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

Run Windows:

```bash
flutter run -d windows
```

Build web:

```bash
flutter build web
```

Build Windows:

```bash
flutter build windows
```

## Quality Gates

Before committing:

```bash
dart format lib test
flutter analyze
flutter test
```

## Roadmap

Recommended implementation order:

1. Split editor widgets into dedicated files.
2. Add open/save for real `.md` files.
3. Add recent documents.
4. Replace preview parser with a Markdown package.
5. Add syntax highlighting or a dedicated editor component.
6. Add export to HTML/PDF.
7. Add sync and conflict handling.
