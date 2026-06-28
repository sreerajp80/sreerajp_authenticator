// File Path: sreerajp_authenticator/lib/providers/sync_provider.dart
// Author: Sreeraj P
// Description: Drives the P2P LAN sync UI. Orchestrates the P2pSyncService and
//   the import funnel, exposing a single SyncState to the screen. Secrets are
//   decrypted with the device key only transiently while building the payload
//   and are never logged.

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../models/group.dart';
import '../services/encryption_service.dart';
import '../services/p2p_sync_service.dart';
import '../utils/constants.dart';

/// UI state for the sync flow. Consumed by `SyncScreen`.
sealed class SyncState {
  const SyncState();
}

class SyncIdle extends SyncState {
  const SyncIdle();
}

class SyncHosting extends SyncState {
  final String ipAddress;
  final int port;
  final String code;
  const SyncHosting({
    required this.ipAddress,
    required this.port,
    required this.code,
  });
}

class SyncConnecting extends SyncState {
  const SyncConnecting();
}

class SyncSyncing extends SyncState {
  const SyncSyncing();
}

class SyncCompleted extends SyncState {
  /// Accounts received and routed to the import funnel (duplicates are skipped
  /// by the funnel itself).
  final int receivedCount;

  /// Accounts sent to the peer (host side).
  final int sentCount;
  const SyncCompleted({this.receivedCount = 0, this.sentCount = 0});
}

class SyncError extends SyncState {
  final String message;
  const SyncError(this.message);
}

class SyncProvider extends ChangeNotifier {
  final P2pSyncService _service = P2pSyncService();
  final EncryptionService _encryption = EncryptionService();

  SyncState _state = const SyncIdle();
  SyncState get state => _state;

  bool get isHosting => _state is SyncHosting;

  void _setState(SyncState state) {
    _state = state;
    notifyListeners();
  }

  // ─── Host ──────────────────────────────────────────────────────────────────

  /// Generate a pairing code, bind a listener on a random port, and start
  /// waiting for a peer. The host auto-stops after [idleTimeoutSeconds] if no
  /// peer completes the handshake.
  Future<void> startHosting({
    required List<Account> accounts,
    required List<Group> groups,
    required int idleTimeoutSeconds,
  }) async {
    final code = P2pSyncService.generatePairingCode();
    try {
      final binding = await _service.startHost(
        code: code,
        idleTimeout: Duration(seconds: idleTimeoutSeconds),
        buildPayload: () => _buildPayload(accounts, groups),
        onSyncing: () => _setState(const SyncSyncing()),
        onCompleted: (sent) => _setState(SyncCompleted(sentCount: sent)),
        onError: (message) => _setState(SyncError(message)),
        onTimedOut: () => _setState(
          const SyncError('No device connected in time; hosting stopped.'),
        ),
      );
      _setState(
        SyncHosting(
          ipAddress: binding.ipAddress,
          port: binding.port,
          code: code,
        ),
      );
    } catch (e) {
      _setState(SyncError('Could not start hosting: $e'));
    }
  }

  /// Build the plaintext JSON payload to send: device-key-decrypted secrets in
  /// the same shape as an encrypted backup. Plaintext exists only transiently.
  Future<String> _buildPayload(
    List<Account> accounts,
    List<Group> groups,
  ) async {
    final decryptedAccounts = await Future.wait(
      accounts.map((account) async {
        final secret = await _encryption.decrypt(account.secret);
        return account.copyWith(secret: secret);
      }),
    );

    final backup = {
      'version': AppConstants.backupVersion,
      'created': DateTime.now().toIso8601String(),
      'accounts': decryptedAccounts.map((a) => a.toMap()).toList(),
      'groups': groups.map((g) => g.toMap()).toList(),
    };
    return jsonEncode(backup);
  }

  Future<void> stopHosting() async {
    await _service.stopHost();
    _setState(const SyncIdle());
  }

  // ─── Client ────────────────────────────────────────────────────────────────

  /// Connect to a host, fetch + validate the payload, then route it through the
  /// import funnel via [onImport]. [onImport] receives a map with 'accounts'
  /// (`List<Account>`) and 'groups' (`List<Group>`).
  Future<void> joinSync({
    required String hostIp,
    required int port,
    required String code,
    required Future<void> Function(Map<String, dynamic> data) onImport,
  }) async {
    _setState(const SyncConnecting());
    try {
      final normalized = P2pSyncService.normalizeCode(code);
      final plain = await _service.connectAndFetch(
        hostIp: hostIp.trim(),
        port: port,
        code: normalized,
        onSyncing: () => _setState(const SyncSyncing()),
      );

      final data = P2pSyncService.validateAndParse(plain);
      final received = (data['accounts'] as List).length;
      await onImport(data);
      _setState(SyncCompleted(receivedCount: received));
    } on P2pSyncException catch (e) {
      _setState(SyncError(e.message));
    } catch (e) {
      _setState(SyncError('Sync failed: $e'));
    }
  }

  /// Return to the idle state (e.g. to retry after an error or completion).
  Future<void> reset() async {
    await _service.stopHost();
    _setState(const SyncIdle());
  }

  @override
  void dispose() {
    _service.stopHost();
    super.dispose();
  }
}
