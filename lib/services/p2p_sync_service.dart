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

      return {'accounts': accounts, 'groups': groups};
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
  /// [buildPayload] is called only after a client authenticates; it returns the
  /// plaintext JSON to send (the caller is responsible for decrypting secrets
  /// with the device key when building it).
  Future<HostBinding> startHost({
    required String code,
    required Duration idleTimeout,
    required Future<String> Function() buildPayload,
    required void Function() onSyncing,
    required void Function(int exportedCount) onCompleted,
    required void Function(String message) onError,
    required void Function() onTimedOut,
  }) async {
    await stopHost();
    _authenticated = false;
    _timedOut = false;
    _stopped = false;

    final ip = await NetworkUtils.getLocalIpAddress();
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _serverSocket = server;

    _idleTimer = Timer(idleTimeout, () {
      if (!_authenticated) {
        _timedOut = true;
        onTimedOut();
        stopHost();
      }
    });

    // Run the accept loop without awaiting so we can return the binding now.
    unawaited(
      _runHostLoop(server, code, buildPayload, onSyncing, onCompleted, onError),
    );

    return HostBinding(ip, server.port);
  }

  Future<void> _runHostLoop(
    ServerSocket server,
    String code,
    Future<String> Function() buildPayload,
    void Function() onSyncing,
    void Function(int) onCompleted,
    void Function(String) onError,
  ) async {
    try {
      await for (final socket in server) {
        final done = await _handleHostTransaction(
          socket,
          code,
          buildPayload,
          onSyncing,
          onCompleted,
          onError,
        );
        if (done) break;
      }
    } catch (e) {
      if (!_timedOut && !_stopped) {
        onError('Server error: $e');
      }
    } finally {
      await stopHost();
    }
  }

  /// Handles a single connection. Returns true when the host should stop
  /// listening (successful sync, or a fatal post-auth error); false to keep
  /// listening (rejected/garbled attempt — the idle timer remains active).
  Future<bool> _handleHostTransaction(
    Socket socket,
    String code,
    Future<String> Function() buildPayload,
    void Function() onSyncing,
    void Function(int) onCompleted,
    void Function(String) onError,
  ) async {
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
      if (clientMessage == null) return false;

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
        return false; // keep listening; idle timer still active
      }

      _authenticated = true;
      _idleTimer?.cancel();
      onSyncing();

      // 2. Send accept + payload.
      final payload = await buildPayload();
      socket.write('${encryptWire(AppConstants.syncAcceptMessage, key)}\n');
      socket.write('${encryptWire(payload, key)}\n');
      await socket.flush();

      onCompleted(_countAccounts(payload));
      return true;
    } catch (e) {
      if (_authenticated) {
        onError('Sync exchange failed: $e');
        return true;
      }
      // Pre-auth transport error (e.g. a port scanner): keep listening quietly.
      return false;
    } finally {
      await reader.cancel();
      try {
        await socket.close();
      } catch (_) {}
    }
  }

  static int _countAccounts(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map && decoded['accounts'] is List) {
        return (decoded['accounts'] as List).length;
      }
    } catch (_) {}
    return 0;
  }

  Future<void> stopHost() async {
    _stopped = true;
    _idleTimer?.cancel();
    _idleTimer = null;
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
  Future<String> connectAndFetch({
    required String hostIp,
    required int port,
    required String code,
    void Function()? onSyncing,
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

      onSyncing?.call();

      // 3. Read + decrypt payload.
      final encPayload = await reader
          .readLine(AppConstants.syncMaxPayloadLine)
          .timeout(AppConstants.syncSocketTimeout);
      if (encPayload == null) {
        throw const P2pSyncException('No data received from host');
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
  late final StreamSubscription<Uint8List> _subscription;

  _BoundedLineReader(Stream<Uint8List> stream) {
    _subscription = stream.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: false,
    );
  }

  void _onData(Uint8List data) {
    _buffer.addAll(data);
    _serve();
  }

  void _onError(Object error) {
    _error = error;
    _serve();
  }

  void _onDone() {
    _closed = true;
    _serve();
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
    try {
      await _subscription.cancel();
    } catch (_) {}
  }
}
