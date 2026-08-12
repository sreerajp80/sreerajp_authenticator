// File Path: sreerajp_authenticator/lib/services/optical_sync_service.dart
// Author: Sreeraj P
// Description: Optical Air-Gap Sync engine powered by a Fountain Code (LT Matrix)
//   chunking algorithm and IEEE 802.3 CRC32 verification. Encodes payload into an
//   animated QR stream (12-15 FPS) and reconstructs out-of-order fragments offline.

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'p2p_sync_service.dart';

/// Exception thrown when optical sync frame processing or reconstruction fails.
class OpticalSyncException implements Exception {
  final String message;
  const OpticalSyncException(this.message);

  @override
  String toString() => message;
}

/// CRC32 checksum helper (IEEE 802.3 polynomial).
class Crc32 {
  static final List<int> _table = List<int>.generate(256, (i) {
    var c = i;
    for (var k = 0; k < 8; k++) {
      if ((c & 1) != 0) {
        c = 0xEDB88320 ^ (c >>> 1);
      } else {
        c = c >>> 1;
      }
    }
    return c;
  });

  static int compute(List<int> bytes) {
    var crc = 0xFFFFFFFF;
    for (final b in bytes) {
      crc = _table[(crc ^ b) & 0xFF] ^ (crc >>> 8);
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }
}

/// Structure representing a single frame in the Optical Air-Gap QR stream.
class OpticalSyncFrame {
  final int version;
  final String sessionHash;
  final int frameIndex;
  final int totalChunks;
  final int payloadLength;
  final int crc32;
  final List<int> indices;
  final Uint8List chunkData;

  const OpticalSyncFrame({
    required this.version,
    required this.sessionHash,
    required this.frameIndex,
    required this.totalChunks,
    required this.payloadLength,
    required this.crc32,
    required this.indices,
    required this.chunkData,
  });

  /// Serialize frame into compact JSON string for QR code generation.
  String toJsonString() {
    final map = <String, dynamic>{
      'v': version,
      's': sessionHash,
      'i': frameIndex,
      't': totalChunks,
      'l': payloadLength,
      'c': crc32,
      'p': indices,
      'd': base64.encode(chunkData),
    };
    return jsonEncode(map);
  }

  /// Parse and validate frame from scanned QR text payload.
  static OpticalSyncFrame fromJsonString(String raw) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw.trim());
    } catch (_) {
      throw const OpticalSyncException('Not a valid optical sync frame');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const OpticalSyncException('Malformed optical sync frame payload');
    }

    final version = decoded['v'] as int?;
    if (version == null || version != 1) {
      throw const OpticalSyncException(
        'Unsupported optical sync frame version',
      );
    }

    final sessionHash = (decoded['s'] as String?) ?? '';
    final frameIndex = decoded['i'] as int?;
    final totalChunks = decoded['t'] as int?;
    final payloadLength = decoded['l'] as int?;
    final crc32 = decoded['c'] as int?;
    final rawIndices = decoded['p'] as List?;
    final payloadBase64 = decoded['d'] as String?;

    if (sessionHash.isEmpty ||
        frameIndex == null ||
        totalChunks == null ||
        payloadLength == null ||
        crc32 == null ||
        rawIndices == null ||
        payloadBase64 == null) {
      throw const OpticalSyncException('Missing fields in optical sync frame');
    }

    final indices = rawIndices.cast<int>();
    final Uint8List chunkData;
    try {
      chunkData = base64.decode(payloadBase64);
    } catch (_) {
      throw const OpticalSyncException('Corrupted chunk payload encoding');
    }

    final computedCrc = Crc32.compute(chunkData);
    if (computedCrc != crc32) {
      throw const OpticalSyncException('Frame CRC32 checksum mismatch');
    }

    return OpticalSyncFrame(
      version: version,
      sessionHash: sessionHash,
      frameIndex: frameIndex,
      totalChunks: totalChunks,
      payloadLength: payloadLength,
      crc32: crc32,
      indices: indices,
      chunkData: chunkData,
    );
  }
}

/// Transmitter Fountain Code encoder. Splits JSON payload into fixed size
/// chunks (128 bytes) and emits an infinite stream of systematic + parity frames.
class OpticalSyncEncoder {
  static const int defaultChunkSize = 128;

