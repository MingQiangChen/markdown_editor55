import 'document_store_base.dart';

DocumentStore createDocumentStore() => _MemoryDocumentStore();

class _MemoryDocumentStore implements DocumentStore {
  String? _draft;

  @override
  Future<String?> loadDraft() async => _draft;

  @override
  Future<void> saveDraft(String content) async {
    _draft = content;
  }
}
