import 'dart:io';

import 'document_store_base.dart';

DocumentStore createDocumentStore() => _FileDocumentStore();

class _FileDocumentStore implements DocumentStore {
  File get _draftFile {
    final root =
        Platform.environment['APPDATA'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    final directory = Directory('$root${Platform.pathSeparator}QLawMarkdown');
    return File('${directory.path}${Platform.pathSeparator}draft.md');
  }

  @override
  Future<String?> loadDraft() async {
    final file = _draftFile;
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  }

  @override
  Future<void> saveDraft(String content) async {
    final file = _draftFile;
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }
}
