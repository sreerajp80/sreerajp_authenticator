// File Path: sreerajp_authenticator/lib/screens/send_to_device_screen.dart
// Author: Sreeraj P
// Description: Host (sender) UI for P2P LAN sync, shown while the device is
//   hosting. Two tabs: "Server Details" (QR + connection info + live connection
//   status) and "Sync" (Full Sync to a new client, or a selective incremental
//   sync to a device that already has the app). The payload is pushed only after
//   a device has connected and the sender chooses what to share.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../services/p2p_sync_service.dart';

/// Tabbed host view. Rendered by `SyncScreen` while the state is [SyncHosting].
class SendToDeviceView extends StatefulWidget {
  final SyncHosting state;

  const SendToDeviceView({super.key, required this.state});

  @override
  State<SendToDeviceView> createState() => _SendToDeviceViewState();
}

class _SendToDeviceViewState extends State<SendToDeviceView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Selection for the incremental "Sync to a Phone" section.
  bool _syncAccounts = true;
  bool _syncSettings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _fullSync() async {
    final accounts = context.read<AccountsProvider>().accounts;
    final settings = context
        .read<SettingsProvider>()
        .syncableSettingsSnapshot();
    await context.read<SyncProvider>().sendFullSync(
      accounts: accounts,
      groups: const [],
      settingsSnapshot: settings,
    );
  }

  Future<void> _selectiveSync() async {
    if (!_syncAccounts && !_syncSettings) {
      _showMessage('Select at least one item to sync', isError: true);
      return;
    }
    final accounts = context.read<AccountsProvider>().accounts;
    final settings = context
        .read<SettingsProvider>()
        .syncableSettingsSnapshot();
    await context.read<SyncProvider>().sendSelectiveSync(
      accounts: accounts,
      groups: const [],
      settingsSnapshot: settings,
      includeAccounts: _syncAccounts,
      includeGroups: false,
      includeSettings: _syncSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Server Details'),
            Tab(text: 'Sync'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildServerDetailsTab(context), _buildSyncTab(context)],
          ),
        ),
      ],
    );
  }

  // ─── Tab 1: Server Details ─────────────────────────────────────────────────

  Widget _buildServerDetailsTab(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _connectionStatusCard(context, state.clientConnected),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: P2pSyncService.buildSyncQrPayload(
                            ipAddress: state.ipAddress,
                            port: state.port,
                            code: state.code,
                          ),
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                          gapless: false,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'On the other device, choose “Receive” → “Scan QR code”',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                Text(
                  'Or enter these manually',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow(context, 'Host IP', state.ipAddress),
                const SizedBox(height: 12),
                _infoRow(context, 'Port', state.port.toString()),
                const SizedBox(height: 16),
                Text('Pairing code', style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                SelectableText(
                  P2pSyncService.formatPairingCode(state.code),
                  style: theme.textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy code'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: state.code));
                      _showMessage('Pairing code copied');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => context.read<SyncProvider>().stopHosting(),
          child: const Text('Stop hosting'),
        ),
      ],
    );
  }

  Widget _connectionStatusCard(BuildContext context, bool connected) {
    final theme = Theme.of(context);
    final Color bg = connected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final Color fg = connected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (connected)
              Icon(Icons.check_circle, color: fg)
            else
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                connected
                    ? 'A device is connected. Open the Sync tab to choose what '
                          'to share.'
                    : 'Waiting for the other device to connect…',
                style: TextStyle(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 2: Sync ───────────────────────────────────────────────────────────

  Widget _buildSyncTab(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;

    if (state.sending) {
      return _buildSendingProgress(context, state.sendingItems);
    }

    final connected = state.clientConnected;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!connected) ...[
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'No device is connected yet. Open the Server Details tab '
                      'and let the other device scan the QR or enter the code.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Section A — New Client Phone (Full Sync).
        _sectionHeader(context, 'New client phone'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send everything — all accounts and app settings — to '
                  'a phone that is setting up for the first time. Device-specific '
                  'items (app lock, PIN, phone-lock unlock, recovery key) are not '
                  'sent.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.cloud_sync),
                    label: const Text('Full Sync'),
                    onPressed: connected ? _fullSync : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Section B — Sync to a Phone (selective / incremental).
        _sectionHeader(context, 'Sync to a phone'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For a phone that already has the app with its own data. Choose '
                  'what to add:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _syncAccounts,
                  onChanged: connected
                      ? (v) => setState(() => _syncAccounts = v ?? false)
                      : null,
                  title: const Text('Accounts'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _syncSettings,
                  onChanged: connected
                      ? (v) => setState(() => _syncSettings = v ?? false)
                      : null,
                  title: const Text('Settings'),
                  subtitle: const Text('Theme, auto-lock, and sync timeouts'),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This will not override anything already on the other '
                          'device. If something matches, the other device keeps '
                          'its own version — its data is retained.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync'),
                    onPressed: connected ? _selectiveSync : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendingProgress(BuildContext context, List<String> items) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text('Syncing…', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.sync),
            title: Text(item),
            trailing: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        SelectableText(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
