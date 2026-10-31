// File Path: sreerajp_authenticator/lib/screens/qr_scanner_screen.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 12
// Description: Screen to scan QR codes for adding new accounts.

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';
import '../services/otp_service.dart';
import '../utils/app_logger.dart';
import '../widgets/qr_camera_view.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final QrCameraController controller = QrCameraController();

  bool isProcessing = false;

  void _processQRCode(String? code) async {
    if (code == null || isProcessing) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      isProcessing = true;
    });

    try {
      final parsedAccount = OTPService.parseOtpAuthUri(code);
      if (parsedAccount == null) {
        throw const _QrCodeError(missingSecret: false);
      }

      if (parsedAccount.secret.isEmpty) {
        throw const _QrCodeError(missingSecret: true);
      }

      final account = parsedAccount.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
      );

      final accountsProvider = context.read<AccountsProvider>();
      await accountsProvider.addAccount(account);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.descAccountAddedName(_displayName(account))),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to process QR code', e);
      if (mounted) {
        final message = e is _QrCodeError
            ? (e.missingSecret ? l10n.errorQrNoSecret : l10n.errorQrInvalid)
            : l10n.errorAddAccountFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  /// "Issuer (name)" or just the name, for the success message.
  String _displayName(Account account) => account.issuer != null
      ? '${account.issuer} (${account.name})'
      : account.name;

  void _showManualEntryDialog() {
    final l10n = AppLocalizations.of(context);
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
              title: Text(l10n.titleAddAccountManually),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: accountNameController,
                      decoration: InputDecoration(
                        labelText: l10n.labelAccountNameRequired,
                        hintText: l10n.descAccountNameHint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: secretController,
                      decoration: InputDecoration(
                        labelText: l10n.labelSecretKeyRequired,
                        hintText: l10n.descSecretKeyHint,
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: issuerController,
                      decoration: InputDecoration(
                        labelText: l10n.labelIssuerOptional,
                        hintText: l10n.descIssuerHint,
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
                  child: Text(l10n.actionCancel),
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
                              SnackBar(
                                content: Text(l10n.errorNameAndSecretRequired),
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
                              Navigator.of(context)
                                  .pop(true); // Close scanner screen
                            }

                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.descAccountAddedName(
                                    _displayName(account),
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            AppLogger.error(
                              'Failed to add account manually',
                              e,
                            );
                            setState(() {
                              isLoading = false;
                            });

                            // Store scaffold messenger before showing error
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.errorAddAccountFailed),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: Text(l10n.actionAdd),
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.titleScanQrCode),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
            tooltip: l10n.tooltipToggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
            tooltip: l10n.tooltipSwitchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          QrCameraView(controller: controller, onCode: _processQRCode),

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
                      Text(
                        l10n.descPositionQr,
                        style: const TextStyle(
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
                          label: Text(l10n.actionEnterManually),
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

/// A scanned QR code that is not a usable authenticator code. The screen
/// turns it into a localized message.
class _QrCodeError implements Exception {
  final bool missingSecret;

  const _QrCodeError({required this.missingSecret});
}
