import 'package:flutter/material.dart';

enum EditorViewMode { editor, split, preview }

class AppSettings {
  final double fontSize;
  final String fontFamily;
  final int tabSize;
  final EditorViewMode defaultViewMode;
  final bool wordWrap;
  final int autoSaveIntervalMs;

  const AppSettings({
    this.fontSize = 14,
    this.fontFamily = '',
    this.tabSize = 2,
    this.defaultViewMode = EditorViewMode.split,
    this.wordWrap = true,
    this.autoSaveIntervalMs = 500,
  });

  AppSettings copyWith({
    double? fontSize,
    String? fontFamily,
    int? tabSize,
    EditorViewMode? defaultViewMode,
    bool? wordWrap,
    int? autoSaveIntervalMs,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      tabSize: tabSize ?? this.tabSize,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      wordWrap: wordWrap ?? this.wordWrap,
      autoSaveIntervalMs: autoSaveIntervalMs ?? this.autoSaveIntervalMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'fontSize': fontSize,
    'fontFamily': fontFamily,
    'tabSize': tabSize,
    'defaultViewMode': defaultViewMode.name,
    'wordWrap': wordWrap,
    'autoSaveIntervalMs': autoSaveIntervalMs,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14,
      fontFamily: json['fontFamily'] as String? ?? '',
      tabSize: json['tabSize'] as int? ?? 2,
      defaultViewMode: EditorViewMode.values.firstWhere(
        (m) => m.name == json['defaultViewMode'],
        orElse: () => EditorViewMode.split,
      ),
      wordWrap: json['wordWrap'] as bool? ?? true,
      autoSaveIntervalMs: json['autoSaveIntervalMs'] as int? ?? 500,
    );
  }

  TextStyle get editorTextStyle => TextStyle(
    fontSize: fontSize,
    fontFamily: fontFamily.isEmpty ? null : fontFamily,
    height: 1.5,
  );
}

abstract class SettingsStore {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
}
