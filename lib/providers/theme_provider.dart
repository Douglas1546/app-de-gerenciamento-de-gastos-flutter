import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' show Locale;

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String? _localeCode;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  Locale? get locale {
    if (_localeCode == null || _localeCode!.isEmpty) return null;
    final code = _localeCode!;
    if (!code.contains('_')) {
      return Locale(code);
    }
    final parts = code.split('_');
    final lang = parts[0];
    final second = parts.length > 1 ? parts[1] : null;
    final third = parts.length > 2 ? parts[2] : null;
    if (second == 'Hans' || second == 'Hant') {
      // Chinese with script code
      return Locale.fromSubtags(
        languageCode: lang,
        scriptCode: second,
        countryCode: third,
      );
    }
    return Locale(lang, second);
  }

  void setDark(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _persist();
  }

  void setLocaleCode(String? code) {
    _localeCode = code;
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
    _localeCode = prefs.getString('localeCode');
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);
    if (_localeCode == null || _localeCode!.isEmpty) {
      await prefs.remove('localeCode');
    } else {
      await prefs.setString('localeCode', _localeCode!);
    }
  }
}
