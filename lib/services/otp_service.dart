// File Path: sreerajp_authenticator/lib/services/otp_service.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 12
// Description: Widget for displaying individual account tiles with OTP codes and countdown timer.

import 'dart:convert';
import 'dart:math';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../services/encryption_service.dart';
import '../utils/constants.dart';

abstract class OTPException implements Exception {
  final String message;
  final Object? cause;
  const OTPException(this.message, [this.cause]);

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' ($cause)' : ''}';
}

class OTPDecryptionException extends OTPException {
  const OTPDecryptionException(super.message, [super.cause]);
}

class OTPInvalidSecretException extends OTPException {
  const OTPInvalidSecretException(super.message, [super.cause]);
}

class OTPSecretUnavailableException extends OTPException {
  const OTPSecretUnavailableException(super.message, [super.cause]);
}

class OTPUnexpectedException extends OTPException {
  const OTPUnexpectedException(super.message, [super.cause]);
}

class OTPGenerationResult {
  final String? code;
  final OTPException? error;

  const OTPGenerationResult.success(this.code) : error = null;
  const OTPGenerationResult.failure(this.error) : code = null;

  bool get isSuccess => code != null;
  bool get isFailure => error != null;
}

class _CacheEntry {
  final String secret;
  final DateTime timestamp;
  _CacheEntry(this.secret) : timestamp = DateTime.now();
}

class OTPService {
  static final EncryptionService _encryption = EncryptionService();
  static final Map<String, _CacheEntry> _cache = {};
  static final Map<String, Future<void>> _inFlight = {};

  /// How long decrypted secrets stay in memory before requiring re-decryption.
  static const Duration cacheTtl = AppConstants.cacheTtl;

  // === SHARED CRYPTO HELPERS ===

  static final RegExp _base32Regex = RegExp(r'^[A-Z2-7]+$');

  static String _cleanSecret(String secret) {
    return secret.toUpperCase().replaceAll(' ', '').replaceAll('-', '');
  }

  static bool _isValidBase32(String cleanSecret) {
    return _base32Regex.hasMatch(cleanSecret);
  }

  static Hash _getHashAlgorithm(String algorithm) {
    switch (algorithm.toUpperCase()) {
      case 'SHA256':
        return sha256;
      case 'SHA512':
        return sha512;
      default:
        return sha1;
    }
  }

  static Uint8List _int64Bytes(int value) {
    final data = ByteData(8);
    data.setUint64(0, value, Endian.big);
    return data.buffer.asUint8List();
  }

  /// Core OTP generation: HMAC + dynamic truncation (RFC 4226).
  static String _generateCode(
    Uint8List secretBytes,
    Uint8List messageBytes,
    Hash hashAlgorithm,
    int digits,
  ) {
    final hmac = Hmac(hashAlgorithm, secretBytes);
    final digest = hmac.convert(messageBytes);

    final offset = digest.bytes[digest.bytes.length - 1] & 0x0f;
    final binary =
        ((digest.bytes[offset] & 0x7f) << 24) |
        ((digest.bytes[offset + 1] & 0xff) << 16) |
        ((digest.bytes[offset + 2] & 0xff) << 8) |
        (digest.bytes[offset + 3] & 0xff);

    return (binary % pow(10, digits).toInt()).toString().padLeft(digits, '0');
  }

  // === ENHANCED DEBUGGING METHODS ===

