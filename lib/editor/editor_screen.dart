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
import 'markdown_preview.dart';
import 'markdown_text_editor.dart';
import 'editor_shortcuts.dart';
import 'find_replace_bar.dart';
import '../settings/settings_panel.dart';
import 'document_outline.dart';
import '../custom_theme/custom_theme.dart';
import '../custom_theme/theme_picker.dart';
import '../table_editor/table_editor.dart';
import '../task_list/task_list_editor.dart';
import '../image_service/image_service.dart';
import 'insert_image_dialog.dart';
import '../file_tree/file_tree_panel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../templates/document_templates.dart';
import '../cloud_sync/cloud_sync.dart';
import '../spell_check/spell_check_overlay.dart';

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
  Timer? _autoSaveTimer;
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
  CustomTheme _currentTheme = CustomTheme.ocean;
  bool _enableSpellCheck = false;
  bool _showFileTree = false;
  bool _showSyncSettings = false;
  SyncConfig _syncConfig = const SyncConfig();
  late CloudSyncService _syncService;
  final Map<String, VoidCallback> _tabListeners = {};
  final Map<String, DocumentStats> _statsCache = {};

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
    _syncService = CloudSyncService(_syncConfig);
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

  void _toggleSyncSettings() {
    setState(() => _showSyncSettings = !_showSyncSettings);
  }

  void _onSyncConfigChanged(SyncConfig newConfig) {
    setState(() => _syncConfig = newConfig);
  }

  Future<void> _syncCurrentFile() async {
    if (!_syncConfig.enabled || !_syncConfig.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置云同步')),
      );
      return;
    }

    final fileName = _activeTab.filePath != null
        ? _activeTab.filePath!.split(Platform.pathSeparator).last
        : 'untitled.md';
    
    final result = await _syncService.syncFile(fileName, _activeTab.controller.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? (result.success ? '同步成功' : '同步失败')),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _toggleOutline() {
    setState(() => _showOutline = !_showOutline);
  }


  void _showSnippetMenu() {
    final snippets = {
      '分割线': '\n\n---\n\n',
      '目录 (TOC)': '\n\n[TOC]\n\n',
      '表格模板': '\n\n| 列1 | 列2 | 列3 |\n|------|------|------|\n| 内容 | 内容 | 内容 |\n\n',
      '任务列表': '\n\n- [ ] 任务 1\n- [ ] 任务 2\n- [x] 已完成任务\n\n',
      '脚注': '\n\n这是一段带脚注的文本[^1]。\n\n[^1]: 这是脚注内容。\n\n',
      'HTML 注释': '\n\n<!-- 注释内容 -->\n\n',
      '定义列表': '\n\n术语 1\n:   定义 1\n\n术语 2\n:   定义 2\n\n',
      '数学公式块': '\n\n```math\nE = mc^2\n```\n\n',
      'Mermaid 流程图': '\n\n```mermaid\ngraph TD\n    A[开始] --> B[结束]\n```\n\n',
    };

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: snippets.entries.map((entry) {
            return ListTile(
              leading: const Icon(Icons.code),
              title: Text(entry.key),
              onTap: () {
                Navigator.pop(context);
                _insertBlock(entry.value);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
  }

  void _showTableEditor() {
    showDialog<void>(
      context: context,
      builder: (context) => TableEditor(
        onTableGenerated: (tableMarkdown) {
          _insertBlock('\n\n$tableMarkdown');
        },
      ),
    );
  }

  void _showTaskListEditor() {
    showDialog<void>(
      context: context,
      builder: (context) => TaskListEditor(
        onTasksGenerated: (tasksMarkdown) {
          _insertBlock('\n\n$tasksMarkdown');
        },
      ),
    );
  }

  void _showThemePicker() {
    showDialog<void>(
      context: context,
      builder: (context) => ThemePicker(
        currentTheme: _currentTheme,
        onThemeSelected: (theme) {
          setState(() => _currentTheme = theme);
        },
      ),
    );
  }

  void _toggleSpellCheck() {
    setState(() => _enableSpellCheck = !_enableSpellCheck);
  }

  void _replaceSpellWord(int start, int end, String replacement) {
    final controller = _activeTab.controller;
    controller.text = controller.text.replaceRange(start, end, replacement);
    _handleDocumentChanged(_activeTab.id);
  }

  void _toggleFileTree() {
    setState(() => _showFileTree = !_showFileTree);
  }

  Future<void> _openFileFromTree(String filePath) async {
    try {
      final result = await widget.fileService.openFilePath(filePath);
      if (result != null && mounted) {
        await _openFileResult(result);
      }
    } catch (e) {
      if (mounted) {
        _showError('打开文件失败: $e');
      }
    }
  }

  void _showInsertImageDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => InsertImageDialog(
        onPickFromFile: _pickImageFromFile,
        onInsertFromUrl: _insertImageFromUrl,
      ),
    );
  }

  Future<void> _pickImageFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null || result.files.isEmpty) return;
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final ext = result.files.single.extension ?? 'png';

      final relativePath = await ImageService.saveImage(
        bytes: bytes,
        extension: ext,
        markdownFilePath: _activeTab.filePath,
      );
      if (relativePath == null) {
        if (mounted) _showError('保存图片失败');
        return;
      }
      _insertBlock('\n\n![$ext]($relativePath)\n\n');
    } catch (e) {
      if (mounted) _showError('选择图片失败: $e');
    }
  }

  void _insertImageFromUrl(String url, String altText) {
    final alt = altText.isNotEmpty ? altText : '';
    _insertBlock('\n\n![$alt]($url)\n\n');
  }

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.svg');
  }

  Future<void> _handleDroppedImage(dynamic droppedFile) async {
    try {
      final file = File(droppedFile.path);
      final bytes = await file.readAsBytes();
      final ext = droppedFile.name.split('.').last.toLowerCase();

      final relativePath = await ImageService.saveImage(
        bytes: bytes,
        extension: ext,
        markdownFilePath: _activeTab.filePath,
      );
      if (relativePath == null) {
        if (mounted) _showError('保存图片失败');
        return;
      }
      _insertBlock('\n\n![$ext]($relativePath)\n\n');
    } catch (e) {
      if (mounted) _showError('插入图片失败: $e');
    }
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
    _autoSaveTimer?.cancel();
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
    _stopAutoSave();
    setState(() {
      _activeTabId = tabId;
      _saveStatus = '已保存';
    });
    _startAutoSave();
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
        _showError('打开文件失败: $e');
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
    _startAutoSave();
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


  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    if (_activeTab.filePath == null) return;
    
    final interval = _settings.autoSaveIntervalMs;
    if (interval <= 0) return;
    
    _autoSaveTimer = Timer.periodic(Duration(milliseconds: interval), (_) {
      _autoSave();
    });
  }

  void _stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  Future<void> _autoSave() async {
    if (_activeTab.filePath == null) return;
    if (!_activeTab.isDirty) return;
    
    try {
      await widget.fileService.saveFile(
        _activeTab.controller.text,
        _activeTab.filePath!,
      );
      if (mounted) {
        setState(() {
          _activeTab.isDirty = false;
          _saveStatus = '已自动保存';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = '自动保存失败');
      }
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
        _showError('保存失败: $e');
      }
    }
  }


  void _showTemplateDialog() {
    showDialog<MapEntry<String, String>>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择文档模板'),
        children: DocumentTemplates.templates.entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, entry),
            child: Text(entry.key),
          );
        }).toList(),
      ),
    ).then((selected) {
      if (selected != null) {
        _newDocumentWithTemplate(selected.value);
      }
    });
  }

  void _newDocumentWithTemplate(String content) {
    final tab = DocumentTab.empty(id: _nextTabId());
    if (content.isNotEmpty) {
      tab.controller.text = content;
    }
    _attachListener(tab);
    setState(() {
      _tabs.add(tab);
      _activeTabId = tab.id;
      _saveStatus = '未保存';
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
        _showError('打开文件失败: $e');
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
        _showError('导出 HTML 失败: $e');
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
        _showError('导出 PDF 失败: $e');
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
      onNewDocument: _showTemplateDialog,
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
              for (final droppedFile in details.files) {
                if (_isImageFile(droppedFile.name)) {
                  await _handleDroppedImage(droppedFile);
                } else {
                  try {
                    final result = await widget.fileService.openFilePath(droppedFile.path);
                    if (result != null && mounted) {
                      await _openFileResult(result);
                    }
                  } catch (e) {
                    if (mounted) {
                      _showError('打开文件失败: $e');
                    }
                  }
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
                    onClose: _toggleSettings,
                  ),
                ),
              if (_showSyncSettings)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: SyncSettingsPanel(
                    config: _syncConfig,
                    onConfigChanged: _onSyncConfigChanged,
                    syncService: _syncService,
                    onClose: _toggleSyncSettings,
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
    final stats = _statsCache[_activeTabId] ?? DocumentStats.fromText(_activeTab.controller.text);
    _statsCache[_activeTabId] = stats;

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
              Tooltip(
              message: '插入图片',
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: _showInsertImageDialog,
              ),
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
          onNewTab: _showTemplateDialog,
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
              message: '文件浏览器',
              child: IconButton(
                icon: const Icon(Icons.account_tree),
                onPressed: _toggleFileTree,
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
                onPressed: _showTemplateDialog,
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
            const VerticalDivider(),
            Tooltip(
              message: '表格',
              child: IconButton(
                icon: const Icon(Icons.table_chart),
                onPressed: _showTableEditor,
              ),
            ),
            Tooltip(
              message: '任务列表',
              child: IconButton(
                icon: const Icon(Icons.checklist),
                onPressed: _showTaskListEditor,
              ),
            ),
            Tooltip(
              message: '代码片段',
              child: IconButton(
                icon: const Icon(Icons.code),
                onPressed: _showSnippetMenu,
              ),
            ),
            Tooltip(
              message: '主题',
              child: IconButton(
                icon: const Icon(Icons.palette),
                onPressed: _showThemePicker,
              ),
            ),
            Tooltip(
              message: _enableSpellCheck ? '关闭拼写检查' : '开启拼写检查',
              child: IconButton(
                icon: Icon(
                  _enableSpellCheck ? Icons.spellcheck : Icons.cancel,
                ),
                onPressed: _toggleSpellCheck,
              ),
            ),
            Tooltip(
              message: '插入图片',
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: _showInsertImageDialog,
              ),
            ),
            const Spacer(),
            Tooltip(
              message: '云同步',
              child: IconButton(
                icon: Icon(
                  _syncService.status == SyncStatus.syncing
                      ? Icons.sync
                      : _syncService.status == SyncStatus.success
                          ? Icons.cloud_done
                          : Icons.cloud_upload,
                  color: _syncService.status == SyncStatus.error
                      ? Colors.red
                      : _syncService.status == SyncStatus.success
                          ? Colors.green
                          : null,
                ),
                onPressed: _syncCurrentFile,
              ),
            ),
            Tooltip(
              message: '同步设置',
              child: IconButton(
                icon: const Icon(Icons.cloud_sync),
                onPressed: _toggleSyncSettings,
              ),
            ),
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
              if (_showFileTree)
                FileTreePanel(
                  onFileSelected: _openFileFromTree,
                ),
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
                      ViewMode.editorOnly => _enableSpellCheck
                        ? Column(children: [Expanded(child: editor), SpellCheckOverlay(
                            text: _activeTab.controller.text,
                            enabled: _enableSpellCheck,
                            onReplace: _replaceSpellWord,
                          )])
                        : editor,
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
