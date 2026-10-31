import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';
import 'package:sreerajp_authenticator/widgets/account_tile.dart';
import 'package:sreerajp_authenticator/widgets/account_tile/timer_indicator.dart';

import '../providers/provider_test_helpers.dart';

/// An HOTP tile shows no code until asked, has no countdown ring, and each tap
/// of the next code button gives the next RFC 4226 value.
void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment(sharedPreferences: const {});
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  for (final locale in LocaleConfig.supportedLocales) {
    testWidgets('HOTP tile in ${locale.languageCode}', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);

      late final AccountsProvider provider;
      await tester.runAsync(() async {
        provider = AccountsProvider();
        await settleAsyncWork();
        await provider.addAccount(
          makeAccount(
            name: 'Counter',
            type: 'hotp',
            counter: 0,
            secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          ),
        );
        await waitForCondition(() => provider.accounts.length == 1);
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<AccountsProvider>.value(
          value: provider,
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: LocaleConfig.localizationsDelegates,
            supportedLocales: LocaleConfig.supportedLocales,
            home: Scaffold(
              body: Consumer<AccountsProvider>(
                builder: (context, accounts, _) =>
                    AccountTile(account: accounts.accounts.first),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final l10n = lookupAppLocalizations(locale);
      expect(find.byType(TimerIndicator), findsNothing);
      expect(find.text(AppConstants.otpUnavailablePlaceholder), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Copy before the first tap gives a clear message.
      await tester.tap(find.text(AppConstants.otpUnavailablePlaceholder));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(l10n.descHotpTapForCode), findsOneWidget);
      // Let the message time out and finish closing.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text(l10n.descHotpTapForCode), findsNothing);

      await tester.tap(find.byTooltip(l10n.tooltipNextCode));
      await tester.pump(const Duration(milliseconds: 50));
      for (var i = 0; i < 100; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
        if (find.text('755 224').evaluate().isNotEmpty) break;
      }

      // RFC 4226 value for counter 0, shown with a space in the middle.
      expect(find.text('755 224'), findsOneWidget);
      expect(provider.accounts.first.counter, 1);
      expect(tester.takeException(), isNull);

      // Copying the code does not move the counter.
      await tester.tap(find.text('755 224'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(l10n.descCodeCopied('Counter')), findsOneWidget);
      expect(provider.accounts.first.counter, 1);
      await tester.pump(const Duration(seconds: 5));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 30));
      await tester.runAsync(() => DatabaseService.resetForTesting());
    });
  }
}
