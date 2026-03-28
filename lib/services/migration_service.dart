// File Path: sreerajp_authenticator/lib/services/migration_service.dart
// Description: Service for migrating account secrets between encryption schemes

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'database_service.dart';
import 'encryption_service.dart';

class MigrationService {
  final DatabaseService _db;
  final EncryptionService _encryption;

  static const String _migrationKey = AppConstants.aesMigrationKey;
  static const String _gcmMigrationKey = AppConstants.gcmMigrationKey;

  MigrationService({
    DatabaseService? db,
    EncryptionService? encryption,
  })  : _db = db ?? DatabaseService.instance,
        _encryption = encryption ?? EncryptionService();

  /// Run all pending migrations in order.
  /// Returns true if any migration was performed.
  Future<bool> runPendingMigrations({
    required void Function(bool isMigrating) onStatusChanged,
  }) async {
    final didXorToAes = await _performMigrationIfNeeded(onStatusChanged: onStatusChanged);
    final didCbcToGcm = await _performGCMMigrationIfNeeded(onStatusChanged: onStatusChanged);
    return didXorToAes || didCbcToGcm;
  }

  /// Migrate all accounts from XOR encryption to AES-256.
  Future<bool> _performMigrationIfNeeded({
    required void Function(bool isMigrating) onStatusChanged,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMigrated = prefs.getBool(_migrationKey) ?? false;

      if (isMigrated) {
        debugPrint('✓ AES migration already complete');
        return false;
      }

      debugPrint('Starting AES migration...');
      onStatusChanged(true);

      final accountsToMigrate = await _db.getAllAccounts();

      if (accountsToMigrate.isEmpty) {
        debugPrint('No accounts to migrate');
        await prefs.setBool(_migrationKey, true);
        onStatusChanged(false);
        return false;
      }

      int successCount = 0;
      int failCount = 0;

      for (final account in accountsToMigrate) {
        try {
          if (account.secret.contains(':')) {
            debugPrint(
              'Account ${account.name} already AES encrypted, skipping',
            );
            successCount++;
            continue;
          }

          final newSecret = await _encryption.migrateToAES(account.secret);
          final updatedAccount = account.copyWith(secret: newSecret);
          await _db.updateAccount(updatedAccount);

          successCount++;
          debugPrint('✓ Migrated account: ${account.name}');
        } catch (e) {
          failCount++;
          debugPrint('✗ Migration failed for account ${account.name}: $e');
        }
      }

      await prefs.setBool(_migrationKey, true);

      debugPrint(
        'AES Migration complete: $successCount succeeded, $failCount failed',
      );

      onStatusChanged(false);
      return true;
    } catch (e) {
      debugPrint('Error during migration: $e');
      onStatusChanged(false);
      rethrow;
    }
  }

  /// Migrate all CBC-encrypted secrets to AES-256-GCM.
  Future<bool> _performGCMMigrationIfNeeded({
    required void Function(bool isMigrating) onStatusChanged,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_gcmMigrationKey) ?? false) return false;

      debugPrint('Starting GCM migration...');
      onStatusChanged(true);

      final accountsToMigrate = await _db.getAllAccounts();
      int successCount = 0;
      int failCount = 0;

      for (final account in accountsToMigrate) {
        try {
          if (account.secret.contains(':') &&
              account.secret.split(':')[0].length == AppConstants.cbcIvBase64Length) {
            final plainSecret = await _encryption.decrypt(account.secret);
            final gcmSecret = await _encryption.encrypt(plainSecret);
            await _db.updateAccount(account.copyWith(secret: gcmSecret));
            successCount++;
            debugPrint('✓ GCM migrated: ${account.name}');
          } else {
            successCount++;
          }
        } catch (e) {
          failCount++;
          debugPrint('✗ GCM migration failed for ${account.name}: $e');
        }
      }

      await prefs.setBool(_gcmMigrationKey, true);
      debugPrint(
        'GCM Migration complete: $successCount succeeded, $failCount failed',
      );

      onStatusChanged(false);
      return true;
    } catch (e) {
      debugPrint('Error during GCM migration: $e');
      onStatusChanged(false);
      return false;
    }
  }

  /// Force re-run XOR→AES migration (for testing or troubleshooting).
  Future<void> forceMigration({
    required void Function(bool isMigrating) onStatusChanged,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationKey, false);
    await _performMigrationIfNeeded(onStatusChanged: onStatusChanged);
  }

  /// Check if XOR→AES migration is complete.
  Future<bool> isMigrationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationKey) ?? false;
  }
}
