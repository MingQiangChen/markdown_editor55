import 'package:flutter/material.dart';

import '../settings/settings.dart';
import 'document_stats.dart';
import 'document_tab.dart';
import 'editor_toolbar.dart';
import 'find_replace_bar.dart';
import 'markdown_preview.dart';
import 'markdown_text_editor.dart';
import '../file_tree/file_tree_panel.dart';
import 'document_outline.dart';
import '../cloud_sync/cloud_sync.dart';
import '../spell_check/spell_check_overlay.dart';

/// Mobile-optimized layout for the editor screen.
class MobileEditorLayout extends StatelessWidget {
  const MobileEditorLayout({
    super.key,
    required this.activeTab,
    required this.viewMode,
    required this.wordWrap,
    required this.saveStatus,
    required this.showFindReplace,
    required this.enableSpellCheck,
    required this.settings,
    required this.syncService,
    required this.onCycleViewMode,
    required this.onToggleFindReplace,
    required this.onWrapSelection,
    required this.onInsertBlock,
    required this.onShowTemplateDialog,
    required this.onOpenFile,
    required this.onSaveFile,
    required this.onExportHtml,
    required this.onExportPdf,
    required this.onToggleSettings,
    required this.onToggleSyncSettings,
    required this.onSyncCurrentFile,
    required this.onShowThemePicker,
    required this.onToggleSpellCheck,
    required this.onShowInsertImageDialog,
    required this.onJumpToLine,
    required this.onReplaceSpellWord,
    required this.onOpenFileFromTree,
    required this.onCloseFindReplace,
  });

  final DocumentTab activeTab;
  final ViewMode viewMode;
  final bool wordWrap;
  final String saveStatus;
  final bool showFindReplace;
  final bool enableSpellCheck;
  final AppSettings settings;
  final CloudSyncService syncService;

  final VoidCallback onCycleViewMode;
  final VoidCallback onToggleFindReplace;
  final void Function(String before, String after) onWrapSelection;
  final void Function(String block) onInsertBlock;
  final VoidCallback onShowTemplateDialog;
  final VoidCallback onOpenFile;
  final VoidCallback onSaveFile;
  final VoidCallback onExportHtml;
  final VoidCallback onExportPdf;
  final VoidCallback onToggleSettings;
  final VoidCallback onToggleSyncSettings;
  final VoidCallback onSyncCurrentFile;
  final VoidCallback onShowThemePicker;
  final VoidCallback onToggleSpellCheck;
  final VoidCallback onShowInsertImageDialog;
  final void Function(int line) onJumpToLine;
  final void Function(int start, int end, String replacement) onReplaceSpellWord;
  final void Function(String path) onOpenFileFromTree;
  final VoidCallback onCloseFindReplace;

