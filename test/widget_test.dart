import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markdown_editor/file_service/file_service.dart';
import 'package:markdown_editor/main.dart';
import 'package:markdown_editor/recent_store/recent_store.dart';
import 'package:markdown_editor/storage/document_store.dart';

void main() {
  testWidgets('editor renders initial document and toggles preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      MarkdownEditorApp(
        documentStore: _FakeDocumentStore(),
        fileService: _FakeFileService(),
        recentStore: _FakeRecentStore(),
        initialMarkdown:
            '# QLaw Markdown\n\nStart writing on the left. The preview updates as you type.',
      ),
    );

    expect(find.text('QLaw Markdown'), findsWidgets);
    expect(
      find.text('Start writing on the left. The preview updates as you type.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.format_bold), findsOneWidget);
    expect(find.byIcon(Icons.folder_open), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
    expect(find.text('Edit + preview'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.text('Edit only'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('save cancellation is shown in the status bar', (tester) async {
    await tester.pumpWidget(
      MarkdownEditorApp(
        documentStore: _FakeDocumentStore(),
        fileService: _FakeFileService(),
        recentStore: _FakeRecentStore(),
        initialMarkdown: '# Draft',
      ),
    );

    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();

    expect(find.text('Save cancelled'), findsOneWidget);
  });

  testWidgets('open failure is shown in the status bar', (tester) async {
    await tester.pumpWidget(
      MarkdownEditorApp(
        documentStore: _FakeDocumentStore(),
        fileService: _FakeFileService(openFileError: Exception('boom')),
        recentStore: _FakeRecentStore(),
        initialMarkdown: '# Draft',
      ),
    );

    await tester.tap(find.byIcon(Icons.folder_open));
    await tester.pump();

    expect(find.textContaining('Open failed:'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
  });

  testWidgets('missing recent file is shown in the status bar', (tester) async {
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
        initialMarkdown: '# Draft',
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    await tester.tap(find.text('missing.md').first);
    await tester.pump();

    expect(find.text('File not found'), findsOneWidget);
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
  Future<FileOpenResult?> openFilePath(String path) async => null;

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
