class RecentDocument {
  const RecentDocument({
    required this.path,
    required this.name,
    this.content,
    required this.lastOpened,
  });

  final String path;
  final String name;
  final String? content;
  final DateTime lastOpened;

  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    if (content != null) 'content': content,
    'lastOpened': lastOpened.toIso8601String(),
  };

  factory RecentDocument.fromJson(Map<String, dynamic> json) {
    return RecentDocument(
      path: json['path'] as String,
      name: json['name'] as String,
      content: json['content'] as String?,
      lastOpened: DateTime.parse(json['lastOpened'] as String),
    );
  }
}

abstract class RecentStore {
  Future<List<RecentDocument>> loadAll();
  Future<void> add(RecentDocument doc);
  Future<void> remove(String path);
}
