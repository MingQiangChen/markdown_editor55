import 'dart:convert';
import 'package:flutter/material.dart';

/// Custom theme configuration
class CustomTheme {
  final String name;
  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color accentColor;
  final Color errorColor;
  final bool isDark;

  const CustomTheme({
    required this.name,
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.accentColor,
    required this.errorColor,
    this.isDark = false,
  });

  /// Create a ThemeData from this custom theme
  ThemeData toThemeData() {
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: isDark ? Colors.black : Colors.white,
      secondary: accentColor,
      onSecondary: isDark ? Colors.black : Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: textColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'primaryColor': primaryColor.toARGB32(),
    'backgroundColor': backgroundColor.toARGB32(),
    'surfaceColor': surfaceColor.toARGB32(),
    'textColor': textColor.toARGB32(),
    'accentColor': accentColor.toARGB32(),
    'errorColor': errorColor.toARGB32(),
    'isDark': isDark,
  };

  /// Create from JSON
  factory CustomTheme.fromJson(Map<String, dynamic> json) => CustomTheme(
    name: json['name'] as String,
    primaryColor: Color(json['primaryColor'] as int),
    backgroundColor: Color(json['backgroundColor'] as int),
    surfaceColor: Color(json['surfaceColor'] as int),
    textColor: Color(json['textColor'] as int),
    accentColor: Color(json['accentColor'] as int),
    errorColor: Color(json['errorColor'] as int),
    isDark: json['isDark'] as bool? ?? false,
  );

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory CustomTheme.fromJsonString(String jsonString) =>
      CustomTheme.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  /// Predefined themes
  static const ocean = CustomTheme(
    name: 'Ocean',
    primaryColor: Color(0xFF0077B6),
    backgroundColor: Color(0xFFF8F9FA),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF212529),
    accentColor: Color(0xFF00B4D8),
    errorColor: Color(0xFFDC3545),
    isDark: false,
  );

  static const forest = CustomTheme(
    name: 'Forest',
    primaryColor: Color(0xFF2D6A4F),
    backgroundColor: Color(0xFFF1FAEE),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF1B4332),
    accentColor: Color(0xFF52B788),
    errorColor: Color(0xFFD62828),
    isDark: false,
  );

  static const sunset = CustomTheme(
    name: 'Sunset',
    primaryColor: Color(0xFFFF6B6B),
    backgroundColor: Color(0xFFFFF5F5),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF2D3436),
    accentColor: Color(0xFFFFA502),
    errorColor: Color(0xFFD63031),
    isDark: false,
  );

  static const midnight = CustomTheme(
    name: 'Midnight',
    primaryColor: Color(0xFF6C63FF),
    backgroundColor: Color(0xFF1A1A2E),
    surfaceColor: Color(0xFF16213E),
    textColor: Color(0xFFEAEAEA),
    accentColor: Color(0xFF0F3460),
    errorColor: Color(0xFFE94560),
    isDark: true,
  );

  static const coffee = CustomTheme(
    name: 'Coffee',
    primaryColor: Color(0xFF6F4E37),
    backgroundColor: Color(0xFFF5F5DC),
    surfaceColor: Color(0xFFFFF8DC),
    textColor: Color(0xFF3E2723),
    accentColor: Color(0xFFA0522D),
    errorColor: Color(0xFFB71C1C),
    isDark: false,
  );

  static const List<CustomTheme> predefined = [
    ocean,
    forest,
    sunset,
    midnight,
    coffee,
  ];
}