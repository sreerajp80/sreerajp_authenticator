import 'dart:convert';
import 'dart:io';

/// The template language and the other declared languages
/// (docs/PROJECT_PROFILE.md §4).
const String templateLocale = 'en';
const List<String> otherLocales = <String>['ml', 'sa'];
const List<String> allLocales = <String>[templateLocale, ...otherLocales];

/// All entries of `lib/l10n/app_<code>.arb`, metadata included.
Map<String, dynamic> readArb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

/// Only the translatable string entries (no `@` metadata keys).
Map<String, String> arbStrings(String code) => {
  for (final e in readArb(code).entries)
    if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
};

/// `{name}` placeholders used in an ARB value.
Set<String> placeholdersIn(String value) =>
    RegExp(r'\{(\w+)\}').allMatches(value).map((m) => m.group(1)!).toSet();

Map<String, dynamic> readAppConfig() =>
    jsonDecode(File('assets/config/app_config.json').readAsStringSync())
        as Map<String, dynamic>;
