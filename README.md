# QLaw Markdown

A Flutter Markdown editor prototype for desktop and web.

## Current MVP

- Plain-text Markdown editing
- Live preview pane with basic headings, paragraphs, lists, quotes, dividers, and code blocks
- Formatting toolbar for common Markdown inserts
- Responsive layout: split editor/preview on wide screens, paged view on compact screens
- Document word and character counts
- Draft auto-save and restore

Draft storage:

- Windows/desktop: `%APPDATA%\QLawMarkdown\draft.md`
- Web: browser `localStorage`

## Run

```bash
flutter pub get
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5173
```

Open:

```text
http://127.0.0.1:5173
```

## Verify

```bash
dart format lib test
flutter analyze
flutter test
```

## Documentation

- [Technical design](docs/technical_design.md)
- [Project manual](docs/project_manual.md)

## Next Milestone

Add file open/save support and a recent documents list.
