// File Path: sreerajp_authenticator/lib/screens/sync_screen.dart
// Author: Sreeraj P
// Description: P2P LAN sync UI. One device hosts (shows IP + random port +
//   pairing code); the other joins by typing them in. See docs/security.md.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/group_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../services/p2p_sync_service.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncProvider = context.read<SyncProvider>();
  }

  @override
  void dispose() {
    // Tear down any active listener when leaving the screen.
    _syncProvider?.reset();
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
    final accounts = context.read<AccountsProvider>().accounts;
    final groups = context.read<GroupsProvider>().groups;
    final idleTimeout = context.read<SettingsProvider>().syncHostIdleTimeout;

    if (accounts.isEmpty) {
      _showMessage('No accounts to send', isError: true);
      return;
    }

    await context.read<SyncProvider>().startHosting(
      accounts: accounts,
      groups: groups,
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
    final groupsProvider = context.read<GroupsProvider>();

    await context.read<SyncProvider>().joinSync(
      hostIp: hostIp,
      port: port,
      code: code,
      onImport: (data) async {
        await accountsProvider.importData(
          data,
          existingGroups: groupsProvider.groups,
          onGroupsChanged: () => groupsProvider.loadGroups(),
        );
      },
    );
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

        return Scaffold(
          appBar: AppBar(title: const Text('Sync to another device')),
          body: Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return _buildBody(context, syncProvider.state);
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SyncState state) {
    return switch (state) {
      SyncHosting() => _buildHosting(context, state),
      SyncConnecting() => _buildProgress('Connecting to host…'),
      SyncSyncing() => _buildProgress('Syncing…'),
      SyncCompleted() => _buildCompleted(context, state),
      SyncError() => _buildError(context, state),
      SyncIdle() => _showJoinForm ? _buildJoinForm(context) : _buildMenu(context),
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
                    'Both devices must be on the same Wi-Fi or hotspot. '
                    'Nothing is sent over the internet, and the pairing code '
                    'never leaves your device — type it on the other device.',
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
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: _iconBox(context, Icons.upload, theme.colorScheme.primaryContainer,
                theme.colorScheme.onPrimaryContainer),
            title: const Text('Send to another device'),
            subtitle: const Text('Host: share your accounts with a paired device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _startHosting,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: _iconBox(context, Icons.download, theme.colorScheme.secondaryContainer,
                theme.colorScheme.onSecondaryContainer),
            title: const Text('Receive from another device'),
            subtitle: const Text('Join: import accounts from a hosting device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _showJoinForm = true),
          ),
        ),
      ],
    );
  }

  Widget _buildHosting(BuildContext context, SyncHosting state) {
    final theme = Theme.of(context);
    final idleTimeout = context.read<SettingsProvider>().syncHostIdleTimeout;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'WAITING FOR THE OTHER DEVICE',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(context, 'Host IP', state.ipAddress),
                const SizedBox(height: 12),
                _infoRow(context, 'Port', state.port.toString()),
                const SizedBox(height: 16),
                Text('Pairing code', style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                SelectableText(
                  P2pSyncService.formatPairingCode(state.code),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFeatures: const [],
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
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'On the other device, choose “Receive”, then enter this IP, '
                'port, and code. Hosting stops automatically after '
                '$idleTimeout seconds if no device connects.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => context.read<SyncProvider>().stopHosting(),
          child: const Text('Stop hosting'),
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
          'ENTER THE HOST DETAILS',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
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

  Widget _buildCompleted(BuildContext context, SyncCompleted state) {
    final theme = Theme.of(context);
    final isHostResult = state.sentCount > 0 && state.receivedCount == 0;
    final summary = isHostResult
        ? 'Sent ${state.sentCount} account(s) to the paired device.'
        : 'Received ${state.receivedCount} account(s). Duplicates were skipped.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Sync complete', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(summary, textAlign: TextAlign.center),
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
