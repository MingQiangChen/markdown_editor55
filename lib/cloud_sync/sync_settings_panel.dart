import 'package:flutter/material.dart';
import 'cloud_sync.dart';
import 'package:file_picker/file_picker.dart';

/// 云同步配置面板
class SyncSettingsPanel extends StatefulWidget {
  final SyncConfig config;
  final ValueChanged<SyncConfig> onConfigChanged;
  final CloudSyncService syncService;
  final VoidCallback onClose;

  const SyncSettingsPanel({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.syncService,
    required this.onClose,
  });

  @override
  State<SyncSettingsPanel> createState() => _SyncSettingsPanelState();
}

class _SyncSettingsPanelState extends State<SyncSettingsPanel> {
  late SyncConfig _config;
  late TextEditingController _webdavUrlController;
  late TextEditingController _webdavUsernameController;
  late TextEditingController _webdavPasswordController;
  late TextEditingController _remotePathController;
  late TextEditingController _localBackupPathController;
  bool _obscurePassword = true;
  bool _isTesting = false;
  bool? _testResult;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
    _webdavUrlController = TextEditingController(text: _config.webdavUrl ?? '');
    _webdavUsernameController = TextEditingController(text: _config.webdavUsername ?? '');
    _webdavPasswordController = TextEditingController(text: _config.webdavPassword ?? '');
    _remotePathController = TextEditingController(text: _config.remotePath ?? '/markdown');
    _localBackupPathController = TextEditingController(text: _config.localBackupPath ?? '');
  }

  @override
  void dispose() {
    _webdavUrlController.dispose();
    _webdavUsernameController.dispose();
    _webdavPasswordController.dispose();
    _remotePathController.dispose();
    _localBackupPathController.dispose();
    super.dispose();
  }

  void _updateConfig() {
    widget.onConfigChanged(_config);
    widget.syncService.updateConfig(_config);
  }

  Future<void> _pickBackupPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择备份目录',
      initialDirectory: _localBackupPathController.text.isEmpty ? null : _localBackupPathController.text,
      lockParentWindow: true,
    );
    
    if (selectedDirectory != null) {
      setState(() {
        _localBackupPathController.text = selectedDirectory;
        _config = _config.copyWith(localBackupPath: selectedDirectory);
        _updateConfig();
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final result = await widget.syncService.testConnection();
    
    if (mounted) {
      setState(() {
        _isTesting = false;
        _testResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('云同步', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                tooltip: '关闭',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 启用同步
          SwitchListTile(
            title: const Text('启用云同步'),
            subtitle: const Text('自动同步文档到云端'),
            value: _config.enabled,
            onChanged: (value) {
              setState(() => _config = _config.copyWith(enabled: value));
              _updateConfig();
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),

          if (_config.enabled) ...[
            // 同步提供商
            Text('同步方式', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            SegmentedButton<SyncProvider>(
              segments: const [
                ButtonSegment(value: SyncProvider.webdav, label: Text('WebDAV')),
                ButtonSegment(value: SyncProvider.localBackup, label: Text('本地备份')),
              ],
              selected: {_config.provider},
              onSelectionChanged: (values) {
                setState(() => _config = _config.copyWith(provider: values.first));
                _updateConfig();
              },
            ),
            const SizedBox(height: 16),

            if (_config.provider == SyncProvider.webdav) ..._buildWebDavSettings(),
            if (_config.provider == SyncProvider.localBackup) ..._buildLocalBackupSettings(),
            
            const SizedBox(height: 16),
            
            // 同步状态
            _buildSyncStatus(),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildWebDavSettings() {
    return [
      Text('WebDAV 配置', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 8),
      
      // 服务器地址
      TextField(
        controller: _webdavUrlController,
        decoration: const InputDecoration(
          labelText: '服务器地址',
          hintText: 'https://dav.jianguoyun.com/dav/',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (value) {
          _config = _config.copyWith(webdavUrl: value);
          _updateConfig();
        },
      ),
      const SizedBox(height: 12),

      // 用户名
      TextField(
        controller: _webdavUsernameController,
        decoration: const InputDecoration(
          labelText: '用户名',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (value) {
          _config = _config.copyWith(webdavUsername: value);
          _updateConfig();
        },
      ),
      const SizedBox(height: 12),

      // 密码
      TextField(
        controller: _webdavPasswordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: '密码',
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        onChanged: (value) {
          _config = _config.copyWith(webdavPassword: value);
          _updateConfig();
        },
      ),
      const SizedBox(height: 12),

      // 远程路径
      TextField(
        controller: _remotePathController,
        decoration: const InputDecoration(
          labelText: '远程目录',
          hintText: '/markdown',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (value) {
          _config = _config.copyWith(remotePath: value);
          _updateConfig();
        },
      ),
      const SizedBox(height: 12),

      // 测试连接按钮
      SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: _isTesting ? null : _testConnection,
          child: _isTesting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_testResult == null ? '测试连接' : (_testResult! ? '连接成功' : '连接失败')),
        ),
      ),
    ];
  }

  List<Widget> _buildLocalBackupSettings() {
    return [
      Text('本地备份配置', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 8),
      
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _localBackupPathController,
              decoration: const InputDecoration(
                labelText: '备份目录',
                hintText: 'C:\\Users\\xxx\\Documents\\MarkdownBackup',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                _config = _config.copyWith(localBackupPath: value);
                _updateConfig();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: '选择目录',
            onPressed: _pickBackupPath,
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        '文档将备份到指定目录',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }

  Widget _buildSyncStatus() {
    final status = widget.syncService.status;
    final lastSync = widget.syncService.history.lastSyncTime;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(status),
                  style: TextStyle(color: _getStatusColor(status)),
                ),
              ],
            ),
            if (lastSync != null) ...[
              const SizedBox(height: 8),
              Text(
                '上次同步: ${_formatTime(lastSync)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(SyncStatus status) {
    return switch (status) {
      SyncStatus.idle => Icons.cloud_queue,
      SyncStatus.syncing => Icons.sync,
      SyncStatus.success => Icons.cloud_done,
      SyncStatus.error => Icons.cloud_off,
      SyncStatus.disconnected => Icons.cloud_off,
    };
  }

  Color _getStatusColor(SyncStatus status) {
    return switch (status) {
      SyncStatus.idle => Colors.grey,
      SyncStatus.syncing => Colors.blue,
      SyncStatus.success => Colors.green,
      SyncStatus.error => Colors.red,
      SyncStatus.disconnected => Colors.orange,
    };
  }

  String _getStatusText(SyncStatus status) {
    return switch (status) {
      SyncStatus.idle => '空闲',
      SyncStatus.syncing => '同步中...',
      SyncStatus.success => '已同步',
      SyncStatus.error => '同步失败',
      SyncStatus.disconnected => '未连接',
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    return '${time.year}/${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