  final String payloadJson;
  final int chunkSize;
  late final Uint8List _payloadBytes;
  late final int _totalChunks;
  late final String _sessionHash;
  late final List<Uint8List> _originalChunks;

  OpticalSyncEncoder(this.payloadJson, {this.chunkSize = defaultChunkSize}) {
    _payloadBytes = Uint8List.fromList(utf8.encode(payloadJson));
    _totalChunks = (_payloadBytes.length / chunkSize).ceil();
    if (_totalChunks == 0) {
      throw const OpticalSyncException('Payload cannot be empty');
    }

    // Compute session hash: first 8 hex characters of SHA-256
    final hashBytes = sha256.convert(_payloadBytes).bytes;
    _sessionHash = hashBytes
        .sublist(0, 4)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    // Prepare original padded chunks
    _originalChunks = List.generate(_totalChunks, (index) {
      final start = index * chunkSize;
      final end = (start + chunkSize > _payloadBytes.length)
          ? _payloadBytes.length
          : start + chunkSize;
      final chunk = Uint8List(chunkSize);
      chunk.setRange(0, end - start, _payloadBytes.sublist(start, end));
      return chunk;
    });
  }

  int get totalChunks => _totalChunks;
  String get sessionHash => _sessionHash;
  int get payloadLength => _payloadBytes.length;

  /// Generate a specific frame by index [frameIndex].
  /// Indexes 0..totalChunks-1 produce systematic frames (raw chunks).
  /// Indexes >= totalChunks produce parity fountain frames (XOR combinations).
  OpticalSyncFrame getFrame(int frameIndex) {
    if (frameIndex < _totalChunks) {
      final chunk = _originalChunks[frameIndex];
      final crc = Crc32.compute(chunk);
      return OpticalSyncFrame(
        version: 1,
        sessionHash: _sessionHash,
        frameIndex: frameIndex,
        totalChunks: _totalChunks,
        payloadLength: _payloadBytes.length,
        crc32: crc,
        indices: [frameIndex],
        chunkData: chunk,
      );
    } else {
      // Parity frame combination logic with multi-stride Fountain Code distribution
      final pIndex = frameIndex - _totalChunks;
      final stride = 1 + (pIndex ~/ _totalChunks);
      final idx1 = pIndex % _totalChunks;
      var idx2 = (idx1 + stride) % _totalChunks;
      if (idx1 == idx2) {
        idx2 = (idx2 + 1) % _totalChunks;
      }

      final c1 = _originalChunks[idx1];
      final c2 = _originalChunks[idx2];
      final parityChunk = Uint8List(chunkSize);
      for (var k = 0; k < chunkSize; k++) {
        parityChunk[k] = c1[k] ^ c2[k];
      }

      final crc = Crc32.compute(parityChunk);
      return OpticalSyncFrame(
        version: 1,
        sessionHash: _sessionHash,
        frameIndex: frameIndex,
        totalChunks: _totalChunks,
        payloadLength: _payloadBytes.length,
        crc32: crc,
        indices: [idx1, idx2],
        chunkData: parityChunk,
      );
    }
  }
}

/// Representation of an unsolved parity equation in the receiver decoder.
class _ParityEquation {
  Set<int> unknownIndices;
  Uint8List parityData;

  _ParityEquation(this.unknownIndices, this.parityData);
}

/// Receiver Fountain Code decoder. Ingests raw frame strings, verifies CRC32,
/// absorbs systematic & parity frames, and solves for missing chunks out-of-order.
class OpticalSyncDecoder {
  String? _activeSessionHash;
  int _totalChunks = 0;
  int _payloadLength = 0;

  final Map<int, Uint8List> _solvedChunks = {};
  final List<_ParityEquation> _pendingParities = [];

  bool get isComplete =>
      _totalChunks > 0 && _solvedChunks.length == _totalChunks;

  double get progress =>
      _totalChunks == 0 ? 0.0 : (_solvedChunks.length / _totalChunks);

  int get solvedCount => _solvedChunks.length;
  int get totalChunks => _totalChunks;
  String? get sessionHash => _activeSessionHash;

