import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const supportedLocales = [
  Locale('en', 'GB'),
  Locale('zh', 'Hans'),
  Locale('ru'),
  Locale('ga'),
];

enum AppTheme { system, light, dark, oled }

class SettingsStore extends ChangeNotifier {
  static const _themeKey = 'theme';
  static const _accentColorKey = 'accent_color';
  static const _localeKey = 'locale';

  AppTheme _theme;
  int _accentColor;
  Locale? _locale;

  SettingsStore({
    this._theme = AppTheme.system,
    this._accentColor = 0xFFF3813F,
    this._locale,
  });

  static Future<SettingsStore> load(SharedPreferences prefs) async {
    return SettingsStore(
      theme:
          AppTheme.values.asNameMap()[prefs.getString(_themeKey)] ??
          AppTheme.system,
      accentColor: prefs.getInt(_accentColorKey) ?? 0xFFF3813F,
      locale: _parseLocale(prefs.getString(_localeKey)),
    );
  }

  static String _localeTag(Locale locale) => locale.countryCode == null
      ? locale.languageCode
      : '${locale.languageCode}_${locale.countryCode}';

  static Locale? _parseLocale(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final locale in supportedLocales) {
      if (_localeTag(locale) == raw) return locale;
    }
    return null;
  }

  AppTheme get theme => _theme;
  int get accentColor => _accentColor;
  Locale? get locale => _locale;

  Future<void> setTheme(AppTheme theme, SharedPreferences prefs) async {
    _theme = theme;
    notifyListeners();
    await prefs.setString(_themeKey, theme.name);
  }

  Future<void> setAccentColor(int color, SharedPreferences prefs) async {
    _accentColor = color;
    notifyListeners();
    await prefs.setInt(_accentColorKey, color);
  }

  Future<void> setLocale(Locale? locale, SharedPreferences prefs) async {
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, _localeTag(locale));
    }
  }
}
