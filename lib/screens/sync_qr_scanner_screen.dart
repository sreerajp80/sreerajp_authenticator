// File Path: sreerajp_authenticator/lib/screens/sync_qr_scanner_screen.dart
// Author: Sreeraj P
// Description: Scans a P2P sync pairing QR shown on the host device and returns
//   the parsed host IP, port, and pairing code to the sync screen. The QR is an
//   out-of-band channel (read by camera, never sent over the network); this
//   screen only parses and returns data and never touches the database.

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/p2p_sync_service.dart';

/// Result returned to the caller on a successful scan.
typedef SyncQrResult = ({String ipAddress, int port, String code});

class SyncQrScannerScreen extends StatefulWidget {
  const SyncQrScannerScreen({super.key});

  @override
  State<SyncQrScannerScreen> createState() => _SyncQrScannerScreenState();
}

class _SyncQrScannerScreenState extends State<SyncQrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
            content: Text(e.message),
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
        title: const Text('Scan sync QR code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                _processCode(barcode.rawValue);
              }
            },
          ),
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
                const Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Scan the QR shown on the sending device',
                    style: TextStyle(
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
