// `characters` is re-exported by material_ui (via package:flutter/widgets.dart).
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'l10n_test_helpers.dart';

/// Short UI text stays short in every language (engineering standard §8.6,
/// language pack §5). Characters are counted as grapheme clusters.
void main() {
  const shortPrefixes = ['action', 'label', 'title', 'tab', 'nav', 'tooltip'];
  const limits = {'en': 20, 'ml': 22, 'sa': 22};

  test('short-prefix keys fit the length budget', () {
    final problems = <String>[];
    for (final locale in allLocales) {
      final limit = limits[locale]!;
      for (final entry in arbStrings(locale).entries) {
        if (!shortPrefixes.any(entry.key.startsWith)) continue;
        // Placeholders are filled at run time; count the fixed text only.
        final fixed = entry.value.replaceAll(RegExp(r'\{\w+\}'), '');
        final length = fixed.characters.length;
        if (length > limit) {
          problems.add(
            'app_$locale.arb: ${entry.key} is $length > $limit: ${entry.value}',
          );
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('every key uses a known prefix or a fixed guideline name', () {
    const longPrefixes = [
      'desc',
      'help',
      'empty',
      'error',
      'body',
      'aboutDetail',
    ];
    const fixedNames = {'madeWithLove', 'madeWithLoveA11y'};
    final bad = [
      for (final key in arbStrings(templateLocale).keys)
        if (!fixedNames.contains(key) &&
            ![...shortPrefixes, ...longPrefixes].any(key.startsWith))
          key,
    ];
    expect(bad, isEmpty, reason: 'keys without a category prefix: $bad');
  });
}
