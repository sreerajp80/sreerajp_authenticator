import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/providers/locale_provider.dart';
import 'package:sreerajp_authenticator/providers/settings_provider.dart';
import 'package:sreerajp_authenticator/providers/sync_provider.dart';
import 'package:sreerajp_authenticator/providers/theme_provider.dart';
import 'package:sreerajp_authenticator/screens/security_screen.dart';
import 'package:sreerajp_authenticator/services/auth_service.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';

import '../providers/provider_test_helpers.dart';

/// "Delete all data": App PIN if set, otherwise the phone lock, otherwise a
/// ticked box. Anything else leaves the data in place.
void main() {
  configureProviderTestBindings();

  const localAuth = MethodChannel('plugins.flutter.io/local_auth');
  const protector = MethodChannel('screen_protector');
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final l10n = lookupAppLocalizations(const Locale('en'));
  const marker = 'still_here';

  late Directory files;
  late List<String> protectorCalls;

  void mockPhoneLock({
    bool available = true,
    bool passes = true,
    PlatformException? error,
  }) {
    messenger.setMockMethodCallHandler(localAuth, (call) async {
      switch (call.method) {
        case 'isDeviceSupported':
          return available;
        case 'authenticate':
          if (error != null) throw error;
          return passes;
        default:
          return null;
      }
    });
  }

  setUp(() async {
    await setUpProviderTestEnvironment(
      sharedPreferences: {'block_screenshots': false, 'theme_mode': 2},
    );
    files = await Directory.systemTemp.createTemp('delete_all_test');
    protectorCalls = [];
    messenger.setMockMethodCallHandler(protector, (call) async {
      protectorCalls.add(call.method);
      return true;
    });
    messenger.setMockMethodCallHandler(
      pathProvider,
      (call) async => files.path,
    );
    fakeSecureStorage[marker] = 'value';
    await DatabaseService.instance.createAccount(makeAccount());
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(protector, null);
    messenger.setMockMethodCallHandler(pathProvider, null);
    await tearDownProviderTestEnvironment();
    await files.delete(recursive: true);
  });

  Future<SettingsProvider> pumpScreen(
    WidgetTester tester, {
    String? pin,
  }) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late final SettingsProvider settings;
    late final AccountsProvider accounts;
    late final LocaleProvider locales;
    late final ThemeProvider theme;
    late final SyncProvider sync;
    await tester.runAsync(() async {
      settings = SettingsProvider();
      await settings.initialized;
      await settings.setAutoLockTimeout(0);
      if (pin != null) {
        await settings.setAppLockPin(pin);
        await settings.setAppLockEnabled(true);
      }
      accounts = AccountsProvider();
      await accounts.loadAccounts();
      locales = LocaleProvider(await SharedPreferences.getInstance());
      theme = ThemeProvider();
      sync = SyncProvider();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: accounts),
          ChangeNotifierProvider.value(value: locales),
          ChangeNotifierProvider.value(value: theme),
          ChangeNotifierProvider.value(value: sync),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
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
    await settle(tester);
    return settings;
  }

  Future<void> openWarning(WidgetTester tester) async {
    await tester.tap(find.text(l10n.labelDeleteAllData));
    await settle(tester);
    expect(find.text(l10n.descDeleteAllDataWarning), findsOneWidget);
  }

  Future<void> tapDeleteAll(WidgetTester tester) async {
    await tester.tap(find.text(l10n.actionDeleteAll));
    await settle(tester);
  }

  Future<void> enterPin(WidgetTester tester, String pin) async {
    await tester.enterText(find.byType(TextField), pin);
    await tester.tap(find.text(l10n.actionVerify));
    // PIN checks take real time. Stop once the short-lived message is showing.
    for (var i = 0; i < 60; i++) {
      await settle(tester, rounds: 1);
      if (find.text(l10n.descAllDataDeleted).evaluate().isNotEmpty) break;
    }
  }

  void expectDeleted(WidgetTester tester) {
    expect(fakeSecureStorage.containsKey(marker), isFalse);
    expect(find.text(l10n.descAllDataDeleted), findsOneWidget);
  }

  void expectKept(WidgetTester tester) {
    expect(fakeSecureStorage.containsKey(marker), isTrue);
    expect(find.text(l10n.descAllDataDeleted), findsNothing);
  }

  testWidgets('cancelling the warning deletes nothing', (tester) async {
    mockPhoneLock();
    await pumpScreen(tester);

    await openWarning(tester);
    await tester.tap(find.text(l10n.actionCancel));
    await settle(tester);

    expectKept(tester);
  });

  group('with an App PIN', () {
    testWidgets('the right PIN deletes everything', (tester) async {
      mockPhoneLock();
      final settings = await pumpScreen(tester, pin: '1234');

      await openWarning(tester);
      expect(find.text(l10n.descDeleteAllDataUnderstand), findsNothing);
      await tapDeleteAll(tester);
      await enterPin(tester, '1234');

      expectDeleted(tester);
      expect(settings.hasPinSet, isFalse);
      expect(settings.isAppLockEnabled, isFalse);
      expect(settings.isLocked, isFalse);
      expect(settings.blockScreenshots, isTrue);
      expect(protectorCalls, contains('preventScreenshotOn'));
      expect(tester.element(find.byType(SecurityScreen)).mounted, isTrue);
      final accounts = tester
          .element(find.byType(SecurityScreen))
          .read<AccountsProvider>();
      expect(accounts.accounts, isEmpty);
    });

    testWidgets('a wrong PIN deletes nothing', (tester) async {
      mockPhoneLock();
      await pumpScreen(tester, pin: '1234');

      await openWarning(tester);
      await tapDeleteAll(tester);
      await enterPin(tester, '9999');

      expectKept(tester);
    });

    testWidgets('the right PIN is refused during a lockout', (tester) async {
      mockPhoneLock();
      await pumpScreen(tester, pin: '1234');
      await tester.runAsync(() async {
        final auth = AuthService();
        for (var i = 0; i < AuthService.maxAttempts; i++) {
          await auth.recordFailedPinAttempt();
        }
      });

      await openWarning(tester);
      await tapDeleteAll(tester);
      await enterPin(tester, '1234');

      expectKept(tester);
    });
  });

  group('with no App PIN and a phone lock', () {
    testWidgets('passing the phone lock deletes everything', (tester) async {
      mockPhoneLock();
      await pumpScreen(tester);

      await openWarning(tester);
      expect(find.text(l10n.descDeleteAllDataUnderstand), findsNothing);
      await tapDeleteAll(tester);
      await settle(tester);

      expectDeleted(tester);
    });

    testWidgets('a failed phone lock deletes nothing', (tester) async {
      mockPhoneLock(passes: false);
      await pumpScreen(tester);

      await openWarning(tester);
      await tapDeleteAll(tester);

      expectKept(tester);
    });

    testWidgets('a phone-lock error deletes nothing', (tester) async {
      mockPhoneLock(error: PlatformException(code: 'LockedOut'));
      await pumpScreen(tester);

      await openWarning(tester);
      await tapDeleteAll(tester);

      expectKept(tester);
    });
  });

  group('with no App PIN and no phone lock', () {
    ElevatedButton deleteButton(WidgetTester tester) =>
        tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, l10n.actionDeleteAll),
        );

    testWidgets('the button works only after the box is ticked', (
      tester,
    ) async {
      mockPhoneLock(available: false);
      await pumpScreen(tester);

      await openWarning(tester);
      expect(deleteButton(tester).onPressed, isNull);

      await tester.tap(find.text(l10n.descDeleteAllDataUnderstand));
      await settle(tester);
      expect(deleteButton(tester).onPressed, isNotNull);

      await tapDeleteAll(tester);
      await settle(tester);

      expectDeleted(tester);
    });
  });
}

/// Lets real work (isolates, files, the database) and fake-clock work both run.
Future<void> settle(WidgetTester tester, {int rounds = 12}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 150));
  }
}
