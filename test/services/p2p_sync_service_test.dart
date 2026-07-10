import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/models/group.dart';
import 'package:sreerajp_authenticator/services/p2p_sync_service.dart';
import 'package:sreerajp_authenticator/utils/constants.dart';

void main() {
  final fixedTime = DateTime(2025, 10, 1);

  String buildPayloadJson({
    int accounts = 1,
    int groups = 0,
    Map<String, dynamic>? settings,
    String? syncMode,
  }) {
    final map = <String, dynamic>{
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
    };
    if (settings != null) map[AppConstants.syncPayloadKeySettings] = settings;
    if (syncMode != null) map[AppConstants.syncPayloadKeySyncMode] = syncMode;
    return jsonEncode(map);
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

  group('sync QR payload', () {
    test('build -> parse round-trips ip, port, and normalized code', () {
      final code = P2pSyncService.generatePairingCode();
      final qr = P2pSyncService.buildSyncQrPayload(
        ipAddress: '192.168.1.42',
        port: 54321,
        code: code,
      );
      final parsed = P2pSyncService.parseSyncQrPayload(qr);
      expect(parsed.ipAddress, '192.168.1.42');
      expect(parsed.port, 54321);
      expect(parsed.code, code);
    });

    test('parse normalizes a hyphen-grouped, lowercased code', () {
      final code = P2pSyncService.generatePairingCode();
      final formatted = P2pSyncService.formatPairingCode(code).toLowerCase();
      final qr =
          '${AppConstants.syncQrScheme}://${AppConstants.syncQrHost}'
          '?${AppConstants.syncQrKeyVersion}=${AppConstants.syncQrVersion}'
          '&${AppConstants.syncQrKeyIp}=10.0.0.5'
          '&${AppConstants.syncQrKeyPort}=8080'
          '&${AppConstants.syncQrKeyCode}=${Uri.encodeQueryComponent(formatted)}';
      final parsed = P2pSyncService.parseSyncQrPayload(qr);
      expect(parsed.code, code);
    });

    test('rejects a foreign scheme', () {
      expect(
        () => P2pSyncService.parseSyncQrPayload(
          'otpauth://totp/Acme?secret=JBSWY3DPEHPK3PXP',
        ),
        throwsA(isA<P2pSyncException>()),
      );
    });

    test('rejects an unsupported version', () {
      final qr =
          '${AppConstants.syncQrScheme}://${AppConstants.syncQrHost}'
          '?${AppConstants.syncQrKeyVersion}=99'
          '&${AppConstants.syncQrKeyIp}=10.0.0.5'
          '&${AppConstants.syncQrKeyPort}=8080'
          '&${AppConstants.syncQrKeyCode}=ABCDEFGH';
      expect(
        () => P2pSyncService.parseSyncQrPayload(qr),
        throwsA(isA<P2pSyncException>()),
      );
    });

    test('rejects a missing or invalid port', () {
      final qr =
          '${AppConstants.syncQrScheme}://${AppConstants.syncQrHost}'
          '?${AppConstants.syncQrKeyVersion}=${AppConstants.syncQrVersion}'
          '&${AppConstants.syncQrKeyIp}=10.0.0.5'
          '&${AppConstants.syncQrKeyPort}=70000'
          '&${AppConstants.syncQrKeyCode}=ABCDEFGH';
      expect(
        () => P2pSyncService.parseSyncQrPayload(qr),
        throwsA(isA<P2pSyncException>()),
      );
    });

    test('rejects an empty pairing code', () {
      final qr =
          '${AppConstants.syncQrScheme}://${AppConstants.syncQrHost}'
          '?${AppConstants.syncQrKeyVersion}=${AppConstants.syncQrVersion}'
          '&${AppConstants.syncQrKeyIp}=10.0.0.5'
          '&${AppConstants.syncQrKeyPort}=8080'
          '&${AppConstants.syncQrKeyCode}=';
      expect(
        () => P2pSyncService.parseSyncQrPayload(qr),
        throwsA(isA<P2pSyncException>()),
      );
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

    test('surfaces settings and syncMode when present', () {
      final data = P2pSyncService.validateAndParse(
        buildPayloadJson(
          accounts: 1,
          settings: {AppConstants.syncSettingThemeMode: 2},
          syncMode: AppConstants.syncModeFull,
        ),
      );
      final settings =
          data[AppConstants.syncPayloadKeySettings] as Map<String, dynamic>;
      expect(settings[AppConstants.syncSettingThemeMode], 2);
      expect(data[AppConstants.syncPayloadKeySyncMode], AppConstants.syncModeFull);
    });

    test('omits category keys that were not part of the payload', () {
      // A settings-only incremental payload carries no accounts/groups keys.
      final json = jsonEncode({
        AppConstants.syncPayloadKeySettings: {
          AppConstants.syncSettingThemeMode: 1,
        },
        AppConstants.syncPayloadKeySyncMode: AppConstants.syncModeIncremental,
      });
      final data = P2pSyncService.validateAndParse(json);
      expect(data.containsKey('accounts'), isFalse);
      expect(data.containsKey('groups'), isFalse);
      expect(data.containsKey(AppConstants.syncPayloadKeySettings), isTrue);
    });
  });

  group('host <-> client over loopback', () {
    test('client connects, then receives the payload the host sends', () async {
      final code = P2pSyncService.generatePairingCode();
      final host = P2pSyncService();
      final payload = buildPayloadJson(
        accounts: 3,
        groups: 1,
        syncMode: AppConstants.syncModeFull,
      );

      // The host holds the connection open on connect and pushes the payload
      // only when the sender chooses — modelled here by sending on connect.
      var connectedFired = false;
      final binding = await host.startHost(
        code: code,
        idleTimeout: const Duration(seconds: 10),
        onClientConnected: () {
          connectedFired = true;
          host.sendToConnectedClient(payload);
        },
        onClientDisconnected: () {},
        onError: (_) {},
        onTimedOut: () {},
      );

      final client = P2pSyncService();
      var clientSawConnected = false;
      final received = await client.connectAndFetch(
        hostIp: '127.0.0.1',
        port: binding.port,
        code: code,
        onConnected: () => clientSawConnected = true,
      );

      expect(received, payload);
      expect(connectedFired, isTrue);
      expect(clientSawConnected, isTrue);
      final data = P2pSyncService.validateAndParse(received);
      expect((data['accounts'] as List<Account>).length, 3);

      await host.stopHost();
    });

    test('wrong pairing code is rejected and never connects', () async {
      final host = P2pSyncService();
      var connectedFired = false;
      final binding = await host.startHost(
        code: P2pSyncService.generatePairingCode(),
        idleTimeout: const Duration(seconds: 10),
        onClientConnected: () => connectedFired = true,
        onClientDisconnected: () {},
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

      expect(connectedFired, isFalse);
      await host.stopHost();
    });

    test('sendToConnectedClient without a client throws', () async {
      final host = P2pSyncService();
      await host.startHost(
        code: P2pSyncService.generatePairingCode(),
        idleTimeout: const Duration(seconds: 10),
        onClientConnected: () {},
        onClientDisconnected: () {},
        onError: (_) {},
        onTimedOut: () {},
      );
      await expectLater(
        host.sendToConnectedClient(buildPayloadJson()),
        throwsA(isA<P2pSyncException>()),
      );
      await host.stopHost();
    });
  });
}
