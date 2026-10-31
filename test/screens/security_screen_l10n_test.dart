import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/screens/security_screen.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';

import '../providers/provider_test_helpers.dart';

/// The Security screen renders in every declared language, with every section
/// visible (app lock on, PIN set), on a narrow phone without overflow.
void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment();
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  for (final locale in LocaleConfig.supportedLocales) {
    testWidgets('Security screen in ${locale.languageCode}', (tester) async {
      tester.view.physicalSize = const Size(360, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now().millisecondsSinceEpoch,
      });
      await tester.runAsync(() => AuthService().setPin('1234'));
      late final SettingsProvider settingsProvider;
      await tester.runAsync(() async {
        settingsProvider = SettingsProvider();
        await settingsProvider.initialized;
      });
      // Show the screen unlocked, as after a successful unlock.
      await tester.runAsync(settingsProvider.handleSuccessfulAppPinUnlock);

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: LocaleConfig.localizationsDelegates,
            supportedLocales: LocaleConfig.supportedLocales,
            home: const SecurityScreen(),
          ),
        ),
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final l10n = lookupAppLocalizations(locale);
      expect(find.text(l10n.titleSecurity), findsOneWidget);
      expect(find.text(l10n.labelEnableAppLock), findsOneWidget);
      expect(find.text(l10n.labelUseAppPin), findsOneWidget);
      expect(find.text(l10n.titleChangeAppPin), findsOneWidget);
      expect(find.text(l10n.descInfoPhoneLockTypes), findsOneWidget);
      // No overflow or other layout error.
      expect(tester.takeException(), isNull);
    });
  }
}
