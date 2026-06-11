import 'dart:async';
import 'package:desktop_drop/desktop_drop.dart';

import 'package:flutter/material.dart';

import '../export/export_service.dart';
import '../file_service/file_service.dart';
import '../recent_store/recent_store.dart';
import '../storage/document_store.dart';
import 'document_stats.dart';
import 'document_tab.dart';
import 'document_tab_bar.dart';
import 'editor_toolbar.dart';
import 'markdown_preview.dart';
import 'markdown_text_editor.dart';
import 'editor_shortcuts.dart';
import 'find_replace_bar.dart';

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
  final List<DocumentTab> _tabs = [];
  String _activeTabId = '';
  int _tabCounter = 0;
  Timer? _saveTimer;
  bool _showPreview = true;
  String _saveStatus = 'Saved';
  List<RecentDocument> _recentDocs = [];
  bool _isDragging = false;
  bool _showFindReplace = false;

  DocumentTab get _activeTab =>
      _tabs.firstWhere((t) => t.id == _activeTabId);

  @override
  void initState() {
    super.initState();
    // Create the first tab with the initial draft content.
    final firstTab = DocumentTab.empty(id: _nextTabId());
    firstTab.controller.text = widget.initialMarkdown;
    firstTab.controller.addListener(_handleDocumentChanged);
    _tabs.add(firstTab);
    _activeTabId = firstTab.id;
    _loadRecentDocs();
  }

  String _nextTabId() {
    _tabCounter++;
    return 'tab_$_tabCounter';
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
    for (final tab in _tabs) {
      tab.dispose();
    }
    super.dispose();
  }

  void _handleDocumentChanged() {
    setState(() => _saveStatus = 'Saving...');
    _activeTab.isDirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        await widget.documentStore.saveDraft(_activeTab.controller.text);
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

  void _switchTab(String tabId) {
    if (tabId == _activeTabId) return;
    setState(() {
      _activeTabId = tabId;
      _saveStatus = 'Saved';
    });
    _activeTab.focusNode.requestFocus();
  }

  void _toggleFindReplace() {
    setState(() => _showFindReplace = !_showFindReplace);
  }

  void _nextTab() {
    final currentIndex = _tabs.indexWhere((t) => t.id == _activeTabId);
    if (currentIndex == -1) return;
    final nextIndex = (currentIndex + 1) % _tabs.length;
    _switchTab(_tabs[nextIndex].id);
  }

  void _previousTab() {
    final currentIndex = _tabs.indexWhere((t) => t.id == _activeTabId);
    if (currentIndex == -1) return;
    final prevIndex = (currentIndex - 1 + _tabs.length) % _tabs.length;
    _switchTab(_tabs[prevIndex].id);
  }

  void _closeActiveTab() {
    _closeTab(_activeTabId);
  }

  Future<void> _closeTab(String tabId) async {
    final tabIndex = _tabs.indexWhere((t) => t.id == tabId);
    if (tabIndex == -1) return;

    final tab = _tabs[tabIndex];

    // If the tab is dirty, ask for confirmation.
    if (tab.isDirty && tab.controller.text.isNotEmpty) {
      final confirmed = await _confirmCloseUnsaved(tab.title);
      if (!confirmed) return;
    }

    // Don't allow closing the last tab.
    if (_tabs.length == 1) {
      // Reset the tab instead of closing it.
      tab.controller.clear();
      tab.title = 'Untitled';
      tab.filePath = null;
      tab.isDirty = false;
      setState(() {});
      return;
    }

    // Determine new active tab.
    String? newActiveId;
    if (_activeTabId == tabId) {
      if (tabIndex > 0) {
        newActiveId = _tabs[tabIndex - 1].id;
      } else {
        newActiveId = _tabs[tabIndex + 1].id;
      }
    }

    tab.controller.removeListener(_handleDocumentChanged);
    tab.dispose();
    setState(() {
      _tabs.removeAt(tabIndex);
      if (newActiveId != null) {
        _activeTabId = newActiveId;
      }
    });
  }

  Future<bool> _confirmCloseUnsaved(String fileName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: Text('"$fileName" has unsaved changes. Close anyway?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _newTab() {
    final tab = DocumentTab.empty(id: _nextTabId());
    tab.controller.addListener(_handleDocumentChanged);
    setState(() {
      _tabs.add(tab);
      _activeTabId = tab.id;
      _saveStatus = 'Saved';
    });
    tab.focusNode.requestFocus();
  }

  Future<void> _addToRecent(String path, String name) async {
    final doc = RecentDocument(
      path: path,
      name: name,
      content: path == name ? _activeTab.controller.text : null,
      lastOpened: DateTime.now(),
    );
    await widget.recentStore.add(doc);
    await _loadRecentDocs();
  }

  Future<void> _openFile() async {
    try {
      final result = await widget.fileService.openFile();
      if (result == null || !mounted) return;

      _openFileResult(result);
      await _addToRecent(result.path, result.name);
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = 'Open failed: $e');
      }
    }
  }

  void _openFileResult(FileOpenResult result) {
    final tab = DocumentTab.fromFile(
      id: _nextTabId(),
      filePath: result.path,
      fileName: result.name,
      content: result.content,
    );
    tab.controller.addListener(_handleDocumentChanged);
    setState(() {
      _tabs.add(tab);
      _activeTabId = tab.id;
      _saveStatus = 'Saved';
    });
    tab.focusNode.requestFocus();
  }

  Future<void> _openRecent(RecentDocument doc) async {
    try {
      final result = await widget.fileService.openFilePath(doc.path);
      final content = result?.content ?? doc.content;
      if (content == null || !mounted) {
        if (mounted) setState(() => _saveStatus = 'File not found');
        return;
      }

      final fileResult = FileOpenResult(
        content: content,
        path: doc.path,
        name: doc.name,
        lastModified: result?.lastModified,
      );
      _openFileResult(fileResult);
      await _addToRecent(doc.path, doc.name);
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = 'Open failed: $e');
      }
    }
  }

  /// Opens a file by path (used by drag-and-drop).
  Future<void> openFilePath(String path) async {
    try {
      final result = await widget.fileService.openFilePath(path);
      if (result == null || !mounted) return;

      _openFileResult(result);
      await _addToRecent(result.path, result.name);
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = 'Open failed: $e');
      }
    }
  }

  Future<void> _saveFile() async {
    try {
      final path = await widget.fileService.saveFileAs(_activeTab.controller.text);
      if (path != null && mounted) {
        final name = path.split('/').last.split('\\').last;
        setState(() {
          _activeTab.title = name;
          _activeTab.filePath = path;
          _activeTab.isDirty = false;
          _saveStatus = 'Saved';
        });
        await _addToRecent(path, name);
      } else if (mounted) {
        setState(() => _saveStatus = 'Save cancelled');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = 'Save failed: $e');
      }
    }
  }

  Future<void> _exportHtml() async {
    final html = markdownToHtmlPage(
      _activeTab.controller.text,
      title: _activeTab.title,
    );
    final defaultName =
        (_activeTab.title).replaceAll(RegExp(r'\.md$'), '') + '.html';
    try {
      final path = await widget.fileService.exportFile(
        html,
        defaultName,
        ['html', 'htm'],
      );
      if (mounted) {
        setState(() {
          _saveStatus = path != null ? 'Exported' : 'Export cancelled';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = 'Export failed: $e');
      }
    }
  }

  Future<void> _exportPdf() async {
    try {
      await shareAsPdf(
        _activeTab.controller.text,
        filename: _activeTab.title,
      );
      if (mounted) setState(() => _saveStatus = 'Exported');
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = 'Export failed: $e');
      }
    }
  }

  void _newDocument() {
    _newTab();
  }

  void _wrapSelection(String before, String after) {
    final controller = _activeTab.controller;
    final selection = controller.selection;
    final text = controller.text;

    if (selection.isCollapsed) {
      controller.text =
        text.replaceRange(selection.start, selection.start, before + after);
      controller.selection = TextSelection.collapsed(
        offset: selection.start + before.length,
      );
    } else {
      final selected = text.substring(selection.start, selection.end);
      controller.text = text.replaceRange(
        selection.start,
        selection.end,
        '$before$selected$after',
      );
      controller.selection = TextSelection(
        baseOffset: selection.start + before.length,
        extentOffset: selection.end + before.length,
      );
    }
    _activeTab.focusNode.requestFocus();
  }

  void _prefixCurrentLine(String prefix) {
    final controller = _activeTab.controller;
    final text = controller.text;
    final cursorPos = controller.selection.baseOffset;

    final lineStart = text.lastIndexOf('\n', cursorPos - 1) + 1;
    controller.text =
        text.replaceRange(lineStart, lineStart, prefix);
    controller.selection = TextSelection.collapsed(
      offset: cursorPos + prefix.length,
    );
    _activeTab.focusNode.requestFocus();
  }

  void _insertBlock(String block) {
    final controller = _activeTab.controller;
    final selection = controller.selection;
    controller.text =
        controller.text.replaceRange(selection.start, selection.end, block);
    controller.selection = TextSelection.collapsed(
      offset: selection.start + block.length,
    );
    _activeTab.focusNode.requestFocus();
  }


  void _onDragEntered(_) {
    setState(() => _isDragging = true);
  }

  void _onDragExited(_) {
    setState(() => _isDragging = false);
  }

  Future<void> _onDragDone(DropDoneDetails message) async {
    setState(() => _isDragging = false);
    for (final file in message.files) {
      if (file.path.toLowerCase().endsWith('.md')) {
        await openFilePath(file.path);
        break; // Only open the first .md file.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = DocumentStats.fromText(_activeTab.controller.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(_activeTab.title),
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
            message: 'Export',
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.file_download),
              onSelected: (value) {
                if (value == 'html') {
                  _exportHtml();
                } else {
                  _exportPdf();
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem<String>(
                      value: 'html',
                      child: Text('Export as HTML'),
                    ),
                    PopupMenuItem<String>(
                      value: 'pdf',
                      child: Text('Export as PDF'),
                    ),
                  ],
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
            message: 'Find and replace (Ctrl+F)',
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _toggleFindReplace,
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
      body: EditorShortcuts(
        onBold: () => _wrapSelection('**', '**'),
        onItalic: () => _wrapSelection('*', '*'),
        onCode: () => _wrapSelection('', ''),
        onLink: () => _wrapSelection('[', '](https://example.com)'),
        onSave: _saveFile,
        onOpen: _openFile,
        onNewDocument: _newDocument,
        onFind: _toggleFindReplace,
        onTogglePreview: () => setState(() => _showPreview = !_showPreview),
        onNextTab: _nextTab,
        onPreviousTab: _previousTab,
        onCloseTab: _closeActiveTab,
        child: DropTarget(
        onDragEntered: _onDragEntered,
        onDragExited: _onDragExited,
        onDragDone: _onDragDone,
        child: Stack(
          children: [
            Column(
              children: [
                DocumentTabBar(
            tabs: _tabs,
            activeTabId: _activeTabId,
            onTabSelected: _switchTab,
            onTabClosed: _closeTab,
            onNewTab: _newTab,
          ),
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
          if (_showFindReplace)
            FindReplaceBar(
              controller: _activeTab.controller,
              onClose: () => setState(() => _showFindReplace = false),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final editor = MarkdownTextEditor(
                  controller: _activeTab.controller,
                  focusNode: _activeTab.focusNode,
                );
                final preview = MarkdownPreview(
                  data: _activeTab.controller.text,
                );

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
                  fileName: _activeTab.title,
                ),
              ],
            ),
            if (_isDragging)
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Drop .md file to open',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}



