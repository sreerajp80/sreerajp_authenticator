// File Path: sreerajp_authenticator/lib/services/p2p_sync_service.dart
// Author: Sreeraj P
// Description: Offline LAN peer-to-peer sync engine. Security comes from a
//   per-session high-entropy pairing code transferred out-of-band (never on the
//   wire); the payload is sealed with a PBKDF2-derived AES-256-GCM key, so a
//   wrong code yields a wrong key and GCM tag verification fails on decrypt.
//   See docs/security.md and the P2P sync plan. Never logs secrets or payloads.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';

import '../models/account.dart';
import '../models/group.dart';
import '../utils/constants.dart';
import '../utils/network_utils.dart';

/// Error type for sync failures surfaced to the UI. The [message] is safe to
/// show to the user and never contains secret or decrypted data.
class P2pSyncException implements Exception {
  final String message;
  const P2pSyncException(this.message);
  @override
  String toString() => message;
}

/// Details returned to the host UI once the listener is bound.
class HostBinding {
  final String ipAddress;
  final int port;
  const HostBinding(this.ipAddress, this.port);
}

class P2pSyncService {
  ServerSocket? _serverSocket;
  Timer? _idleTimer;
  bool _authenticated = false;
  bool _timedOut = false;
  bool _stopped = false;

  // Held-open client session (host side). After a client authenticates the host
  // keeps the connection open and waits for the sender to choose what to share;
  // the payload is pushed later via [sendToConnectedClient].
  Socket? _activeSocket;
  enc.Key? _activeKey;
  _BoundedLineReader? _activeReader;
  void Function()? _onClientConnected;
  void Function()? _onClientDisconnected;
  void Function(String message)? _onHostError;

  /// True once a client has authenticated and the connection is being held open.
  bool get hasConnectedClient => _activeSocket != null;

  // ─── Crypto (app-agnostic core) ────────────────────────────────────────────

  static final Random _secureRandom = Random.secure();

  /// Fresh ~320-bit pairing code: 64 chars from a 31-symbol alphabet.
  static String generatePairingCode() {
    const alphabet = AppConstants.syncPairingAlphabet;
    final sb = StringBuffer();
    for (var i = 0; i < AppConstants.syncPairingCodeLength; i++) {
      sb.write(alphabet[_secureRandom.nextInt(alphabet.length)]);
    }
    return sb.toString();
  }

  /// Both sides normalize identically so the hyphen-grouped displayed code
  /// matches what is typed (uppercase, drop anything outside the alphabet).
  static String normalizeCode(String input) {
    const alphabet = AppConstants.syncPairingAlphabet;
    final sb = StringBuffer();
    for (final ch in input.toUpperCase().split('')) {
      if (alphabet.contains(ch)) sb.write(ch);
    }
    return sb.toString();
  }

  /// Hyphen-group the code for display, e.g. ABCDEFGH-JKMNPQRS-...
  static String formatPairingCode(String code) {
    const group = AppConstants.syncPairingCodeGroup;
    final chunks = <String>[];
    for (var i = 0; i < code.length; i += group) {
      chunks.add(code.substring(i, min(i + group, code.length)));
    }
    return chunks.join('-');
  }

  /// Build the out-of-band QR payload for the host: a versioned URI carrying the
  /// host IP, port, and pairing code so the peer can scan instead of typing. This
  /// is shown only on-screen and read by the peer's camera — it is never sent
  /// over the network (see docs/security.md §5.1).
  static String buildSyncQrPayload({
    required String ipAddress,
    required int port,
    required String code,
  }) {
    final uri = Uri(
      scheme: AppConstants.syncQrScheme,
      host: AppConstants.syncQrHost,
      queryParameters: {
        AppConstants.syncQrKeyVersion: AppConstants.syncQrVersion,
        AppConstants.syncQrKeyIp: ipAddress,
        AppConstants.syncQrKeyPort: port.toString(),
        AppConstants.syncQrKeyCode: code,
      },
    );
    return uri.toString();
  }

