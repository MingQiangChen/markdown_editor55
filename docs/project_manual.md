# QLaw Markdown Project Manual

## What This Project Does

QLaw Markdown is a local-first Markdown editor prototype. You can write Markdown, preview the result, and keep a draft automatically saved between sessions.

Current best use:

- quick Markdown drafting
- testing the app layout and editing workflow
- serving as the base for a fuller cross-platform Markdown editor

## Open The Project

Project directory:

```text
E:\markdown\markdown_editor
```

Recommended editor:

- VS Code with Flutter extension
- Android Studio with Flutter plugin

## Run The App

From the project directory:

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

## Use The Editor

The main screen has:

- top app bar
- Markdown toolbar
- editor pane
- preview pane
- status bar

On wide screens, editor and preview are side by side.

On compact screens, editor and preview are shown as swipeable pages when preview is enabled.

## Toolbar Buttons

Available actions:

```text
Heading
Bold
Italic
Inline code
Link
Quote
List
Code block
```

Most actions use the current text selection. If no text is selected, Markdown markers are inserted at the cursor.

## Preview Toggle

Use the eye icon in the app bar:

- eye: preview is visible
- crossed eye: editor-only mode

The status bar shows either:

```text
Edit + preview
Edit only
```

## New Document

Use the note-add icon in the app bar to start a fresh draft.

This replaces the current editor content and auto-saves it shortly after the change.

## Auto-Save

The app auto-saves drafts while you type.

Status bar values:

```text
Saving...
Saved
Save failed
```

Draft locations:

```text
Windows: %APPDATA%\QLawMarkdown\draft.md
Web: browser localStorage key qlaw_markdown.draft
```

## Verify The Project

Run:

```bash
dart format lib test
flutter analyze
flutter test
```

Expected result:

```text
No issues found
All tests passed
```

## Build Release Artifacts

Web:

```bash
flutter build web
```

Output:

```text
build\web
```

Windows:

```bash
flutter build windows
```

Output:

```text
build\windows\x64\runner\Release
```

## Git Workflow

Check status:

```bash
git status --short --branch
```

Commit changes:

```bash
git add .
git commit -m "Describe the change"
```

Push to GitHub:

```bash
git push -u origin main
```

Configured remote:

```text
https://github.com/MingQiangChen/markdown_editor55.git
```

At the time this manual was written, GitHub push from this machine failed because the machine could not connect to `github.com:443`.

## Known Limitations

The current MVP does not yet support:

- opening arbitrary `.md` files
- saving as a selected file path
- multiple documents
- tables
- images
- ordered lists
- nested lists
- syntax highlighting
- cloud sync

## Recommended Next Work

1. Add file open/save.
2. Add recent documents.
3. Replace the simple preview parser with a full Markdown renderer.
4. Split `main.dart` into editor-specific widgets.
5. Add export to HTML/PDF.
6. Add local document library.
7. Add account and sync features.
