import 'dart:async';

import 'package:flutter/material.dart';

import '../file_service/file_service.dart';
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
    required this.initialMarkdown,
  });

  final DocumentStore documentStore;
  final FileService fileService;
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMarkdown);
    _controller.addListener(_handleDocumentChanged);
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
        setState(() {
          _currentFilePath = path;
          _currentFileName = path.split('/').last.split('\\').last;
          _saveStatus = 'Saved';
        });
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
