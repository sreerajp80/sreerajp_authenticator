// File Path: sreerajp_authenticator/lib/services/export_import_service.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2025 October 14
// Description: Service for exporting and importing account data with re-encryption

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

import '../models/account.dart';
import '../models/group.dart';
import '../utils/constants.dart';
import 'encryption_service.dart';

class ExportImportService {
  final _encryptionService = EncryptionService();

  // Export accounts and groups as encrypted JSON (RECOMMENDED)
  Future<bool> exportAccountsEncrypted(
    List<Account> accounts,
    List<Group> groups,
    String password,
  ) async {
    File? file;
    try {
      // Step 1: Decrypt all secrets with device key
      final decryptedAccounts = await Future.wait(
        accounts.map((account) async {
          final decryptedSecret = await _encryptionService.decrypt(
            account.secret,
          );
          return account.copyWith(secret: decryptedSecret);
        }),
      );

      // Step 2: Convert to JSON (includes groups)
      final jsonData = _dataToJson(decryptedAccounts, groups);

      // Step 3: Encrypt with user password
      final encryptedData = _encryptData(jsonData, password);

      final fileName =
          'authenticator_backup_encrypted_${DateTime.now().millisecondsSinceEpoch}.aes';

      final directory = await getTemporaryDirectory();
      file = File('${directory.path}/$fileName');
      await file.writeAsString(encryptedData);

      final xFile = XFile(file.path);
      final params = ShareParams(
        files: [xFile],
        subject: 'Authenticator Encrypted Backup',
        text: 'Encrypted backup created on ${DateTime.now().toIso8601String()}',
      );
      final result = await SharePlus.instance.share(params);

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error exporting encrypted accounts: $e');
      return false;
    } finally {
      try { await file?.delete(); } catch (_) {}
    }
  }

