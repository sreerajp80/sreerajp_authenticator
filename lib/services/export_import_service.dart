// File Path: sreerajp_authenticator/lib/services/export_import_service.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2026 August 01
// Description: Service for exporting and importing account data with re-encryption

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

import '../models/account.dart';
import '../utils/app_logger.dart';
import '../utils/constants.dart';
import 'encryption_service.dart';
import 'p2p_sync_service.dart';

/// The backup password is wrong or the file is damaged. The UI shows a
/// localized message for it.
class BackupPasswordException implements Exception {
  const BackupPasswordException();

  @override
  String toString() => 'Invalid password or corrupted file';
}

/// The backup file is above [AppConstants.backupMaxFileBytes]. It was not read.
class BackupFileTooLargeException implements Exception {
  const BackupFileTooLargeException();

  @override
  String toString() => 'Backup file is too large';
}

/// The backup opened, but its content is malformed or above the import limits.
class BackupContentException implements Exception {
  const BackupContentException();

  @override
  String toString() => 'Backup content is not valid';
}

/// Saves [bytes] somewhere the user chooses. Returns the saved location, or null
/// if the user cancelled.
typedef BackupFileSaver = Future<Uri?> Function(
  String fileName,
  Uint8List bytes,
);

class ExportImportService {
  ExportImportService({@visibleForTesting BackupFileSaver? fileSaver})
    : _fileSaver = fileSaver ?? _saveWithSystemDialog;

  final _encryptionService = EncryptionService();
  final BackupFileSaver _fileSaver;

  static Future<Uri?> _saveWithSystemDialog(String fileName, Uint8List bytes) =>
      FilePicker.saveFile(fileName: fileName, bytes: bytes);

  // Export accounts as encrypted JSON (RECOMMENDED).
  // Returns true only when the file was really saved. Returns false if the user
  // cancelled the save screen or saving failed.
  Future<bool> exportAccountsEncrypted(
    List<Account> accounts,
    String password,
  ) async {
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

      // Step 2: Convert to JSON
      final jsonData = _dataToJson(decryptedAccounts);

      // Step 3: Encrypt with user password
      final encryptedData = _encryptData(jsonData, password);

      final fileName =
          'authenticator_backup_encrypted_${DateTime.now().millisecondsSinceEpoch}.aes';

      final saved = await _fileSaver(
        fileName,
        Uint8List.fromList(utf8.encode(encryptedData)),
      );

      return saved != null;
    } catch (e) {
      AppLogger.error('Failed to export encrypted backup', e);
      return false;
    }
  }

  // Import accounts from encrypted file.
  // Returns parsed backup data map (with 'accounts' key), or null if the user
  // cancelled the file picker. Throws [BackupPasswordException],
  // [BackupFileTooLargeException] or [BackupContentException] on failure.
  // Secrets are plaintext — the caller is responsible for encrypting with the
  // device key.
  Future<Map<String, dynamic>?> importAccountsEncrypted(String password) async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['aes'],
    );

    if (picked == null) {
      return null;
    }

    final path = picked.path;
    if (path == null) {
      throw const BackupPasswordException();
    }

    return readBackupFile(File(path), password);
  }

  /// Check the size of [file], then read, decrypt and validate it.
  @visibleForTesting
  Future<Map<String, dynamic>> readBackupFile(
    File file,
    String password,
  ) async {
    final String encryptedData;
    try {
      if (await file.length() > AppConstants.backupMaxFileBytes) {
        throw const BackupFileTooLargeException();
      }
      encryptedData = await file.readAsString();
    } on BackupFileTooLargeException {
      rethrow;
    } catch (e) {
      // Not readable as text, so it is not a backup made by this app.
      AppLogger.error('Failed to read backup file', e);
      throw const BackupPasswordException();
    }

    // Step 1: Decrypt with user password
    final jsonData = _decryptData(encryptedData, password);
    if (jsonData == null) {
      throw const BackupPasswordException();
    }

    // Step 2: Parse accounts
    final parsed = _parseBackupJson(jsonData);
    if (parsed == null) {
      throw const BackupContentException();
    }
    return parsed;
  }

  String _dataToJson(List<Account> accounts) {
    final backup = {
      'version': AppConstants.backupVersion,
      'created': DateTime.now().toIso8601String(),
      'accounts': accounts.map((account) => account.toMap()).toList(),
    };

    return jsonEncode(backup);
  }

  /// Parse backup JSON into a map with an 'accounts' list.
  /// The same limits as Wi-Fi sync apply (account count, field length).
  Map<String, dynamic>? _parseBackupJson(String jsonData) {
    try {
      final parsed = P2pSyncService.validateAndParse(jsonData);
      return {'accounts': parsed['accounts'] ?? <Account>[]};
    } catch (e) {
      AppLogger.error('Failed to parse backup JSON', e);
      return null;
    }
  }

  // Derive a 32-byte AES-256 key from password + salt using PBKDF2-HMAC-SHA256.
  Uint8List _deriveKey(
    String password,
    Uint8List salt, {
    int iterations = AppConstants.pbkdf2Iterations,
  }) {
    final pbkdf2 = PBKDF2KeyDerivator(
      HMac(SHA256Digest(), AppConstants.hmacBlockSize),
    )..init(Pbkdf2Parameters(salt, iterations, AppConstants.pbkdf2HashSize));
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

  // Reads the v3 format. Any other format returns null.
  String? _decryptData(String encryptedData, String password) {
    try {
      if (!encryptedData.startsWith('v3:')) return null;

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
    } catch (e) {
      AppLogger.error('Failed to decrypt backup payload', e);
      return null;
    }
  }

  @visibleForTesting
  String encryptDataForTest(String plainText, String password) =>
      _encryptData(plainText, password);

  @visibleForTesting
  String? decryptDataForTest(String encryptedData, String password) =>
      _decryptData(encryptedData, password);

  @visibleForTesting
  String dataToJsonForTest(List<Account> accounts) => _dataToJson(accounts);

  @visibleForTesting
  Map<String, dynamic>? parseBackupJsonForTest(String jsonData) =>
      _parseBackupJson(jsonData);
}
