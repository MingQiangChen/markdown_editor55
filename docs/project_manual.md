# QLaw Markdown Project Manual

## What This Project Does

QLaw Markdown is a local-first Markdown editor. You can write Markdown, preview the result, open and save `.md` files, and export to HTML or PDF.

Key features:

- Markdown editing with formatting toolbar
- Live preview with full GitHub-Flavored Markdown support
- Syntax highlighting in code blocks
- Open, save, and save-as for `.md` files
- Recent documents list
- Auto-save drafts between sessions
- Export to HTML and PDF
- External file change detection
- Responsive layout (side-by-side or paged)
- Dark and light themes

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

### Main screen

On wide screens (≥760px), the editor and preview are side by side. On compact screens, they are shown as swipeable pages when preview is enabled.

### Toolbar buttons

| Button | Action |
|--------|--------|
| **Heading** | Inserts `## ` at the start of the current line |
| **Bold** | Wraps selection with `**` |
| **Italic** | Wraps selection with `*` |
| **Inline code** | Wraps selection with `` ` `` |
| **Link** | Wraps selection with `[` and `](https://example.com)` |
| **Quote** | Inserts `> ` at start of line |
| **List** | Inserts `- ` at start of line |
| **Code block** | Inserts a fenced code block |

Most actions use the current text selection. If nothing is selected, Markdown markers are inserted at the cursor position.

### App bar buttons

| Icon | Action |
|------|--------|
| 📂 Folder open | Open a `.md` file |
| 💾 Save | Save current file (or Save As if new) |
| 📥 Download | Export menu: HTML or PDF |
| 🕐 History | Recent files list (click to reopen) |
| 📝 Note add | Start a new document |
| 👁️ Eye | Toggle preview visibility |

### Status bar

Shows:

```text
filename.md · 150 words · 1200 characters · Saved · Edit + preview
```

When no file is open, the filename section is hidden.

## File Operations

### Open a file

Click the folder icon or use the recent files menu. Only `.md` files are shown in the file dialog.

### Save a file

If a file was previously opened or saved, **Save** writes directly to the same path. Otherwise, it opens a **Save As** dialog.

### Save As

Opens a file save dialog. On desktop, choose a location and filename. On web, the file downloads automatically.

### Recent files

Click the history icon to see up to 10 recently opened files. Click any item to reopen it.

- **Desktop**: Files are reopened directly from disk.
- **Web**: File content is cached in browser storage so files can be reopened without re-uploading.

### Conflict detection

If you open a file and it is modified by another application before you save, a dialog will appear with three options:

- **Cancel save** — don't save, keep editing
- **Reload from disk** — load the external version into the editor
- **Overwrite** — save your version, replacing the external changes

## Export

### Export as HTML

Click the download icon → **Export as HTML**. This saves a complete HTML page with embedded CSS styling.

### Export as PDF

Click the download icon → **Export as PDF**. This opens the platform share/save dialog for the PDF.

## Preview

The preview pane renders Markdown using `flutter_markdown_plus` with full GitHub-Flavored Markdown support:

- Headings (h1–h6)
- Bold, italic, inline code
- Ordered and unordered lists (including nested)
- Task lists (`- [ ]` and `- [x]`)
- Code blocks with syntax highlighting
- Blockquotes
- Tables
- Images
- Links
- Dividers

### Preview toggle

Use the eye icon in the app bar:

- 👁️ Eye: preview is visible (default)
- 🚫 Crossed eye: editor-only mode

## Auto-Save

The app auto-saves drafts while you type (500 ms debounce).

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

## Recent Files Storage

```text
Windows: %APPDATA%\QLawMarkdown\recent.json
Web: browser localStorage key qlaw_markdown.recent
```

Maximum 10 entries, ordered by most recently opened.

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

## Known Limitations

The current version does not yet support:

- Editor-side syntax highlighting (plain text only)
- Cloud sync
- Multiple documents open simultaneously (tabs)
- Drag-and-drop file opening
- Custom export templates

## Next Steps (Ideas)

- Editor syntax highlighting (e.g., CodeMirror or re_editor)
- Tabbed multi-document editing
- Drag-and-drop file opening
- Cloud sync with conflict resolution
- Custom CSS export templates
- Mobile/touch platform support