  /// Parse a scanned sync QR back into its host IP, port, and normalized code.
  /// Throws [P2pSyncException] with a user-safe message on any foreign or
  /// malformed QR (wrong scheme/host/version, missing/invalid port, empty code).
  static ({String ipAddress, int port, String code}) parseSyncQrPayload(
    String raw,
  ) {
    final Uri uri;
    try {
      uri = Uri.parse(raw.trim());
    } catch (_) {
      throw const P2pSyncException('Not a sync QR code');
    }

    if (uri.scheme != AppConstants.syncQrScheme ||
        uri.host != AppConstants.syncQrHost) {
      throw const P2pSyncException('Not a sync QR code');
    }
    if (uri.queryParameters[AppConstants.syncQrKeyVersion] !=
        AppConstants.syncQrVersion) {
      throw const P2pSyncException('Unsupported sync QR version');
    }

    final ipAddress =
        (uri.queryParameters[AppConstants.syncQrKeyIp] ?? '').trim();
    if (ipAddress.isEmpty) {
      throw const P2pSyncException('Sync QR is missing the host address');
    }

    final port = int.tryParse(
      uri.queryParameters[AppConstants.syncQrKeyPort] ?? '',
    );
    if (port == null || port < 1 || port > 65535) {
      throw const P2pSyncException('Sync QR has an invalid port');
    }

    final code = normalizeCode(uri.queryParameters[AppConstants.syncQrKeyCode] ?? '');
    if (code.isEmpty) {
      throw const P2pSyncException('Sync QR is missing the pairing code');
    }

    return (ipAddress: ipAddress, port: port, code: code);
  }

