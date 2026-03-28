import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

import 'provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  late DatabaseService db;

  setUp(() async {
    await setUpProviderTestEnvironment(
      sharedPreferences: const {
        AppConstants.aesMigrationKey: true,
        AppConstants.gcmMigrationKey: true,
      },
    );
    db = DatabaseService.instance;
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  group('AccountsProvider', () {
    test('loads accounts ordered by sortOrder', () async {
      await db.createAccount(makeAccount(name: 'Third', sortOrder: 2));
      await db.createAccount(makeAccount(name: 'First', sortOrder: 0));
      await db.createAccount(makeAccount(name: 'Second', sortOrder: 1));

      final provider = AccountsProvider();

      await waitForCondition(
        () =>
            provider.accounts.length == 3 &&
            !provider.isLoading &&
            !provider.isPreDecrypting,
      );

      expect(provider.accounts.map((account) => account.name).toList(), [
        'First',
        'Second',
        'Third',
      ]);
    });

    test('addAccount encrypts the secret before persisting', () async {
      final provider = AccountsProvider();
      await settleAsyncWork();

      const plainSecret = 'JBSWY3DPEHPK3PXP';
      await provider.addAccount(
        makeAccount(name: 'GitHub', secret: plainSecret),
      );

      await waitForCondition(
        () => provider.accounts.length == 1 && !provider.isLoading,
      );

      final storedAccount = (await db.getAllAccounts()).single;

      expect(storedAccount.secret, isNot(plainSecret));
      expect(storedAccount.secret, contains(':'));
      expect(provider.accounts.single.secret, storedAccount.secret);
    });

    test('searchQuery filters accounts by name and issuer', () async {
      await db.createAccount(makeAccount(name: 'GitHub', issuer: 'GitHub'));
      await db.createAccount(makeAccount(name: 'Workspace', issuer: 'Google'));
      await db.createAccount(makeAccount(name: 'Slack', issuer: 'Slack'));

      final provider = AccountsProvider();
      await waitForCondition(
        () =>
            provider.accounts.length == 3 &&
            !provider.isLoading &&
            !provider.isPreDecrypting,
      );

      provider.setSearchQuery('goo');

      expect(
        provider.filteredAccounts.map((account) => account.name).toList(),
        ['Workspace'],
      );

      provider.setSearchQuery('git');

      expect(
        provider.filteredAccounts.map((account) => account.name).toList(),
        ['GitHub'],
      );
    });

    test('moveAccountsToGroup updates selected accounts', () async {
      final groupId = await db.createGroup(makeGroup(name: 'Work'));
      final accountId = await db.createAccount(makeAccount(name: 'Slack'));
      await db.createAccount(makeAccount(name: 'Personal'));

      final provider = AccountsProvider();
      await waitForCondition(
        () =>
            provider.accounts.length == 2 &&
            !provider.isLoading &&
            !provider.isPreDecrypting,
      );

      await provider.moveAccountsToGroup([accountId], groupId);

      await waitForCondition(
        () =>
            provider.accounts
                .firstWhere((account) => account.id == accountId)
                .groupId ==
            groupId,
      );

      expect(provider.getAccountCountForGroup(groupId), 1);
      expect(
        provider
            .getAccountsByGroup(groupId)
            .map((account) => account.name)
            .toList(),
        ['Slack'],
      );

      final storedAccount = (await db.getAllAccounts()).firstWhere(
        (account) => account.id == accountId,
      );
      expect(storedAccount.groupId, groupId);
    });

    test(
      'deleteMultipleAccounts removes records from memory and database',
      () async {
        final id1 = await db.createAccount(makeAccount(name: 'One'));
        final id2 = await db.createAccount(makeAccount(name: 'Two'));
        await db.createAccount(makeAccount(name: 'Three'));

        final provider = AccountsProvider();
        await waitForCondition(
          () =>
              provider.accounts.length == 3 &&
              !provider.isLoading &&
              !provider.isPreDecrypting,
        );

        await provider.deleteMultipleAccounts([id1, id2]);

        expect(provider.accounts.map((account) => account.name).toList(), [
          'Three',
        ]);
        expect(
          (await db.getAllAccounts()).map((account) => account.name).toList(),
          ['Three'],
        );
      },
    );
  });
}
