// File Path: sreerajp_authenticator/lib/providers/theme_provider.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 September 25
// Description: A provider to manage and persist theme settings (light, dark, system) using SharedPreferences.

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentKey = 'accent_color';
  ThemeMode _themeMode = ThemeMode.system;
  AppAccent _accent = AppAccent.blue;

  ThemeMode get themeMode => _themeMode;
  AppAccent get accent => _accent;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _accent = AppAccent.fromName(prefs.getString(_accentKey));
    notifyListeners();
  }

  /// Read the saved theme again, after all app data was deleted.
  Future<void> reload() => _loadTheme();

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setAccent(AppAccent accent) async {
    _accent = accent;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentKey, accent.name);
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}
