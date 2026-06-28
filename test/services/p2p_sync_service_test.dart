import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/models/group.dart';
import 'package:sreerajp_authenticator/services/p2p_sync_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

void main() {
  final fixedTime = DateTime(2025, 10, 1);

  String buildPayloadJson({int accounts = 1, int groups = 0}) {
    return jsonEncode({
      'version': AppConstants.backupVersion,
      'created': fixedTime.toIso8601String(),
      'accounts': [
        for (var i = 0; i < accounts; i++)
          Account(
            name: 'Account $i',
            secret: 'JBSWY3DPEHPK3PXP',
            type: 'totp',
            issuer: 'Issuer $i',
            createdAt: fixedTime,
          ).toMap(),
      ],
      'groups': [
        for (var i = 0; i < groups; i++)
          Group(name: 'Group $i', createdAt: fixedTime).toMap(),
      ],
    });
  }

  group('pairing code', () {
    test('has the configured length and only allowed symbols', () {
      final code = P2pSyncService.generatePairingCode();
      expect(code.length, AppConstants.syncPairingCodeLength);
      for (final ch in code.split('')) {
        expect(AppConstants.syncPairingAlphabet.contains(ch), isTrue);
      }
    });

    test('two generated codes differ (high entropy)', () {
      final a = P2pSyncService.generatePairingCode();
      final b = P2pSyncService.generatePairingCode();
      expect(a, isNot(equals(b)));
    });

    test('normalizeCode uppercases and strips grouping/invalid chars', () {
      final code = P2pSyncService.generatePairingCode();
      final formatted = P2pSyncService.formatPairingCode(code).toLowerCase();
      // What the user types (lowercased + hyphens) must normalize back.
      expect(P2pSyncService.normalizeCode(formatted), code);
    });

    test('formatPairingCode groups in fixed-size chunks', () {
      final code = P2pSyncService.generatePairingCode();
      final parts = P2pSyncService.formatPairingCode(code).split('-');
      expect(parts.first.length, AppConstants.syncPairingCodeGroup);
    });
  });

  group('wire crypto', () {
    test('round-trips with the same code', () {
      final code = P2pSyncService.generatePairingCode();
      final salt = List<int>.generate(AppConstants.saltSize, (i) => i);
      final key = P2pSyncService.deriveKey(code, salt);

      final encoded = P2pSyncService.encryptWire('HELLO_SYNC', key);
      expect(P2pSyncService.decryptWire(encoded, key), 'HELLO_SYNC');
    });

    test('wrong code yields a wrong key and decryption throws', () {
      final salt = List<int>.generate(AppConstants.saltSize, (i) => i);
      final goodKey = P2pSyncService.deriveKey('CODEONE', salt);
      final badKey = P2pSyncService.deriveKey('CODETWO', salt);

      final encoded = P2pSyncService.encryptWire('ACCEPT_SYNC', goodKey);
      expect(() => P2pSyncService.decryptWire(encoded, badKey), throwsA(anything));
    });
  });

  group('validateAndParse', () {
    test('parses a valid payload into accounts and groups', () {
      final data = P2pSyncService.validateAndParse(
        buildPayloadJson(accounts: 2, groups: 1),
      );
      expect((data['accounts'] as List<Account>).length, 2);
      expect((data['groups'] as List<Group>).length, 1);
    });

    test('rejects malformed JSON', () {
      expect(
        () => P2pSyncService.validateAndParse('not json'),
        throwsA(isA<P2pSyncException>()),
      );
    });

    test('rejects too many accounts', () {
      final json = jsonEncode({
        'accounts': List.generate(
          AppConstants.syncMaxAccounts + 1,
          (i) => {'name': 'a$i'},
        ),
        'groups': [],
      });
      expect(
        () => P2pSyncService.validateAndParse(json),
        throwsA(isA<P2pSyncException>()),
      );
    });

    test('rejects an oversized field', () {
      final json = jsonEncode({
        'accounts': [
          {
            'name': 'x' * (AppConstants.syncMaxFieldLength + 1),
            'secret': 'JBSWY3DPEHPK3PXP',
            'type': 'totp',
            'digits': 6,
            'period': 30,
            'algorithm': 'SHA1',
            'createdAt': fixedTime.toIso8601String(),
            'sortOrder': 0,
          },
        ],
        'groups': [],
      });
      expect(
        () => P2pSyncService.validateAndParse(json),
        throwsA(isA<P2pSyncException>()),
      );
    });
  });

  group('host <-> client over loopback', () {
    test('happy path: client receives the host payload', () async {
      final code = P2pSyncService.generatePairingCode();
      final host = P2pSyncService();
      final payload = buildPayloadJson(accounts: 3, groups: 1);

      var hostCompleted = false;
      final binding = await host.startHost(
        code: code,
        idleTimeout: const Duration(seconds: 10),
        buildPayload: () async => payload,
        onSyncing: () {},
        onCompleted: (_) => hostCompleted = true,
        onError: (_) {},
        onTimedOut: () {},
      );

      final client = P2pSyncService();
      final received = await client.connectAndFetch(
        hostIp: '127.0.0.1',
        port: binding.port,
        code: code,
      );

      expect(received, payload);
      final data = P2pSyncService.validateAndParse(received);
      expect((data['accounts'] as List<Account>).length, 3);

      // Allow the host's send/close to settle.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(hostCompleted, isTrue);
      await host.stopHost();
    });

    test('wrong pairing code is rejected', () async {
      final host = P2pSyncService();
      final binding = await host.startHost(
        code: P2pSyncService.generatePairingCode(),
        idleTimeout: const Duration(seconds: 10),
        buildPayload: () async => buildPayloadJson(),
        onSyncing: () {},
        onCompleted: (_) {},
        onError: (_) {},
        onTimedOut: () {},
      );

      final client = P2pSyncService();
      await expectLater(
        client.connectAndFetch(
          hostIp: '127.0.0.1',
          port: binding.port,
          code: P2pSyncService.generatePairingCode(), // different code
        ),
        throwsA(isA<P2pSyncException>()),
      );

      await host.stopHost();
    });
  });
}
