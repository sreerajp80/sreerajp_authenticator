// File Path: sreerajp_authenticator/lib/screens/sync_qr_scanner_screen.dart
// Author: Sreeraj P
// Description: Scans a P2P sync pairing QR shown on the host device and returns
//   the parsed host IP, port, and pairing code to the sync screen. The QR is an
//   out-of-band channel (read by camera, never sent over the network); this
//   screen only parses and returns data and never touches the database.

import 'package:material_ui/material_ui.dart';

import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/widgets/sync_error_text.dart';

import '../services/p2p_sync_service.dart';
import '../widgets/qr_camera_view.dart';

/// Result returned to the caller on a successful scan.
typedef SyncQrResult = ({String ipAddress, int port, String code});

class SyncQrScannerScreen extends StatefulWidget {
  const SyncQrScannerScreen({super.key});

  @override
  State<SyncQrScannerScreen> createState() => _SyncQrScannerScreenState();
}

class _SyncQrScannerScreenState extends State<SyncQrScannerScreen> {
  /// Localized strings. Read only while the screen is mounted.
  AppLocalizations get _l10n => AppLocalizations.of(context);
  final QrCameraController controller = QrCameraController();

  bool _isProcessing = false;

  void _processCode(String? raw) {
    if (raw == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final result = P2pSyncService.parseSyncQrPayload(raw);
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } on P2pSyncException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(p2pSyncErrorText(_l10n, e.code)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        // Keep scanning so the user can line up the correct code.
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_l10n.titleScanSyncQr),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
            tooltip: _l10n.tooltipToggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
            tooltip: _l10n.tooltipSwitchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          QrCameraView(controller: controller, onCode: _processCode),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Text(
                    _l10n.descScanSenderQr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
