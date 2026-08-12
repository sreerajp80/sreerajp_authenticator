// File Path: sreerajp_authenticator/lib/providers/account_provider.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2026 August 01
// Description: Provider for managing authenticator accounts

import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/migration_service.dart';
import '../services/otp_service.dart';
import '../utils/app_logger.dart';

/// Outcome of an [AccountsProvider.importData] call: how many accounts
/// were newly added versus skipped as duplicates.
class ImportResult {
  final int accountsAdded;
  final int accountsSkipped;

  const ImportResult({this.accountsAdded = 0, this.accountsSkipped = 0});
}

class AccountsProvider extends ChangeNotifier {
  List<Account> _accounts = [];
  final DatabaseService _db = DatabaseService.instance;
  final EncryptionService _encryption = EncryptionService();
  final MigrationService _migration = MigrationService();
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isPreDecrypting = false;
  bool _isMigrating = false;

  final Set<String> _selectedTags = {};

  // Getters
  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isPreDecrypting => _isPreDecrypting;
  bool get isMigrating => _isMigrating;
  Set<String> get selectedTags => _selectedTags;

  List<String> get allAvailableTags {
    final tagsSet = <String>{};
    for (final account in _accounts) {
      tagsSet.addAll(account.tags);
    }
    final list = tagsSet.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  /// Filtered accounts based on search query and active tags (AND logic).
  List<Account> get filteredAccounts {
    var result = _accounts;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((account) {
        final name = account.name.toLowerCase();
        final issuer = (account.issuer ?? '').toLowerCase();
        final tagMatch = account.tags.any(
          (t) => t.toLowerCase().contains(query),
        );
        return name.contains(query) || issuer.contains(query) || tagMatch;
      }).toList();
    }

    if (_selectedTags.isNotEmpty) {
      result = result.where((account) {
        return _selectedTags.every(
          (selTag) => account.tags.any(
            (accTag) => accTag.toLowerCase() == selTag.toLowerCase(),
          ),
        );
      }).toList();
    }

    return result;
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

  // ====================== SEARCH & TAG METHODS ======================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void toggleTag(String tag) {
    final existing = _selectedTags.firstWhere(
      (t) => t.toLowerCase() == tag.toLowerCase(),
      orElse: () => '',
    );
    if (existing.isNotEmpty) {
      _selectedTags.remove(existing);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearSelectedTags() {
    _selectedTags.clear();
    notifyListeners();
  }

  int getAccountCountForTag(String tag) {
    final target = tag.toLowerCase().trim();
    var count = 0;
    for (final account in _accounts) {
      if (account.tags.any((t) => t.toLowerCase().trim() == target)) {
        count++;
      }
    }
    return count;
  }

  Future<void> renameTag(String oldTag, String newTag) async {
    final oldTarget = oldTag.trim();
    final newTarget = newTag.trim();
    if (oldTarget.isEmpty ||
        newTarget.isEmpty ||
        oldTarget.toLowerCase() == newTarget.toLowerCase()) {
      return;
    }

    try {
      for (final account in _accounts) {
        final hasTag = account.tags.any(
          (t) => t.toLowerCase() == oldTarget.toLowerCase(),
        );
        if (hasTag) {
          final updatedTags = <String>[];
          for (final t in account.tags) {
            if (t.toLowerCase() == oldTarget.toLowerCase()) {
              if (!updatedTags.any(
                (existing) => existing.toLowerCase() == newTarget.toLowerCase(),
              )) {
                updatedTags.add(newTarget);
              }
            } else {
              if (!updatedTags.any(
                (existing) => existing.toLowerCase() == t.toLowerCase(),
              )) {
                updatedTags.add(t);
              }
            }
          }
          final updatedAccount = account.copyWith(tags: updatedTags);
          await _db.updateAccount(updatedAccount);
        }
      }

      if (_selectedTags.any(
        (t) => t.toLowerCase() == oldTarget.toLowerCase(),
      )) {
        _selectedTags.removeWhere(
          (t) => t.toLowerCase() == oldTarget.toLowerCase(),
        );
        _selectedTags.add(newTarget);
      }

      await loadAccounts();
    } catch (e) {
      AppLogger.error('Failed to rename tag', e);
      rethrow;
    }
  }

  Future<void> deleteTag(String tag) async {
    final target = tag.trim();
    if (target.isEmpty) return;

    try {
      for (final account in _accounts) {
        final hasTag = account.tags.any(
          (t) => t.toLowerCase() == target.toLowerCase(),
        );
        if (hasTag) {
          final updatedTags = account.tags
              .where((t) => t.toLowerCase() != target.toLowerCase())
              .toList();
          final updatedAccount = account.copyWith(tags: updatedTags);
          await _db.updateAccount(updatedAccount);
        }
      }

      _selectedTags.removeWhere((t) => t.toLowerCase() == target.toLowerCase());
      await loadAccounts();
    } catch (e) {
      AppLogger.error('Failed to delete tag', e);
      rethrow;
    }
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
      AppLogger.error('Failed to load accounts', e);
      _accounts = [];
      _isPreDecrypting = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      final encryptedAccount = account.copyWith(
        secret: await _encryption.encrypt(account.secret),
      );

      await _db.createAccount(encryptedAccount);
      await loadAccounts();
    } catch (e) {
      AppLogger.error('Failed to add account', e);
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _db.updateAccount(account);
      await loadAccounts();
    } catch (e) {
      AppLogger.error('Failed to update account', e);
      rethrow;
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _db.deleteAccount(id);
      _accounts.removeWhere((account) => account.id == id);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to delete account', e);
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
      AppLogger.error('Failed to update account directly', e);
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
      await _db.updateAccount(account.copyWith(sortOrder: i));
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
      AppLogger.error('Failed to delete multiple accounts', e);
      rethrow;
    }
  }

  Future<void> bulkUpdateTags(
    List<int> ids,
    List<String> tags, {
    bool replace = false,
  }) async {
    try {
      for (final id in ids) {
        final index = _accounts.indexWhere((a) => a.id == id);
        if (index != -1) {
          final account = _accounts[index];
          List<String> updatedTags;
          if (replace) {
            updatedTags = List.from(tags);
          } else {
            final currentSet = account.tags.map((t) => t.toLowerCase()).toSet();
            updatedTags = List.from(account.tags);
            for (final tag in tags) {
              if (!currentSet.contains(tag.toLowerCase())) {
                updatedTags.add(tag);
                currentSet.add(tag.toLowerCase());
              }
            }
          }
          final updatedAccount = account.copyWith(tags: updatedTags);
          await _db.updateAccount(updatedAccount);
        }
      }
      await loadAccounts();
    } catch (e) {
      AppLogger.error('Failed to bulk update tags', e);
      rethrow;
    }
  }

  // ====================== BACKUP & RESTORE ======================

  Future<Map<String, dynamic>> exportData() async {
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
        'groups':
            <Map<String, dynamic>>[], // kept for backup format compatibility
      };
    } catch (e) {
      AppLogger.error('Failed to export account data', e);
      rethrow;
    }
  }

  Future<ImportResult> importData(Map<String, dynamic> data) async {
    try {
      var accountsAdded = 0;
      var accountsSkipped = 0;

      // Import accounts, skipping duplicates matched on name + issuer + type.
      if (data['accounts'] != null) {
        final existingKeys = _accounts
            .map(
              (a) =>
                  '${a.name.toLowerCase()}|${(a.issuer ?? '').toLowerCase()}|${a.type.toLowerCase()}',
            )
            .toSet();
        final accounts = data['accounts'] as List;
        for (final item in accounts) {
          final account = item is Account
              ? item
              : Account.fromMap(item as Map<String, dynamic>);
          final key =
              '${account.name.toLowerCase()}|${(account.issuer ?? '').toLowerCase()}|${account.type.toLowerCase()}';
          if (!existingKeys.contains(key)) {
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
              tags: account.tags,
              createdAt: account.createdAt,
              sortOrder: account.sortOrder,
            );
            await _db.createAccount(encryptedAccount);
            existingKeys.add(key);
            accountsAdded++;
          } else {
            accountsSkipped++;
            AppLogger.verbose('Skipped a duplicate account during import');
          }
        }
      }

      await loadAccounts();

      return ImportResult(
        accountsAdded: accountsAdded,
        accountsSkipped: accountsSkipped,
      );
    } catch (e) {
      AppLogger.error('Failed to import account data', e);
      rethrow;
    }
  }
}
