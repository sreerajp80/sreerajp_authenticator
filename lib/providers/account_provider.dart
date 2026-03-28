// File Path: sreerajp_authenticator/lib/providers/account_provider.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 14
// Description: Provider for managing authenticator accounts

import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../models/group.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/migration_service.dart';
import '../services/otp_service.dart';

class AccountsProvider extends ChangeNotifier {
  List<Account> _accounts = [];
  final DatabaseService _db = DatabaseService.instance;
  final EncryptionService _encryption = EncryptionService();
  final MigrationService _migration = MigrationService();
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isPreDecrypting = false;
  bool _isMigrating = false;

  // Getters
  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isPreDecrypting => _isPreDecrypting;
  bool get isMigrating => _isMigrating;

  // Filtered accounts based on search query
  List<Account> get filteredAccounts {
    if (_searchQuery.isEmpty) {
      return _accounts;
    }

    final query = _searchQuery.toLowerCase();
    return _accounts.where((account) {
      final name = account.name.toLowerCase();
      final issuer = (account.issuer ?? '').toLowerCase();
      return name.contains(query) || issuer.contains(query);
    }).toList();
  }

  // Accounts by group
  List<Account> getAccountsByGroup(int? groupId) {
    if (groupId == null) {
      return _accounts.where((account) => account.groupId == null).toList();
    }
    return _accounts.where((account) => account.groupId == groupId).toList();
  }

  int getAccountCountForGroup(int? groupId) {
    if (groupId == null) {
      return _accounts.where((a) => a.groupId == null).length;
    }
    return _accounts.where((a) => a.groupId == groupId).length;
  }

  AccountsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _migration.runPendingMigrations(
      onStatusChanged: (migrating) {
        _isMigrating = migrating;
        notifyListeners();
      },
    );
    await loadAccounts();
  }

  // ====================== SEARCH METHODS ======================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ====================== ACCOUNT METHODS ======================

  Future<void> loadAccounts() async {
    _isLoading = true;
    _isPreDecrypting = true;
    await Future.microtask(() => notifyListeners());

    try {
      _accounts = await _db.getAllAccounts();

      // Sort accounts by sortOrder
      _accounts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // Clear cache and pre-decrypt secrets
      OTPService.clearCache();
      await OTPService.preDecryptAllSecrets(_accounts);

      _isPreDecrypting = false;
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      _accounts = [];
      _isPreDecrypting = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      // Ensure type is set (default to TOTP)
      final accountWithType = Account(
        id: account.id,
        name: account.name,
        secret: account.secret,
        issuer: account.issuer,
        description: account.description,
        type: account.type,
        counter: account.counter,
        digits: account.digits,
        period: account.period,
        algorithm: account.algorithm,
        groupId: account.groupId,
        createdAt: account.createdAt,
        sortOrder: account.sortOrder,
      );

      // Encrypt the secret with AES before storing
      final encryptedAccount = accountWithType.copyWith(
        secret: await _encryption.encrypt(accountWithType.secret),
      );

      await _db.createAccount(encryptedAccount);
      await loadAccounts();
    } catch (e) {
      debugPrint('Error adding account: $e');
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      final accountWithType = Account(
        id: account.id,
        name: account.name,
        secret: account.secret,
        issuer: account.issuer,
        description: account.description,
        type: account.type,
        counter: account.counter,
        digits: account.digits,
        period: account.period,
        algorithm: account.algorithm,
        groupId: account.groupId,
        createdAt: account.createdAt,
        sortOrder: account.sortOrder,
      );

      await _db.updateAccount(accountWithType);
      await loadAccounts();
    } catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _db.deleteAccount(id);
      _accounts.removeWhere((account) => account.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  Future<String> encryptSecret(String plainSecret) async {
    return await _encryption.encrypt(plainSecret);
  }

  Future<void> updateAccountDirect(Account account) async {
    try {
      await _db.updateAccount(account);
      await loadAccounts();
    } catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }

  Future<String> getDecryptedSecret(String encryptedSecret) async {
    return await _encryption.decrypt(encryptedSecret);
  }

  void reorderAccounts(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Account item = _accounts.removeAt(oldIndex);
    _accounts.insert(newIndex, item);
    notifyListeners();
    _saveAccountOrder();
  }

  Future<void> _saveAccountOrder() async {
    for (int i = 0; i < _accounts.length; i++) {
      final account = _accounts[i];
      final updatedAccount = Account(
        id: account.id,
        name: account.name,
        secret: account.secret,
        issuer: account.issuer,
        description: account.description,
        type: account.type,
        counter: account.counter,
        digits: account.digits,
        period: account.period,
        algorithm: account.algorithm,
        groupId: account.groupId,
        createdAt: account.createdAt,
        sortOrder: i,
      );
      await _db.updateAccount(updatedAccount);
    }
  }

  // Bulk operations
  Future<void> deleteMultipleAccounts(List<int> ids) async {
    try {
      for (final id in ids) {
        await _db.deleteAccount(id);
      }
      _accounts.removeWhere((account) => ids.contains(account.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting multiple accounts: $e');
      rethrow;
    }
  }

  Future<void> moveAccountsToGroup(List<int> accountIds, int? groupId) async {
    try {
      for (final accountId in accountIds) {
        final account = _accounts.firstWhere((a) => a.id == accountId);
        final updatedAccount = Account(
          id: account.id,
          name: account.name,
          secret: account.secret,
          issuer: account.issuer,
          description: account.description,
          type: account.type,
          counter: account.counter,
          digits: account.digits,
          period: account.period,
          algorithm: account.algorithm,
          groupId: groupId,
          createdAt: account.createdAt,
          sortOrder: account.sortOrder,
        );
        await _db.updateAccount(updatedAccount);
      }
      await loadAccounts();
    } catch (e) {
      debugPrint('Error moving accounts to group: $e');
      rethrow;
    }
  }

  // ====================== BACKUP & RESTORE ======================

  Future<Map<String, dynamic>> exportData(List<Group> groups) async {
    try {
      final decryptedAccounts = <Map<String, dynamic>>[];

      for (final account in _accounts) {
        final decryptedSecret = await getDecryptedSecret(account.secret);
        final accountMap = account.toMap();
        accountMap['secret'] = decryptedSecret;
        decryptedAccounts.add(accountMap);
      }

      return {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'accounts': decryptedAccounts,
        'groups': groups.map((g) => g.toMap()).toList(),
      };
    } catch (e) {
      debugPrint('Error exporting data: $e');
      rethrow;
    }
  }

  Future<void> importData(
    Map<String, dynamic> data, {
    required List<Group> existingGroups,
    VoidCallback? onGroupsChanged,
  }) async {
    try {
      // Maps old backup group IDs → new database group IDs so that
      // account.groupId references remain correct after import.
      final Map<int, int> groupIdMap = {};

      // Import groups, skipping any whose name already exists (case-insensitive).
      if (data['groups'] != null) {
        final existingGroupsByName = {
          for (final g in existingGroups) g.name.toLowerCase(): g,
        };
        final groups = data['groups'] as List;
        for (final item in groups) {
          final group = item is Group ? item : Group.fromMap(item as Map<String, dynamic>);
          final oldId = group.id;
          final existing = existingGroupsByName[group.name.toLowerCase()];
          if (existing != null) {
            // Group already exists — map old ID to the existing one
            if (oldId != null && existing.id != null) {
              groupIdMap[oldId] = existing.id!;
            }
            debugPrint('Skipping duplicate group: ${group.name}');
          } else {
            // Insert without the old ID so the DB auto-generates a new one
            final groupWithoutId = group.copyWith(id: null);
            final newId = await _db.createGroup(groupWithoutId);
            if (oldId != null) {
              groupIdMap[oldId] = newId;
            }
            existingGroupsByName[group.name.toLowerCase()] =
                group.copyWith(id: newId);
          }
        }
      }

      // Import accounts, skipping duplicates matched on name + issuer + type.
      final bool hasGroupsInBackup = data['groups'] != null &&
          (data['groups'] as List).isNotEmpty;
      if (data['accounts'] != null) {
        final existingKeys = _accounts
            .map((a) =>
                '${a.name.toLowerCase()}|${(a.issuer ?? '').toLowerCase()}|${a.type.toLowerCase()}')
            .toSet();
        final accounts = data['accounts'] as List;
        for (final item in accounts) {
          final account = item is Account ? item : Account.fromMap(item as Map<String, dynamic>);
          final key =
              '${account.name.toLowerCase()}|${(account.issuer ?? '').toLowerCase()}|${account.type.toLowerCase()}';
          if (!existingKeys.contains(key)) {
            // Remap groupId to the new database ID.
            // If the backup contained groups, any unmapped ID means the group
            // wasn't in the backup — clear it to avoid dangling references.
            int? mappedGroupId = account.groupId;
            if (hasGroupsInBackup && mappedGroupId != null) {
              mappedGroupId = groupIdMap[mappedGroupId]; // null if not found
            }

            // Build account directly to allow setting groupId to null
            final encryptedAccount = Account(
              name: account.name,
              secret: await _encryption.encrypt(account.secret),
              issuer: account.issuer,
              description: account.description,
              type: account.type,
              counter: account.counter,
              digits: account.digits,
              period: account.period,
              algorithm: account.algorithm,
              groupId: mappedGroupId,
              createdAt: account.createdAt,
              sortOrder: account.sortOrder,
            );
            await _db.createAccount(encryptedAccount);
            existingKeys.add(key);
          } else {
            debugPrint('Skipping duplicate account: ${account.name}');
          }
        }
      }

      onGroupsChanged?.call();
      await loadAccounts();
    } catch (e) {
      debugPrint('Error importing data: $e');
      rethrow;
    }
  }
}
