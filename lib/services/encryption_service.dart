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
      final keyBytes = List<int>.generate(
        AppConstants.aesKeySize,
        (_) => random.nextInt(256),
      );
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
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt the AES-256-GCM format "<nonce>:<ciphertext>". Anything else throws.
  Future<String> decrypt(String encryptedText) async {
    if (encryptedText.isEmpty) return encryptedText;

    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2 ||
          parts[0].length != AppConstants.gcmNonceBase64Length) {
        throw Exception('Invalid encrypted data format');
      }

      final ivBase64 = parts[0];
      final keyString = await _getOrCreateKey();
      final key = enc.Key.fromBase64(keyString);
      final iv = enc.IV.fromBase64(ivBase64);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}
