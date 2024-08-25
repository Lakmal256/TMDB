import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/theme.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'themePreference';
  late AppThemeMode _currentThemeMode = AppThemeMode.system;

  AppThemeMode get currentThemeMode => _currentThemeMode;

  ThemeManager() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getInt(_themeKey);
    if (savedTheme == null) {
      _currentThemeMode = AppThemeMode.system;
    } else {
      _currentThemeMode = AppThemeMode.values[savedTheme];
    }
    notifyListeners();
  }

  void setTheme(AppThemeMode themeMode) async {
    _currentThemeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  ThemeData get themeData {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return AppTheme.light;
      case AppThemeMode.dark:
        return AppTheme.dark;
      case AppThemeMode.system:
      default:
        return AppTheme.light; // Fallback in case of system mode
    }
  }
}
