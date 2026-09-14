import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class ReaderSettingsProvider extends ChangeNotifier {
  static const String _keyFontSize = 'reader_font_size';
  static const String _keyThemeMode = 'reader_theme_mode';
  static const String _keyLineHeight = 'reader_line_height';

  double _fontSize = 18.0;
  ReaderThemeMode _themeMode = ReaderThemeMode.dark;
  double _lineHeight = 1.8;

  double get fontSize => _fontSize;
  ReaderThemeMode get themeMode => _themeMode;
  double get lineHeight => _lineHeight;

  ReaderSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_keyFontSize) ?? 18.0;
    _lineHeight = prefs.getDouble(_keyLineHeight) ?? 1.8;
    final themeIndex = prefs.getInt(_keyThemeMode);
    if (themeIndex != null && themeIndex < ReaderThemeMode.values.length) {
      _themeMode = ReaderThemeMode.values[themeIndex];
    }
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(14.0, 30.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, _fontSize);
  }

  Future<void> setThemeMode(ReaderThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
  }

  Future<void> setLineHeight(double height) async {
    _lineHeight = height.clamp(1.4, 2.4);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLineHeight, _lineHeight);
  }

  Color get backgroundColor {
    switch (_themeMode) {
      case ReaderThemeMode.light:
        return AppTheme.readerLightBg;
      case ReaderThemeMode.sepia:
        return AppTheme.readerSepiaBg;
      case ReaderThemeMode.dark:
        return AppTheme.readerDarkBg;
    }
  }

  Color get textColor {
    switch (_themeMode) {
      case ReaderThemeMode.light:
        return AppTheme.readerLightText;
      case ReaderThemeMode.sepia:
        return AppTheme.readerSepiaText;
      case ReaderThemeMode.dark:
        return AppTheme.readerDarkText;
    }
  }
}
