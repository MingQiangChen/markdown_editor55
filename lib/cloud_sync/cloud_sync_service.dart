import 'dart:async';
import 'dart:io';
import 'sync_config.dart';
import 'sync_status.dart';
import 'webdav_client.dart';
import 'local_backup.dart';

/// 云同步服务
class CloudSyncService {
  SyncConfig _config;
  SyncStatus _status = SyncStatus.idle;
  final SyncHistory _history = SyncHistory();
  Timer? _autoSyncTimer;
  WebDavClient? _webdavClient;
  LocalBackup? _localBackup;
  
  // 同步回调
  void Function(SyncStatus)? onStatusChanged;
  void Function(SyncResult)? onSyncCompleted;

  CloudSyncService(this._config);

  SyncStatus get status => _status;
  SyncConfig get config => _config;
  SyncHistory get history => _history;
  bool get isSyncing => _status == SyncStatus.syncing;

  /// 更新配置
  void updateConfig(SyncConfig newConfig) {
    _config = newConfig;
    _initClients();
    if (_config.enabled && _config.autoSyncIntervalMinutes > 0) {
      startAutoSync();
    } else {
      stopAutoSync();
    }
  }

  /// 初始化客户端
  void _initClients() {
    _webdavClient?.dispose();
    _webdavClient = null;
    _localBackup = null;

    if (!_config.enabled) return;

    if (_config.provider == SyncProvider.webdav && _config.isValid) {
      _webdavClient = WebDavClient(
        baseUrl: _config.webdavUrl!,
        username: _config.webdavUsername!,
        password: _config.webdavPassword!,
      );
    } else if (_config.provider == SyncProvider.localBackup && 
               _config.localBackupPath != null) {
      _localBackup = LocalBackup(backupPath: _config.localBackupPath!);
    }
  }

  /// 测试连接
  Future<bool> testConnection() async {
    if (_config.provider == SyncProvider.webdav && _webdavClient != null) {
      return await _webdavClient!.testConnection();
    } else if (_config.provider == SyncProvider.localBackup && _localBackup != null) {
      await _localBackup!.ensureBackupDir();
      return true;
    }
    return false;
  }

  /// 同步单个文件
  Future<SyncResult> syncFile(String fileName, String content) async {
    if (!_config.enabled || !_config.isValid) {
      return SyncResult.error('同步未启用或配置无效');
    }

    _setStatus(SyncStatus.syncing);

    try {
      bool success = false;
      
      if (_config.provider == SyncProvider.webdav && _webdavClient != null) {
        // 确保远程目录存在
        await _webdavClient!.createDirectory(_config.remotePath!);
        final remotePath = '/';
        success = await _webdavClient!.uploadFile(remotePath, content);
      } else if (_config.provider == SyncProvider.localBackup && _localBackup != null) {
        success = await _localBackup!.backupFile(fileName, content);
      }

      final result = success 
          ? SyncResult.success(message: '文件已同步', uploadedCount: 1)
          : SyncResult.error('同步失败');

      _history.add(result);
      _setStatus(success ? SyncStatus.success : SyncStatus.error);
      onSyncCompleted?.call(result);
      
      return result;
    } catch (e) {
      final result = SyncResult.error('同步出错: ');
      _history.add(result);
      _setStatus(SyncStatus.error);
      onSyncCompleted?.call(result);
      return result;
    }
  }

  /// 从云端下载文件
  Future<String?> downloadFile(String fileName) async {
    if (!_config.enabled || !_config.isValid) return null;

    try {
      if (_config.provider == SyncProvider.webdav && _webdavClient != null) {
        final remotePath = '/';
        return await _webdavClient!.downloadFile(remotePath);
      } else if (_config.provider == SyncProvider.localBackup && _localBackup != null) {
        return await _localBackup!.restoreFile(fileName);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// 列出云端文件
  Future<List<String>> listRemoteFiles() async {
    if (!_config.enabled || !_config.isValid) return [];

    try {
      if (_config.provider == SyncProvider.webdav && _webdavClient != null) {
        return await _webdavClient!.listDirectory(_config.remotePath!);
      } else if (_config.provider == SyncProvider.localBackup && _localBackup != null) {
        return await _localBackup!.listBackups();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  /// 启动自动同步
  void startAutoSync() {
    stopAutoSync();
    if (!_config.enabled || _config.autoSyncIntervalMinutes <= 0) return;

    _autoSyncTimer = Timer.periodic(
      Duration(minutes: _config.autoSyncIntervalMinutes),
      (_) {
        // 自动同步逻辑由外部触发
      },
    );
  }

  /// 停止自动同步
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  void _setStatus(SyncStatus newStatus) {
    _status = newStatus;
    onStatusChanged?.call(newStatus);
  }

  /// 释放资源
  void dispose() {
    stopAutoSync();
    _webdavClient?.dispose();
  }
}
