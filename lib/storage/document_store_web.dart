// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'document_store_base.dart';

DocumentStore createDocumentStore() => _WebDocumentStore();

class _WebDocumentStore implements DocumentStore {
  static const _draftKey = 'qlaw_markdown.draft';

  @override
  Future<String?> loadDraft() async {
    try {
      return html.window.localStorage[_draftKey];
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveDraft(String content) async {
    try {
      html.window.localStorage[_draftKey] = content;
    } catch (_) {
      return;
    }
  }
}
