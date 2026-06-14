import 'settings_base.dart';

SettingsStore createSettingsStore() => _MemorySettingsStore();

class _MemorySettingsStore implements SettingsStore {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}
