import 'dart:io';

/// 表示文件树中的一个节点
class FileTreeNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileTreeNode> children;
  bool isExpanded;

  FileTreeNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    List<FileTreeNode>? children,
    this.isExpanded = false,
  }) : children = children ?? [];

  /// 从文件系统路径创建节点
  static Future<FileTreeNode?> fromPath(String path) async {
    final entity = FileSystemEntity.typeSync(path);
    if (entity == FileSystemEntityType.notFound) return null;

    final isDir = entity == FileSystemEntityType.directory;
    final name = path.split(Platform.pathSeparator).last;

    return FileTreeNode(
      name: name,
      path: path,
      isDirectory: isDir,
    );
  }

  /// 加载目录的子节点
  Future<void> loadChildren() async {
    if (!isDirectory) return;

    children.clear();
    final dir = Directory(path);
    
    try {
      await for (final entity in dir.list()) {
        // 跳过隐藏文件和目录
        final name = entity.path.split(Platform.pathSeparator).last;
        if (name.startsWith('.')) continue;

        final isDir = entity is Directory;
        final node = FileTreeNode(
          name: name,
          path: entity.path,
          isDirectory: isDir,
        );
        children.add(node);
      }

      // 排序：目录在前，文件在后，各自按名称排序
      children.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.compareTo(b.name);
      });
    } catch (e) {
      // 忽略权限错误等
    }
  }

  /// 是否为Markdown文件
  bool get isMarkdown {
    if (isDirectory) return false;
    final lower = name.toLowerCase();
    return lower.endsWith('.md') || lower.endsWith('.markdown');
  }
}