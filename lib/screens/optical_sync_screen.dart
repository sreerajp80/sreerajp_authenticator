// File Path: sreerajp_authenticator/lib/screens/optical_sync_screen.dart
// Author: Sreeraj P
// Description: Optical Air-Gap Sync UI. The receiving device shows a one-time
//   transfer code; the user types it on the transmitting device, which then shows
//   the encrypted animated QR stream (10-15 FPS). The receiver scans frames until
//   Fountain Code 100% reconstruction is achieved offline, then decrypts.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/widgets/sync_error_text.dart';

import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../services/optical_sync_service.dart';
import '../utils/constants.dart';
import '../widgets/qr_camera_view.dart';

enum OpticalSyncMode { transmit, receive }

class OpticalSyncScreen extends StatefulWidget {
  final OpticalSyncMode initialMode;

  const OpticalSyncScreen({super.key, required this.initialMode});

  @override
  State<OpticalSyncScreen> createState() => _OpticalSyncScreenState();
}

class _OpticalSyncScreenState extends State<OpticalSyncScreen> {
  /// Localized strings. Read only while the screen is mounted.
  AppLocalizations get _l10n => AppLocalizations.of(context);
  SyncProvider? _syncProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncProvider ??= context.read<SyncProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialMode == OpticalSyncMode.transmit) {
        _askCodeAndTransmit();
      } else {
        context.read<SyncProvider>().startOpticalReceiving();
      }
    });
  }

  @override
  void dispose() {
    _syncProvider?.reset();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return _l10n.labelDurationSeconds(0);
    if (seconds < 60) return _l10n.labelDurationSeconds(seconds);
    final mins = seconds ~/ 60;
    final remSecs = seconds % 60;
    return remSecs == 0
        ? _l10n.labelDurationMinutes(mins)
        : _l10n.labelDurationMinSec(mins, remSecs);
  }

  /// Ask for the transfer code shown on the receiving device, then start the
  /// encrypted stream. Cancel closes the screen.
  Future<void> _askCodeAndTransmit() async {
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _TransferCodeDialog(),
    );
    if (!mounted) return;
    if (code == null) {
      Navigator.of(context).pop();
      return;
    }
    final accountsProvider = context.read<AccountsProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    await context.read<SyncProvider>().startOpticalTransmitting(
      accounts: accountsProvider.accounts,
      settingsSnapshot: settingsProvider.syncableSettingsSnapshot(),
      transferCode: code,
      fps: 12,
    );
  }

  /// Every frame of the current format starts with this text.
  static final String _framePrefix =
      '{"v":${AppConstants.opticalFrameVersion},';

  void _onFrameDecoded(String raw) {
    if (!raw.startsWith(_framePrefix)) return;
    final accountsProvider = context.read<AccountsProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    context.read<SyncProvider>().processOpticalFrame(
      rawFrame: raw,
      importData: (data) => accountsProvider.importData(data),
      applySettings: (settings, {required overwrite}) =>
          settingsProvider.applySyncedSettings(settings, overwrite: overwrite),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        final state = syncProvider.state;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.initialMode == OpticalSyncMode.transmit
                  ? _l10n.titleOpticalSend
                  : _l10n.titleOpticalScan,
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SyncState state) {
    return switch (state) {
      SyncOpticalTransmitting() => _buildTransmitterView(context, state),
      SyncOpticalReceiving() => _buildReceiverView(context, state),
      SyncSyncing() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_l10n.descReconstructing),
          ],
        ),
      ),
      SyncCompleted() => _buildCompletedView(context, state),
      SyncError() => _buildErrorView(context, state),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildTransmitterView(
    BuildContext context,
    SyncOpticalTransmitting state,
  ) {
    final theme = Theme.of(context);
    final totalSecs = (state.totalChunks / state.fps).ceil();
    final estDurationStr = _formatDuration(totalSecs);
    final isLargeVault =
        state.totalChunks >= AppConstants.opticalLargeVaultChunkThreshold;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (isLargeVault) ...[
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.onErrorContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _l10n.titleLargeVaultWarning,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _l10n.descLargeVault(
                            state.totalChunks,
                            estDurationStr,
                          ),
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.sensors,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _l10n.descPointReceiver,
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
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: QrImageView(
              data: state.currentQrData,
              version: QrVersions.auto,
              size: 260,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_l10n.labelStreamHash),
                    Chip(
                      label: Text(
                        state.sessionHash.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_l10n.labelEstDuration),
                    Text(
                      estDurationStr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_l10n.labelFramesRendered),
                    Text(
                      _l10n.labelFramesValue(
                        state.currentFrameIndex,
                        state.totalChunks,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(_l10n.labelTargetFps),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<int>(
                        segments: [
                          for (final fps in const [10, 12, 15])
                            ButtonSegment(
                              value: fps,
                              label: Text(_l10n.labelFps(fps)),
                            ),
                        ],
                        selected: {state.fps},
                        onSelectionChanged: (selection) {
                          context.read<SyncProvider>().setOpticalFps(
                            selection.first,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Receiver, before scanning: show the one-time transfer code.
  Widget _buildTransferCodeView(
    BuildContext context,
    SyncOpticalReceiving state,
  ) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(Icons.key_rounded, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          _l10n.titleTransferCode,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Text(
              OpticalSyncCrypto.formatTransferCode(state.transferCode),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _l10n.descTransferCodeShow,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => context.read<SyncProvider>().beginOpticalScanning(),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: Text(_l10n.actionStartScanning),
        ),
      ],
    );
  }

  Widget _buildReceiverView(BuildContext context, SyncOpticalReceiving state) {
    if (!state.scanning) return _buildTransferCodeView(context, state);
    final theme = Theme.of(context);
    final pct = (state.progress * 100).toStringAsFixed(0);

    final remainingChunks = state.totalChunks - state.solvedChunks;
    final remainingSecs = state.totalChunks == 0
        ? 0
        : (remainingChunks / 12).ceil();
    final estRemainingStr = state.totalChunks == 0
        ? ''
        : ' (${_l10n.labelRemaining(_formatDuration(remainingSecs))})';

    return Stack(
      children: [
        QrCameraView(ignoreDuplicates: false, onCode: _onFrameDecoded),
        Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.totalChunks == 0
                              ? _l10n.descAlignCamera
                              : _l10n.descReconstructingStream,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '$pct%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _l10n.descCaptured(
                                state.solvedChunks,
                                state.totalChunks,
                              ) +
                              estRemainingStr,
                          style: theme.textTheme.bodySmall,
                        ),
                        if (state.sessionHash != null)
                          Text(
                            _l10n.labelSession(
                              state.sessionHash!.toUpperCase(),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedView(BuildContext context, SyncCompleted state) {
    final theme = Theme.of(context);
    final summary = state.summary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(_l10n.titleOpticalComplete, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              _l10n.descOpticalComplete,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              summary.accountsSkipped > 0
                  ? _l10n.descAddedAccountsSkipped(
                      summary.accounts,
                      summary.accountsSkipped,
                    )
                  : _l10n.descAddedAccounts(summary.accounts),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SyncProvider>().reset();
                Navigator.of(context).pop();
              },
              child: Text(_l10n.actionDone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, SyncError state) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(_l10n.titleOpticalFailed, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(syncErrorText(_l10n, state), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SyncProvider>().reset();
                Navigator.of(context).pop();
              },
              child: Text(_l10n.actionBack),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sender: asks for the transfer code shown on the receiving device. Returns
/// the normalized code, or null on cancel.
class _TransferCodeDialog extends StatefulWidget {
  const _TransferCodeDialog();

  @override
  State<_TransferCodeDialog> createState() => _TransferCodeDialogState();
}

class _TransferCodeDialogState extends State<_TransferCodeDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = OpticalSyncCrypto.parseTransferCode(_controller.text);
    if (code == null) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.titleTransferCode),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.descTransferCodeEnter),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(fontFamily: 'monospace', letterSpacing: 1.5),
            decoration: InputDecoration(
              labelText: l10n.titleTransferCode,
              hintText: 'XXXX-XXXX-XXXX',
              errorText: _showError
                  ? l10n.errorTransferCodeLength(
                      AppConstants.opticalTransferCodeLength,
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_showError) setState(() => _showError = false);
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionStartSending)),
      ],
    );
  }
}
