import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/screens/about_screen.dart';
import 'package:sreerajp_authenticator/utils/build_date.g.dart';
import 'package:sreerajp_authenticator/utils/theme.dart';
import 'package:sreerajp_authenticator/widgets/made_with_love.dart';

import '../providers/provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  setUp(() async {
    // rootBundle caches the config asset future in the zone of the test that
    // first loaded it; a later test would wait on that old zone forever.
    rootBundle.clear();
    PackageInfo.setMockInitialValues(
      appName: 'Sreeraj P Authenticator',
      packageName: 'in.sreerajp.sreerajp_authenticator',
      version: '2.9.3',
      buildNumber: '27',
      buildSignature: '',
    );

    await setUpProviderTestEnvironment(sharedPreferences: const {});
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  Widget buildTestableWidget(SettingsProvider settingsProvider, Locale locale) {
    return MaterialApp(
      locale: locale,
      supportedLocales: LocaleConfig.supportedLocales,
      localizationsDelegates: LocaleConfig.localizationsDelegates,
      home: ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider,
        child: const AboutScreen(),
      ),
    );
  }

  group('AboutScreen Widget Tests', () {
    for (final locale in LocaleConfig.supportedLocales) {
      testWidgets('renders in ${locale.languageCode} with the badge last', (
        tester,
      ) async {
        late final SettingsProvider settingsProvider;
        await tester.runAsync(() async {
          settingsProvider = SettingsProvider();
          await settingsProvider.initialized;
        });

        await tester.pumpWidget(buildTestableWidget(settingsProvider, locale));
        await tester.pumpAndSettle();

        final l10n = lookupAppLocalizations(locale);
        expect(find.text(l10n.titleAbout), findsWidgets);
        expect(find.text(kBuildDate), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
        // Row labels come from ARB, not from the JSON keys.
        await tester.scrollUntilVisible(find.text(l10n.aboutDetailAuthor), 300);
        expect(find.text(l10n.aboutDetailAuthor), findsOneWidget);
        expect(find.text('author'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(find.byType(MadeWithLove), 300);
        final heart = tester.widget<Icon>(
          find.descendant(
            of: find.byType(MadeWithLove),
            matching: find.byIcon(Icons.favorite),
          ),
        );
        expect(heart.color, AppTheme.heartRed);
        expect(find.bySemanticsLabel(l10n.madeWithLoveA11y), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  });
}
