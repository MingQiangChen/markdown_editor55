/// 同步状态
enum SyncStatus {
  idle,           // 空闲
  syncing,        // 同步中
  success,        // 同步成功
  error,          // 同步失败
  disconnected,   // 未连接
}

/// 同步结果
class SyncResult {
  final bool success;
  final String? message;
  final int? uploadedCount;
  final int? downloadedCount;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    this.message,
    this.uploadedCount,
    this.downloadedCount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SyncResult.success({
    String? message,
    int? uploadedCount,
    int? downloadedCount,
  }) {
    return SyncResult(
      success: true,
      message: message ?? '同步成功',
      uploadedCount: uploadedCount,
      downloadedCount: downloadedCount,
      timestamp: DateTime.now(),
    );
  }

  factory SyncResult.error(String message) {
    return SyncResult(
      success: false,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}

/// 同步历史记录
class SyncHistory {
  final List<SyncResult> history;
  final int maxHistorySize;

  SyncHistory({
    List<SyncResult>? history,
    this.maxHistorySize = 50,
  }) : history = history ?? [];

  void add(SyncResult result) {
    history.insert(0, result);
    if (history.length > maxHistorySize) {
      history.removeLast();
    }
  }

  SyncResult? get lastSync => history.isEmpty ? null : history.first;

  int get successCount => history.where((r) => r.success).length;
  int get errorCount => history.where((r) => !r.success).length;

  DateTime? get lastSyncTime => lastSync?.timestamp;

  Map<String, dynamic> toJson() => {
    'history': history.map((r) => {
      'success': r.success,
      'message': r.message,
      'uploadedCount': r.uploadedCount,
      'downloadedCount': r.downloadedCount,
      'timestamp': r.timestamp.toIso8601String(),
    }).toList(),
  };

  factory SyncHistory.fromJson(Map<String, dynamic> json) {
    final historyList = (json['history'] as List?)?.map((r) {
      return SyncResult(
        success: r['success'] as bool,
        message: r['message'] as String?,
        uploadedCount: r['uploadedCount'] as int?,
        downloadedCount: r['downloadedCount'] as int?,
        timestamp: DateTime.parse(r['timestamp'] as String),
      );
    }).toList() ?? [];
    
    return SyncHistory(history: historyList);
  }
}
