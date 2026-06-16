/// 云同步配置
class SyncConfig {
  final bool enabled;
  final SyncProvider provider;
  final String? webdavUrl;
  final String? webdavUsername;
  final String? webdavPassword;
  final String? remotePath;
  final int autoSyncIntervalMinutes;
  final bool syncOnSave;
  final String? localBackupPath;

  const SyncConfig({
    this.enabled = false,
    this.provider = SyncProvider.webdav,
    this.webdavUrl,
    this.webdavUsername,
    this.webdavPassword,
    this.remotePath = '/markdown',
    this.autoSyncIntervalMinutes = 5,
    this.syncOnSave = true,
    this.localBackupPath,
  });

  SyncConfig copyWith({
    bool? enabled,
    SyncProvider? provider,
    String? webdavUrl,
    String? webdavUsername,
    String? webdavPassword,
    String? remotePath,
    int? autoSyncIntervalMinutes,
    bool? syncOnSave,
    String? localBackupPath,
  }) {
    return SyncConfig(
      enabled: enabled ?? this.enabled,
      provider: provider ?? this.provider,
      webdavUrl: webdavUrl ?? this.webdavUrl,
      webdavUsername: webdavUsername ?? this.webdavUsername,
      webdavPassword: webdavPassword ?? this.webdavPassword,
      remotePath: remotePath ?? this.remotePath,
      autoSyncIntervalMinutes: autoSyncIntervalMinutes ?? this.autoSyncIntervalMinutes,
      syncOnSave: syncOnSave ?? this.syncOnSave,
      localBackupPath: localBackupPath ?? this.localBackupPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'provider': provider.name,
    'webdavUrl': webdavUrl,
    'webdavUsername': webdavUsername,
    'webdavPassword': webdavPassword,
    'remotePath': remotePath,
    'autoSyncIntervalMinutes': autoSyncIntervalMinutes,
    'syncOnSave': syncOnSave,
    'localBackupPath': localBackupPath,
  };

  factory SyncConfig.fromJson(Map<String, dynamic> json) {
    return SyncConfig(
      enabled: json['enabled'] as bool? ?? false,
      provider: SyncProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => SyncProvider.webdav,
      ),
      webdavUrl: json['webdavUrl'] as String?,
      webdavUsername: json['webdavUsername'] as String?,
      webdavPassword: json['webdavPassword'] as String?,
      remotePath: json['remotePath'] as String? ?? '/markdown',
      autoSyncIntervalMinutes: json['autoSyncIntervalMinutes'] as int? ?? 5,
      syncOnSave: json['syncOnSave'] as bool? ?? true,
      localBackupPath: json['localBackupPath'] as String?,
    );
  }

  bool get isValid {
    if (!enabled) return true;
    if (provider == SyncProvider.webdav) {
      return webdavUrl != null && 
             webdavUrl!.isNotEmpty &&
             webdavUsername != null && 
             webdavUsername!.isNotEmpty &&
             webdavPassword != null && 
             webdavPassword!.isNotEmpty;
    }
    if (provider == SyncProvider.localBackup) {
      return localBackupPath != null && localBackupPath!.isNotEmpty;
    }
    return false;
  }
}

enum SyncProvider {
  webdav,
  localBackup,
}
