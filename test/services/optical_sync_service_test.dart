// File Path: sreerajp_authenticator/test/services/optical_sync_service_test.dart
// Author: Sreeraj P
// Description: Unit test suite for Optical Air-Gap Sync engine (Fountain Code
//   chunking, CRC32 checksums, out-of-order frame decoding, parity solving, and
//   payload round-trip).

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/services/optical_sync_service.dart';

void main() {
  group('CRC32 Checksum Tests', () {
    test('computes correct IEEE 802.3 CRC32', () {
      final bytes = utf8.encode('123456789');
      final crc = Crc32.compute(bytes);
      // Standard reference value for '123456789' is 0xCBF43926 (3421780262)
      expect(crc, equals(0xCBF43926));
    });
  });

  group('OpticalSyncEncoder & Frame Serialization', () {
    test('splits payload into expected chunk count', () {
      final payloadMap = {
        'version': 1,
        'created': '2026-08-01T12:00:00Z',
        'accounts': List.generate(
          20,
          (i) => {
            'id': i,
            'name': 'user$i@example.com',
            'issuer': 'Service $i',
            'secret': 'JBSWY3DPEHPK3PXP',
            'algorithm': 'SHA1',
            'digits': 6,
            'period': 30,
            'type': 'totp',
            'createdAt': '2026-08-01T12:00:00.000',
            'sortOrder': i,
          },
        ),
      };
      final payloadJson = jsonEncode(payloadMap);
      final encoder = OpticalSyncEncoder(payloadJson, chunkSize: 128);

      expect(encoder.totalChunks, greaterThan(1));
      expect(encoder.sessionHash.length, equals(8));

      final frame0 = encoder.getFrame(0);
      expect(frame0.version, equals(1));
      expect(frame0.frameIndex, equals(0));
      expect(frame0.totalChunks, equals(encoder.totalChunks));
      expect(frame0.indices, equals([0]));

      final jsonStr = frame0.toJsonString();
      final parsed = OpticalSyncFrame.fromJsonString(jsonStr);
      expect(parsed.sessionHash, equals(encoder.sessionHash));
      expect(parsed.frameIndex, equals(0));
      expect(parsed.crc32, equals(frame0.crc32));
    });

    test('throws exception on invalid or corrupted JSON frame payload', () {
      expect(
        () => OpticalSyncFrame.fromJsonString('{"v": 1}'),
        throwsA(isA<OpticalSyncException>()),
      );
      expect(
        () => OpticalSyncFrame.fromJsonString('invalid json string'),
        throwsA(isA<OpticalSyncException>()),
      );
    });
  });

  group('OpticalSyncDecoder Reconstruction & Fountain Code Solver', () {
    late String testPayloadJson;

    setUp(() {
      final payloadMap = {
        'version': 1,
        'created': '2026-08-01T12:00:00Z',
        'syncMode': 'FULL',
        'accounts': List.generate(
          15,
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
      };
      testPayloadJson = jsonEncode(payloadMap);
    });

    test('reconstructs payload from in-order systematic frames', () {
      final encoder = OpticalSyncEncoder(testPayloadJson, chunkSize: 64);
      final decoder = OpticalSyncDecoder();

      for (var i = 0; i < encoder.totalChunks; i++) {
        final frame = encoder.getFrame(i);
        final processed = decoder.processFrameString(frame.toJsonString());
        expect(processed, isTrue);
      }

      expect(decoder.isComplete, isTrue);
      expect(decoder.progress, equals(1.0));

      final reconstructed = decoder.getReconstructedPayload();
      expect(reconstructed, equals(testPayloadJson));
    });

    test('reconstructs payload from out-of-order systematic frames', () {
      final encoder = OpticalSyncEncoder(testPayloadJson, chunkSize: 64);
      final decoder = OpticalSyncDecoder();

      final total = encoder.totalChunks;
      final indices = List.generate(total, (i) => i)..shuffle();

      for (final idx in indices) {
        final frame = encoder.getFrame(idx);
        decoder.processFrameString(frame.toJsonString());
      }

      expect(decoder.isComplete, isTrue);
      expect(decoder.getReconstructedPayload(), equals(testPayloadJson));
    });

    test(
      'reconstructs payload when systematic frames are dropped using parity frames',
      () {
        final encoder = OpticalSyncEncoder(testPayloadJson, chunkSize: 64);
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
        expect(decoder.getReconstructedPayload(), equals(testPayloadJson));
      },
    );

    test('rejects frame with tampered payload / CRC mismatch', () {
      final encoder = OpticalSyncEncoder(testPayloadJson, chunkSize: 64);
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
