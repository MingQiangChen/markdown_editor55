import 'dart:convert';
import 'dart:io';

import 'settings_base.dart';

SettingsStore createSettingsStore() => _FileSettingsStore();

class _FileSettingsStore implements SettingsStore {
  File get _settingsFile {
    final root =
        Platform.environment['APPDATA'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    final directory = Directory('QLawMarkdown');
    return File('settings.json');
  }

  @override
  Future<AppSettings> loadSettings() async {
    try {
      final file = _settingsFile;
      if (!await file.exists()) {
        return const AppSettings();
      }
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final file = _settingsFile;
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(settings.toJson()));
    } catch (_) {
      // Silently ignore save errors
    }
  }
}
