import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/screens/features_screen.dart';
import 'package:sreerajp_authenticator/screens/help/backup_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/biometrics_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/faq_troubleshooting_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/getting_started_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/help_home_screen.dart';
import 'package:sreerajp_authenticator/screens/help/optical_sync_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/p2p_sync_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/tag_management_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/time_sync_help_screen.dart';
import 'package:sreerajp_authenticator/screens/help/vault_security_help_screen.dart';

import '../providers/provider_test_helpers.dart';

/// The Features screen and every help screen render in every declared
/// language on a narrow phone, scrolled from top to bottom, without overflow.
/// Each check uses a text that is only on that screen.
void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment();
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  final screens = <String, (Widget, String Function(AppLocalizations))>{
    'Features': (const FeaturesScreen(), (l) => l.descFeatures101),
    'Help home': (const HelpHomeScreen(), (l) => l.helpHome01),
    'Getting started': (const GettingStartedHelpScreen(), (l) => l.helpStart01),
    'Time sync': (const TimeSyncHelpScreen(), (l) => l.helpTime01),
    'Tags': (const TagManagementHelpScreen(), (l) => l.helpTags01),
    'Lock': (const BiometricsHelpScreen(), (l) => l.helpLock01),
    'Vault': (const VaultSecurityHelpScreen(), (l) => l.helpVault01),
    'Wi-Fi': (const P2PSyncHelpScreen(), (l) => l.helpWifi01),
    'Optical': (const OpticalSyncHelpScreen(), (l) => l.helpOptical01),
    'Backup': (const BackupHelpScreen(), (l) => l.helpBackup01),
    'FAQ': (const FaqTroubleshootingHelpScreen(), (l) => l.helpFaq01),
  };

  for (final locale in LocaleConfig.supportedLocales) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} screen in ${locale.languageCode}', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({});
        late final SettingsProvider settingsProvider;
        await tester.runAsync(() async {
          settingsProvider = SettingsProvider();
          await settingsProvider.initialized;
        });

        final (screen, titleOf) = entry.value;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SettingsProvider>.value(
                value: settingsProvider,
              ),
              Provider<AppConfig>.value(value: AppConfig.fallback),
            ],
            child: MaterialApp(
              locale: locale,
              localizationsDelegates: LocaleConfig.localizationsDelegates,
              supportedLocales: LocaleConfig.supportedLocales,
              home: screen,
            ),
          ),
        );
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        });
        await tester.pump();

        final l10n = lookupAppLocalizations(locale);
        expect(find.text(titleOf(l10n)), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Scroll to the end, checking the layout on the way.
        for (var i = 0; i < 12; i++) {
          await tester.drag(find.byType(ListView), const Offset(0, -600));
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('Help menu paths use the current button names', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      l10n.helpBackup04(
        l10n.titleSettings,
        l10n.titleBackupRestore,
        l10n.labelCreateEncryptedBackup,
      ),
      contains(l10n.labelCreateEncryptedBackup),
    );
    expect(
      l10n.helpWifi05(
        l10n.titleSettings,
        l10n.titleSyncDevice,
        l10n.labelSendOverWifi,
      ),
      contains(l10n.labelSendOverWifi),
    );
  });
}
