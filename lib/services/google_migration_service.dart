// File Path: sreerajp_authenticator/lib/services/google_migration_service.dart
// Author: Sreeraj P
// Description: Reads the otpauth-migration:// QR codes that Google Authenticator
// exports, and collects the QR codes of one export. All input is untrusted.

import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';

import '../models/account.dart';
import '../utils/constants.dart';

enum GoogleMigrationErrorCode { notMigrationLink, malformedData }

/// A whole QR code could not be used. Holds a code only, never scanned data,
/// so it is safe to log.
class GoogleMigrationException implements Exception {
  final GoogleMigrationErrorCode code;

  const GoogleMigrationException(this.code);

  @override
  String toString() => 'GoogleMigrationException(${code.name})';
}

/// Why one account in a QR code cannot be imported.
enum GoogleMigrationProblem {
  damaged,
  missingSecret,
  shortSecret,
  unsupportedAlgorithm,
  unsupportedDigits,
  unsupportedType,
}

/// One account in a QR code. Exactly one of [account] and [problem] is set.
class GoogleMigrationEntry {
  final String name;
  final String? issuer;
  final Account? account;
  final GoogleMigrationProblem? problem;

  const GoogleMigrationEntry.ok(Account this.account)
    : name = '',
      issuer = null,
      problem = null;

  const GoogleMigrationEntry.problem(
    GoogleMigrationProblem this.problem, {
    this.name = '',
    this.issuer,
  }) : account = null;

  String get displayName => account?.name ?? name;

  String? get displayIssuer => account?.issuer ?? issuer;
}

/// The content of one QR code. [batchIndex] counts from 0.
class GoogleMigrationBatch {
  final List<GoogleMigrationEntry> entries;
  final int batchSize;
  final int batchIndex;
  final int batchId;

  const GoogleMigrationBatch({
    required this.entries,
    required this.batchSize,
    required this.batchIndex,
    required this.batchId,
  });
}

class GoogleMigrationService {
  GoogleMigrationService._();

  /// A QR code holds under 4,300 characters, so this leaves room to spare.
  static const int maxLinkLength = 8192;
  static const int maxBatchSize = 256;
  static const int maxSecretBytes = 512;
  static const int maxTextBytes = 512;

  /// Google's format has no period field. Its TOTP accounts always use this.
  static const int _totpPeriod = 30;

  static bool isMigrationLink(String text) =>
      text.trimLeft().toLowerCase().startsWith('otpauth-migration://');

  /// Reads one QR code. Throws only [GoogleMigrationException].
  static GoogleMigrationBatch parse(String link) {
    final trimmed = link.trim();
    if (!isMigrationLink(trimmed)) {
      throw const GoogleMigrationException(
        GoogleMigrationErrorCode.notMigrationLink,
      );
    }
    try {
      if (trimmed.length > maxLinkLength) throw const _ProtoError();
      return _parseBatch(_decodeData(trimmed));
    } on GoogleMigrationException {
      rethrow;
    } catch (_) {
      // Do not keep the cause: a FormatException can hold the scanned data,
      // and that data includes secrets.
      throw const GoogleMigrationException(
        GoogleMigrationErrorCode.malformedData,
      );
    }
  }

  /// The counter value to store for an HOTP account. The app stores the next
  /// unused value. This assumes Google's number means the same, which still
  /// has to be confirmed with a real export; any change belongs here.
  static int counterFromGoogle(int googleCounter) => googleCounter;

  static Uint8List _decodeData(String link) {
    final uri = Uri.parse(link);
    if (uri.host.toLowerCase() != 'offline') throw const _ProtoError();
    // Query parsing turns a raw '+' into a space. Base64 never has spaces.
    final data = uri.queryParameters['data']?.replaceAll(' ', '+');
    if (data == null || data.isEmpty) throw const _ProtoError();
    return base64.decode(base64.normalize(data));
  }

