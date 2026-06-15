import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markdown_editor/file_service/file_service.dart';
import 'package:markdown_editor/main.dart';
import 'package:markdown_editor/recent_store/recent_store.dart';
import 'package:markdown_editor/settings/settings_base.dart';
import 'package:markdown_editor/storage/document_store.dart';

void main() {
  testWidgets('editor renders initial document', (
    tester,
  ) async {
    // Set a large screen size to ensure all toolbar buttons are visible
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MarkdownEditorApp(
        documentStore: _FakeDocumentStore(),
        fileService: _FakeFileService(),
        recentStore: _FakeRecentStore(),
        settingsStore: _FakeSettingsStore(),
        initialSettings: AppSettings(),
        initialMarkdown:
            '# QLaw Markdown\n\nStart writing on the left. The preview updates as you type.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QLaw Markdown'), findsWidgets);
    expect(
      find.text('Start writing on the left. The preview updates as you type.'),
      findsOneWidget,
    );
    // Check for toolbar icons that should be visible
    expect(find.byIcon(Icons.folder_open), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.text('编辑 + 预览'), findsOneWidget);
    expect(find.text('自动换行'), findsOneWidget);
  });

  testWidgets('toggle word wrap', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MarkdownEditorApp(
        documentStore: _FakeDocumentStore(),
        fileService: _FakeFileService(),
        recentStore: _FakeRecentStore(),
        settingsStore: _FakeSettingsStore(),
        initialSettings: AppSettings(),
        initialMarkdown: '# Draft',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('自动换行'), findsOneWidget);
    expect(find.byIcon(Icons.wrap_text), findsOneWidget);

    // Toggle word wrap off.
    await tester.tap(find.byIcon(Icons.wrap_text));
    await tester.pumpAndSettle();
    expect(find.text('不换行'), findsOneWidget);
    expect(find.byIcon(Icons.text_format), findsOneWidget);

    // Toggle word wrap on.
    await tester.tap(find.byIcon(Icons.text_format));
    await tester.pumpAndSettle();
    expect(find.text('自动换行'), findsOneWidget);
    expect(find.byIcon(Icons.wrap_text), findsOneWidget);
  });

  testWidgets('save cancellation is shown in the status bar', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MarkdownEditorApp(
        documentStore: _FakeDocumentStore(),
        fileService: _FakeFileService(),
        recentStore: _FakeRecentStore(),
        settingsStore: _FakeSettingsStore(),
        initialSettings: AppSettings(),
        initialMarkdown: '# Draft',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.text('Save cancelled'), findsOneWidget);
  });

  testWidgets('open failure shows error dialog', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MarkdownEditorApp(
        documentStore: _FakeDocumentStore(),
        fileService: _FakeFileService(openFileError: Exception('boom')),
        recentStore: _FakeRecentStore(),
        settingsStore: _FakeSettingsStore(),
        initialSettings: AppSettings(),
        initialMarkdown: '# Draft',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.folder_open));
    await tester.pumpAndSettle();

    // Error dialog should be shown
    expect(find.text('错误'), findsOneWidget);
    expect(find.textContaining('打开文件失败'), findsOneWidget);
  });

  testWidgets('missing recent file shows error dialog', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MarkdownEditorApp(
        documentStore: _FakeDocumentStore(),
        fileService: _FakeFileService(),
        recentStore: _FakeRecentStore(
          docs: [
            RecentDocument(
              path: 'missing.md',
              name: 'missing.md',
              lastOpened: DateTime(2026),
            ),
          ],
        ),
        settingsStore: _FakeSettingsStore(),
        initialSettings: AppSettings(),
        initialMarkdown: '# Draft',
      ),
    );
    await tester.pumpAndSettle();

    // Open recent files menu
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    
    // Tap on the missing file
    await tester.tap(find.text('missing.md').first);
    await tester.pumpAndSettle();

    // Error dialog should be shown
    expect(find.text('错误'), findsOneWidget);
    expect(find.textContaining('打开文件失败'), findsOneWidget);
  });
}

class _FakeDocumentStore implements DocumentStore {
  String? draft;

  @override
  Future<String?> loadDraft() async => draft;

  @override
  Future<void> saveDraft(String content) async {
    draft = content;
  }
}

class _FakeFileService implements FileService {
  _FakeFileService({this.openFileError});

  final Object? openFileError;

  @override
  Future<FileOpenResult?> openFile() async {
    final error = openFileError;
    if (error != null) {
      throw error;
    }
    return null;
  }

  @override
  Future<FileOpenResult?> openFilePath(String path) async {
    // Simulate file not found for missing.md
    if (path == 'missing.md') {
      throw Exception('File not found');
    }
    return null;
  }

  @override
  Future<String?> saveFileAs(String content) async => null;

  @override
  Future<void> saveFile(String content, String path) async {}

  @override
  Future<String?> exportFile(
    String content,
    String fileName,
    List<String> allowedExtensions,
  ) async => null;

  @override
  Future<DateTime?> getLastModified(String path) async => null;
}

class _FakeRecentStore implements RecentStore {
  _FakeRecentStore({List<RecentDocument>? docs}) : _docs = docs ?? [];

  final List<RecentDocument> _docs;

  @override
  Future<List<RecentDocument>> loadAll() async => _docs;

  @override
  Future<void> add(RecentDocument doc) async {
    _docs
      ..removeWhere((existing) => existing.path == doc.path)
      ..insert(0, doc);
  }

  @override
  Future<void> remove(String path) async {}
}

class _FakeSettingsStore implements SettingsStore {
  @override
  Future<AppSettings> loadSettings() async => AppSettings();

  @override
  Future<void> saveSettings(AppSettings settings) async {}
}