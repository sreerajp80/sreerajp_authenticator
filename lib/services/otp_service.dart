// File Path: sreerajp_authenticator/lib/services/otp_service.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 12
// Description: Widget for displaying individual account tiles with OTP codes and countdown timer.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';

import '../models/account.dart';
import '../services/encryption_service.dart';
import '../utils/app_logger.dart';
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

  static const String _steamAlphabet = '23456789BCDFGHJKMNPQRTVWXY';
  static final RegExp _base32Regex = RegExp(r'^[A-Z2-7]+$');
  static final RegExp _hexRegex = RegExp(r'^[0-9A-FA-F]+$');

  static String _cleanSecret(String secret) {
    return secret.toUpperCase().replaceAll(' ', '').replaceAll('-', '');
  }

  static bool _isValidBase32(String cleanSecret) {
    return _base32Regex.hasMatch(cleanSecret);
  }

  static bool _isHex(String cleanSecret) {
    return cleanSecret.isNotEmpty &&
        cleanSecret.length % 2 == 0 &&
        _hexRegex.hasMatch(cleanSecret);
  }

  static Uint8List _hexDecode(String hex) {
    final bytes = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return bytes;
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

  /// Core OTP generation dispatch helper.
  static String _generateCodeForAccount(
    Account account,
    Uint8List secretBytes,
    int timeStep,
    String plainSecret,
  ) {
    final algo = account.algorithm.toUpperCase();
    final type = account.type.toLowerCase();

    if (algo == 'STEAM' || type == 'steam') {
      return _generateSteamCode(secretBytes, timeStep);
    } else if (algo == 'BLIZZARD' || type == 'blizzard') {
      return _generateCode(
        secretBytes,
        _int64Bytes(timeStep),
        sha1,
        account.digits == 6 ? 8 : account.digits,
      );
    } else if (algo == 'YUBIKEY') {
      return _generateCode(
        secretBytes,
        _int64Bytes(timeStep),
        sha1,
        account.digits,
      );
    } else {
      return _generateCode(
        secretBytes,
        _int64Bytes(timeStep),
        _getHashAlgorithm(account.algorithm),
        account.digits,
      );
    }
  }

  /// Steam Guard TOTP: HMAC-SHA1 dynamic truncation mapped to 5-char alphabet.
  static String _generateSteamCode(Uint8List secretBytes, int timeStep) {
    final messageBytes = _int64Bytes(timeStep);
    final hmac = Hmac(sha1, secretBytes);
    final digest = hmac.convert(messageBytes);

    final offset = digest.bytes[digest.bytes.length - 1] & 0x0f;
    int binary =
        ((digest.bytes[offset] & 0x7f) << 24) |
        ((digest.bytes[offset + 1] & 0xff) << 16) |
        ((digest.bytes[offset + 2] & 0xff) << 8) |
        (digest.bytes[offset + 3] & 0xff);

    final buffer = StringBuffer();
    for (int i = 0; i < 5; i++) {
      buffer.write(_steamAlphabet[binary % 26]);
      binary ~/= 26;
    }
    return buffer.toString();
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

  /// Generate OTP Auth URI for the account
  static String generateOtpAuthUri(Account account, String plainSecret) {
    final isHotp = account.type.toLowerCase() == 'hotp';
    final params = <String, String>{
      'secret': _cleanSecret(plainSecret),
      'issuer': account.issuer ?? account.name,
      'algorithm': account.algorithm,
      'digits': account.digits.toString(),
      if (isHotp)
        'counter': (account.counter ?? 0).toString()
      else
        'period': account.period.toString(),
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final label = account.issuer != null
        ? '${Uri.encodeComponent(account.issuer!)}:${Uri.encodeComponent(account.name)}'
        : Uri.encodeComponent(account.name);

    return 'otpauth://${isHotp ? 'hotp' : 'totp'}/$label?$queryString';
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
        _generateCodeForAccount(account, secretBytes, timeStep, actualSecret),
      );
    } on OTPException catch (e) {
      AppLogger.error('Failed to generate TOTP', e);
      return OTPGenerationResult.failure(e);
    } catch (e) {
      final error = OTPUnexpectedException(
        'Failed to generate TOTP for account "${account.name}"',
        e,
      );
      AppLogger.error('Failed to generate TOTP', error);
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
        _generateCodeForAccount(account, secretBytes, timeStep, actualSecret),
      );
    } on OTPException catch (e) {
      AppLogger.error('Failed to generate cached TOTP', e);
      return OTPGenerationResult.failure(e);
    } catch (e) {
      final error = OTPUnexpectedException(
        'Failed to generate TOTP for account "${account.name}"',
        e,
      );
      AppLogger.error('Failed to generate cached TOTP', error);
      return OTPGenerationResult.failure(error);
    }
  }

  /// Code for the account's stored counter. Decrypts the secret if it is not
  /// cached. Does not move the counter; see [AccountsProvider.nextHotpCode].
  static Future<OTPGenerationResult> generateHOTPAsync(Account account) async {
    try {
      final actualSecret = await _getDecryptedSecret(account);
      final secretBytes = _decodeSecretBytes(account, actualSecret);
      return OTPGenerationResult.success(
        _generateCode(
          secretBytes,
          _int64Bytes(account.counter ?? 0),
          _getHashAlgorithm(account.algorithm),
          account.digits,
        ),
      );
    } on OTPException catch (e) {
      AppLogger.error('Failed to generate HOTP', e);
      return OTPGenerationResult.failure(e);
    } catch (e) {
      final error = OTPUnexpectedException(
        'Failed to generate HOTP for account "${account.name}"',
        e,
      );
      AppLogger.error('Failed to generate HOTP', error);
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
      AppLogger.error('Failed to generate HOTP', e);
      return OTPGenerationResult.failure(e);
    } catch (e) {
      final error = OTPUnexpectedException(
        'Failed to generate HOTP for account "${account.name}"',
        e,
      );
      AppLogger.error('Failed to generate HOTP', error);
      return OTPGenerationResult.failure(error);
    }
  }

  static Uint8List _decodeSecretBytes(
    Account account,
    String secret, {
    bool requireMinLength = false,
  }) {
    final cleanSecret = _cleanSecret(secret);
    final algo = account.algorithm.toUpperCase();
    final type = account.type.toLowerCase();

    // mOTP is no longer supported. An account left from an old version must
    // show no code, not a wrong one.
    if (algo == 'MOTP' || type == 'motp') {
      throw OTPInvalidSecretException(
        'Account "${account.name}" uses mOTP, which is not supported',
      );
    }

    if (requireMinLength &&
        algo != 'STEAM' &&
        type != 'steam' &&
        cleanSecret.length < AppConstants.minSecretLength) {
      throw OTPInvalidSecretException(
        'Secret for account "${account.name}" is shorter than ${AppConstants.minSecretLength} characters',
      );
    }

    if (_isValidBase32(cleanSecret)) {
      try {
        return base32.decode(cleanSecret);
      } catch (e) {
        throw OTPInvalidSecretException(
          'Secret for account "${account.name}" could not be decoded',
          e,
        );
      }
    } else if (_isHex(cleanSecret)) {
      try {
        return _hexDecode(cleanSecret);
      } catch (e) {
        throw OTPInvalidSecretException(
          'Hex secret for account "${account.name}" could not be decoded',
          e,
        );
      }
    } else {
      throw OTPInvalidSecretException(
        'Secret for account "${account.name}" is not valid Base32 or Hex',
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
    if (_isValidBase32(normalized.toUpperCase()) ||
        _isHex(normalized.toUpperCase())) {
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
          AppLogger.error('Background OTP secret decryption failed', e);
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
      AppLogger.error('OTP secret decryption failed', e);
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
          AppLogger.error('Failed to pre-decrypt an OTP secret', e);
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

  static Account? parseOtpAuthUri(String uriStr) {
    try {
      final parsedUri = Uri.parse(uriStr.trim());
      final scheme = parsedUri.scheme.toLowerCase();

      if (scheme == 'steam') {
        String secret = parsedUri.queryParameters['secret'] ?? '';
        String label = 'Steam';

        if (secret.isEmpty) {
          if (parsedUri.host.isNotEmpty) {
            secret = parsedUri.host;
          } else if (parsedUri.path.isNotEmpty) {
            secret = parsedUri.path.replaceAll('/', '');
          }
        }

        if (parsedUri.path.contains(':')) {
          label = parsedUri.path.split(':').last;
        } else if (parsedUri.pathSegments.isNotEmpty &&
            secret != parsedUri.pathSegments.last) {
          label = parsedUri.pathSegments.last;
        }

        return Account(
          name: label.isEmpty ? 'Steam' : label,
          secret: _cleanSecret(secret),
          issuer: 'Steam',
          type: 'totp',
          digits: 5,
          period: 30,
          algorithm: 'STEAM',
        );
      }

      if (scheme != 'otpauth') return null;

      final rawType = parsedUri.host.toLowerCase();
      if (rawType != 'totp' &&
          rawType != 'hotp' &&
          rawType != 'steam' &&
          rawType != 'blizzard' &&
          rawType != 'yubikey') {
        return null;
      }

      final pathSegments = parsedUri.path.split(':');
      final issuer = pathSegments.length > 1
          ? pathSegments[0].startsWith('/')
                ? pathSegments[0].substring(1)
                : pathSegments[0]
          : null;
      final name = pathSegments.length > 1
          ? pathSegments[1]
          : pathSegments[0].startsWith('/')
          ? pathSegments[0].substring(1)
          : pathSegments[0];

      final secret = parsedUri.queryParameters['secret'] ?? '';
      var algorithm =
          parsedUri.queryParameters['algorithm']?.toUpperCase() ?? 'SHA1';
      if (algorithm == 'MOTP') return null;
      final type =
          (rawType == 'steam' || rawType == 'blizzard' || rawType == 'yubikey')
          ? 'totp'
          : rawType;

      if (rawType == 'steam' || algorithm == 'STEAM') {
        algorithm = 'STEAM';
      } else if (rawType == 'blizzard' || algorithm == 'BLIZZARD') {
        algorithm = 'BLIZZARD';
      } else if (rawType == 'yubikey' || algorithm == 'YUBIKEY') {
        algorithm = 'YUBIKEY';
      }

      final digits =
          int.tryParse(parsedUri.queryParameters['digits'] ?? '') ??
          (algorithm == 'STEAM' ? 5 : (algorithm == 'BLIZZARD' ? 8 : 6));
      final period =
          int.tryParse(parsedUri.queryParameters['period'] ?? '') ?? 30;
      final counter = int.tryParse(parsedUri.queryParameters['counter'] ?? '0');
      if (type == 'hotp' && counter != null && counter < 0) return null;

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
