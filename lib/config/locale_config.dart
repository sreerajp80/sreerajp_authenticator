import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/l10n/fallback_localizations.dart';

/// Declared languages and the localization wiring (engineering standard §8).
///
/// Resolution order (§8.4): the language saved in the app, else the system
/// language when it is declared, else English (the template language).
class LocaleConfig {
  LocaleConfig._();

  static const String template = 'en';

  /// The declared languages from docs/PROJECT_PROFILE.md §4, template first.
  static const List<Locale> supportedLocales =
      AppLocalizations.supportedLocales;

  /// Delegates for [MaterialApp.localizationsDelegates].
  ///
  /// Use this, not the generated `AppLocalizations.localizationsDelegates`:
  /// that list names the old SDK Material/Cupertino delegates, whose types do
  /// not match the material_ui / cupertino_ui widgets. The Sanskrit fallbacks
  /// come before the global delegates so they win for Locale('sa').
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    FallbackMaterialLocalizationsDelegate(),
    FallbackCupertinoLocalizationsDelegate(),
    FallbackWidgetsLocalizationsDelegate(),
    ...GlobalMaterialLocalizations.delegates,
  ];

  /// Each language's own name (endonym). These are never translated
  /// (standard §8.4, language pack §3).
  static const Map<String, String> endonyms = {
    'en': 'English',
    'ml': 'മലയാളം',
    'sa': 'संस्कृतम्',
  };

  /// Maps a device locale onto a declared locale; anything else is English.
  static Locale resolve(Locale? deviceLocale, [Iterable<Locale>? supported]) {
    final code = deviceLocale?.languageCode;
    for (final locale in supported ?? supportedLocales) {
      if (locale.languageCode == code) return locale;
    }
    return const Locale(template);
  }

  /// [MaterialApp.localeResolutionCallback].
  static Locale localeResolution(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) => resolve(deviceLocale, supported);

  /// Locale to hand to `intl` (standard §8.3.2). Languages with no CLDR data
  /// (Sanskrit) are formatted with English patterns, never Hindi, while the UI
  /// text stays translated.
  static String formattingLocale(Locale locale) {
    final full = Intl.canonicalizedLocale(locale.toString());
    if (DateFormat.localeExists(full)) return full;
    if (DateFormat.localeExists(locale.languageCode)) {
      return locale.languageCode;
    }
    return template;
  }
}