  static Uint8List _randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _secureRandom.nextInt(256);
    }
    return bytes;
  }

  /// PBKDF2-HMAC-SHA256 stretch of the pairing code into a 256-bit AES key.
  static enc.Key deriveKey(String code, List<int> salt) {
    final pbkdf2 = PBKDF2KeyDerivator(
      HMac(SHA256Digest(), AppConstants.hmacBlockSize),
    )..init(
      Pbkdf2Parameters(
        Uint8List.fromList(salt),
        AppConstants.pbkdf2Iterations,
        AppConstants.pbkdf2HashSize,
      ),
    );
    final keyBytes = pbkdf2.process(Uint8List.fromList(utf8.encode(code)));
    return enc.Key(keyBytes);
  }

  /// AES-256-GCM. Wire format: base64(nonce(12) || ciphertext+tag), one line.
  static String encryptWire(String data, enc.Key key) {
    final iv = enc.IV.fromSecureRandom(AppConstants.gcmNonceSize);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encrypt(data, iv: iv);
    final combined = Uint8List(iv.bytes.length + encrypted.bytes.length)
      ..setRange(0, iv.bytes.length, iv.bytes)
      ..setRange(iv.bytes.length, iv.bytes.length + encrypted.bytes.length,
          encrypted.bytes);
    return base64.encode(combined);
  }

  /// Throws on tamper / wrong key. Callers treat a throw as auth failure.
  static String decryptWire(String encoded, enc.Key key) {
    final all = base64.decode(encoded);
    if (all.length <= AppConstants.gcmNonceSize) {
      throw const P2pSyncException('Malformed ciphertext');
    }
    final iv = enc.IV(
      Uint8List.fromList(all.sublist(0, AppConstants.gcmNonceSize)),
    );
    final ct = enc.Encrypted(
      Uint8List.fromList(all.sublist(AppConstants.gcmNonceSize)),
    );
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    return encrypter.decrypt(ct, iv: iv);
  }

  // ─── Payload validation (before ingestion) ─────────────────────────────────

  /// Parse + validate a received plaintext JSON payload against the caps in
  /// [AppConstants]. Returns a map with 'accounts' (`List<Account>`) and
  /// 'groups' (`List<Group>`) ready for the import funnel. Throws
  /// [P2pSyncException] on any cap violation or malformed data — applied before
  /// the data reaches the DB.
  static Map<String, dynamic> validateAndParse(String jsonStr) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonStr);
    } catch (_) {
      throw const P2pSyncException('Malformed sync payload');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const P2pSyncException('Malformed sync payload');
    }

    final hasAccounts = decoded['accounts'] is List;
    final hasGroups = decoded['groups'] is List;
    final accountsJson = (decoded['accounts'] as List?) ?? const [];
    final groupsJson = (decoded['groups'] as List?) ?? const [];

    if (accountsJson.length > AppConstants.syncMaxAccounts) {
      throw const P2pSyncException('Payload exceeds the account limit');
    }
    if (groupsJson.length > AppConstants.syncMaxGroups) {
      throw const P2pSyncException('Payload exceeds the group limit');
    }

    try {
      final accounts = <Account>[];
      for (final item in accountsJson) {
        if (item is! Map<String, dynamic>) {
          throw const P2pSyncException('Malformed account entry');
        }
        _checkFieldLengths(item);
        accounts.add(Account.fromMap(item));
      }

      final groups = <Group>[];
      for (final item in groupsJson) {
        if (item is! Map<String, dynamic>) {
          throw const P2pSyncException('Malformed group entry');
        }
        _checkFieldLengths(item);
        groups.add(Group.fromMap(item));
      }

      // Only include category keys that were actually present, so the receiver
      // can tell "0 accounts sent" from "accounts not part of this sync".
      final result = <String, dynamic>{};
      if (hasAccounts) result['accounts'] = accounts;
      if (hasGroups) result['groups'] = groups;

      final settings = decoded[AppConstants.syncPayloadKeySettings];
      if (settings is Map<String, dynamic>) {
        _checkFieldLengths(settings);
        result[AppConstants.syncPayloadKeySettings] = settings;
      }

      final mode = decoded[AppConstants.syncPayloadKeySyncMode];
      if (mode is String) {
        result[AppConstants.syncPayloadKeySyncMode] = mode;
      }

      return result;
    } on P2pSyncException {
      rethrow;
    } catch (_) {
      throw const P2pSyncException('Malformed sync payload');
    }
  }

  static void _checkFieldLengths(Map<String, dynamic> map) {
    for (final value in map.values) {
      if (value is String && value.length > AppConstants.syncMaxFieldLength) {
        throw const P2pSyncException('A field in the payload is too large');
      }
    }
  }

  // ─── Host (server) ─────────────────────────────────────────────────────────

  /// Bind a listener on a random OS-assigned port and begin accepting in the
  /// background. Returns the address/port to display to the user. The host
  /// auto-stops after [idleTimeout] if no client completes the handshake.
  ///
  /// The payload is NOT sent on connect. When a client authenticates the host
  /// sends the accept immediately and fires [onClientConnected], then holds the
  /// connection open; the sender pushes the chosen data later via
  /// [sendToConnectedClient]. If the held connection drops before a send,
  /// [onClientDisconnected] fires and the host resumes waiting.
  Future<HostBinding> startHost({
    required String code,
    required Duration idleTimeout,
    required void Function() onClientConnected,
    required void Function() onClientDisconnected,
    required void Function(String message) onError,
    required void Function() onTimedOut,
  }) async {
    await stopHost();
    _authenticated = false;
    _timedOut = false;
    _stopped = false;
    _onClientConnected = onClientConnected;
    _onClientDisconnected = onClientDisconnected;
    _onHostError = onError;

    final ip = await NetworkUtils.getLocalIpAddress();
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _serverSocket = server;

    _armIdleTimer(idleTimeout, onTimedOut);

    // Run the accept loop without awaiting so we can return the binding now.
    unawaited(_runHostLoop(server, code));

    return HostBinding(ip, server.port);
  }

  void _armIdleTimer(Duration idleTimeout, void Function() onTimedOut) {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleTimeout, () {
      if (!_authenticated) {
        _timedOut = true;
        onTimedOut();
        stopHost();
      }
    });
  }

  Future<void> _runHostLoop(ServerSocket server, String code) async {
    try {
      await for (final socket in server) {
        await _handleHostConnection(socket, code);
      }
    } catch (e) {
      if (!_timedOut && !_stopped) {
        _onHostError?.call('Server error: $e');
      }
    }
  }

  /// Handle one incoming connection. On successful auth the socket is retained
  /// as the active client (connection held open) and the accept line is sent so
  /// the peer knows it is connected; the payload follows later. Rejected or
  /// garbled attempts are closed quietly and the host keeps listening.
  Future<void> _handleHostConnection(Socket socket, String code) async {
    // Single client at a time: reject anyone who connects while one is held.
    if (_activeSocket != null) {
      try {
        await socket.close();
      } catch (_) {}
      return;
    }

    final reader = _BoundedLineReader(socket);
    try {
      // 0. Per-session salt sent in clear (not secret), then derive key.
      final salt = _randomBytes(AppConstants.saltSize);
      socket.write('${base64.encode(salt)}\n');
      await socket.flush();
      final key = deriveKey(code, salt);

      // 1. Authenticated greeting. Wrong code -> wrong key -> decrypt throws.
      final clientMessage = await reader
          .readLine(AppConstants.syncMaxHandshakeLine)
          .timeout(AppConstants.syncSocketTimeout);
      if (clientMessage == null) {
        await _closeQuietly(reader, socket);
        return;
      }

      bool authenticated;
      try {
        authenticated =
            decryptWire(clientMessage, key) == AppConstants.syncHelloMessage;
      } catch (_) {
        authenticated = false;
      }
      if (!authenticated) {
        try {
          socket.write('${encryptWire(AppConstants.syncDeniedMessage, key)}\n');
          await socket.flush();
        } catch (_) {}
        await _closeQuietly(reader, socket); // keep listening; idle timer active
        return;
      }

      // 2. Authenticated: acknowledge immediately, then hold the connection.
      _authenticated = true;
      _idleTimer?.cancel();
      _idleTimer = null;
      socket.write('${encryptWire(AppConstants.syncAcceptMessage, key)}\n');
      await socket.flush();

      _activeSocket = socket;
      _activeKey = key;
      _activeReader = reader;

      // Detect the peer dropping the held connection before we send.
      unawaited(reader.closed.then((_) => _handleClientDropped()));

      _onClientConnected?.call();
    } catch (_) {
      // Pre-auth transport error (e.g. a port scanner): close and keep listening.
      await _closeQuietly(reader, socket);
    }
  }

  /// Push the chosen plaintext JSON [payload] to the connected client over the
  /// held connection, then tear the session down. Throws [P2pSyncException] if
  /// no client is connected or the send fails.
  Future<void> sendToConnectedClient(String payload) async {
    final socket = _activeSocket;
    final key = _activeKey;
    if (socket == null || key == null) {
      throw const P2pSyncException('The other device is no longer connected');
    }
    try {
      socket.write('${encryptWire(payload, key)}\n');
      await socket.flush();
    } catch (e) {
      throw P2pSyncException('Sync send failed: $e');
    } finally {
      // A session sends exactly one payload; stop hosting once it is delivered.
      await stopHost();
    }
  }

  void _handleClientDropped() {
    // Ignore drops caused by our own teardown (stop / successful send).
    if (_stopped || _activeSocket == null) return;
    _clearActiveClient();
    _authenticated = false;
    _onClientDisconnected?.call();
  }

  void _clearActiveClient() {
    final reader = _activeReader;
    final socket = _activeSocket;
    _activeReader = null;
    _activeSocket = null;
    _activeKey = null;
    if (reader != null) {
      reader.cancel();
    }
    if (socket != null) {
      try {
        socket.destroy();
      } catch (_) {}
    }
  }

  Future<void> _closeQuietly(_BoundedLineReader reader, Socket socket) async {
    await reader.cancel();
    try {
      await socket.close();
    } catch (_) {}
  }

  Future<void> stopHost() async {
    _stopped = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    _clearActiveClient();
    _onClientConnected = null;
    _onClientDisconnected = null;
    _onHostError = null;
    final server = _serverSocket;
    _serverSocket = null;
    if (server != null) {
      try {
        await server.close();
      } catch (_) {}
    }
  }

  // ─── Client ────────────────────────────────────────────────────────────────

  /// Connect to a host, authenticate with [code], and return the decrypted
  /// plaintext JSON payload. Throws [P2pSyncException] on any failure. The
  /// caller validates and imports the returned payload.
  ///
  /// [onConnected] fires once the host has accepted this device but before the
  /// payload arrives — the sender then chooses what to share, so the wait for
  /// the payload can be long (bounded by [AppConstants.syncPayloadWaitTimeout]).
  Future<String> connectAndFetch({
    required String hostIp,
    required int port,
    required String code,
    void Function()? onConnected,
  }) async {
    Socket? socket;
    _BoundedLineReader? reader;
    try {
      socket = await Socket.connect(
        hostIp,
        port,
        timeout: AppConstants.syncConnectTimeout,
      );
      reader = _BoundedLineReader(socket);

      // 0. Read host salt, derive key.
      final saltLine = await reader
          .readLine(AppConstants.syncMaxHandshakeLine)
          .timeout(AppConstants.syncSocketTimeout);
      if (saltLine == null) {
        throw const P2pSyncException('No response from host');
      }
      final List<int> salt;
      try {
        salt = base64.decode(saltLine);
      } catch (_) {
        throw const P2pSyncException('Invalid response from host');
      }
      final key = deriveKey(code, salt);

      // 1. Send authenticated greeting.
      socket.write('${encryptWire(AppConstants.syncHelloMessage, key)}\n');
      await socket.flush();

      // 2. Read accept (wrong code -> decrypt throws -> not accepted).
      final ans = await reader
          .readLine(AppConstants.syncMaxHandshakeLine)
          .timeout(AppConstants.syncSocketTimeout);
      if (ans == null) {
        throw const P2pSyncException('Connection closed by host');
      }
      bool accepted;
      try {
        accepted = decryptWire(ans, key) == AppConstants.syncAcceptMessage;
      } catch (_) {
        accepted = false;
      }
      if (!accepted) {
        throw const P2pSyncException('Incorrect pairing code');
      }

      // Connected and waiting: the sender now chooses what to share.
      onConnected?.call();

      // 3. Read + decrypt payload. The sender may take a while to choose, so
      // this read uses the long payload-wait timeout, not the socket timeout.
      final encPayload = await reader
          .readLine(AppConstants.syncMaxPayloadLine)
          .timeout(AppConstants.syncPayloadWaitTimeout);
      if (encPayload == null) {
        throw const P2pSyncException('The other device closed the connection');
      }
      try {
        return decryptWire(encPayload, key);
      } catch (_) {
        throw const P2pSyncException(
          'Decryption failed; check the pairing code',
        );
      }
    } on P2pSyncException {
      rethrow;
    } on TimeoutException {
      throw const P2pSyncException('The connection timed out');
    } on SocketException catch (e) {
      throw P2pSyncException('Could not connect to host: ${e.message}');
    } finally {
      await reader?.cancel();
      try {
        await socket?.close();
      } catch (_) {}
    }
  }
}

