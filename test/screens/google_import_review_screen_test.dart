import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/screens/google_import_review_screen.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';
import 'package:sreerajp_authenticator/services/google_migration_service.dart';

import '../providers/provider_test_helpers.dart';
import '../services/google_migration_test_data.dart';

void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment(sharedPreferences: const {});
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  List<GoogleMigrationEntry> entriesFor(List<List<int>> accounts) =>
      GoogleMigrationService.parse(migrationLink(migrationPayload(accounts)))
          .entries;

  Future<AccountsProvider> pumpScreen(
    WidgetTester tester,
    List<GoogleMigrationEntry> entries, {
    bool withExisting = false,
    Locale? locale,
  }) async {
    late final AccountsProvider provider;
    await tester.runAsync(() async {
      if (withExisting) {
        await DatabaseService.instance.createAccount(
          makeAccount(name: 'taken', issuer: 'Site'),
        );
      }
      provider = AccountsProvider();
      await waitForCondition(
        () => !provider.isLoading && !provider.isPreDecrypting,
      );
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<AccountsProvider>.value(
        value: provider,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: LocaleConfig.localizationsDelegates,
          supportedLocales: LocaleConfig.supportedLocales,
          home: GoogleImportReviewScreen(entries: entries),
        ),
      ),
    );
    await tester.pump();
    return provider;
  }

  Finder importButton(int count) =>
      find.widgetWithText(ElevatedButton, 'Import ($count)');

  testWidgets('new accounts start selected and can be unselected', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      entriesFor([
        migrationAccount(name: 'one', issuer: 'Site'),
        migrationAccount(name: 'two', issuer: 'Site'),
      ]),
    );
    expect(importButton(2), findsOneWidget);

    await tester.tap(find.text('Site (one)'));
    await tester.pump();
    expect(importButton(1), findsOneWidget);

    await tester.tap(find.text('Site (two)'));
    await tester.pump();
    final button = tester.widget<ElevatedButton>(importButton(0));
    expect(button.onPressed, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('duplicates and problems are shown and cannot be chosen', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      entriesFor([
        migrationAccount(name: 'taken', issuer: 'Site'),
        migrationAccount(name: 'twice', issuer: 'Site'),
        migrationAccount(name: 'twice', issuer: 'Site'),
        migrationAccount(name: 'old', issuer: 'Site', algorithm: 4),
      ]),
      withExisting: true,
    );

    // Only the first "twice" can be chosen.
    expect(importButton(1), findsOneWidget);
    expect(find.text('Already in app'), findsNWidgets(2));
    expect(
      find.text('This account uses an algorithm the app does not support.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Site (old)'));
    await tester.pump();
    expect(importButton(1), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('secrets are never shown', (tester) async {
    final entries = entriesFor([migrationAccount()]);
    await pumpScreen(tester, entries);
    expect(find.textContaining(entries.single.account!.secret), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('import saves the chosen accounts only', (tester) async {
    final provider = await pumpScreen(
      tester,
      entriesFor([
        migrationAccount(name: 'keep', issuer: 'Site'),
        migrationAccount(name: 'drop', issuer: 'Site'),
      ]),
    );
    await tester.tap(find.text('Site (drop)'));
    await tester.pump();

    // Real database work runs only inside runAsync.
    await tester.runAsync(() async {
      tester.widget<ElevatedButton>(importButton(1)).onPressed!();
      await waitForCondition(() => provider.accounts.isNotEmpty);
    });
    await tester.pump();

    expect(provider.accounts.map((a) => a.name), ['keep']);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final locale in const [Locale('ml'), Locale('sa')]) {
    testWidgets('renders in ${locale.languageCode}', (tester) async {
      await pumpScreen(
        tester,
        entriesFor([migrationAccount(), migrationAccount(digits: 3)]),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
