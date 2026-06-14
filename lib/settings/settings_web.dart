// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';

import 'dart:html' as html;

import 'settings_base.dart';

SettingsStore createSettingsStore() => _WebSettingsStore();

class _WebSettingsStore implements SettingsStore {
  static const _settingsKey = 'qlaw_markdown.settings';

  @override
  Future<AppSettings> loadSettings() async {
    try {
      final raw = html.window.localStorage[_settingsKey];
      if (raw == null) return const AppSettings();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      html.window.localStorage[_settingsKey] = jsonEncode(settings.toJson());
    } catch (_) {
      // Silently ignore
    }
  }
}
