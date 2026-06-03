abstract class DocumentStore {
  Future<String?> loadDraft();
  Future<void> saveDraft(String content);
}
