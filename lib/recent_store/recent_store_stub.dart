import 'recent_store_base.dart';

RecentStore createRecentStore() => _StubRecentStore();

class _StubRecentStore implements RecentStore {
  final List<RecentDocument> _docs = [];

  @override
  Future<List<RecentDocument>> loadAll() async => List.of(_docs);

  @override
  Future<void> add(RecentDocument doc) async {
    _docs.removeWhere((d) => d.path == doc.path);
    _docs.insert(0, doc);
  }

  @override
  Future<void> remove(String path) async {
    _docs.removeWhere((d) => d.path == path);
  }
}
