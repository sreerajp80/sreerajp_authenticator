import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';

/// Single source of truth for the app language (engineering standard §8.4).
///
/// A `null` [locale] means "follow the system"; [MaterialApp] then resolves
/// the device locale against the declared languages.
class LocaleProvider extends ChangeNotifier {
  static const String prefKey = 'app_language';
  static const String systemValue = 'system';

  /// The declared language codes, template first.
  static final List<String> supported = LocaleConfig.supportedLocales
      .map((l) => l.languageCode)
      .toList(growable: false);

  final SharedPreferences _prefs;
  Locale? _locale;

  /// Reads the saved choice synchronously, so the app can build its first
  /// frame in the right language (create it before `runApp`).
  LocaleProvider(this._prefs) {
    _readSaved();
  }

  void _readSaved() {
    final saved = _prefs.getString(prefKey) ?? systemValue;
    _locale = supported.contains(saved) ? Locale(saved) : null;
  }

  /// Read the saved choice again, after all app data was deleted.
  void reload() {
    _readSaved();
    notifyListeners();
  }

  /// `null` => follow the system locale.
  Locale? get locale => _locale;

  bool get isSystem => _locale == null;

  /// The saved value: [systemValue] or a declared language code.
  String get selection => _locale?.languageCode ?? systemValue;

  Future<void> setLanguage(String value) async {
    if (value != systemValue && !supported.contains(value)) return;
    _locale = value == systemValue ? null : Locale(value);
    await _prefs.setString(prefKey, value);
    notifyListeners();
  }
}
