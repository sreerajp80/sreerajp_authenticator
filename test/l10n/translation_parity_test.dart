import 'package:flutter_test/flutter_test.dart';

import 'l10n_test_helpers.dart';

/// Translation parity (engineering standard §8.7): every key exists in every
/// declared language, with a real translation.
void main() {
  /// Keys allowed to match the template: brand names and symbols only.
  const sameAsTemplateAllowed = <String>{
    // Pure pattern "{label}: {value}"; the words come from other keys.
    'labelMaskedValue',
    // "{fps} FPS": a number and a unit abbreviation used in every language.
    'labelFps',
    // Feature chips that are only technical names (same in every language).
    'descFeatures06', // SHA-1/256/512
    'descFeatures33', // AES-256-GCM
    'descFeatures34', // Android Keystore
    'descFeatures48', // FLAG_SECURE
  };

  group('ARB parity', () {
    test('every ARB file has the same keys as the template', () {
      final base = arbStrings(templateLocale).keys.toSet();
      for (final locale in otherLocales) {
        final other = arbStrings(locale).keys.toSet();
        expect(
          other.difference(base),
          isEmpty,
          reason: 'extra keys in $locale',
        );
        expect(
          base.difference(other),
          isEmpty,
          reason: 'missing keys in $locale',
        );
      }
    });

    test('every ARB file declares its own locale', () {
      for (final locale in allLocales) {
        expect(readArb(locale)['@@locale'], locale);
      }
    });

    test('every template key has an @key description', () {
      final arb = readArb(templateLocale);
      final missing = [
        for (final key in arbStrings(templateLocale).keys)
          if (arb['@$key'] is! Map ||
              ((arb['@$key'] as Map)['description'] as String? ?? '')
                  .trim()
                  .isEmpty)
            key,
      ];
      expect(missing, isEmpty, reason: 'keys without a description: $missing');
    });

    test('no translation is a copy of the template value', () {
      final base = arbStrings(templateLocale);
      final problems = <String>[];
      for (final locale in otherLocales) {
        for (final entry in arbStrings(locale).entries) {
          if (sameAsTemplateAllowed.contains(entry.key)) continue;
          if (entry.value.trim().isNotEmpty && entry.value == base[entry.key]) {
            problems.add('app_$locale.arb: ${entry.key} matches the template');
          }
        }
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('placeholders match the template in every language', () {
      final base = arbStrings(templateLocale);
      final problems = <String>[];
      for (final locale in otherLocales) {
        for (final entry in arbStrings(locale).entries) {
          final expected = placeholdersIn(base[entry.key] ?? '');
          final actual = placeholdersIn(entry.value);
          if (expected.length != actual.length ||
              !expected.containsAll(actual)) {
            problems.add(
              'app_$locale.arb: ${entry.key} has $actual, '
              'template has $expected',
            );
          }
        }
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('the About badge is complete in every language', () {
      final heartEmoji = RegExp('❤|♥|\u{1F496}|\u{1F497}|\u{1F49C}');
      for (final locale in allLocales) {
        final strings = arbStrings(locale);
        final text = strings['madeWithLove'];
        final a11y = strings['madeWithLoveA11y'];
        expect(text, isNotNull, reason: '$locale: madeWithLove missing');
        expect(a11y, isNotNull, reason: '$locale: madeWithLoveA11y missing');
        expect(
          '{heart}'.allMatches(text!).length,
          1,
          reason: '$locale: madeWithLove needs exactly one {heart}',
        );
        expect(heartEmoji.hasMatch(text), isFalse, reason: '$locale: emoji');
        expect(heartEmoji.hasMatch(a11y!), isFalse, reason: '$locale: emoji');
        expect(a11y.contains('{heart}'), isFalse, reason: '$locale: a11y');
      }
    });
  });

  group('app_config.json parity', () {
    test('every display field has a value for every declared language', () {
      final config = readAppConfig();
      final problems = <String>[];

      void check(String path, Object? value) {
        if (value is! Map) {
          problems.add('$path is not a locale map');
          return;
        }
        for (final locale in allLocales) {
          final text = value[locale];
          if (text is! String || text.trim().isEmpty) {
            problems.add('$path has no "$locale" value');
          }
        }
      }

      check('appName', config['appName']);
      check('description', config['description']);
      // Technical values (addresses, URLs) may stay plain strings.
      const technical = {'email', 'website', 'privacyPolicy'};
      final details = config['details'] as Map<String, dynamic>;
      for (final entry in details.entries) {
        if (technical.contains(entry.key)) continue;
        check('details.${entry.key}', entry.value);
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('every details key has an aboutDetail<Key> label in ARB', () {
      final details = readAppConfig()['details'] as Map<String, dynamic>;
      final strings = arbStrings(templateLocale);
      for (final key in details.keys) {
        final label = 'aboutDetail${key[0].toUpperCase()}${key.substring(1)}';
        expect(strings.containsKey(label), isTrue, reason: 'missing $label');
      }
    });
  });
}
