import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';

import '../providers/provider_test_helpers.dart';
import 'screen_harness.dart';

/// Finds the source line of a layout error, so a failure names the code to fix.
final _location = RegExp(r'lib/[^\s:]+\.dart:\d+');

/// Engineering standard §7: tap targets, labels and contrast in both themes,
/// and layouts at text scale 1.0, 1.5 and 2.0 in every declared language.
void main() {
  configureProviderTestBindings();

  setUp(setUpA11yEnvironment);

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  for (final entry in a11yScreens.entries) {
    for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('${entry.key} guidelines, ${mode.name}', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpA11yScreen(tester, entry.value, themeMode: mode);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
        await removeA11yScreen(tester);
      });
    }

    for (final locale in LocaleConfig.supportedLocales) {
      for (final scale in const [1.0, 1.5, 2.0]) {
        testWidgets('${entry.key} layout, ${locale.languageCode}, x$scale', (
          tester,
        ) async {
          final errors = <String>[];
          final original = FlutterError.onError;
          FlutterError.onError = (details) => errors.add(
            '${details.exceptionAsString().split('\n').first} '
            '${_location.firstMatch(details.toString())?.group(0) ?? ''}',
          );
          try {
            await pumpA11yScreen(
              tester,
              entry.value,
              locale: locale,
              textScale: scale,
            );
            final lists = find.byType(Scrollable);
            for (var i = 0; i < 6 && lists.evaluate().isNotEmpty; i++) {
              await tester.drag(
                lists.first,
                const Offset(0, -500),
                warnIfMissed: false,
              );
              await tester.pump(const Duration(milliseconds: 100));
            }
            await removeA11yScreen(tester);
          } finally {
            FlutterError.onError = original;
          }
          expect(errors.toSet(), isEmpty);
        });
      }
    }
  }
}
