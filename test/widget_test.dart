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
  @override
  Future<FileOpenResult?> openFile() async => null;

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
}

class _FakeRecentStore implements RecentStore {
  @override
  Future<List<RecentDocument>> loadAll() async => [];

  @override
  Future<void> add(RecentDocument doc) async {}

  @override
  Future<void> remove(String path) async {}
}
