// File Path: sreerajp_authenticator/lib/screens/send_to_device_screen.dart
// Author: Sreeraj P
// Description: Host (sender) UI for P2P LAN sync, shown while the device is
//   hosting. Two tabs: "Server Details" (QR + connection info + live connection
//   status) and "Sync" (Full Sync to a new client, or a selective incremental
//   sync to a device that already has the app). The payload is pushed only after
//   a device has connected and the sender chooses what to share.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../services/clipboard_service.dart';
import '../services/p2p_sync_service.dart';
import '../utils/constants.dart';

/// Tabbed host view. Rendered by `SyncScreen` while the state is [SyncHosting].
class SendToDeviceView extends StatefulWidget {
  final SyncHosting state;

  const SendToDeviceView({super.key, required this.state});

  @override
  State<SendToDeviceView> createState() => _SendToDeviceViewState();
}

class _SendToDeviceViewState extends State<SendToDeviceView>
    with SingleTickerProviderStateMixin {
  /// Localized strings. Read only while the screen is mounted.
  AppLocalizations get _l10n => AppLocalizations.of(context);
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
      settingsSnapshot: settings,
    );
  }

  Future<void> _selectiveSync() async {
    if (!_syncAccounts && !_syncSettings) {
      _showMessage(_l10n.errorSyncNothingSelected, isError: true);
      return;
    }
    final accounts = context.read<AccountsProvider>().accounts;
    final settings = context
        .read<SettingsProvider>()
        .syncableSettingsSnapshot();
    await context.read<SyncProvider>().sendSelectiveSync(
      accounts: accounts,
      settingsSnapshot: settings,
      includeAccounts: _syncAccounts,
      includeSettings: _syncSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: _l10n.tabServerDetails),
            Tab(text: _l10n.tabSync),
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
                        _l10n.descReceiveHint,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                Text(
                  _l10n.descEnterManuallyHint,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow(context, _l10n.labelHostIpShort, state.ipAddress),
                const SizedBox(height: 12),
                _infoRow(context, _l10n.labelPort, state.port.toString()),
                const SizedBox(height: 16),
                Text(
                  _l10n.labelPairingCode,
                  style: theme.textTheme.labelMedium,
                ),
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
                    label: Text(_l10n.actionCopyCode),
                    onPressed: () {
                      ClipboardService.copySecret(
                        state.code,
                        clearAfter: AppConstants.clipboardClearLong,
                      );
                      _showMessage(_l10n.descPairingCodeCopied);
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
          child: Text(_l10n.actionStopHosting),
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
                    ? _l10n.descClientConnected
                    : _l10n.descWaitingForClient,
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
                      _l10n.descNoClientYet,
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
        _sectionHeader(context, _l10n.titleNewClientPhone),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_l10n.descFullSync, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.cloud_sync),
                    label: Text(_l10n.actionFullSync),
                    onPressed: connected ? _fullSync : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Section B — Sync to a Phone (selective / incremental).
        _sectionHeader(context, _l10n.titleSyncToPhone),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _l10n.descSelectiveSync,
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
                  title: Text(_l10n.labelSyncAccounts),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _syncSettings,
                  onChanged: connected
                      ? (v) => setState(() => _syncSettings = v ?? false)
                      : null,
                  title: Text(_l10n.labelSyncSettings),
                  subtitle: Text(_l10n.descSyncSettings),
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
                          _l10n.descNoOverride,
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
                    label: Text(_l10n.actionSync),
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
            Text(_l10n.descSyncing, style: theme.textTheme.titleMedium),
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
