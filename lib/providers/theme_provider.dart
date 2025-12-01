import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setDark(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _persist();
  }

  Future<void> loadPersistedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool('isDark');
    if (stored != null) {
      _themeMode = stored ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);
  }
}
