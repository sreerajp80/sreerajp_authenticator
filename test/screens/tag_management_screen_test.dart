import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/screens/tag_management_screen.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

import '../providers/provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment(
      sharedPreferences: const {
        AppConstants.aesMigrationKey: true,
        AppConstants.gcmMigrationKey: true,
      },
    );
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  Widget buildTestableWidget(AccountsProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<AccountsProvider>.value(
        value: provider,
        child: const TagManagementScreen(),
      ),
    );
  }

  group('TagManagementScreen Widget Tests', () {
    testWidgets('displays empty state when no tags exist', (tester) async {
      late final AccountsProvider provider;
      await tester.runAsync(() async {
        provider = AccountsProvider();
        await waitForCondition(
          () => !provider.isLoading && !provider.isPreDecrypting,
        );
      });

      await tester.pumpWidget(buildTestableWidget(provider));
      await tester.pump();

      expect(find.text('Manage Tags'), findsOneWidget);
      expect(find.text('No tags found'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('displays tag list when tags exist', (tester) async {
      late final AccountsProvider provider;
      await tester.runAsync(() async {
        final db = DatabaseService.instance;
        await db.createAccount(
          makeAccount(name: 'GitHub', tags: ['Work', 'Dev']),
        );

        provider = AccountsProvider();
        await waitForCondition(
          () =>
              !provider.isLoading &&
              !provider.isPreDecrypting &&
              provider.accounts.isNotEmpty,
        );
      });

      await tester.pumpWidget(buildTestableWidget(provider));
      await tester.pump();

      expect(find.text('#Work'), findsOneWidget);
      expect(find.text('#Dev'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
