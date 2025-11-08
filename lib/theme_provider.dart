// Updated theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  // ignore: unused_field
  static const String _useMaterial3Key = 'use_material3';

  // Define available accent colors
  static const List<Color> accentColors = [
    Colors.deepOrange,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.deepPurple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
  ];

  // Build light theme
  static ThemeData buildLightTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
      ),
      primaryColor: accentColor,
      appBarTheme: AppBarTheme(
        backgroundColor: accentColor.withAlpha(100),
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
        ),
      ),
    );
  }

  // Build dark theme
  static ThemeData buildDarkTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
      ),
      primaryColor: accentColor,
      appBarTheme: AppBarTheme(
        backgroundColor: accentColor.withAlpha(50),
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
        ),
      ),
    );
  }
}

// Theme provider using ChangeNotifier
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = Colors.deepPurple;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  ThemeData get lightTheme => AppTheme.buildLightTheme(_accentColor);
  ThemeData get darkTheme => AppTheme.buildDarkTheme(_accentColor);

  // Load saved preferences
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeIndex = prefs.getInt(AppTheme._themeModeKey) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    final accentColorValue = prefs.getInt(AppTheme._accentColorKey) ?? Colors.deepOrange.value;
    _accentColor = Color(accentColorValue);
    
    notifyListeners();
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppTheme._themeModeKey, mode.index);
    notifyListeners();
  }

  // Set accent color
  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppTheme._accentColorKey, color.value);
    notifyListeners();
  }
}
