// File Path: sreerajp_authenticator/lib/screens/optical_sync_screen.dart
// Author: Sreeraj P
// Description: Optical Air-Gap Sync UI. Displays animated high-speed QR stream on
//   the transmitting device (12-15 FPS) or scans frames continuously on the receiving
//   device until Fountain Code 100% reconstruction is achieved offline.

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../utils/constants.dart';

enum OpticalSyncMode { transmit, receive }

class OpticalSyncScreen extends StatefulWidget {
  final OpticalSyncMode initialMode;

  const OpticalSyncScreen({super.key, required this.initialMode});

  @override
  State<OpticalSyncScreen> createState() => _OpticalSyncScreenState();
}

class _OpticalSyncScreenState extends State<OpticalSyncScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    formats: const [BarcodeFormat.qrCode],
  );
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
        _startTransmitting();
      } else {
        context.read<SyncProvider>().startOpticalReceiving();
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _syncProvider?.reset();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '~0s';
    if (seconds < 60) return '~${seconds}s';
    final mins = seconds ~/ 60;
    final remSecs = seconds % 60;
    return remSecs == 0 ? '~${mins}m' : '~${mins}m ${remSecs}s';
  }

  Future<void> _startTransmitting() async {
    final accountsProvider = context.read<AccountsProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    await context.read<SyncProvider>().startOpticalTransmitting(
      accounts: accountsProvider.accounts,
      settingsSnapshot: settingsProvider.syncableSettingsSnapshot(),
      fps: 12,
    );
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.contains('"v":1')) {
        final accountsProvider = context.read<AccountsProvider>();
        final settingsProvider = context.read<SettingsProvider>();

        context.read<SyncProvider>().processOpticalFrame(
          rawFrame: raw,
          importData: (data) => accountsProvider.importData(data),
          applySettings: (settings, {required overwrite}) => settingsProvider
              .applySyncedSettings(settings, overwrite: overwrite),
        );
      }
    }
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
                  ? 'Optical Air-Gap Stream'
                  : 'Scan Optical QR Stream',
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
      SyncSyncing() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Reconstructing vault…'),
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
                          'Large Vault Data Warning',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This vault contains ${state.totalChunks} chunks ($estDurationStr est. transfer time). '
                          'Streaming a large vault over camera QR can be slow. Consider using P2P Wi-Fi Sync for faster transfer.',
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
                    'Point the receiver device camera at this animated QR stream. '
                    'Chunks are encoded with Fountain Codes for zero-data air-gap sync.',
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
                    const Text('Stream Hash:'),
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
                    const Text('Est. Transfer Duration:'),
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
                    const Text('Frames Rendered:'),
                    Text(
                      '${state.currentFrameIndex} (Total Chunks: ${state.totalChunks})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Target FPS: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 10, label: Text('10 FPS')),
                          ButtonSegment(value: 12, label: Text('12 FPS')),
                          ButtonSegment(value: 15, label: Text('15 FPS')),
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

  Widget _buildReceiverView(BuildContext context, SyncOpticalReceiving state) {
    final theme = Theme.of(context);
    final pct = (state.progress * 100).toStringAsFixed(0);

    final remainingChunks = state.totalChunks - state.solvedChunks;
    final remainingSecs = state.totalChunks == 0
        ? 0
        : (remainingChunks / 12).ceil();
    final estRemainingStr = state.totalChunks == 0
        ? ''
        : ' (${_formatDuration(remainingSecs)} remaining)';

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onBarcodeDetected,
        ),
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
                              ? 'Align camera with transmitter stream…'
                              : 'Reconstructing Fountain Code stream…',
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
                          'Captured: ${state.solvedChunks} / ${state.totalChunks} chunks$estRemainingStr',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (state.sessionHash != null)
                          Text(
                            'Session: ${state.sessionHash!.toUpperCase()}',
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
            Text(
              'Optical Air-Gap Sync Complete',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Successfully reconstructed vault payload from optical QR stream.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Added ${summary.accounts} account(s)'
              '${summary.accountsSkipped > 0 ? " (${summary.accountsSkipped} skipped duplicates)" : ""}',
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
              child: const Text('Done'),
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
            Text('Optical Sync Failed', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SyncProvider>().reset();
                Navigator.of(context).pop();
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
