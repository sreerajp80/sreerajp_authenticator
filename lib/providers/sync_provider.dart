// File Path: sreerajp_authenticator/lib/providers/sync_provider.dart
// Author: Sreeraj P
// Description: Drives the P2P LAN sync UI. On the host (sender) side it binds a
//   listener, holds the authenticated connection open, and pushes the chosen
//   data (Full Sync or a selective incremental sync) when the user acts. On the
//   client (receiver) side it connects, waits for the sender to choose, then
//   imports. Secrets are decrypted with the device key only transiently while
//   building the payload and are never logged.

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../models/group.dart';
import '../providers/account_provider.dart';
import '../services/encryption_service.dart';
import '../services/p2p_sync_service.dart';
import '../utils/constants.dart';

/// Summary of one completed sync, shown to the user. On the host it reports what
/// was sent; on the client it reports what was added / skipped / applied.
class SyncSummary {
  final bool isHost;

  /// [AppConstants.syncModeFull] or [AppConstants.syncModeIncremental].
  final String mode;

  final bool includedAccounts;
  final bool includedGroups;
  final bool includedSettings;

  /// Host: accounts sent. Client: accounts newly added.
  final int accounts;

  /// Host: groups sent. Client: groups newly added.
  final int groups;

  /// Host: settings sent. Client: settings applied.
  final int settings;

  /// Client only: duplicates skipped (retained on the receiver).
  final int accountsSkipped;
  final int groupsSkipped;

  const SyncSummary({
    required this.isHost,
    required this.mode,
    required this.includedAccounts,
    required this.includedGroups,
    required this.includedSettings,
    this.accounts = 0,
    this.groups = 0,
    this.settings = 0,
    this.accountsSkipped = 0,
    this.groupsSkipped = 0,
  });

  bool get isFull => mode == AppConstants.syncModeFull;
}

/// UI state for the sync flow. The host (send) flow lives in [SyncHosting]
/// (which stays visible across the tabbed host screen); the client (receive)
/// flow is the linear Connecting → Waiting → Syncing → Completed sequence.
sealed class SyncState {
  const SyncState();
}

class SyncIdle extends SyncState {
  const SyncIdle();
}

/// Host is listening. Carries the connection details (Server Details tab), the
/// live connection status, and any in-flight send progress (Sync tab).
class SyncHosting extends SyncState {
  final String ipAddress;
  final int port;
  final String code;
  final bool clientConnected;

  /// True while a chosen payload is being pushed to the connected client.
  final bool sending;

  /// Human-readable labels of the categories being sent, for the progress list.
  final List<String> sendingItems;

  const SyncHosting({
    required this.ipAddress,
    required this.port,
    required this.code,
    this.clientConnected = false,
    this.sending = false,
    this.sendingItems = const [],
  });

  SyncHosting copyWith({
    bool? clientConnected,
    bool? sending,
    List<String>? sendingItems,
  }) => SyncHosting(
    ipAddress: ipAddress,
    port: port,
    code: code,
    clientConnected: clientConnected ?? this.clientConnected,
    sending: sending ?? this.sending,
    sendingItems: sendingItems ?? this.sendingItems,
  );
}

class SyncConnecting extends SyncState {
  const SyncConnecting();
}

/// Client has connected and authenticated and is waiting for the sender to
/// choose what to share.
class SyncWaitingForSender extends SyncState {
  const SyncWaitingForSender();
}

class SyncSyncing extends SyncState {
  const SyncSyncing();
}

class SyncCompleted extends SyncState {
  final SyncSummary summary;
  const SyncCompleted(this.summary);
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