  // Import accounts and groups from encrypted file
  // Returns parsed backup data map (with 'accounts' and 'groups' keys),
  // or null if import failed. Secrets are plaintext — the caller is
  // responsible for encrypting with the device key.
  Future<Map<String, dynamic>?> importAccountsEncrypted(String password) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['aes'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = File(result.files.single.path!);
      final encryptedData = await file.readAsString();

      // Step 1: Decrypt with user password
      final jsonData = _decryptData(encryptedData, password);
      if (jsonData == null) {
        throw Exception('Invalid password or corrupted file');
      }

      // Step 2: Parse accounts and groups
      return _parseBackupJson(jsonData);
    } catch (e) {
      debugPrint('Error importing encrypted accounts: $e');
      return null;
    }
  }

  // Export accounts as plain JSON (NOT RECOMMENDED - for backward compatibility only)
  // Consider removing this after migration
  Future<bool> exportAccounts(List<Account> accounts, List<Group> groups) async {
    File? file;
    try {
      // Decrypt secrets before exporting
      final decryptedAccounts = await Future.wait(
        accounts.map((account) async {
          final decryptedSecret = await _encryptionService.decrypt(
            account.secret,
          );
          return account.copyWith(secret: decryptedSecret);
        }),
      );

      final jsonData = _dataToJson(decryptedAccounts, groups);
      final fileName =
          'authenticator_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      final directory = await getTemporaryDirectory();
      file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonData);

      final xFile = XFile(file.path);
      final params = ShareParams(
        files: [xFile],
        subject: 'Authenticator Backup (UNENCRYPTED)',
        text: '⚠️ WARNING: This backup contains unencrypted secrets!',
      );
      final result = await SharePlus.instance.share(params);

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error exporting accounts: $e');
      return false;
    } finally {
      try { await file?.delete(); } catch (_) {}
    }
  }

  // Import accounts and groups from JSON file
  Future<Map<String, dynamic>?> importAccounts() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = File(result.files.single.path!);
      final jsonData = await file.readAsString();

      return _parseBackupJson(jsonData);
    } catch (e) {
      debugPrint('Error importing accounts: $e');
      return null;
    }
  }

  // Export accounts as CSV (NOT RECOMMENDED - secrets exposed)
  Future<bool> exportAccountsAsCSV(List<Account> accounts, List<Group> groups) async {
    File? file;
    try {
      // Decrypt secrets before CSV export
      final decryptedAccounts = await Future.wait(
        accounts.map((account) async {
          final decryptedSecret = await _encryptionService.decrypt(
            account.secret,
          );
          return account.copyWith(secret: decryptedSecret);
        }),
      );

      final csvData = _accountsToCsv(decryptedAccounts);
      final fileName =
          'authenticator_backup_${DateTime.now().millisecondsSinceEpoch}.csv';

      final directory = await getTemporaryDirectory();
      file = File('${directory.path}/$fileName');
      await file.writeAsString(csvData);

      final xFile = XFile(file.path);
      final params = ShareParams(
        files: [xFile],
        subject: 'Authenticator Backup (CSV - UNENCRYPTED)',
        text: '⚠️ WARNING: This CSV contains unencrypted secrets!',
      );
      final result = await SharePlus.instance.share(params);

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error exporting accounts as CSV: $e');
      return false;
    } finally {
      try { await file?.delete(); } catch (_) {}
    }
  }

  String _dataToJson(List<Account> accounts, List<Group> groups) {
    final backup = {
      'version': AppConstants.backupVersion,
      'created': DateTime.now().toIso8601String(),
      'accounts': accounts.map((account) => account.toMap()).toList(),
      'groups': groups.map((group) => group.toMap()).toList(),
    };

    return jsonEncode(backup);
  }

  /// Parse backup JSON into a map with 'accounts' and 'groups' lists.
  /// Supports both old (no groups) and new (with groups) backup formats.
  Map<String, dynamic>? _parseBackupJson(String jsonData) {
    try {
      final Map<String, dynamic> backup = jsonDecode(jsonData);
      final List<dynamic> accountsJson = backup['accounts'] ?? [];
      final List<dynamic> groupsJson = backup['groups'] ?? [];

      return {
        'accounts': accountsJson
            .map((json) => Account.fromMap(json as Map<String, dynamic>))
            .toList(),
        'groups': groupsJson
            .map((json) => Group.fromMap(json as Map<String, dynamic>))
            .toList(),
      };
    } catch (e) {
      debugPrint('Error parsing backup JSON: $e');
      return null;
    }
  }

  String _accountsToCsv(List<Account> accounts) {
    final StringBuffer csv = StringBuffer();

    csv.writeln(
      'Name,Issuer,Secret,Digits,Period,Algorithm,Group ID,Created At',
    );

    for (final account in accounts) {
      csv.writeln(
        '"${account.name}",'
        '"${account.issuer ?? ''}",'
        '"${account.secret}",'
        '${account.digits},'
        '${account.period},'
        '"${account.algorithm}",'
        '${account.groupId ?? ""},'
        '"${account.createdAt.toIso8601String()}"',
      );
    }

    return csv.toString();
  }

  // Derive a 32-byte AES-256 key from password + salt using PBKDF2-HMAC-SHA256.
  Uint8List _deriveKey(String password, Uint8List salt, {int iterations = AppConstants.pbkdf2Iterations}) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), AppConstants.hmacBlockSize))
      ..init(Pbkdf2Parameters(salt, iterations, AppConstants.pbkdf2HashSize));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  // v3 format: PBKDF2-derived key + AES-256-GCM
  // Output: "v3:<salt_b64>:<nonce_b64>:<ciphertext_b64>"
  String _encryptData(String plainText, String password) {
    final salt = encrypt.SecureRandom(AppConstants.saltSize).bytes;
    final keyBytes = _deriveKey(password, salt);
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromSecureRandom(AppConstants.gcmNonceSize);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final saltB64 = base64Encode(salt);
    return 'v3:$saltB64:${iv.base64}:${encrypted.base64}';
  }

  // Supports all backup formats:
  //   "v3:<salt>:<nonce>:<ciphertext>"  → PBKDF2 + AES-256-GCM (current)
  //   "v2:<nonce>:<ciphertext>"         → SHA-256 key + AES-256-GCM (legacy)
  //   "<iv>:<ciphertext>"               → SHA-256 key + AES-256-CTR/SIC (legacy)
  String? _decryptData(String encryptedData, String password) {
    try {
      if (encryptedData.startsWith('v3:')) {
        final rest = encryptedData.substring(3);
        final parts = rest.split(':');
        if (parts.length != 3) return null;

        final salt = base64Decode(parts[0]);
        final iv = encrypt.IV.fromBase64(parts[1]);
        final encrypted = encrypt.Encrypted.fromBase64(parts[2]);

        final keyBytes = _deriveKey(password, Uint8List.fromList(salt));
        final key = encrypt.Key(keyBytes);
        final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.gcm),
        );
        return encrypter.decrypt(encrypted, iv: iv);
      } else if (encryptedData.startsWith('v2:')) {
        final legacyKey = encrypt.Key.fromUtf8(_legacyPadPassword(password));
        final rest = encryptedData.substring(3);
        final parts = rest.split(':');
        if (parts.length != 2) return null;

        final iv = encrypt.IV.fromBase64(parts[0]);
        final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
        final encrypter = encrypt.Encrypter(
          encrypt.AES(legacyKey, mode: encrypt.AESMode.gcm),
        );
        return encrypter.decrypt(encrypted, iv: iv);
      } else {
        // Legacy CTR/SIC backup
        final legacyKey = encrypt.Key.fromUtf8(_legacyPadPassword(password));
        final parts = encryptedData.split(':');
        if (parts.length != 2) return null;

        final iv = encrypt.IV.fromBase64(parts[0]);
        final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
        final encrypter = encrypt.Encrypter(
          encrypt.AES(legacyKey, mode: encrypt.AESMode.sic),
        );
        return encrypter.decrypt(encrypted, iv: iv);
      }
    } catch (e) {
      debugPrint('Error decrypting data: $e');
      return null;
    }
  }

  // Kept only for decrypting old v2 and legacy backups.
  String _legacyPadPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, AppConstants.aesKeySize);
  }

  @visibleForTesting
  String encryptDataForTest(String plainText, String password) =>
      _encryptData(plainText, password);

  @visibleForTesting
  String? decryptDataForTest(String encryptedData, String password) =>
      _decryptData(encryptedData, password);

  @visibleForTesting
  String dataToJsonForTest(List<Account> accounts, List<Group> groups) =>
      _dataToJson(accounts, groups);

  @visibleForTesting
  Map<String, dynamic>? parseBackupJsonForTest(String jsonData) =>
      _parseBackupJson(jsonData);

  @visibleForTesting
  String accountsToCsvForTest(List<Account> accounts) =>
      _accountsToCsv(accounts);
}
