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
  final settings = await _loadSettingsSafely(settingsStore);
  await _clearDraft(documentStore);

  runApp(
    MarkdownEditorApp(
      documentStore: documentStore,
      fileService: fileService,
      recentStore: recentStore,
      settingsStore: settingsStore,
      initialSettings: settings,
      initialMarkdown: '',
    ),
  );
}

Future<void> _clearDraft(DocumentStore documentStore) async {
  try {
    await documentStore.saveDraft('');
  } catch (_) {}
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