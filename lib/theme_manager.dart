import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal(); // 靜態單例實例
  factory ThemeManager() => _instance; // 工廠建構子，返回單例實例
  ThemeManager._internal(); // 私有建構子

  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier(ThemeMode.system); // 使用 ValueNotifier 管理主題模式

  static const String _themeKey = 'app_theme_mode'; // SharedPreferences Key

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0; // 預設為 System (index 0)
    themeModeNotifier.value = ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
}
