import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/providers/sync_provider.dart';
import 'package:sreerajp_authenticator/services/optical_sync_service.dart';

import 'provider_test_helpers.dart';

/// The optical receiver shows a one-time transfer code, ignores frames until
/// scanning starts, and imports only when the stream was sealed with that code.
void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment();
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  final payloadJson = jsonEncode({
    'version': 1,
    'created': '2026-08-01T12:00:00Z',
    'syncMode': 'FULL',
    'accounts': [
      {
        'id': 1,
        'name': 'user@domain.com',
        'issuer': 'Provider',
        'secret': 'HXDMVJECBOXWIZLAMI',
        'algorithm': 'SHA1',
        'digits': 6,
        'period': 30,
        'type': 'totp',
        'createdAt': '2026-08-01T12:00:00.000',
        'sortOrder': 0,
      },
    ],
  });

  Future<void> feed(SyncProvider provider, Uint8List sealed) async {
    final encoder = OpticalSyncEncoder(sealed);
    for (var i = 0; i < encoder.totalChunks; i++) {
      await provider.processOpticalFrame(
        rawFrame: encoder.getFrame(i).toJsonString(),
        importData: (data) async => const ImportResult(accountsAdded: 1),
        applySettings: (settings, {required overwrite}) async => 0,
      );
    }
  }

  test('frames are ignored until scanning starts', () async {
    final provider = SyncProvider();
    await provider.startOpticalReceiving();
    final state = provider.state as SyncOpticalReceiving;
    expect(state.scanning, isFalse);
    expect(state.transferCode, isNotEmpty);

    final sealed = OpticalSyncCrypto.seal(payloadJson, state.transferCode);
    await feed(provider, sealed);
    expect((provider.state as SyncOpticalReceiving).solvedChunks, 0);
    await provider.reset();
  });

  test('right code → import completes', () async {
    final provider = SyncProvider();
    await provider.startOpticalReceiving();
    final code = (provider.state as SyncOpticalReceiving).transferCode;
    provider.beginOpticalScanning();

    await feed(provider, OpticalSyncCrypto.seal(payloadJson, code));
    expect(provider.state, isA<SyncCompleted>());
    expect((provider.state as SyncCompleted).summary.accounts, 1);
    await provider.reset();
  });

  test('wrong code → wrongTransferCode error, nothing imported', () async {
    final provider = SyncProvider();
    await provider.startOpticalReceiving();
    provider.beginOpticalScanning();
    var imported = false;

    final sealed = OpticalSyncCrypto.seal(
      payloadJson,
      OpticalSyncCrypto.generateTransferCode(),
    );
    final encoder = OpticalSyncEncoder(sealed);
    for (var i = 0; i < encoder.totalChunks; i++) {
      await provider.processOpticalFrame(
        rawFrame: encoder.getFrame(i).toJsonString(),
        importData: (data) async {
          imported = true;
          return const ImportResult();
        },
        applySettings: (settings, {required overwrite}) async => 0,
      );
    }

    final state = provider.state;
    expect(state, isA<SyncError>());
    expect(
      (state as SyncError).opticalCode,
      OpticalSyncErrorCode.wrongTransferCode,
    );
    expect(imported, isFalse);
    await provider.reset();
  });

  test('sender refuses a badly formed code', () async {
    final provider = SyncProvider();
    await provider.startOpticalTransmitting(
      accounts: const [],
      settingsSnapshot: const {},
      transferCode: 'ABC',
    );
    final state = provider.state;
    expect(state, isA<SyncError>());
    expect((state as SyncError).code, SyncErrorCode.opticalCodeInvalid);
    await provider.reset();
  });
}
