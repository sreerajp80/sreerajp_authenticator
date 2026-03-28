// File Path: sreerajp_authenticator/lib/screens/qr_scanner_screen.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 12
// Description: Screen to scan QR codes for adding new accounts.

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  bool isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _processQRCode(String? code) async {
    if (code == null || isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Parse OTP Auth URI
      final uri = Uri.parse(code);
      if (uri.scheme != 'otpauth') {
        throw Exception('Invalid QR code. Not an authenticator code.');
      }

      final type = uri.host;
      if (type != 'totp') {
        throw Exception('Only TOTP codes are supported.');
      }

      final pathSegments = uri.pathSegments.join('/');
      String issuer = '';
      String accountName = pathSegments;

      // Extract issuer and account name
      if (pathSegments.contains(':')) {
        final parts = pathSegments.split(':');
        issuer = parts[0];
        accountName = parts.length > 1 ? parts[1] : parts[0];
      }

      // Get parameters
      final secret = uri.queryParameters['secret'] ?? '';
      final issuerParam = uri.queryParameters['issuer'] ?? issuer;
      final digits = int.tryParse(uri.queryParameters['digits'] ?? '6') ?? 6;
      final period = int.tryParse(uri.queryParameters['period'] ?? '30') ?? 30;
      final algorithm =
          uri.queryParameters['algorithm']?.toUpperCase() ?? 'SHA1'; // ✅ ADDED

      if (secret.isEmpty) {
        throw Exception('Secret key is missing.');
      }

      // Create account with correct parameters INCLUDING ALGORITHM
      final account = Account(
        id: DateTime.now().millisecondsSinceEpoch,
        name: accountName,
        type: 'totp',
        issuer: issuerParam,
        secret: secret,
        digits: digits,
        period: period,
        algorithm: algorithm, // ✅ ADDED
      );

      // Add account
      final accountsProvider = context.read<AccountsProvider>();
      await accountsProvider.addAccount(account);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account added: ${account.issuer} (${account.name})'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error processing QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showManualEntryDialog() {
    // Controllers for text fields
    final accountNameController = TextEditingController();
    final secretController = TextEditingController();
    final issuerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Account Manually'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: accountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Name *',
                        hintText: 'Enter account name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: secretController,
                      decoration: const InputDecoration(
                        labelText: 'Secret Key *',
                        hintText: 'Enter secret key',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: issuerController,
                      decoration: const InputDecoration(
                        labelText: 'Issuer (Optional)',
                        hintText: 'e.g., Google',
                      ),
                    ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final accountName = accountNameController.text.trim();
                          final secret = secretController.text.trim();
                          final issuer = issuerController.text.trim();

                          if (accountName.isEmpty || secret.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Account Name and Secret Key are required',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final account = Account(
                              id: DateTime.now().millisecondsSinceEpoch,
                              name: accountName,
                              type: 'totp',
                              issuer: issuer.isEmpty ? null : issuer,
                              secret: secret,
                              digits: 6,
                              period: 30,
                              algorithm: 'SHA1', // ✅ ADDED
                            );

                            // Get providers and navigators before async
                            final accountsProvider = dialogContext
                                .read<AccountsProvider>();
                            final navigator = Navigator.of(dialogContext);
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              dialogContext,
                            );

                            await accountsProvider.addAccount(account);

                            // Use the stored references after async operation
                            navigator.pop(); // Close dialog

                            // Check if parent route is still mounted before popping
                            if (context.mounted) {
                              Navigator.of(
                                context,
                              ).pop(true); // Close scanner screen
                            }

                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Account added: ${account.issuer ?? account.name}${account.issuer != null ? ' (${account.name})' : ''}',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });

                            // Store scaffold messenger before showing error
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
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
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _processQRCode(barcode.rawValue);
              }
            },
          ),

          // Overlay
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

                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        'Position QR code within frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton.icon(
                          onPressed: _showManualEntryDialog,
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Enter Manually'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