  /// Generate detailed debug information for an account.
  /// Only available in debug builds — returns an empty map in release.
  static Future<Map<String, dynamic>> getDebugInfo(Account account) async {
    if (!kDebugMode) return const {};
    try {
      final actualSecret = await _getDecryptedSecret(account);
      final cleanSecret = _cleanSecret(actualSecret);

      final secretBytes = base32.decode(cleanSecret);
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeStep = timestamp ~/ account.period;

      return {
        'account_name': account.name,
        'issuer': account.issuer ?? 'N/A',
        'secret_length': cleanSecret.length,
        'secret_first_4': cleanSecret.substring(0, min(4, cleanSecret.length)),
        'secret_last_4': cleanSecret.substring(max(0, cleanSecret.length - 4)),
        'secret_bytes_length': secretBytes.length,
        'secret_bytes_hex': secretBytes
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(' '),
        'digits': account.digits,
        'period': account.period,
        'algorithm': account.algorithm,
        'current_timestamp_ms': DateTime.now().millisecondsSinceEpoch,
        'current_timestamp_s': timestamp,
        'time_step': timeStep,
        'device_time_utc': DateTime.now().toUtc().toIso8601String(),
        'is_base32_valid': _isValidBase32(cleanSecret),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Generate OTP for multiple time windows (for debugging time sync issues)
  static Future<Map<int, String>> generateTimeWindowCodes(
    Account account, {
    int windowsBefore = 1,
    int windowsAfter = 1,
  }) async {
    final codes = <int, String>{};

    try {
      final actualSecret = await _getDecryptedSecret(account);
      final cleanSecret = _cleanSecret(actualSecret);
      final secretBytes = base32.decode(cleanSecret);
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final currentTimeStep = currentTime ~/ account.period;
      final hashAlgorithm = _getHashAlgorithm(account.algorithm);

      for (int offset = -windowsBefore; offset <= windowsAfter; offset++) {
        final timeStep = currentTimeStep + offset;
        codes[offset] = _generateCode(
          secretBytes,
          _int64Bytes(timeStep),
          hashAlgorithm,
          account.digits,
        );
      }
    } catch (e) {
      debugPrint('Error generating TOTP window codes: $e');
    }

    return codes;
  }

  /// Compare two secrets byte by byte.
  /// Only available in debug builds — returns an empty map in release.
  static Future<Map<String, dynamic>> compareSecrets(
    String secret1,
    String secret2,
  ) async {
    if (!kDebugMode) return const {};
    try {
      final clean1 = _cleanSecret(secret1);
      final clean2 = _cleanSecret(secret2);

      final bytes1 = base32.decode(clean1);
      final bytes2 = base32.decode(clean2);

      return {
        'secrets_match': clean1 == clean2,
        'secret1_length': clean1.length,
        'secret2_length': clean2.length,
        'secret1_bytes': bytes1.length,
        'secret2_bytes': bytes2.length,
        'bytes_match': bytes1.toString() == bytes2.toString(),
        'secret1_hex': bytes1
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(' '),
        'secret2_hex': bytes2
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(' '),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Generate OTP Auth URI for the account
  static String generateOtpAuthUri(Account account, String plainSecret) {
    final params = <String, String>{
      'secret': _cleanSecret(plainSecret),
      'issuer': account.issuer ?? account.name,
      'algorithm': account.algorithm,
      'digits': account.digits.toString(),
      'period': account.period.toString(),
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final label = account.issuer != null
        ? '${Uri.encodeComponent(account.issuer!)}:${Uri.encodeComponent(account.name)}'
        : Uri.encodeComponent(account.name);

    return 'otpauth://totp/$label?$queryString';
  }

  // === MAIN TOTP GENERATION METHODS ===

  static Future<OTPGenerationResult> generateTOTPAsync(Account account) async {
    try {
      final actualSecret = await _getDecryptedSecret(account);
      final secretBytes = _decodeSecretBytes(
        account,
        actualSecret,
        requireMinLength: true,
      );
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeStep = timestamp ~/ account.period;

      return OTPGenerationResult.success(
        _generateCode(
          secretBytes,
          _int64Bytes(timeStep),
          _getHashAlgorithm(account.algorithm),
          account.digits,
        ),
      );
    } on OTPException catch (e) {
      debugPrint('Error generating TOTP for ${account.name}: $e');
      return OTPGenerationResult.failure(e);
    } catch (e) {
      final error = OTPUnexpectedException(
        'Failed to generate TOTP for account "${account.name}"',
        e,
      );
      debugPrint('Error generating TOTP for ${account.name}: $error');
      return OTPGenerationResult.failure(error);
    }
  }

  static OTPGenerationResult generateTOTP(Account account) {
    try {
      final actualSecret = _getCachedSecret(account);
      final secretBytes = _decodeSecretBytes(
        account,
        actualSecret,
        requireMinLength: true,
      );
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeStep = timestamp ~/ account.period;

      return OTPGenerationResult.success(
        _generateCode(
          secretBytes,
          _int64Bytes(timeStep),
          _getHashAlgorithm(account.algorithm),
          account.digits,
        ),
      );
    } on OTPException catch (e) {
      debugPrint('Error generating sync TOTP for ${account.name}: $e');
      return OTPGenerationResult.failure(e);
    } catch (e) {
      final error = OTPUnexpectedException(
        'Failed to generate TOTP for account "${account.name}"',
        e,
      );
      debugPrint('Error generating sync TOTP for ${account.name}: $error');
      return OTPGenerationResult.failure(error);
    }
  }

  static OTPGenerationResult generateHOTP(Account account) {
    try {
      final actualSecret = _getCachedSecret(account);
      final secretBytes = _decodeSecretBytes(account, actualSecret);
      final counter = account.counter ?? 0;

      return OTPGenerationResult.success(
        _generateCode(
          secretBytes,
          _int64Bytes(counter),
          _getHashAlgorithm(account.algorithm),
          account.digits,
        ),
      );
    } on OTPException catch (e) {
      debugPrint('Error generating HOTP for ${account.name}: $e');
      return OTPGenerationResult.failure(e);
    } catch (e) {
      final error = OTPUnexpectedException(
        'Failed to generate HOTP for account "${account.name}"',
        e,
      );
      debugPrint('Error generating HOTP for ${account.name}: $error');
      return OTPGenerationResult.failure(error);
    }
  }

  static Uint8List _decodeSecretBytes(
    Account account,
    String secret, {
    bool requireMinLength = false,
  }) {
    final cleanSecret = _cleanSecret(secret);
    if (!_isValidBase32(cleanSecret)) {
      throw OTPInvalidSecretException(
        'Secret for account "${account.name}" is not valid Base32',
      );
    }
    if (requireMinLength && cleanSecret.length < AppConstants.minSecretLength) {
      throw OTPInvalidSecretException(
        'Secret for account "${account.name}" is shorter than ${AppConstants.minSecretLength} characters',
      );
    }

    try {
      return base32.decode(cleanSecret);
    } catch (e) {
      throw OTPInvalidSecretException(
        'Secret for account "${account.name}" could not be decoded',
        e,
      );
    }
  }

  static String _getCachedSecret(Account account) {
    final cacheKey = '${account.id}_${account.secret}';
    final entry = _cache[cacheKey];

    if (entry != null && _isCacheValid(entry)) {
      return entry.secret;
    }

    _cache.remove(cacheKey);
    if (_isEncrypted(account.secret)) {
      _enqueueDecrypt(account);
      throw OTPSecretUnavailableException(
        'Secret for account "${account.name}" is not decrypted yet',
      );
    }

    return account.secret;
  }

  static bool _isEncrypted(String value) {
    // GCM/CBC encrypted values always contain ':' (<nonce>:<ciphertext> format).
    if (value.contains(':')) return true;

    final normalized = value.replaceAll(' ', '').replaceAll('-', '');
    if (_isValidBase32(normalized.toUpperCase())) {
      return false;
    }

    if (normalized.isEmpty || normalized.length % 4 != 0) {
      return false;
    }

    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    if (!base64Regex.hasMatch(normalized)) {
      return false;
    }

    try {
      base64.decode(normalized);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool _isCacheValid(_CacheEntry entry) {
    return DateTime.now().difference(entry.timestamp) < cacheTtl;
  }

  static void _putCache(String cacheKey, String decrypted) {
    _cache[cacheKey] = _CacheEntry(decrypted);
  }

  static void _enqueueDecrypt(Account account) {
    final cacheKey = '${account.id}_${account.secret}';
    if (_inFlight.containsKey(cacheKey)) return;
    final future = _decryptAndCache(account)
        .catchError((e) {
          debugPrint('Async decryption failed for ${account.name}: $e');
        })
        .whenComplete(() {
          _inFlight.remove(cacheKey);
        });
    _inFlight[cacheKey] = future;
  }

  static Future<void> _decryptAndCache(Account account) async {
    try {
      final decrypted = await _encryption.decrypt(account.secret);
      final cacheKey = '${account.id}_${account.secret}';
      _putCache(cacheKey, decrypted);
    } catch (e) {
      debugPrint('Decryption failed for ${account.name}: $e');
      throw OTPDecryptionException(
        'Failed to decrypt secret for account "${account.name}"',
        e,
      );
    }
  }

  static Future<String> _getDecryptedSecret(Account account) async {
    final cacheKey = '${account.id}_${account.secret}';

    final entry = _cache[cacheKey];
    if (entry != null && _isCacheValid(entry)) {
      return entry.secret;
    }

    if (_isEncrypted(account.secret)) {
      try {
        final decrypted = await _encryption.decrypt(account.secret);
        _putCache(cacheKey, decrypted);
        return decrypted;
      } catch (e) {
        throw OTPDecryptionException(
          'Failed to decrypt secret for account "${account.name}"',
          e,
        );
      }
    }

    return account.secret;
  }

  static void clearCache() {
    _cache.clear();
    _inFlight.clear();
  }

  static Future<void> preDecryptAllSecrets(List<Account> accounts) async {
    for (final account in accounts) {
      if (_isEncrypted(account.secret)) {
        try {
          await _decryptAndCache(account);
        } catch (e) {
          debugPrint('Pre-decryption failed for ${account.name}: $e');
          // Continue with other accounts — individual OTP generation
          // will surface the error for this account.
        }
      }
    }
  }

  static int getRemainingSeconds(int period) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return period - (now % period);
  }

  static Account? parseOtpAuthUri(String uri) {
    try {
      final parsedUri = Uri.parse(uri);
      if (parsedUri.scheme != 'otpauth') return null;

      final type = parsedUri.host;
      if (type != 'totp' && type != 'hotp') return null;

      final pathSegments = parsedUri.path.split(':');
      final issuer = pathSegments.length > 1
          ? pathSegments[0].substring(1)
          : null;
      final name = pathSegments.length > 1
          ? pathSegments[1]
          : pathSegments[0].substring(1);

      final secret = parsedUri.queryParameters['secret'] ?? '';
      final digits =
          int.tryParse(parsedUri.queryParameters['digits'] ?? '6') ?? 6;
      final period =
          int.tryParse(parsedUri.queryParameters['period'] ?? '30') ?? 30;
      final counter = int.tryParse(parsedUri.queryParameters['counter'] ?? '0');
      final algorithm =
          parsedUri.queryParameters['algorithm']?.toUpperCase() ?? 'SHA1';

      return Account(
        name: name,
        secret: secret,
        issuer: issuer ?? parsedUri.queryParameters['issuer'],
        type: type,
        counter: counter,
        digits: digits,
        period: period,
        algorithm: algorithm,
      );
    } catch (e) {
      return null;
    }
  }
}