/// Bounded replacement for an unbounded `readLine`: buffers incoming bytes and
/// aborts past [maxLen] so one giant line cannot exhaust memory (guide §4).
/// Only one [readLine] may be pending at a time.
class _BoundedLineReader {
  final List<int> _buffer = [];
  bool _closed = false;
  Object? _error;
  Completer<String?>? _pending;
  int _pendingMax = 0;
  final Completer<void> _closedCompleter = Completer<void>();
  late final StreamSubscription<Uint8List> _subscription;

  _BoundedLineReader(Stream<Uint8List> stream) {
    _subscription = stream.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: false,
    );
  }

  /// Completes when the underlying stream ends or errors (i.e. the peer closed
  /// the connection). Used by the host to notice a held client dropping.
  Future<void> get closed => _closedCompleter.future;

  void _completeClosed() {
    if (!_closedCompleter.isCompleted) _closedCompleter.complete();
  }

  void _onData(Uint8List data) {
    _buffer.addAll(data);
    _serve();
  }

  void _onError(Object error) {
    _error = error;
    _serve();
    _completeClosed();
  }

  void _onDone() {
    _closed = true;
    _serve();
    _completeClosed();
  }

  Future<String?> readLine(int maxLen) {
    if (_pending != null) {
      throw StateError('A readLine is already pending');
    }
    final completer = Completer<String?>();
    _pending = completer;
    _pendingMax = maxLen;
    _serve();
    return completer.future;
  }

  void _serve() {
    final completer = _pending;
    if (completer == null) return;

    final newlineIndex = _buffer.indexOf(0x0A); // '\n'
    if (newlineIndex >= 0) {
      var end = newlineIndex;
      if (end > 0 && _buffer[end - 1] == 0x0D) end--; // strip trailing '\r'
      if (end > _pendingMax) {
        _failPending('Line exceeds maximum length');
        return;
      }
      final lineBytes = _buffer.sublist(0, end);
      _buffer.removeRange(0, newlineIndex + 1);
      _pending = null;
      completer.complete(utf8.decode(lineBytes, allowMalformed: true));
      return;
    }

    if (_buffer.length > _pendingMax) {
      _failPending('Line exceeds maximum length');
      return;
    }
    if (_error != null) {
      _failPending('Connection error');
      return;
    }
    if (_closed) {
      _pending = null;
      completer.complete(null); // EOF before a full line
    }
  }

  void _failPending(String message) {
    final completer = _pending;
    _pending = null;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(P2pSyncException(message));
    }
  }

  Future<void> cancel() async {
    _completeClosed();
    try {
      await _subscription.cancel();
    } catch (_) {}
  }
}