  static GoogleMigrationBatch _parseBatch(Uint8List bytes) {
    final entries = <GoogleMigrationEntry>[];
    var batchSize = 0;
    var batchIndex = 0;
    var batchId = 0;

    final reader = _ProtoReader(bytes);
    while (!reader.isAtEnd) {
      final field = reader.readTag();
      switch (field.number) {
        case 1:
          entries.add(_parseEntry(reader.readBytes(field.wireType)));
        case 3:
          batchSize = reader.readVarint(field.wireType);
        case 4:
          batchIndex = reader.readVarint(field.wireType);
        case 5:
          batchId = reader.readVarint(field.wireType);
        default:
          reader.skip(field.wireType);
      }
    }

    // Exports with one QR code may leave the batch fields out.
    if (batchSize == 0) batchSize = 1;
    if (entries.isEmpty ||
        batchSize < 0 ||
        batchSize > maxBatchSize ||
        batchIndex < 0 ||
        batchIndex >= batchSize) {
      throw const _ProtoError();
    }

    return GoogleMigrationBatch(
      entries: entries,
      batchSize: batchSize,
      batchIndex: batchIndex,
      batchId: batchId,
    );
  }

  static GoogleMigrationEntry _parseEntry(Uint8List bytes) {
    Uint8List secret = Uint8List(0);
    var rawName = '';
    var rawIssuer = '';
    var algorithm = 0;
    var digits = 0;
    var type = 0;
    var counter = 0;

    try {
      final reader = _ProtoReader(bytes);
      while (!reader.isAtEnd) {
        final field = reader.readTag();
        switch (field.number) {
          case 1:
            secret = reader.readBytes(field.wireType);
          case 2:
            rawName = _readText(reader, field.wireType);
          case 3:
            rawIssuer = _readText(reader, field.wireType);
          case 4:
            algorithm = reader.readVarint(field.wireType);
          case 5:
            digits = reader.readVarint(field.wireType);
          case 6:
            type = reader.readVarint(field.wireType);
          case 7:
            counter = reader.readVarint(field.wireType);
          default:
            reader.skip(field.wireType);
        }
      }
    } on _ProtoError {
      return const GoogleMigrationEntry.problem(GoogleMigrationProblem.damaged);
    } on FormatException {
      // Invalid UTF-8 in a name. The exception itself is not kept.
      return const GoogleMigrationEntry.problem(GoogleMigrationProblem.damaged);
    }

    final (:name, :issuer) = _splitLabel(rawName, rawIssuer);

    GoogleMigrationEntry problem(GoogleMigrationProblem value) =>
        GoogleMigrationEntry.problem(value, name: name, issuer: issuer);

    if (name.isEmpty || secret.length > maxSecretBytes) {
      return problem(GoogleMigrationProblem.damaged);
    }
    if (secret.isEmpty) return problem(GoogleMigrationProblem.missingSecret);

    final algorithmName = switch (algorithm) {
      0 || 1 => 'SHA1',
      2 => 'SHA256',
      3 => 'SHA512',
      _ => null,
    };
    if (algorithmName == null) {
      return problem(GoogleMigrationProblem.unsupportedAlgorithm);
    }

    final digitCount = switch (digits) {
      0 || 1 => 6,
      2 => 8,
      _ => null,
    };
    if (digitCount == null) {
      return problem(GoogleMigrationProblem.unsupportedDigits);
    }

    final typeName = switch (type) {
      1 => 'hotp',
      2 => 'totp',
      _ => null,
    };
    if (typeName == null) {
      return problem(GoogleMigrationProblem.unsupportedType);
    }
    if (typeName == 'hotp' && counter < 0) {
      return problem(GoogleMigrationProblem.damaged);
    }

    // The app's secret check accepts Base32 letters only, so no '=' padding.
    final encodedSecret = base32.encode(secret).replaceAll('=', '');
    if (encodedSecret.length < AppConstants.minSecretLength) {
      return problem(GoogleMigrationProblem.shortSecret);
    }

    return GoogleMigrationEntry.ok(
      Account(
        name: name,
        secret: encodedSecret,
        issuer: issuer,
        type: typeName,
        counter: typeName == 'hotp' ? counterFromGoogle(counter) : null,
        digits: digitCount,
        period: _totpPeriod,
        algorithm: algorithmName,
      ),
    );
  }

  static String _readText(_ProtoReader reader, int wireType) {
    final bytes = reader.readBytes(wireType);
    if (bytes.length > maxTextBytes) throw const _ProtoError();
    return utf8.decode(bytes);
  }

