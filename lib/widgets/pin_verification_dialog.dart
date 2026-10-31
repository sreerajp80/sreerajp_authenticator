// File Path: sreerajp_authenticator/lib/widgets/pin_verification_dialog.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../services/auth_service.dart';

/// Asks for the app PIN (or the phone lock when no PIN is set).
/// [purpose] is one localized sentence that says why, shown under the title.
Future<bool> showPinVerificationDialog({
  required BuildContext context,
  required String purpose,
  required SettingsProvider settingsProvider,
  required AuthService authService,
}) async {
  final l10n = AppLocalizations.of(context);
  if (!settingsProvider.isAppLockEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.errorAppLockMisconfigured),
        backgroundColor: Colors.orange,
      ),
    );
    return false;
  }

  if (!settingsProvider.hasPinSet) {
    if (!settingsProvider.phoneLockQuickUnlockEnabled) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorAppLockNoMethod),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    final result = await authService.authenticateWithPhoneLock(
      reason: l10n.descAuthReasonPhoneLock,
    );
    if (!result.isSuccess) return false;
    await settingsProvider.handleSuccessfulAppPinUnlock();
    return true;
  }

  final TextEditingController pinController = TextEditingController();
  bool isVerifying = false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (statefulContext, setDialogState) => AlertDialog(
        title: Text(l10n.titleEnterAppPin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(purpose, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l10n.descPinRequiredForSensitive),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              enabled: !isVerifying,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.labelAppPin,
                border: const OutlineInputBorder(),
                counterText: '',
              ),
              onSubmitted: isVerifying
                  ? null
                  : (value) async {
                      setDialogState(() => isVerifying = true);
                      await Future.delayed(const Duration(milliseconds: 100));

                      if (!statefulContext.mounted) return;

                      if (await settingsProvider.verifyPin(value)) {
                        await settingsProvider.handleSuccessfulAppPinUnlock();
                        if (statefulContext.mounted) {
                          Navigator.pop(statefulContext, true);
                        }
                      } else {
                        setDialogState(() => isVerifying = false);
                        pinController.clear();

                        if (!statefulContext.mounted) return;

                        ScaffoldMessenger.of(statefulContext).showSnackBar(
                          SnackBar(
                            content: Text(l10n.errorPinIncorrect),
                            backgroundColor: Theme.of(statefulContext)
                                .colorScheme
                                .error,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(8),
                          ),
                        );
                        HapticFeedback.heavyImpact();
                      }
                    },
            ),
            if (isVerifying) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: isVerifying
                ? null
                : () => Navigator.pop(dialogContext, false),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: isVerifying
                ? null
                : () async {
                    setDialogState(() => isVerifying = true);
                    await Future.delayed(const Duration(milliseconds: 100));

                    if (!dialogContext.mounted) return;

                    if (await settingsProvider.verifyPin(pinController.text)) {
                      await settingsProvider.handleSuccessfulAppPinUnlock();
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } else {
                      setDialogState(() => isVerifying = false);
                      pinController.clear();

                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(l10n.errorPinIncorrect),
                          backgroundColor: Theme.of(dialogContext)
                              .colorScheme
                              .error,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(8),
                        ),
                      );
                      HapticFeedback.heavyImpact();
                    }
                  },
            child: Text(l10n.actionVerify),
          ),
        ],
      ),
    ),
  );

  return result ?? false;
}
