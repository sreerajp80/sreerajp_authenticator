// File Path: sreerajp_authenticator/lib/services/encryption_service.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 14
// Description: Service for handling AES encryption and secure storage

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'dart:convert';
import 'dart:math';

import '../utils/constants.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const String _keyAlias = AppConstants.encryptionKeyAlias;

  // Generate or retrieve encryption key
  Future<String> _getOrCreateKey() async {
    String? key = await _storage.read(key: _keyAlias);
    if (key == null) {
      // Generate a new secure random key (32 bytes for AES-256)
      final random = Random.secure();
      final keyBytes = List<int>.generate(AppConstants.aesKeySize, (_) => random.nextInt(256));
      key = base64.encode(keyBytes);
      await _storage.write(key: _keyAlias, value: key);
    }
    return key;
  }

  // Encrypt with AES-256-GCM (12-byte nonce; auth tag is appended inside ciphertext)
  Future<String> encrypt(String plainText) async {
    if (plainText.isEmpty) return plainText;

    try {
      final keyString = await _getOrCreateKey();
      final key = enc.Key.fromBase64(keyString);

      // GCM requires a 12-byte (96-bit) nonce
      final iv = enc.IV.fromSecureRandom(AppConstants.gcmNonceSize);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Format: "<12-byte-nonce-base64>:<ciphertext+tag-base64>"
      // 12-byte nonce encodes to exactly 16 base64 chars (no padding),
      // distinguishing it from the legacy 16-byte CBC IV (24 chars).
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt — handles all three historical formats:
  //   • No ':' separator      → legacy XOR
  //   • IV is 16 base64 chars → AES-256-GCM (12-byte nonce)
  //   • IV is 24 base64 chars → AES-256-CBC (16-byte IV, old format)
  Future<String> decrypt(String encryptedText) async {
    if (encryptedText.isEmpty) return encryptedText;

    try {
      if (!encryptedText.contains(':')) {
        return await _legacyDecrypt(encryptedText);
      }

      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }

      final ivBase64 = parts[0];
      final keyString = await _getOrCreateKey();
      final key = enc.Key.fromBase64(keyString);
      final iv = enc.IV.fromBase64(ivBase64);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);

      final mode =
          ivBase64.length == AppConstants.gcmNonceBase64Length ? enc.AESMode.gcm : enc.AESMode.cbc;

      final encrypter = enc.Encrypter(enc.AES(key, mode: mode));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Legacy XOR decryption for backward compatibility
  Future<String> _legacyDecrypt(String encryptedText) async {
    try {
      final key = await _getOrCreateKey();
      final encryptedBytes = base64.decode(encryptedText);
      final keyBytes = base64.decode(key);
      final decryptedBytes = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw Exception('Legacy decryption failed: $e');
    }
  }

  // Migrate old XOR-encrypted data to AES (call this after app update)
  Future<String> migrateToAES(String oldEncrypted) async {
    final decrypted = await _legacyDecrypt(oldEncrypted);
    return await encrypt(decrypted);
  }

  Future<void> storeSecureData(String key, String value) async {
    final encryptedValue = await encrypt(value);
    await _storage.write(key: key, value: encryptedValue);
  }

  Future<String?> getSecureData(String key) async {
    final encryptedValue = await _storage.read(key: key);
    if (encryptedValue == null) return null;
    return await decrypt(encryptedValue);
  }

  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAllSecureData() async {
    await _storage.deleteAll();
  }

}