  /// Process a scanned frame QR string.
  /// Returns `true` if a new chunk was solved as a result of this frame.
  bool processFrameString(String rawFrame) {
    final OpticalSyncFrame frame;
    try {
      frame = OpticalSyncFrame.fromJsonString(rawFrame);
    } catch (_) {
      return false; // Ignore foreign / corrupted QR frames
    }

    if (_activeSessionHash == null) {
      _activeSessionHash = frame.sessionHash;
      _totalChunks = frame.totalChunks;
      _payloadLength = frame.payloadLength;
    } else if (frame.sessionHash != _activeSessionHash) {
      // Ignore frames from another session stream
      return false;
    }

    if (isComplete) return false;

    if (frame.indices.length == 1) {
      // Systematic frame
      final idx = frame.indices.first;
      if (!_solvedChunks.containsKey(idx)) {
        _solvedChunks[idx] = frame.chunkData;
        _propagateSolved(idx);
        return true;
      }
    } else if (frame.indices.length > 1) {
      // Parity frame
      final unknowns = frame.indices
          .where((i) => !_solvedChunks.containsKey(i))
          .toSet();

      if (unknowns.isEmpty) {
        return false; // Already know all components
      } else if (unknowns.length == 1) {
        // Can solve immediately!
        final targetIdx = unknowns.first;
        final solvedData = Uint8List.fromList(frame.chunkData);
        for (final idx in frame.indices) {
          if (idx != targetIdx) {
            final known = _solvedChunks[idx]!;
            for (var k = 0; k < solvedData.length; k++) {
              solvedData[k] ^= known[k];
            }
          }
        }
        _solvedChunks[targetIdx] = solvedData;
        _propagateSolved(targetIdx);
        return true;
      } else {
        // Store for later simplification
        final parityData = Uint8List.fromList(frame.chunkData);
        for (final idx in frame.indices) {
          if (_solvedChunks.containsKey(idx)) {
            final known = _solvedChunks[idx]!;
            for (var k = 0; k < parityData.length; k++) {
              parityData[k] ^= known[k];
            }
          }
        }
        _pendingParities.add(_ParityEquation(unknowns, parityData));
      }
    }

    return false;
  }

  void _propagateSolved(int initialSolvedIdx) {
    final queue = [initialSolvedIdx];

    while (queue.isNotEmpty) {
      final currentSolvedIdx = queue.removeAt(0);
      final knownData = _solvedChunks[currentSolvedIdx];
      if (knownData == null) continue;

      final remaining = <_ParityEquation>[];

      for (final eq in _pendingParities) {
        if (eq.unknownIndices.contains(currentSolvedIdx)) {
          eq.unknownIndices.remove(currentSolvedIdx);
          for (var k = 0; k < eq.parityData.length; k++) {
            eq.parityData[k] ^= knownData[k];
          }
        }

        if (eq.unknownIndices.length == 1) {
          final solvedIdx = eq.unknownIndices.first;
          if (!_solvedChunks.containsKey(solvedIdx)) {
            _solvedChunks[solvedIdx] = eq.parityData;
            queue.add(solvedIdx);
          }
        } else if (eq.unknownIndices.length > 1) {
          remaining.add(eq);
        }
      }

      _pendingParities.clear();
      _pendingParities.addAll(remaining);
    }
  }

  /// Finalize reconstruction and return decoded JSON vault string.
  /// Validates SHA-256 session hash against original payload.
  String getReconstructedPayload() {
    if (!isComplete) {
      throw const OpticalSyncException('Reconstruction incomplete');
    }

    final totalBytes = BytesBuilder();
    for (var i = 0; i < _totalChunks; i++) {
      final chunk = _solvedChunks[i];
      if (chunk == null) {
        throw const OpticalSyncException('Missing chunk in reconstruction');
      }
      totalBytes.add(chunk);
    }

    final fullBytes = Uint8List.fromList(totalBytes.takeBytes());
    if (fullBytes.length < _payloadLength) {
      throw const OpticalSyncException('Reconstructed payload truncated');
    }

    final payloadBytes = fullBytes.sublist(0, _payloadLength);

    // Verify session hash
    final hashBytes = sha256.convert(payloadBytes).bytes;
    final checkHash = hashBytes
        .sublist(0, 4)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    if (checkHash != _activeSessionHash) {
      throw const OpticalSyncException('Session hash integrity check failed');
    }

    final jsonStr = utf8.decode(payloadBytes, allowMalformed: false);
    // Validate schema
    P2pSyncService.validateAndParse(jsonStr);

    return jsonStr;
  }
}
