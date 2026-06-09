// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'recent_store_base.dart';

RecentStore createRecentStore() => _WebRecentStore();

class _WebRecentStore implements RecentStore {
  static const _storageKey = 'qlaw_markdown.recent';
  static const _maxEntries = 10;

  @override
  Future<List<RecentDocument>> loadAll() async {
    try {
      final raw = html.window.localStorage[_storageKey];
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => RecentDocument.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> add(RecentDocument doc) async {
    final all = await loadAll();
    all.removeWhere((d) => d.path == doc.path);
    all.insert(0, doc);
    if (all.length > _maxEntries) {
      all.removeRange(_maxEntries, all.length);
    }
    _writeAll(all);
  }

  @override
  Future<void> remove(String path) async {
    final all = await loadAll();
    all.removeWhere((d) => d.path == path);
    _writeAll(all);
  }

  void _writeAll(List<RecentDocument> docs) {
    try {
      html.window.localStorage[_storageKey] = jsonEncode(
        docs.map((d) => d.toJson()).toList(),
      );
    } catch (_) {}
  }
}
