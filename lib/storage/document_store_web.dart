// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'document_store_base.dart';

DocumentStore createDocumentStore() => _WebDocumentStore();

class _WebDocumentStore implements DocumentStore {
  static const _draftKey = 'qlaw_markdown.draft';

  @override
  Future<String?> loadDraft() async => html.window.localStorage[_draftKey];

  @override
  Future<void> saveDraft(String content) async {
    html.window.localStorage[_draftKey] = content;
  }
}
