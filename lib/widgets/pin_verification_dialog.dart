// File Path: sreerajp_authenticator/lib/widgets/pin_verification_dialog.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/settings_provider.dart';
import '../services/auth_service.dart';

Future<bool> showPinVerificationDialog({
  required BuildContext context,
  required String purpose,
  required SettingsProvider settingsProvider,
  required AuthService authService,
}) async {
  if (!settingsProvider.isAppLockEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'App lock is not properly configured. Please re-enable it.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
    return false;
  }

  if (!settingsProvider.hasPinSet) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App PIN is not set. Please re-enable app lock.'),
        backgroundColor: Colors.orange,
      ),
    );
    return false;
  }

  final TextEditingController pinController = TextEditingController();
  bool isVerifying = false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (statefulContext, setDialogState) => AlertDialog(
        title: Text('Enter App PIN to $purpose'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'App PIN is required for sensitive actions and secret access.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              enabled: !isVerifying,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'App PIN',
                border: OutlineInputBorder(),
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
                            content: const Text('Incorrect App PIN'),
                            backgroundColor:
                                Theme.of(statefulContext).colorScheme.error,
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
            child: const Text('Cancel'),
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
                          content: const Text('Incorrect App PIN'),
                          backgroundColor:
                              Theme.of(dialogContext).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(8),
                        ),
                      );
                      HapticFeedback.heavyImpact();
                    }
                  },
            child: const Text('Verify'),
          ),
        ],
      ),
    ),
  );

  return result ?? false;
}
