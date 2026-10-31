// File Path: sreerajp_authenticator/test/services/optical_sync_service_test.dart
// Author: Sreeraj P
// Description: Unit test suite for Optical Air-Gap Sync engine (AES-256-GCM
//   seal/open with a one-time transfer code, Fountain Code chunking, CRC32
//   checksums, out-of-order frame decoding, parity solving, payload round-trip,
//   and that no frame carries plaintext secrets).

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/services/optical_sync_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

Matcher _opticalCode(OpticalSyncErrorCode code) =>
    throwsA(isA<OpticalSyncException>().having((e) => e.code, 'code', code));

String _payload(int count) => jsonEncode({
  'version': 1,
  'created': '2026-08-01T12:00:00Z',
  'syncMode': 'FULL',
  'accounts': List.generate(
    count,
    (i) => {
      'id': i,
      'name': 'user$i@domain.com',
      'issuer': 'Provider $i',
      'secret': 'HXDMVJECBOXWIZLAMI',
      'algorithm': 'SHA1',
      'digits': 6,
      'period': 30,
      'type': 'totp',
      'createdAt': '2026-08-01T12:00:00.000',
      'sortOrder': i,
    },
  ),
});

void main() {
  // PBKDF2 (300,000 iterations) is slow on purpose, so seal once and reuse.
  late String code;
  late String payloadJson;
  late Uint8List sealed;

  setUpAll(() {
    code = OpticalSyncCrypto.generateTransferCode();
    payloadJson = _payload(15);
    sealed = OpticalSyncCrypto.seal(payloadJson, code);
  });

  group('CRC32 Checksum Tests', () {
    test('computes correct IEEE 802.3 CRC32', () {
      final bytes = utf8.encode('123456789');
      final crc = Crc32.compute(bytes);
      // Standard reference value for '123456789' is 0xCBF43926 (3421780262)
      expect(crc, equals(0xCBF43926));
    });
  });

  group('Transfer code', () {
    test('has the configured length and only alphabet characters', () {
      final c = OpticalSyncCrypto.generateTransferCode();
      expect(c.length, AppConstants.opticalTransferCodeLength);
      for (final ch in c.split('')) {
        expect(AppConstants.syncPairingAlphabet.contains(ch), isTrue);
      }
    });

    test('codes differ between calls', () {
      expect(
        OpticalSyncCrypto.generateTransferCode(),
        isNot(OpticalSyncCrypto.generateTransferCode()),
      );
    });

    test('formatted, lower-case input parses back to the same code', () {
      final formatted = OpticalSyncCrypto.formatTransferCode(code);
      expect(formatted.split('-').length, 3);
      expect(
        OpticalSyncCrypto.parseTransferCode(' ${formatted.toLowerCase()} '),
        code,
      );
    });

    test('a code of the wrong length is refused', () {
      expect(OpticalSyncCrypto.parseTransferCode('ABCD-EFGH'), isNull);
      expect(OpticalSyncCrypto.parseTransferCode(''), isNull);
    });
  });

  group('Seal / open', () {
    test('right code returns the same JSON', () {
      expect(OpticalSyncCrypto.open(sealed, code), payloadJson);
    });

    test('wrong code → wrongTransferCode', () {
      final other = OpticalSyncCrypto.generateTransferCode();
      expect(
        () => OpticalSyncCrypto.open(sealed, other),
        _opticalCode(OpticalSyncErrorCode.wrongTransferCode),
      );
    });

    test('one changed ciphertext byte fails the GCM check', () {
      final tampered = Uint8List.fromList(sealed);
      tampered[tampered.length - 20] ^= 0x01;
      expect(
        () => OpticalSyncCrypto.open(tampered, code),
        _opticalCode(OpticalSyncErrorCode.wrongTransferCode),
      );
    });

    test('too-short data → invalidFrame', () {
      expect(
        () => OpticalSyncCrypto.open(Uint8List(10), code),
        _opticalCode(OpticalSyncErrorCode.invalidFrame),
      );
    });

    test('sealing twice gives different bytes (fresh salt and nonce)', () {
      final again = OpticalSyncCrypto.seal(payloadJson, code);
      expect(again, isNot(equals(sealed)));
    });
  });

  group('OpticalSyncEncoder & Frame Serialization', () {
    test('splits payload into expected chunk count', () {
      final encoder = OpticalSyncEncoder(sealed, chunkSize: 128);

      expect(encoder.totalChunks, greaterThan(1));
      expect(encoder.sessionHash.length, equals(8));

      final frame0 = encoder.getFrame(0);
      expect(frame0.version, equals(AppConstants.opticalFrameVersion));
      expect(frame0.frameIndex, equals(0));
      expect(frame0.totalChunks, equals(encoder.totalChunks));
      expect(frame0.indices, equals([0]));

      final jsonStr = frame0.toJsonString();
      final parsed = OpticalSyncFrame.fromJsonString(jsonStr);
      expect(parsed.sessionHash, equals(encoder.sessionHash));
      expect(parsed.frameIndex, equals(0));
      expect(parsed.crc32, equals(frame0.crc32));
    });

    test('no frame carries a secret or an account name', () {
      final encoder = OpticalSyncEncoder(sealed, chunkSize: 64);
      final buffer = BytesBuilder();
      for (var i = 0; i < encoder.totalChunks * 2; i++) {
        final frame = encoder.getFrame(i);
        final text = frame.toJsonString();
        expect(text.contains('HXDMVJECBOXWIZLAMI'), isFalse);
        expect(text.contains('domain.com'), isFalse);
        buffer.add(frame.chunkData);
      }
      final allBytes = latin1.decode(buffer.takeBytes());
      expect(allBytes.contains('HXDMVJECBOXWIZLAMI'), isFalse);
      expect(allBytes.contains('Provider'), isFalse);
    });

    test('a version 1 (plaintext) frame is refused', () {
      final frame = OpticalSyncEncoder(sealed).getFrame(0).toJsonString();
      final v1 = frame.replaceFirst(
        '"v":${AppConstants.opticalFrameVersion},',
        '"v":1,',
      );
      expect(
        () => OpticalSyncFrame.fromJsonString(v1),
        _opticalCode(OpticalSyncErrorCode.unsupportedVersion),
      );
    });

    test('throws exception on invalid or corrupted JSON frame payload', () {
      expect(
        () => OpticalSyncFrame.fromJsonString('{"v": 2}'),
        throwsA(isA<OpticalSyncException>()),
      );
      expect(
        () => OpticalSyncFrame.fromJsonString('invalid json string'),
        throwsA(isA<OpticalSyncException>()),
      );
    });
  });

  group('OpticalSyncDecoder Reconstruction & Fountain Code Solver', () {
    test('reconstructs sealed bytes from in-order systematic frames', () {
      final encoder = OpticalSyncEncoder(sealed, chunkSize: 64);
      final decoder = OpticalSyncDecoder();

      for (var i = 0; i < encoder.totalChunks; i++) {
        final frame = encoder.getFrame(i);
        final processed = decoder.processFrameString(frame.toJsonString());
        expect(processed, isTrue);
      }

      expect(decoder.isComplete, isTrue);
      expect(decoder.progress, equals(1.0));
      expect(decoder.getReconstructedSealed(), equals(sealed));
    });

    test('reconstructs and decrypts the payload with the right code', () {
      final encoder = OpticalSyncEncoder(sealed, chunkSize: 64);
      final decoder = OpticalSyncDecoder();
      for (var i = 0; i < encoder.totalChunks; i++) {
        decoder.processFrameString(encoder.getFrame(i).toJsonString());
      }
      expect(decoder.getReconstructedPayload(code), equals(payloadJson));
    });

    test('reconstructs from out-of-order systematic frames', () {
      final encoder = OpticalSyncEncoder(sealed, chunkSize: 64);
      final decoder = OpticalSyncDecoder();

      final total = encoder.totalChunks;
      final indices = List.generate(total, (i) => i)..shuffle();

      for (final idx in indices) {
        final frame = encoder.getFrame(idx);
        decoder.processFrameString(frame.toJsonString());
      }

      expect(decoder.isComplete, isTrue);
      expect(decoder.getReconstructedSealed(), equals(sealed));
    });

    test(
      'reconstructs when systematic frames are dropped using parity frames',
      () {
        final encoder = OpticalSyncEncoder(sealed, chunkSize: 64);
        final decoder = OpticalSyncDecoder();

        final total = encoder.totalChunks;
        // Skip last 2 systematic frames
        for (var i = 0; i < total - 2; i++) {
          final frame = encoder.getFrame(i);
          decoder.processFrameString(frame.toJsonString());
        }

        expect(decoder.isComplete, isFalse);

        // Feed parity frames (indices >= total) until parity solver resolves missing chunks
        var frameIdx = total;
        while (!decoder.isComplete && frameIdx < total + 2 * total) {
          final parityFrame = encoder.getFrame(frameIdx);
          decoder.processFrameString(parityFrame.toJsonString());
          frameIdx++;
        }

        expect(decoder.isComplete, isTrue);
        expect(decoder.getReconstructedSealed(), equals(sealed));
      },
    );

    test('rejects frame with tampered payload / CRC mismatch', () {
      final encoder = OpticalSyncEncoder(sealed, chunkSize: 64);
      final decoder = OpticalSyncDecoder();

      final validFrame = encoder.getFrame(0);
      final frameJson = validFrame.toJsonString();

      // Tamper CRC value
      final tamperedJson = frameJson.replaceAll(
        '"c":${validFrame.crc32}',
        '"c":12345',
      );
      final result = decoder.processFrameString(tamperedJson);

      expect(result, isFalse);
      expect(decoder.solvedCount, equals(0));
    });
  });
}
