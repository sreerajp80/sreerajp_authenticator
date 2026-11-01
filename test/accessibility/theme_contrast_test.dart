import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/utils/theme.dart';

double _ratio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

/// Engineering standard §7.2 and §7.7: computed ratios for the theme's main
/// colour pairs, in both themes.
void main() {
  for (final entry in {
    for (final accent in AppAccent.values) ...{
      'light ${accent.name}': AppTheme.light(accent),
      'dark ${accent.name}': AppTheme.dark(accent),
    },
  }.entries) {
    final scheme = entry.value.colorScheme;
    final page = entry.value.scaffoldBackgroundColor;
    final pairs = <String, (Color, Color)>{
      'text on surface': (scheme.onSurface, scheme.surface),
      'muted text on surface': (scheme.onSurfaceVariant, scheme.surface),
      'primary text on surface': (scheme.primary, scheme.surface),
      'primary text on page': (scheme.primary, page),
      'text on primary': (scheme.onPrimary, scheme.primary),
      'text on primary container': (
        scheme.onPrimaryContainer,
        scheme.primaryContainer,
      ),
      'text on secondary container': (
        scheme.onSecondaryContainer,
        scheme.secondaryContainer,
      ),
      'text on tertiary container': (
        scheme.onTertiaryContainer,
        scheme.tertiaryContainer,
      ),
      'text on error container': (
        scheme.onErrorContainer,
        scheme.errorContainer,
      ),
      'text on permissions banner': (
        scheme.onSurface,
        Color.alphaBlend(scheme.primaryContainer.withValues(alpha: 0.3), page),
      ),
    };
    for (final pair in pairs.entries) {
      test('${entry.key}: ${pair.key} is at least 4.5 : 1', () {
        expect(_ratio(pair.value.$1, pair.value.$2), greaterThanOrEqualTo(4.5));
      });
    }
  }

  // Status labels are drawn on a 10% tint of their own colour over the card.
  for (final entry in {
    'light': (Brightness.light, AppTheme.backgroundLight),
    'dark': (Brightness.dark, AppTheme.darkTheme.colorScheme.surface),
  }.entries) {
    final (brightness, card) = entry.value;
    final colors = {
      'success': AppTheme.statusSuccess(brightness),
      'warning': AppTheme.statusWarning(brightness),
      'error': AppTheme.statusError(brightness),
    };
    for (final color in colors.entries) {
      test('${entry.key}: ${color.key} status is at least 4.5 : 1', () {
        final tint = Color.alphaBlend(color.value.withValues(alpha: 0.1), card);
        expect(_ratio(color.value, tint), greaterThanOrEqualTo(4.5));
      });
    }
  }

  test('light input hint is at least 4.5 : 1 on white', () {
    final hint = AppTheme.lightTheme.inputDecorationTheme.hintStyle!.color!;
    expect(_ratio(hint, Colors.white), greaterThanOrEqualTo(4.5));
  });
}