  @override
  Widget build(BuildContext context) {
    final stats = DocumentStats.fromText(activeTab.controller.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          activeTab.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(switch (viewMode) {
              ViewMode.editorOnly => Icons.edit,
              ViewMode.split => Icons.view_column,
              ViewMode.previewOnly => Icons.preview,
            }),
            onPressed: onCycleViewMode,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'new':
                  onShowTemplateDialog();
                case 'open':
                  onOpenFile();
                case 'save':
                  onSaveFile();
                case 'find':
                  onToggleFindReplace();
                case 'outline':
                  _showMobileOutline(context);
                case 'export_html':
                  onExportHtml();
                case 'export_pdf':
                  onExportPdf();
                case 'settings':
                  onToggleSettings();
                case 'sync':
                  onSyncCurrentFile();
                case 'sync_settings':
                  onToggleSyncSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text('新建'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'open',
                child: ListTile(
                  leading: Icon(Icons.folder_open),
                  title: Text('打开'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: ListTile(
                  leading: Icon(Icons.save),
                  title: Text('保存'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'find',
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: Text('查找替换'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'outline',
                child: ListTile(
                  leading: Icon(Icons.list),
                  title: Text('文档大纲'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'export_html',
                child: ListTile(
                  leading: Icon(Icons.html),
                  title: Text('导出 HTML'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export_pdf',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('导出 PDF'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'sync',
                child: ListTile(
                  leading: Icon(Icons.cloud_upload),
                  title: Text('云同步'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sync_settings',
                child: ListTile(
                  leading: Icon(Icons.cloud_sync),
                  title: Text('同步设置'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('设置'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (showFindReplace)
            FindReplaceBar(
              controller: activeTab.controller,
              onClose: onCloseFindReplace,
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final editor = MarkdownTextEditor(
                  controller: activeTab.controller,
                  focusNode: activeTab.focusNode,
                  wordWrap: wordWrap,
                  textStyle: settings.editorTextStyle,
                );
                final preview = MarkdownPreview(
                  data: activeTab.controller.text,
                );

                return switch (viewMode) {
                  ViewMode.editorOnly => enableSpellCheck
                      ? Column(children: [
                          Expanded(child: editor),
                          SpellCheckOverlay(
                            text: activeTab.controller.text,
                            enabled: enableSpellCheck,
                            onReplace: onReplaceSpellWord,
                          )
                        ])
                      : editor,
                  ViewMode.split => PageView(
                      children: [editor, preview],
                    ),
                  ViewMode.previewOnly => preview,
                };
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EditorToolbar(
            onBold: () => onWrapSelection('**', '**'),
            onItalic: () => onWrapSelection('*', '*'),
            onCode: () => onWrapSelection('`', '`'),
            onLink: () => onWrapSelection('[', '](https://example.com)'),
            onHeading: () => onInsertBlock('## '),
            onQuote: () => onInsertBlock('> '),
            onList: () => onInsertBlock('- '),
            onCodeBlock: () => onInsertBlock('```\n\n```'),
            onInlineMath: () => onWrapSelection('\$', '\$'),
            onBlockMath: () => onInsertBlock('\$\$\n\$\$'),
            onMermaid: () => onInsertBlock('```mermaid\n\n```'),
            onInsertImage: onShowInsertImageDialog,
          ),
          _MobileStatusBar(
            stats: stats,
            viewMode: viewMode,
            saveStatus: saveStatus,
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'QLaw Markdown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeTab.filePath ?? '未保存文档',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('打开文件'),
                onTap: () {
                  Navigator.pop(context);
                  onOpenFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('保存'),
                onTap: () {
                  Navigator.pop(context);
                  onSaveFile();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('文件树'),
                onTap: () {
                  Navigator.pop(context);
                  _showMobileFileTree(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('文档大纲'),
                onTap: () {
                  Navigator.pop(context);
                  _showMobileOutline(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('主题'),
                onTap: () {
                  Navigator.pop(context);
                  onShowThemePicker();
                },
              ),
              ListTile(
                leading: Icon(enableSpellCheck ? Icons.spellcheck : Icons.cancel),
                title: Text(enableSpellCheck ? '关闭拼写检查' : '开启拼写检查'),
                onTap: () {
                  Navigator.pop(context);
                  onToggleSpellCheck();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('插入图片'),
                onTap: () {
                  Navigator.pop(context);
                  onShowInsertImageDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  syncService.status == SyncStatus.syncing
                      ? Icons.sync
                      : syncService.status == SyncStatus.success
                          ? Icons.cloud_done
                          : Icons.cloud_upload,
                  color: syncService.status == SyncStatus.error
                      ? Colors.red
                      : syncService.status == SyncStatus.success
                          ? Colors.green
                          : null,
                ),
                title: const Text('云同步'),
                onTap: () {
                  Navigator.pop(context);
                  onSyncCurrentFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_sync),
                title: const Text('同步设置'),
                onTap: () {
                  Navigator.pop(context);
                  onToggleSyncSettings();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                onTap: () {
                  Navigator.pop(context);
                  onToggleSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMobileFileTree(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('文件树', style: Theme.of(context).textTheme.titleMedium),
            ),
            const Divider(height: 1),
            Expanded(
              child: FileTreePanel(
                onFileSelected: (path) {
                  Navigator.pop(context);
                  onOpenFileFromTree(path);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileOutline(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('文档大纲', style: Theme.of(context).textTheme.titleMedium),
            ),
            const Divider(height: 1),
            Expanded(
              child: DocumentOutline(
                text: activeTab.controller.text,
                onItemTap: (item) {
                  Navigator.pop(context);
                  onJumpToLine(item.lineIndex);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileStatusBar extends StatelessWidget {
  const _MobileStatusBar({
    required this.stats,
    required this.viewMode,
    required this.saveStatus,
  });

  final DocumentStats stats;
  final ViewMode viewMode;
  final String saveStatus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 28,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  '${stats.words} 词',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Text(
                  '${stats.characters} 字符',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  saveStatus,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
