import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spongemock_flutter/constants/preference_keys.dart';

class AppTheme {
  final BuildContext context;
  final _defaultTheme = ThemeMode.dark;
  final _sharedPreferences = SharedPreferences.getInstance();
  late final NeumorphicThemeInherited? _neomorphTheme;

  AppTheme(this.context) {
    _neomorphTheme = NeumorphicTheme.of(context);
  }

  NeumorphicThemeInherited? get neomorphTheme => _neomorphTheme;

  Future<void> setTheme(ThemeMode mode) {
    _neomorphTheme?.themeMode = mode;
    return _saveThemePref(mode);
  }

  Future<void> setThemeFromPref() async {
    bool themePrefIsDarkTheme =
        await _getThemePrefIsDarkTheme() ?? _defaultThemeIsDark();
    setTheme(themePrefIsDarkTheme ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get theme => _themeModeFromBool(
        _neomorphTheme?.isUsingDark ?? _defaultThemeIsDark(),
      );

  bool get isDarkTheme => _themeIsDarkTheme(theme);

  bool _defaultThemeIsDark() {
    return _themeIsDarkTheme(_defaultTheme);
  }

  bool _themeIsDarkTheme(ThemeMode theme) {
    return theme == ThemeMode.dark;
  }

  ThemeMode _themeModeFromBool(bool isDarkTheme) {
    return isDarkTheme ? ThemeMode.dark : ThemeMode.light;
  }

  Future<bool?> _getThemePrefIsDarkTheme() async {
    return _sharedPreferences.then(
      (prefs) => prefs.getBool(PreferenceKeys.IS_DARK_THEME),
    );
  }

  Future<bool> _saveThemePref(ThemeMode theme) async {
    bool isDarkTheme = _themeIsDarkTheme(theme);
    return _sharedPreferences.then(
      (prefs) => prefs.setBool(
        PreferenceKeys.IS_DARK_THEME,
        isDarkTheme,
      ),
    );
  }
}
