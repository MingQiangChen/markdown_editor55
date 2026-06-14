import 'dart:async';
import 'package:desktop_drop/desktop_drop.dart';

import 'package:flutter/material.dart';

import '../export/export_service.dart';
import '../export/export_options_dialog.dart';
import '../file_service/file_service.dart';
import '../recent_store/recent_store.dart';
import '../settings/settings.dart';
import '../storage/document_store.dart';
import 'document_stats.dart';
import 'document_tab.dart';
import 'document_tab_bar.dart';
import 'editor_toolbar.dart';
import 'markdown_preview.dart';
import 'markdown_text_editor.dart';
import 'editor_shortcuts.dart';
import 'find_replace_bar.dart';
import '../settings/settings_panel.dart';
import 'document_outline.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.documentStore,
    required this.fileService,
    required this.recentStore,
    required this.settingsStore,
    required this.initialSettings,
    required this.initialMarkdown,
  });

  final DocumentStore documentStore;
  final FileService fileService;
  final RecentStore recentStore;
  final SettingsStore settingsStore;
  final AppSettings initialSettings;
  final String initialMarkdown;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final List<DocumentTab> _tabs = [];
  String _activeTabId = '';
  int _tabCounter = 0;
  Timer? _saveTimer;
  late ViewMode _viewMode;
  late bool _wordWrap;
  late AppSettings _settings;
  String _saveStatus = '已保存';
  List<RecentDocument> _recentDocs = [];
  bool _isDragging = false;
  bool _showFindReplace = false;
  bool _showSettings = false;
  bool _showOutline = false;
  bool _isFullScreen = false;
  final Map<String, VoidCallback> _tabListeners = {};

  DocumentTab get _activeTab => _tabs.firstWhere((t) => t.id == _activeTabId);

  void _attachListener(DocumentTab tab) {
    // ignore: prefer_function_declarations_over_variables
    final listener = () => _handleDocumentChanged(tab.id);
    _tabListeners[tab.id] = listener;
    tab.controller.addListener(listener);
  }

  void _detachListener(DocumentTab tab) {
    final listener = _tabListeners.remove(tab.id);
    if (listener != null) {
      tab.controller.removeListener(listener);
    }
  }

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _viewMode = _viewModeFromSettings(_settings.defaultViewMode);
    _wordWrap = _settings.wordWrap;
    
    final firstTab = DocumentTab.empty(id: _nextTabId());
    firstTab.controller.text = widget.initialMarkdown;
    _attachListener(firstTab);
    _tabs.add(firstTab);
    _activeTabId = firstTab.id;
    _loadRecentDocs();
  }

  ViewMode _viewModeFromSettings(EditorViewMode mode) {
    return switch (mode) {
      EditorViewMode.editor => ViewMode.editorOnly,
      EditorViewMode.split => ViewMode.split,
      EditorViewMode.preview => ViewMode.previewOnly,
    };
  }

  EditorViewMode _viewModeToSettings(ViewMode mode) {
    return switch (mode) {
      ViewMode.editorOnly => EditorViewMode.editor,
      ViewMode.split => EditorViewMode.split,
      ViewMode.previewOnly => EditorViewMode.preview,
    };
  }

  void _toggleSettings() {
    setState(() => _showSettings = !_showSettings);
  }

  void _toggleOutline() {
    setState(() => _showOutline = !_showOutline);
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
  }

  Future<void> _saveSettings(AppSettings newSettings) async {
    setState(() => _settings = newSettings);
    await widget.settingsStore.saveSettings(newSettings);
  }

  void _jumpToLine(int lineIndex) {
    final controller = _activeTab.controller;
    final text = controller.text;
    final lines = text.split('\n');
    
    if (lineIndex >= lines.length) return;
    
    int charIndex = 0;
    for (int i = 0; i < lineIndex; i++) {
      charIndex += lines[i].length + 1; // +1 for newline
    }
    
    controller.selection = TextSelection.collapsed(offset: charIndex);
    _activeTab.focusNode.requestFocus();
  }

  String _nextTabId() {
    _tabCounter++;
    return 'tab_';
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

  void _handleDocumentChanged(String tabId) {
    final tabIndex = _tabs.indexWhere((t) => t.id == tabId);
    if (tabIndex == -1) return;

    setState(() => _saveStatus = 'Saving...');
    _tabs[tabIndex].isDirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      final currentIndex = _tabs.indexWhere((t) => t.id == tabId);
      if (currentIndex == -1) return;
      try {
        await widget.documentStore.saveDraft(
          _tabs[currentIndex].controller.text,
        );
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
    _saveTimer?.cancel();
    setState(() {
      _activeTabId = tabId;
      _saveStatus = '已保存';
    });
    _activeTab.focusNode.requestFocus();
  }

  void _toggleFindReplace() {
    setState(() => _showFindReplace = !_showFindReplace);
  }

  void _cycleViewMode() {
    setState(() {
      _viewMode = switch (_viewMode) {
        ViewMode.editorOnly => ViewMode.split,
        ViewMode.split => ViewMode.previewOnly,
        ViewMode.previewOnly => ViewMode.editorOnly,
      };
    });
    _saveSettings(_settings.copyWith(defaultViewMode: _viewModeToSettings(_viewMode)));
  }

  void _toggleWordWrap() {
    setState(() => _wordWrap = !_wordWrap);
    _saveSettings(_settings.copyWith(wordWrap: _wordWrap));
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

    if (tab.isDirty && tab.controller.text.isNotEmpty) {
      final confirmed = await _confirmCloseUnsaved(tab.title);
      if (!confirmed) return;
    }

    if (_tabs.length == 1) {
      _detachListener(tab);
      tab.controller.clear();
      tab.title = '未命名';
      tab.filePath = null;
      tab.isDirty = false;
      _attachListener(tab);
      _saveTimer?.cancel();
      setState(() => _saveStatus = '已保存');
      return;
    }

    String? newActiveId;
    if (_activeTabId == tabId) {
      if (tabIndex > 0) {
        newActiveId = _tabs[tabIndex - 1].id;
      } else {
        newActiveId = _tabs[tabIndex + 1].id;
      }
    }

    _detachListener(tab);
    tab.dispose();
    setState(() {
      _tabs.removeAt(tabIndex);
      if (newActiveId != null) {
        _activeTabId = newActiveId;
      }
    });
  }

  Future<bool> _confirmCloseUnsaved(String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关闭文档'),
        content: Text('文档 "" 有未保存的更改，是否关闭？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _openFile() async {
    try {
      final result = await widget.fileService.openFile();
      if (result != null && mounted) {
        await _openFileResult(result);
      }
    } catch (e) {
      if (mounted) {
        _showError('打开文件失败: ');
      }
    }
  }

  Future<void> _openFileResult(FileOpenResult result) async {
    final existingIndex = _tabs.indexWhere((t) => t.filePath == result.path);
    if (existingIndex >= 0) {
      _switchTab(_tabs[existingIndex].id);
      return;
    }

    final tab = DocumentTab.fromFile(
      id: _nextTabId(),
      filePath: result.path,
      fileName: result.name,
      content: result.content,
    );
    _attachListener(tab);
    setState(() {
      _tabs.add(tab);
      _activeTabId = tab.id;
      _saveStatus = '已保存';
    });
    await _addToRecent(result.path, result.name);
  }

  Future<void> _addToRecent(String path, String name) async {
    try {
      await widget.recentStore.add(
        RecentDocument(
          path: path,
          name: name,
          content: null,
          lastOpened: DateTime.now(),
        ),
      );
      await _loadRecentDocs();
    } catch (_) {
      // Ignore recent store errors
    }
  }

  Future<void> _saveFile() async {
    try {
      if (_activeTab.filePath != null) {
        await widget.fileService.saveFile(
          _activeTab.controller.text,
          _activeTab.filePath!,
        );
        if (mounted) {
          setState(() {
            _activeTab.isDirty = false;
            _saveStatus = '已保存';
          });
        }
      } else {
        final path = await widget.fileService.saveFileAs(
          _activeTab.controller.text,
        );
        if (path != null && mounted) {
          final name = path.split('/').last.split('\\').last;
          setState(() {
            _activeTab.title = name;
            _activeTab.filePath = path;
            _activeTab.isDirty = false;
            _saveStatus = '已保存';
          });
          await _addToRecent(path, name);
        } else if (mounted) {
          setState(() => _saveStatus = 'Save cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('保存失败: ');
      }
    }
  }

  void _newDocument() {
    final tab = DocumentTab.empty(id: _nextTabId());
    _attachListener(tab);
    setState(() {
      _tabs.add(tab);
      _activeTabId = tab.id;
      _saveStatus = '已保存';
    });
  }

  Future<void> _openRecent(RecentDocument doc) async {
    try {
      final result = await widget.fileService.openFilePath(doc.path);
      if (result != null && mounted) {
        await _openFileResult(result);
      }
    } catch (e) {
      if (mounted) {
        _showError('打开文件失败: ');
      }
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportHtml() async {
    final options = await showExportOptionsDialog(context);
    if (options == null) return;

    try {
      final html = markdownToHtmlPage(
        _activeTab.controller.text,
        title: _activeTab.title,
        template: options.template,
        enableKatex: options.enableKatex,
        enableMermaid: options.enableMermaid,
      );
      final path = await widget.fileService.exportFile(
        html,
        _activeTab.title.replaceAll('.md', ''),
        ['html'],
      );
      if (path != null && mounted) {
        setState(() => _saveStatus = '已导出');
      }
    } catch (e) {
      if (mounted) {
        _showError('导出 HTML 失败: ');
      }
    }
  }

  Future<void> _exportPdf() async {
    final options = await showExportOptionsDialog(context);
    if (options == null) return;

    try {
      await shareAsPdf(
        _activeTab.controller.text,
        filename: _activeTab.title,
        template: options.template,
        enableKatex: options.enableKatex,
        enableMermaid: options.enableMermaid,
      );
      if (mounted) {
        setState(() => _saveStatus = '已导出');
      }
    } catch (e) {
      if (mounted) {
        _showError('导出 PDF 失败: ');
      }
    }
  }

  void _wrapSelection(String before, String after) {
    final controller = _activeTab.controller;
    final selection = controller.selection;
    final text = controller.text;

    if (!selection.isValid || selection.start < 0) {
      final insertPos = text.length;
      controller.text = text + before + after;
      controller.selection = TextSelection.collapsed(
        offset: insertPos + before.length,
      );
      _activeTab.focusNode.requestFocus();
      return;
    }

    if (selection.isCollapsed) {
      controller.text = text.replaceRange(
        selection.start,
        selection.end,
        before + after,
      );
      controller.selection = TextSelection.collapsed(
        offset: selection.start + before.length,
      );
    } else {
      final selected = text.substring(selection.start, selection.end);
      controller.text = text.replaceRange(
        selection.start,
        selection.end,
        before + selected + after,
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

    if (cursorPos < 0) return;
    final searchFrom = cursorPos > 0 ? cursorPos - 1 : 0;
    final lineStart = text.lastIndexOf('\n', searchFrom) + 1;
    controller.text = text.replaceRange(lineStart, lineStart, prefix);
    controller.selection = TextSelection.collapsed(
      offset: cursorPos + prefix.length,
    );
    _activeTab.focusNode.requestFocus();
  }

  void _insertBlock(String block) {
    final controller = _activeTab.controller;
    final selection = controller.selection;
    final start =
        selection.isValid && selection.start >= 0
            ? selection.start
            : controller.text.length;
    final end =
        selection.isValid && selection.end >= 0 ? selection.end : start;
    controller.text = controller.text.replaceRange(start, end, block);
    controller.selection = TextSelection.collapsed(
      offset: start + block.length,
    );
    _activeTab.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return EditorShortcuts(
      onBold: () => _wrapSelection('**', '**'),
      onItalic: () => _wrapSelection('*', '*'),
      onCode: () => _wrapSelection('', ''),
      onLink: () => _wrapSelection('[', '](https://example.com)'),
      onSave: _saveFile,
      onOpen: _openFile,
      onNewDocument: _newDocument,
      onCycleViewMode: _cycleViewMode,
      onToggleWordWrap: _toggleWordWrap,
      onFind: _toggleFindReplace,
      onTogglePreview: _cycleViewMode,
      onNextTab: _nextTab,
      onPreviousTab: _previousTab,
      onCloseTab: _closeActiveTab,
      child: Scaffold(
        body: DropTarget(
          onDragDone: (details) async {
            if (details.files.isNotEmpty) {
              final file = details.files.first;
              try {
                final result = await widget.fileService.openFilePath(file.path);
                if (result != null && mounted) {
                  await _openFileResult(result);
                }
              } catch (e) {
                if (mounted) {
                  _showError('打开文件失败: ');
                }
              }
            }
          },
          onDragEntered: (_) => setState(() => _isDragging = true),
          onDragExited: (_) => setState(() => _isDragging = false),
          child: Stack(
            children: [
              _buildMainContent(context),
              if (_showSettings)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: SettingsPanel(
                    settings: _settings,
                    onSave: _saveSettings,
                  ),
                ),
              if (_isDragging)
                Positioned.fill(
                  child: Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
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
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
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

  Widget _buildMainContent(BuildContext context) {
    final stats = DocumentStats.fromText(_activeTab.controller.text);

    if (_isFullScreen) {
      return Column(
        children: [
          // Full screen: minimal UI
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.fullscreen_exit),
                tooltip: '退出全屏 (Esc)',
                onPressed: _toggleFullScreen,
              ),
              const Spacer(),
              Text(
                _activeTab.title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              Text(
                _saveStatus,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          Expanded(
            child: MarkdownTextEditor(
              controller: _activeTab.controller,
              focusNode: _activeTab.focusNode,
              wordWrap: _wordWrap,
              textStyle: _settings.editorTextStyle,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        DocumentTabBar(
          tabs: _tabs,
          activeTabId: _activeTabId,
          onTabSelected: _switchTab,
          onTabClosed: _closeTab,
          onNewTab: _newDocument,
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: '打开文件',
              onPressed: _openFile,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: '保存文件',
              onPressed: _saveFile,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.file_download),
              tooltip: '导出',
              onSelected: (value) {
                if (value == 'html') {
                  _exportHtml();
                } else if (value == 'pdf') {
                  _exportPdf();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'html', child: Text('导出为 HTML')),
                const PopupMenuItem(value: 'pdf', child: Text('导出为 PDF')),
              ],
            ),
            PopupMenuButton<RecentDocument>(
              icon: const Icon(Icons.history),
              tooltip: '最近文档',
              onSelected: _openRecent,
              itemBuilder: (context) => [
                if (_recentDocs.isEmpty)
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('暂无最近文档'),
                  )
                else
                  ..._recentDocs.map(
                    (doc) => PopupMenuItem(
                      value: doc,
                      child: Text(doc.name),
                    ),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Tooltip(
              message: '查找和替换',
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _toggleFindReplace,
              ),
            ),
            Tooltip(
              message: '文档大纲',
              child: IconButton(
                icon: const Icon(Icons.list),
                onPressed: _toggleOutline,
              ),
            ),
            Tooltip(
              message: '新建文档',
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _newDocument,
              ),
            ),
            Tooltip(
              message: switch (_viewMode) {
                ViewMode.editorOnly => '切换到分屏',
                ViewMode.split => '切换到预览',
                ViewMode.previewOnly => '切换到编辑',
              },
              child: IconButton(
                icon: Icon(switch (_viewMode) {
                  ViewMode.editorOnly => Icons.edit,
                  ViewMode.split => Icons.view_column,
                  ViewMode.previewOnly => Icons.preview,
                }),
                onPressed: _cycleViewMode,
              ),
            ),
            Tooltip(
              message: _wordWrap ? '关闭自动换行' : '开启自动换行',
              child: IconButton(
                icon: Icon(_wordWrap ? Icons.wrap_text : Icons.text_format),
                onPressed: _toggleWordWrap,
              ),
            ),
            Tooltip(
              message: _isFullScreen ? '退出全屏' : '全屏模式',
              child: IconButton(
                icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                onPressed: _toggleFullScreen,
              ),
            ),
            const Spacer(),
            Tooltip(
              message: '设置',
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _toggleSettings,
              ),
            ),
          ],
        ),
        if (_showFindReplace)
          FindReplaceBar(
            controller: _activeTab.controller,
            onClose: () => setState(() => _showFindReplace = false),
          ),
        Expanded(
          child: Row(
            children: [
              if (_showOutline)
                DocumentOutline(
                  text: _activeTab.controller.text,
                  onItemTap: (item) => _jumpToLine(item.lineIndex),
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 760;
                    final editor = MarkdownTextEditor(
                      controller: _activeTab.controller,
                      focusNode: _activeTab.focusNode,
                      wordWrap: _wordWrap,
                      textStyle: _settings.editorTextStyle,
                    );
                    final preview = MarkdownPreview(
                      data: _activeTab.controller.text,
                    );

                    return switch (_viewMode) {
                      ViewMode.editorOnly => editor,
                      ViewMode.split when compact => PageView(
                        children: [editor, preview],
                      ),
                      ViewMode.split => Row(
                        children: [
                          Expanded(child: editor),
                          const VerticalDivider(width: 1),
                          Expanded(child: preview),
                        ],
                      ),
                      ViewMode.previewOnly => preview,
                    };
                  },
                ),
              ),
            ],
          ),
        ),
        StatusBar(
          stats: stats,
          viewMode: _viewMode,
          wordWrap: _wordWrap,
          saveStatus: _saveStatus,
          fileName: _activeTab.title,
          controller: _activeTab.controller,
        ),
      ],
    );
  }
}
