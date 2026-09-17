import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class ReaderSettingsProvider extends ChangeNotifier {
  static const String _keyFontSize = 'reader_font_size';
  static const String _keyThemeMode = 'reader_theme_mode';
  static const String _keyLineHeight = 'reader_line_height';
  static const String _keyAppThemeMode = 'app_theme_mode'; // 'dark', 'light', 'system'
  static const String _keyFontFamily = 'reader_font_family';

  double _fontSize = 18.0;
  ReaderThemeMode _themeMode = ReaderThemeMode.dark;
  double _lineHeight = 1.8;
  ThemeMode _appThemeMode = ThemeMode.dark;
  String _readerFontFamily = 'Prompt';

  // Available Thai Fonts
  static const List<String> availableFonts = [
    'Prompt',
    'Sarabun',
    'Mitr',
    'Noto Sans Thai',
    'Chakra Petch',
  ];

  double get fontSize => _fontSize;
  ReaderThemeMode get themeMode => _themeMode;
  double get lineHeight => _lineHeight;
  ThemeMode get appThemeMode => _appThemeMode;
  String get readerFontFamily => _readerFontFamily;

  ReaderSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_keyFontSize) ?? 18.0;
    _lineHeight = prefs.getDouble(_keyLineHeight) ?? 1.8;
    _readerFontFamily = prefs.getString(_keyFontFamily) ?? 'Prompt';

    final themeIndex = prefs.getInt(_keyThemeMode);
    if (themeIndex != null && themeIndex < ReaderThemeMode.values.length) {
      _themeMode = ReaderThemeMode.values[themeIndex];
    }

    final appThemeString = prefs.getString(_keyAppThemeMode);
    if (appThemeString == 'light') {
      _appThemeMode = ThemeMode.light;
    } else if (appThemeString == 'system') {
      _appThemeMode = ThemeMode.system;
    } else {
      _appThemeMode = ThemeMode.dark;
    }

    notifyListeners();
  }

  Future<void> setAppThemeMode(ThemeMode mode) async {
    _appThemeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    String val = 'dark';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.system) val = 'system';
    await prefs.setString(_keyAppThemeMode, val);
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(14.0, 32.0);
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

  Future<void> setReaderFontFamily(String font) async {
    _readerFontFamily = font;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFontFamily, font);
  }

  Future<void> setFontFamily(String font) => setReaderFontFamily(font);

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
      case ReaderThemeMode.cream:
        return AppTheme.readerCreamBg;
      case ReaderThemeMode.dark:
        return AppTheme.readerDarkBg;
      case ReaderThemeMode.night:
        return AppTheme.readerNightBg;
    }
  }

  Color get textColor {
    switch (_themeMode) {
      case ReaderThemeMode.light:
        return AppTheme.readerLightText;
      case ReaderThemeMode.sepia:
        return AppTheme.readerSepiaText;
      case ReaderThemeMode.cream:
        return AppTheme.readerCreamText;
      case ReaderThemeMode.dark:
        return AppTheme.readerDarkText;
      case ReaderThemeMode.night:
        return AppTheme.readerNightText;
    }
  }

  TextStyle getReaderTextStyle({
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    final effectiveFont = fontFamily ?? _readerFontFamily;
    final effectiveSize = fontSize ?? _fontSize;
    final effectiveColor = color ?? textColor;
    final effectiveHeight = height ?? _lineHeight;

    switch (effectiveFont) {
      case 'Sarabun':
        return GoogleFonts.sarabun(
          fontSize: effectiveSize,
          fontWeight: fontWeight,
          color: effectiveColor,
          height: effectiveHeight,
          letterSpacing: letterSpacing ?? 0.2,
        );
      case 'Mitr':
        return GoogleFonts.mitr(
          fontSize: effectiveSize,
          fontWeight: fontWeight,
          color: effectiveColor,
          height: effectiveHeight,
          letterSpacing: letterSpacing ?? 0.2,
        );
      case 'Noto Sans Thai':
        return GoogleFonts.notoSansThai(
          fontSize: effectiveSize,
          fontWeight: fontWeight,
          color: effectiveColor,
          height: effectiveHeight,
          letterSpacing: letterSpacing ?? 0.2,
        );
      case 'Chakra Petch':
        return GoogleFonts.chakraPetch(
          fontSize: effectiveSize,
          fontWeight: fontWeight,
          color: effectiveColor,
          height: effectiveHeight,
          letterSpacing: letterSpacing ?? 0.2,
        );
      case 'Prompt':
      default:
        return GoogleFonts.prompt(
          fontSize: effectiveSize,
          fontWeight: fontWeight,
          color: effectiveColor,
          height: effectiveHeight,
          letterSpacing: letterSpacing ?? 0.2,
        );
    }
  }
}
