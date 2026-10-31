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
    'light': AppTheme.lightTheme,
    'dark': AppTheme.darkTheme,
  }.entries) {
    final scheme = entry.value.colorScheme;
    final page = entry.value.scaffoldBackgroundColor;
    final pairs = <String, (Color, Color)>{
      'text on surface': (scheme.onSurface, scheme.surface),
      'muted text on surface': (scheme.onSurfaceVariant, scheme.surface),
      'primary text on surface': (scheme.primary, scheme.surface),
      'primary text on page': (scheme.primary, page),
      'text on primary': (scheme.onPrimary, scheme.primary),
    };
    for (final pair in pairs.entries) {
      test('${entry.key}: ${pair.key} is at least 4.5 : 1', () {
        expect(_ratio(pair.value.$1, pair.value.$2), greaterThanOrEqualTo(4.5));
      });
    }
  }

  test('light input hint is at least 4.5 : 1 on white', () {
    final hint = AppTheme.lightTheme.inputDecorationTheme.hintStyle!.color!;
    expect(_ratio(hint, Colors.white), greaterThanOrEqualTo(4.5));
  });
}
