import 'dart:async';

import 'package:flutter/material.dart';

import 'editor/editor_screen.dart';
import 'file_service/file_service.dart';
import 'recent_store/recent_store.dart';
import 'storage/document_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documentStore = createDocumentStore();
  final fileService = createFileService();
  final recentStore = createRecentStore();
  final savedDraft = await _loadDraftSafely(documentStore);

  runApp(
    MarkdownEditorApp(
      documentStore: documentStore,
      fileService: fileService,
      recentStore: recentStore,
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

class MarkdownEditorApp extends StatelessWidget {
  const MarkdownEditorApp({
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QLaw Markdown',
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
        initialMarkdown: initialMarkdown,
      ),
    );
  }
}

const _initialMarkdown = '''# QLaw Markdown

Start writing on the left. The preview updates as you type.

## MVP checklist

- Markdown editing
- Live preview
- Formatting toolbar
- Responsive desktop and web layout

> Next milestone: add file open/save and persistent local documents.

```
final status = 'prototype ready';
```
''';