  /// Bind a listener on a random port and begin waiting for a peer. The payload
  /// is not sent on connect; once a client authenticates the host holds the
  /// connection open (state → [SyncHosting] with `clientConnected == true`) and
  /// the sender pushes data via [sendFullSync] / [sendSelectiveSync].
  Future<void> startHosting({required int idleTimeoutSeconds}) async {
    final code = P2pSyncService.generatePairingCode();
    try {
      final binding = await _service.startHost(
        code: code,
        idleTimeout: Duration(seconds: idleTimeoutSeconds),
        onClientConnected: _onClientConnected,
        onClientDisconnected: _onClientDisconnected,
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

  void _onClientConnected() {
    final current = _state;
    if (current is SyncHosting) {
      _setState(current.copyWith(clientConnected: true));
    }
  }

  void _onClientDisconnected() {
    final current = _state;
    if (current is SyncHosting && !current.sending) {
      _setState(current.copyWith(clientConnected: false));
    }
  }

  /// Full Sync to a fresh client: send all accounts, groups, and syncable
  /// settings ([AppConstants.syncModeFull] — settings overwrite on the client).
  Future<void> sendFullSync({
    required List<Account> accounts,
    required List<Group> groups,
    required Map<String, dynamic> settingsSnapshot,
  }) => _send(
    accounts: accounts,
    groups: groups,
    settingsSnapshot: settingsSnapshot,
    includeAccounts: true,
    includeGroups: true,
    includeSettings: true,
    mode: AppConstants.syncModeFull,
  );

  /// Selective incremental sync: send only the chosen categories
  /// ([AppConstants.syncModeIncremental] — the client never overrides its own
  /// data and applies settings fill-only).
  Future<void> sendSelectiveSync({
    required List<Account> accounts,
    required List<Group> groups,
    required Map<String, dynamic> settingsSnapshot,
    required bool includeAccounts,
    required bool includeGroups,
    required bool includeSettings,
  }) => _send(
    accounts: accounts,
    groups: groups,
    settingsSnapshot: settingsSnapshot,
    includeAccounts: includeAccounts,
    includeGroups: includeGroups,
    includeSettings: includeSettings,
    mode: AppConstants.syncModeIncremental,
  );

  Future<void> _send({
    required List<Account> accounts,
    required List<Group> groups,
    required Map<String, dynamic> settingsSnapshot,
    required bool includeAccounts,
    required bool includeGroups,
    required bool includeSettings,
    required String mode,
  }) async {
    final current = _state;
    if (current is! SyncHosting || !current.clientConnected) {
      _setState(const SyncError('No device is connected to sync with.'));
      return;
    }
    if (!includeAccounts && !includeGroups && !includeSettings) {
      _setState(const SyncError('Select at least one item to sync.'));
      return;
    }

    final items = <String>[
      if (includeAccounts) 'Accounts',
      if (includeGroups) 'Groups',
      if (includeSettings) 'Settings',
    ];
    _setState(current.copyWith(sending: true, sendingItems: items));

    try {
      final payload = await _buildPayload(
        accounts: includeAccounts ? accounts : const [],
        groups: includeGroups ? groups : const [],
        settingsSnapshot: includeSettings ? settingsSnapshot : null,
        includeAccounts: includeAccounts,
        includeGroups: includeGroups,
        mode: mode,
      );
      await _service.sendToConnectedClient(payload);
      _setState(
        SyncCompleted(
          SyncSummary(
            isHost: true,
            mode: mode,
            includedAccounts: includeAccounts,
            includedGroups: includeGroups,
            includedSettings: includeSettings,
            accounts: includeAccounts ? accounts.length : 0,
            groups: includeGroups ? groups.length : 0,
            settings: includeSettings ? settingsSnapshot.length : 0,
          ),
        ),
      );
    } on P2pSyncException catch (e) {
      _setState(SyncError(e.message));
    } catch (e) {
      _setState(SyncError('Sync failed: $e'));
    }
  }

  /// Build the plaintext JSON payload: device-key-decrypted secrets in the same
  /// shape as an encrypted backup, plus an optional settings object and a sync
  /// mode marker. Plaintext exists only transiently and is never logged. Only
  /// the categories flagged for inclusion carry data.
  Future<String> _buildPayload({
    required List<Account> accounts,
    required List<Group> groups,
    required Map<String, dynamic>? settingsSnapshot,
    required bool includeAccounts,
    required bool includeGroups,
    required String mode,
  }) async {
    final backup = <String, dynamic>{
      'version': AppConstants.backupVersion,
      'created': DateTime.now().toIso8601String(),
      AppConstants.syncPayloadKeySyncMode: mode,
    };

    if (includeAccounts) {
      final decryptedAccounts = await Future.wait(
        accounts.map((account) async {
          final secret = await _encryption.decrypt(account.secret);
          return account.copyWith(secret: secret);
        }),
      );
      backup['accounts'] = decryptedAccounts.map((a) => a.toMap()).toList();
    }

    if (includeGroups) {
      backup['groups'] = groups.map((g) => g.toMap()).toList();
    }

    if (settingsSnapshot != null) {
      backup[AppConstants.syncPayloadKeySettings] = settingsSnapshot;
    }

    return jsonEncode(backup);
  }

  Future<void> stopHosting() async {
    await _service.stopHost();
    _setState(const SyncIdle());
  }

  // ─── Client ────────────────────────────────────────────────────────────────

  /// Connect to a host, wait for the sender to choose, then import the received
  /// payload. [importData] routes accounts/groups through the account import
  /// funnel (client-wins) and [applySettings] applies any synced settings.
  Future<void> joinSync({
    required String hostIp,
    required int port,
    required String code,
    required Future<ImportResult> Function(Map<String, dynamic> data)
    importData,
    required Future<int> Function(
      Map<String, dynamic> settings, {
      required bool overwrite,
    })
    applySettings,
  }) async {
    _setState(const SyncConnecting());
    try {
      final normalized = P2pSyncService.normalizeCode(code);
      final plain = await _service.connectAndFetch(
        hostIp: hostIp.trim(),
        port: port,
        code: normalized,
        onConnected: () => _setState(const SyncWaitingForSender()),
      );

      _setState(const SyncSyncing());
      final data = P2pSyncService.validateAndParse(plain);

      final importResult = await importData(data);

      final mode =
          (data[AppConstants.syncPayloadKeySyncMode] as String?) ??
          AppConstants.syncModeIncremental;
      final settings =
          data[AppConstants.syncPayloadKeySettings] as Map<String, dynamic>?;
      var settingsApplied = 0;
      if (settings != null && settings.isNotEmpty) {
        settingsApplied = await applySettings(
          settings,
          overwrite: mode == AppConstants.syncModeFull,
        );
      }

      _setState(
        SyncCompleted(
          SyncSummary(
            isHost: false,
            mode: mode,
            includedAccounts: data.containsKey('accounts'),
            includedGroups: data.containsKey('groups'),
            includedSettings: settings != null,
            accounts: importResult.accountsAdded,
            groups: importResult.groupsAdded,
            settings: settingsApplied,
            accountsSkipped: importResult.accountsSkipped,
            groupsSkipped: importResult.groupsSkipped,
          ),
        ),
      );
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
