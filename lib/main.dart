import 'dart:async';

import 'package:flutter/material.dart';

import 'editor/editor_screen.dart';
import 'file_service/file_service.dart';
import 'recent_store/recent_store.dart';
import 'settings/settings.dart';
import 'storage/document_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documentStore = createDocumentStore();
  final fileService = createFileService();
  final recentStore = createRecentStore();
  final settingsStore = createSettingsStore();
  final savedDraft = await _loadDraftSafely(documentStore);
  final settings = await _loadSettingsSafely(settingsStore);

  runApp(
    MarkdownEditorApp(
      documentStore: documentStore,
      fileService: fileService,
      recentStore: recentStore,
      settingsStore: settingsStore,
      initialSettings: settings,
      initialMarkdown: savedDraft ?? _initialMarkdown,
    ),
  );
}

Future<String?> _loadDraftSafely(DocumentStore documentStore) async {
  try {
    return await documentStore.loadDraft();
  } catch (_) {
    return null;
  }
}

Future<AppSettings> _loadSettingsSafely(SettingsStore settingsStore) async {
  try {
    return await settingsStore.loadSettings();
  } catch (_) {
    return const AppSettings();
  }
}

class MarkdownEditorApp extends StatelessWidget {
  const MarkdownEditorApp({
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QLaw Markdown 编辑器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff256f7f),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff3d8f72),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: EditorScreen(
        documentStore: documentStore,
        fileService: fileService,
        recentStore: recentStore,
        settingsStore: settingsStore,
        initialSettings: initialSettings,
        initialMarkdown: initialMarkdown,
      ),
    );
  }
}

const _initialMarkdown = '''# QLaw Markdown 编辑器

在左侧编辑，右侧实时预览。

## 功能清单

- Markdown 编辑
- 实时预览
- 格式化工具栏
- 响应式桌面和网页布局

> 下一步：添加文件打开/保存和本地文档持久化。

\\\
final status = 'prototype ready';
\\\
''';
