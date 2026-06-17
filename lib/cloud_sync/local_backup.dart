import 'dart:io';

/// 本地备份服务
class LocalBackup {
  final String backupPath;

  LocalBackup({required this.backupPath});

  /// 确保备份目录存在
  Future<void> ensureBackupDir() async {
    final dir = Directory(backupPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  String _filePath(String fileName) => '$backupPath${Platform.pathSeparator}$fileName';

  /// 备份文件
  Future<bool> backupFile(String fileName, String content) async {
    try {
      await ensureBackupDir();
      final file = File(_filePath(fileName));
      await file.writeAsString(content, flush: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 恢复文件
  Future<String?> restoreFile(String fileName) async {
    try {
      final file = File(_filePath(fileName));
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 列出备份文件
  Future<List<String>> listBackups() async {
    try {
      final dir = Directory(backupPath);
      if (!await dir.exists()) {
        return [];
      }
      return await dir
          .list()
          .where((e) => e is File && e.path.endsWith('.md'))
          .map((e) => e.path.split(Platform.pathSeparator).last)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 删除备份
  Future<bool> deleteBackup(String fileName) async {
    try {
      final file = File(_filePath(fileName));
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取备份目录大小
  Future<int> getBackupSize() async {
    try {
      final dir = Directory(backupPath);
      if (!await dir.exists()) {
        return 0;
      }
      var totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}