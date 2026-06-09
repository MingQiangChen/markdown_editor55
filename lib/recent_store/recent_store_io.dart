import 'dart:convert';
import 'dart:io';

import 'recent_store_base.dart';

RecentStore createRecentStore() => _FileRecentStore();

class _FileRecentStore implements RecentStore {
  static const _maxEntries = 10;

  File get _storeFile {
    final root =
        Platform.environment['APPDATA'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    final directory = Directory('$root${Platform.pathSeparator}QLawMarkdown');
    return File('${directory.path}${Platform.pathSeparator}recent.json');
  }

  @override
  Future<List<RecentDocument>> loadAll() async {
    final file = _storeFile;
    if (!await file.exists()) return [];

    try {
      final json = await file.readAsString();
      final list = jsonDecode(json) as List<dynamic>;
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
    // Remove existing entry with same path, then insert at top.
    all.removeWhere((d) => d.path == doc.path);
    all.insert(0, doc);
    // Trim to max.
    if (all.length > _maxEntries) {
      all.removeRange(_maxEntries, all.length);
    }
    await _writeAll(all);
  }

  @override
  Future<void> remove(String path) async {
    final all = await loadAll();
    all.removeWhere((d) => d.path == path);
    await _writeAll(all);
  }

  Future<void> _writeAll(List<RecentDocument> docs) async {
    final file = _storeFile;
    await file.parent.create(recursive: true);
    final json = jsonEncode(docs.map((d) => d.toJson()).toList());
    await file.writeAsString(json);
  }
}
