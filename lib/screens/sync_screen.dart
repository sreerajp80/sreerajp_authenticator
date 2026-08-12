// File Path: sreerajp_authenticator/lib/screens/sync_screen.dart
// Author: Sreeraj P
// Description: P2P LAN sync UI. The sender hosts (Server Details + Sync tabs, see
//   SendToDeviceView); the receiver joins by scanning the QR or typing the host
//   IP, port, and pairing code. See docs/security.md.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../services/p2p_sync_service.dart';
import 'optical_sync_screen.dart';
import 'send_to_device_screen.dart';
import 'sync_qr_scanner_screen.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final _hostIpController = TextEditingController();
  final _portController = TextEditingController();
  final _codeController = TextEditingController();

  bool _showJoinForm = false;
  SyncProvider? _syncProvider;
  SettingsProvider? _settingsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncProvider = context.read<SyncProvider>();
    // Suppress idle/background auto-lock while on this screen so a host waiting
    // for a peer (or an in-flight transfer) is not locked out mid-sync.
    _settingsProvider ??= context.read<SettingsProvider>()
      ..setSyncInProgress(true);
  }

  @override
  void dispose() {
    // Tear down any active listener when leaving the screen.
    _syncProvider?.reset();
    _settingsProvider?.setSyncInProgress(false);
    _hostIpController.dispose();
    _portController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _startHosting() async {
    final idleTimeout = context.read<SettingsProvider>().syncHostIdleTimeout;
    await context.read<SyncProvider>().startHosting(
      idleTimeoutSeconds: idleTimeout,
    );
  }

  Future<void> _join() async {
    final hostIp = _hostIpController.text.trim();
    final portText = _portController.text.trim();
    final code = _codeController.text.trim();

    if (hostIp.isEmpty) {
      _showMessage('Enter the host IP address', isError: true);
      return;
    }
    final port = int.tryParse(portText);
    if (port == null || port < 1 || port > 65535) {
      _showMessage('Enter the port shown on the other device', isError: true);
      return;
    }
    if (P2pSyncService.normalizeCode(code).isEmpty) {
      _showMessage('Enter the pairing code', isError: true);
      return;
    }

    final accountsProvider = context.read<AccountsProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await context.read<SyncProvider>().joinSync(
      hostIp: hostIp,
      port: port,
      code: code,
      importData: (data) => accountsProvider.importData(data),
      applySettings: (settings, {required overwrite}) =>
          settingsProvider.applySyncedSettings(settings, overwrite: overwrite),
    );
  }

  Future<void> _scanQr() async {
    final result = await Navigator.of(context).push<SyncQrResult>(
      MaterialPageRoute(builder: (_) => const SyncQrScannerScreen()),
    );
    if (result == null || !mounted) return;

    _hostIpController.text = result.ipAddress;
    _portController.text = result.port.toString();
    _codeController.text = result.code;
    await _join();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Auto-pop (and tear down the listener via dispose) if the app locks.
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Consumer<SyncProvider>(
          builder: (context, syncProvider, child) {
            final isHosting = syncProvider.state is SyncHosting;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  isHosting
                      ? 'Send to another device'
                      : 'Sync to another device',
                ),
              ),
              body: _buildBody(context, syncProvider.state),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SyncState state) {
    return switch (state) {
      SyncHosting() => SendToDeviceView(state: state),
      SyncConnecting() => _buildProgress('Connecting to host…'),
      SyncWaitingForSender() => _buildWaitingForSender(context),
      SyncSyncing() => _buildProgress('Receiving…'),
      SyncCompleted() => _buildCompleted(context, state),
      SyncError() => _buildError(context, state),
      SyncOpticalTransmitting() =>
        _showJoinForm ? _buildJoinForm(context) : _buildMenu(context),
      SyncOpticalReceiving() =>
        _showJoinForm ? _buildJoinForm(context) : _buildMenu(context),
      SyncIdle() =>
        _showJoinForm ? _buildJoinForm(context) : _buildMenu(context),
    };
  }

  Widget _buildMenu(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.wifi, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'P2P LAN Sync: Both devices on the same Wi-Fi or hotspot. '
                    'Pairing code never leaves your device.',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: _iconBox(
              context,
              Icons.upload,
              theme.colorScheme.primaryContainer,
              theme.colorScheme.onPrimaryContainer,
            ),
            title: const Text('Send over Wi-Fi / LAN'),
            subtitle: const Text(
              'Host: share your accounts and settings over local Wi-Fi',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _startHosting,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: _iconBox(
              context,
              Icons.download,
              theme.colorScheme.secondaryContainer,
              theme.colorScheme.onSecondaryContainer,
            ),
            title: const Text('Receive over Wi-Fi / LAN'),
            subtitle: const Text('Join: scan the host QR or enter host IP'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _showJoinForm = true),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'OPTICAL AIR-GAP SYNC (NO WI-FI / NO SOCKETS)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: _iconBox(
              context,
              Icons.sensors,
              theme.colorScheme.tertiaryContainer,
              theme.colorScheme.onTertiaryContainer,
            ),
            title: const Text('Optical Air-Gap Stream (Send)'),
            subtitle: const Text(
              'Transmit vault as animated QR stream (12-15 FPS)',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OpticalSyncScreen(
                    initialMode: OpticalSyncMode.transmit,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: _iconBox(
              context,
              Icons.qr_code_scanner,
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.onSurfaceVariant,
            ),
            title: const Text('Scan Optical Air-Gap Stream (Receive)'),
            subtitle: const Text(
              'Capture animated QR stream using camera live preview',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OpticalSyncScreen(
                    initialMode: OpticalSyncMode.receive,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJoinForm(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'SCAN THE QR ON THE OTHER DEVICE',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan QR code'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _scanQr,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or enter manually',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _hostIpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Host IP address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lan),
            hintText: 'e.g. 192.168.1.42',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _portController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Port',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Pairing code',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.vpn_key),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.sync),
          label: const Text('Connect & receive'),
          onPressed: _join,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _showJoinForm = false),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildProgress(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildWaitingForSender(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Connected', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Waiting for the sender to choose what to share…',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleted(BuildContext context, SyncCompleted state) {
    final theme = Theme.of(context);
    final summary = state.summary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Sync complete', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ..._summaryLines(context, summary),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SyncProvider>().reset();
                setState(() => _showJoinForm = false);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  /// One line per synced category, phrased for the sender or the receiver.
  List<Widget> _summaryLines(BuildContext context, SyncSummary s) {
    final theme = Theme.of(context);
    final lines = <String>[];

    if (s.isHost) {
      if (s.includedAccounts) lines.add('Sent ${s.accounts} account(s)');
      if (s.includedSettings) lines.add('Sent ${s.settings} setting(s)');
    } else {
      if (s.includedAccounts) {
        final skipped = s.accountsSkipped > 0
            ? ' (${s.accountsSkipped} already present, kept)'
            : '';
        lines.add('Added ${s.accounts} account(s)$skipped');
      }
      if (s.includedSettings) {
        lines.add('Applied ${s.settings} setting(s)');
      }
    }

    if (lines.isEmpty) lines.add('Nothing to sync.');

    return [
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(child: Text(line, style: theme.textTheme.bodyMedium)),
            ],
          ),
        ),
    ];
  }

  Widget _buildError(BuildContext context, SyncError state) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Sync failed', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SyncProvider>().reset();
                setState(() => _showJoinForm = false);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(BuildContext context, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: fg),
    );
  }
}
