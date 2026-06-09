import 'dart:async';

import 'package:flutter/material.dart';

import '../file_service/file_service.dart';
import '../recent_store/recent_store.dart';
import '../storage/document_store.dart';
import 'document_stats.dart';
import 'editor_toolbar.dart';
import 'markdown_preview.dart';
import 'markdown_text_editor.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.documentStore,
    required this.fileService,
    required this.recentStore,
    required this.initialMarkdown,
  });

  final DocumentStore documentStore;
  final FileService fileService;
  final RecentStore recentStore;
  final String initialMarkdown;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController _controller;
  final FocusNode _editorFocusNode = FocusNode();
  Timer? _saveTimer;
  bool _showPreview = true;
  String _saveStatus = 'Saved';
  String? _currentFilePath;
  String? _currentFileName;
  List<RecentDocument> _recentDocs = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMarkdown);
    _controller.addListener(_handleDocumentChanged);
    _loadRecentDocs();
  }

  Future<void> _loadRecentDocs() async {
    final docs = await widget.recentStore.loadAll();
    if (mounted) {
      setState(() => _recentDocs = docs);
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _controller.removeListener(_handleDocumentChanged);
    _controller.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _handleDocumentChanged() {
    setState(() => _saveStatus = 'Saving...');
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        await widget.documentStore.saveDraft(_controller.text);
        if (mounted) {
          setState(() => _saveStatus = 'Saved');
        }
      } catch (_) {
        if (mounted) {
          setState(() => _saveStatus = 'Save failed');
        }
      }
    });
  }

  Future<void> _addToRecent(String path, String name) async {
    final doc = RecentDocument(
      path: path,
      name: name,
      // On web, cache content so recent files can be reopened without filesystem access.
      content: path == name ? _controller.text : null,
      lastOpened: DateTime.now(),
    );
    await widget.recentStore.add(doc);
    await _loadRecentDocs();
  }

  Future<void> _openFile() async {
    final result = await widget.fileService.openFile();
    if (result == null || !mounted) return;

    setState(() {
      _controller.text = result.content;
      _currentFilePath = result.path;
      _currentFileName = result.name;
      _saveStatus = 'Saved';
    });
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _editorFocusNode.requestFocus();
    await _addToRecent(result.path, result.name);
  }

  Future<void> _openRecent(RecentDocument doc) async {
    // Try to read from filesystem (desktop). If not available (web), use cached content.
    final result = await widget.fileService.openFilePath(doc.path);
    final content = result?.content ?? doc.content;
    if (content == null || !mounted) return;

    setState(() {
      _controller.text = content;
      _currentFilePath = doc.path;
      _currentFileName = doc.name;
      _saveStatus = 'Saved';
    });
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _editorFocusNode.requestFocus();
    await _addToRecent(doc.path, doc.name); // bumps timestamp to top.
  }

  Future<void> _saveFile() async {
    if (_currentFilePath != null) {
      try {
        await widget.fileService.saveFile(_controller.text, _currentFilePath!);
        if (mounted) {
          setState(() => _saveStatus = 'Saved');
        }
      } catch (_) {
        if (mounted) {
          setState(() => _saveStatus = 'Save failed');
        }
      }
    } else {
      final path = await widget.fileService.saveFileAs(_controller.text);
      if (path != null && mounted) {
        final name = path.split('/').last.split('\\').last;
        setState(() {
          _currentFilePath = path;
          _currentFileName = name;
          _saveStatus = 'Saved';
        });
        await _addToRecent(path, name);
      }
    }
  }

  void _newDocument() {
    _controller.text = '# Untitled document\n\n';
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _currentFilePath = null;
    _currentFileName = null;
    _editorFocusNode.requestFocus();
  }

  void _wrapSelection(String prefix, String suffix) {
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final selected = text.substring(start, end);
    final replacement = '$prefix$selected$suffix';

    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(
        offset: start + prefix.length + selected.length,
      ),
    );
    _editorFocusNode.requestFocus();
  }

  void _prefixCurrentLine(String prefix) {
    final selection = _controller.selection;
    final text = _controller.text;
    final cursor =
        selection.baseOffset < 0 ? text.length : selection.baseOffset;
    final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;

    _controller.value = TextEditingValue(
      text: text.replaceRange(lineStart, lineStart, prefix),
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
    _editorFocusNode.requestFocus();
  }

  void _insertBlock(String value) {
    final selection = _controller.selection;
    final text = _controller.text;
    final start = selection.start < 0 ? text.length : selection.start;
    final needsLeadingBreak = start > 0 && text[start - 1] != '\n';
    final insertion = needsLeadingBreak ? '\n$value' : value;

    _controller.value = TextEditingValue(
      text: text.replaceRange(
        start,
        selection.end < 0 ? start : selection.end,
        insertion,
      ),
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
    _editorFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final stats = DocumentStats.fromText(_controller.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentFileName ?? 'QLaw Markdown'),
        actions: [
          Tooltip(
            message: 'Open file',
            child: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _openFile,
            ),
          ),
          Tooltip(
            message: 'Save file',
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveFile,
            ),
          ),
          Tooltip(
            message: 'Recent files',
            child: PopupMenuButton<RecentDocument>(
              icon: const Icon(Icons.history),
              enabled: _recentDocs.isNotEmpty,
              onSelected: _openRecent,
              itemBuilder:
                  (context) =>
                      _recentDocs.map((doc) {
                        return PopupMenuItem<RecentDocument>(
                          value: doc,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                doc.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                doc.path,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
            ),
          ),
          Tooltip(
            message: 'New document',
            child: IconButton(
              icon: const Icon(Icons.note_add),
              onPressed: _newDocument,
            ),
          ),
          Tooltip(
            message: _showPreview ? 'Hide preview' : 'Show preview',
            child: IconButton(
              icon: Icon(
                _showPreview ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _showPreview = !_showPreview),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          EditorToolbar(
            onBold: () => _wrapSelection('**', '**'),
            onItalic: () => _wrapSelection('*', '*'),
            onCode: () => _wrapSelection('`', '`'),
            onLink: () => _wrapSelection('[', '](https://example.com)'),
            onHeading: () => _prefixCurrentLine('## '),
            onQuote: () => _prefixCurrentLine('> '),
            onList: () => _prefixCurrentLine('- '),
            onCodeBlock: () => _insertBlock('```\ncode\n```\n'),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final editor = MarkdownTextEditor(
                  controller: _controller,
                  focusNode: _editorFocusNode,
                );
                final preview = MarkdownPreview(data: _controller.text);

                if (compact || !_showPreview) {
                  return _showPreview
                      ? PageView(children: [editor, preview])
                      : editor;
                }

                return Row(
                  children: [
                    Expanded(child: editor),
                    const VerticalDivider(width: 1),
                    Expanded(child: preview),
                  ],
                );
              },
            ),
          ),
          StatusBar(
            stats: stats,
            previewEnabled: _showPreview,
            saveStatus: _saveStatus,
            fileName: _currentFileName,
          ),
        ],
      ),
    );
  }
}
