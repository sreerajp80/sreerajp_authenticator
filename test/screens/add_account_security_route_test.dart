import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/screens/add_account_screen.dart';
import 'package:sreerajp_authenticator/screens/security_screen.dart';

import '../providers/provider_test_helpers.dart';

/// "Open security" in the "App lock required" dialog must open the Security
/// screen (it used a named route that does not exist and threw).
void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment();
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  testWidgets('Open security opens the Security screen', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late final SettingsProvider settingsProvider;
    await tester.runAsync(() async {
      settingsProvider = SettingsProvider();
      await settingsProvider.initialized;
    });
    expect(settingsProvider.isAppLockEnabled, isFalse);

    final account = Account(
      id: 1,
      name: 'user@example.com',
      issuer: 'Example',
      secret: 'JBSWY3DPEHPK3PXP',
      type: 'totp',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
          ChangeNotifierProvider<AccountsProvider>(
            create: (_) => AccountsProvider(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: LocaleConfig.localizationsDelegates,
          supportedLocales: LocaleConfig.supportedLocales,
          home: AddAccountScreen(accountToEdit: account),
        ),
      ),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
    await tester.pump(const Duration(milliseconds: 200));

    // App lock is off, so the secret key shows "Enable app lock".
    await tester.tap(find.text('Enable app lock'));
    await tester.pumpAndSettle();
    expect(find.text('App lock required'), findsOneWidget);

    await tester.tap(find.text('Open security'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.byType(SecurityScreen), findsOneWidget);
  });
}
