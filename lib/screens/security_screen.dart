// File Path: sreerajp_authenticator/lib/screens/security_screen.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2026 April 05
// Description: Screen for configuring app PIN, phone lock quick unlock, and adaptive authentication

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _authService = AuthService();
  bool _isPhoneLockAvailable = false;
  bool _isCheckingPhoneLock = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPhoneLockAvailability();
  }

  Future<void> _checkPhoneLockAvailability() async {
    final isAvailable = await _authService.isPhoneLockQuickUnlockAvailable();
    if (!mounted) return;

    setState(() {
      _isPhoneLockAvailable = isAvailable;
      _isCheckingPhoneLock = false;
    });
  }

  Future<void> _handleAppLockToggle(
    bool value,
    SettingsProvider provider,
  ) async {
    if (value) {
      final pinSet = provider.hasPinSet
          ? true
          : await _showPinSetupDialog(provider, isInitialSetup: true);
      if (!pinSet || !mounted) return;

      if (provider.hasPinSet && !await provider.hasRecoveryKey()) {
        if (!mounted) return;
        setState(() => _isLoading = true);
        final recoveryKey = await provider.generateRecoveryKey();
        if (!mounted) return;
        setState(() => _isLoading = false);
        await _showRecoveryKeyDialog(recoveryKey);
      }

      await provider.setAppLockEnabled(true);
      if (!mounted) return;
      _showMessage('App lock enabled with App PIN');
    } else {
      final confirmed = await _showConfirmDialog(
        'Disable App Lock',
        'Disabling app lock removes your App PIN, quick unlock preference, and recovery key.',
      );
      if (confirmed && mounted) {
        await provider.setAppLockEnabled(false);
        _showMessage('App lock disabled');
      }
    }
  }

  Future<void> _handleQuickUnlockToggle(
    bool value,
    SettingsProvider provider,
  ) async {
    if (!value) {
      await provider.setPhoneLockQuickUnlockEnabled(false);
      _showMessage('Phone Screen Lock quick unlock disabled');
      return;
    }

    final result = await _authService.authenticateWithPhoneLock();
    if (!mounted) return;

    if (result.isSuccess) {
      await provider.setPhoneLockQuickUnlockEnabled(true);
      _showMessage('Phone Screen Lock quick unlock enabled');
      return;
    }

    _showMessage(_mapQuickUnlockError(result), isError: true);
  }

  String _mapQuickUnlockError(LocalAuthResult result) {
    switch (result.outcome) {
      case LocalAuthOutcome.notAvailable:
        return 'Phone Screen Lock is not available on this device';
      case LocalAuthOutcome.lockedOut:
        return 'Phone Screen Lock is temporarily locked out';
      case LocalAuthOutcome.canceled:
        return 'Phone Screen Lock was canceled';
      case LocalAuthOutcome.failure:
        return 'Phone Screen Lock verification failed';
      case LocalAuthOutcome.error:
        return 'Unable to verify Phone Screen Lock';
      case LocalAuthOutcome.success:
        return '';
    }
  }

  Future<void> _handleAutoLockTimeoutChange(SettingsProvider provider) async {
    final timeouts = {
      'Immediately': 0,
      '30 seconds': 30,
      '1 minute': 60,
      '5 minutes': 300,
      '10 minutes': 600,
    };

    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        final currentTimeout = provider.autoLockTimeout;
        return SimpleDialog(
          title: const Text('Auto-lock timeout'),
          children: timeouts.entries.map((entry) {
            final isSelected = entry.value == currentTimeout;
            return ListTile(
              title: Text(entry.key),
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onTap: () => Navigator.pop(context, entry.value),
            );
          }).toList(),
        );
      },
    );

    if (selected != null && mounted) {
      await provider.setAutoLockTimeout(selected);
    }
  }

  Future<void> _handleChangePIN(SettingsProvider provider) async {
    final currentPin = await _showPinInputDialog('Enter Current App PIN');
    if (currentPin == null || !mounted) return;

    setState(() => _isLoading = true);
    bool verified = false;
    try {
      verified = await provider.verifyPin(currentPin);
      if (verified) await provider.handleSuccessfulAppPinUnlock();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!verified) {
      if (mounted) _showMessage('Incorrect App PIN', isError: true);
      return;
    }

    final newPin = await _showPinSetupDialog(provider);
    if (!newPin || !mounted) return;

    setState(() => _isLoading = true);
    String recoveryKey;
    try {
      recoveryKey = await provider.generateRecoveryKey();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (mounted) {
      await _showRecoveryKeyDialog(recoveryKey);
      _showMessage('App PIN changed successfully');
    }
  }

  Future<bool> _showPinSetupDialog(
    SettingsProvider provider, {
    bool isInitialSetup = false,
  }) async {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isInitialSetup ? 'Set App PIN' : 'Change App PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'App PIN is required for app protection and all secret access.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter App PIN (4-6 digits)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Confirm App PIN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (pinController.text.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'App PIN must be at least 4 digits',
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                            return;
                          }
                          if (pinController.text != confirmController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('App PINs do not match'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            await provider.setAppLockPin(pinController.text);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                          } catch (_) {
                            if (dialogContext.mounted) {
                              setDialogState(() => isSaving = false);
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save App PIN'),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }

  Future<String?> _showPinInputDialog(String title) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'App PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecoveryKeyDialog(String recoveryKey) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Recovery Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Save this recovery key in a safe place. It is the only way to regain access if you forget your App PIN.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: SelectableText(
                recoveryKey,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: recoveryKey));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recovery key copied to clipboard')),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'This key will NOT be shown again.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I\'ve saved it'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetRecoveryKey(SettingsProvider provider) async {
    final currentPin = await _showPinInputDialog('Enter Current App PIN');
    if (currentPin == null || !mounted) return;

    setState(() => _isLoading = true);
    bool verified = false;
    String recoveryKey = '';
    try {
      verified = await provider.verifyPin(currentPin);
      if (verified) {
        await provider.handleSuccessfulAppPinUnlock();
        recoveryKey = await provider.generateRecoveryKey();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!verified) {
      if (mounted) _showMessage('Incorrect App PIN', isError: true);
      return;
    }

    if (mounted) {
      await _showRecoveryKeyDialog(recoveryKey);
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
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

  String _getAutoLockTimeoutText(int seconds) {
    if (seconds == 0) return 'Immediately';
    if (seconds < 60) return '$seconds seconds';
    final minutes = seconds ~/ 60;
    return '$minutes minute${minutes > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Security')),
          body: (_isCheckingPhoneLock || _isLoading)
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'APP LOCK',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Enable App Lock'),
                            subtitle: const Text(
                              'Protect the app with your App PIN and optional Phone Screen Lock quick unlock',
                            ),
                            value: settingsProvider.isAppLockEnabled,
                            onChanged: (value) =>
                                _handleAppLockToggle(value, settingsProvider),
                          ),
                          if (settingsProvider.isAppLockEnabled) ...[
                            const Divider(height: 1),
                            ListTile(
                              title: const Text('Auto-lock timeout'),
                              subtitle: Text(
                                _getAutoLockTimeoutText(
                                  settingsProvider.autoLockTimeout,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  _handleAutoLockTimeoutChange(settingsProvider),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (settingsProvider.isAppLockEnabled) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'APP PIN',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            const ListTile(
                              title: Text('App PIN'),
                              subtitle: Text(
                                'Required for app protection and all secret access',
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              title: const Text('Change App PIN'),
                              subtitle: const Text('Update your App PIN'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _handleChangePIN(settingsProvider),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              title: const Text('Reset Recovery Key'),
                              subtitle: const Text(
                                'Generate a new recovery key for your App PIN',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _handleResetRecoveryKey(settingsProvider),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'PHONE SCREEN LOCK',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: SwitchListTile(
                          title: const Text('Use Phone Screen Lock'),
                          subtitle: Text(
                            _isPhoneLockAvailable
                                ? 'Optional quick unlock for opening the app'
                                : 'Phone Screen Lock is not available on this device',
                          ),
                          value: settingsProvider.phoneLockQuickUnlockEnabled,
                          onChanged: _isPhoneLockAvailable
                              ? (value) =>
                                  _handleQuickUnlockToggle(value, settingsProvider)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'LOCKDOWN',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: SwitchListTile(
                          title: const Text('Lockdown Mode'),
                          subtitle: const Text(
                            'Disable quick unlock and require your App PIN until you turn this off',
                          ),
                          value: settingsProvider.lockdownEnabled,
                          onChanged: (value) =>
                              settingsProvider.setLockdownEnabled(value),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Card(
                      margin: const EdgeInsets.all(16),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Phone Screen Lock is optional quick unlock. App PIN is always required for revealing secrets.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Phone Screen Lock may use fingerprint, face, pattern, PIN, or password depending on your device.',
                              style: theme.textTheme.bodySmall,
                            ),
                            if (settingsProvider.needsMandatoryPinMigrationSync) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Finish your one-time App PIN setup from the lock screen before using the app normally.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