  /// Google often stores the name as "Issuer:user".
  static ({String name, String? issuer}) _splitLabel(
    String rawName,
    String rawIssuer,
  ) {
    var name = rawName.trim();
    var issuer = rawIssuer.trim();
    final colon = name.indexOf(':');
    if (colon >= 0) {
      final prefix = name.substring(0, colon).trim();
      final rest = name.substring(colon + 1).trim();
      if (issuer.isEmpty && prefix.isNotEmpty) {
        issuer = prefix;
        name = rest;
      } else if (prefix.toLowerCase() == issuer.toLowerCase()) {
        name = rest;
      }
    }
    if (name.isEmpty) name = issuer;
    return (name: name, issuer: issuer.isEmpty ? null : issuer);
  }
}

enum GoogleMigrationAddResult { added, repeated, otherExport }

/// Gathers the QR codes of one export, in any scan order.
class GoogleMigrationCollector {
  final Map<int, GoogleMigrationBatch> _batches = {};
  int? _batchId;
  int _total = 0;

  bool get isEmpty => _batches.isEmpty;
  int get scanned => _batches.length;
  int get total => _total;
  bool get isComplete => !isEmpty && scanned == total;

  GoogleMigrationAddResult add(GoogleMigrationBatch batch) {
    if (isEmpty) {
      _batchId = batch.batchId;
      _total = batch.batchSize;
    } else if (batch.batchId != _batchId || batch.batchSize != _total) {
      return GoogleMigrationAddResult.otherExport;
    }
    if (_batches.containsKey(batch.batchIndex)) {
      return GoogleMigrationAddResult.repeated;
    }
    _batches[batch.batchIndex] = batch;
    return GoogleMigrationAddResult.added;
  }

  /// All entries so far, in the export's own order.
  List<GoogleMigrationEntry> get entries {
    final indexes = _batches.keys.toList()..sort();
    return [for (final index in indexes) ..._batches[index]!.entries];
  }

  /// Drop the scanned data.
  void clear() {
    _batches.clear();
    _batchId = null;
    _total = 0;
  }
}

/// Bad data. Holds nothing, so it can't leak what was scanned.
class _ProtoError implements Exception {
  const _ProtoError();
}

/// Reads Protobuf's wire format. Every read is checked against the bytes left.
class _ProtoReader {
  static const int _wireVarint = 0;
  static const int _wire64Bit = 1;
  static const int _wireBytes = 2;
  static const int _wire32Bit = 5;

  /// A 64-bit value never takes more than 10 bytes.
  static const int _maxVarintBytes = 10;

  final Uint8List _bytes;
  int _position = 0;

  _ProtoReader(this._bytes);

  bool get isAtEnd => _position >= _bytes.length;

  ({int number, int wireType}) readTag() {
    final tag = _readRawVarint();
    final number = tag >>> 3;
    if (number == 0) throw const _ProtoError();
    return (number: number, wireType: tag & 7);
  }

  int readVarint(int wireType) {
    if (wireType != _wireVarint) throw const _ProtoError();
    return _readRawVarint();
  }

  Uint8List readBytes(int wireType) {
    if (wireType != _wireBytes) throw const _ProtoError();
    final length = _readRawVarint();
    if (length < 0 || length > _bytes.length - _position) {
      throw const _ProtoError();
    }
    final view = Uint8List.sublistView(_bytes, _position, _position + length);
    _position += length;
    return view;
  }

  void skip(int wireType) {
    switch (wireType) {
      case _wireVarint:
        _readRawVarint();
      case _wire64Bit:
        _advance(8);
      case _wireBytes:
        readBytes(wireType);
      case _wire32Bit:
        _advance(4);
      default:
        throw const _ProtoError();
    }
  }

  void _advance(int count) {
    if (count > _bytes.length - _position) throw const _ProtoError();
    _position += count;
  }

  int _readRawVarint() {
    var result = 0;
    for (var i = 0; i < _maxVarintBytes; i++) {
      if (isAtEnd) throw const _ProtoError();
      final byte = _bytes[_position++];
      result |= (byte & 0x7f) << (7 * i);
      if (byte & 0x80 == 0) return result;
    }
    throw const _ProtoError();
  }
}
