import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/screens/lock_screen.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';

import '../providers/provider_test_helpers.dart';

/// The lock screen renders in every declared language, maps each
/// PinRequiredReason to its own text, and does not overflow.
void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment();
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  Future<void> pumpLockScreen(
    WidgetTester tester,
    SettingsProvider settingsProvider,
    Locale locale,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: LocaleConfig.localizationsDelegates,
          supportedLocales: LocaleConfig.supportedLocales,
          home: const LockScreen(),
        ),
      ),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  for (final locale in LocaleConfig.supportedLocales) {
    testWidgets('PIN-required lock screen in ${locale.languageCode}', (
      tester,
    ) async {
      // Narrow phone screen, so long Malayalam / Sanskrit text must wrap.
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({
        'app_lock_enabled': true,
        'require_authentication': true,
        'phone_lock_quick_unlock_enabled': true,
        'last_strong_auth_at_ms': DateTime.now()
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch,
      });
      await tester.runAsync(() => AuthService().setPin('1234'));
      final settingsProvider = SettingsProvider();
      await settingsProvider.initialized;

      await pumpLockScreen(tester, settingsProvider, locale);

      final l10n = lookupAppLocalizations(locale);
      expect(settingsProvider.pinRequiredReason, PinRequiredReason.idleTimeout);
      expect(find.text(l10n.titleEnterYourPin), findsWidgets);
      expect(find.text(l10n.descPinRequiredIdle), findsOneWidget);
      expect(find.text(l10n.actionUnlockWithPin), findsOneWidget);
      expect(find.text(l10n.actionForgotPin), findsOneWidget);
      // No overflow or other layout error.
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'every PIN-required reason and unlock instruction has distinct text',
    () {
      for (final locale in LocaleConfig.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        final reasons = {
          l10n.descPinRequiredIdle,
          l10n.descPinRequiredReboot,
          l10n.descPinRequiredFailures,
          l10n.descPinRequiredLockdown,
        };
        final instructions = {
          l10n.descUnlockPhoneOnly,
          l10n.descUnlockPhoneOrPin,
          l10n.descUnlockPinOnly,
        };
        expect(reasons, hasLength(4), reason: locale.languageCode);
        expect(instructions, hasLength(3), reason: locale.languageCode);
        // One text per enum value (ignoring `none`).
        expect(PinRequiredReason.values, hasLength(5));
        expect(UnlockInstruction.values, hasLength(3));
      }
    },
  );
}
