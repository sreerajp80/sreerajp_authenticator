// File Path: sreerajp_authenticator/lib/screens/lock_screen.dart
// Author: Sreeraj P
// Created: 2025 October 01
// Last Modified: 2026 April 05
// Description: Lock screen for app security with mandatory App PIN and optional Phone Screen Lock quick unlock

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/group_provider.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  final _pinController = TextEditingController();
  final _authService = AuthService();
  String _errorMessage = '';
  String _pinFieldError = '';
  bool _isAuthenticating = false;
  bool _isPinSetupFlowActive = false;
  bool _unlockOptionsReady = false;
  bool _fallbackToPinUi = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshUnlockOptions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshUnlockOptions(autoTrigger: !_isPinSetupFlowActive);
    }
  }

  Future<void> _refreshUnlockOptions({bool autoTrigger = true}) async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.reevaluateUnlockPolicy(notify: false);

    final showQuickUnlock =
        settingsProvider.canUsePhoneLockQuickUnlock ||
        settingsProvider.needsMandatoryPinMigrationSync;

    if (!mounted) return;

    setState(() {
      _unlockOptionsReady = true;
      if (!settingsProvider.requiresAppPinForUnlock) {
        _errorMessage = '';
      }
    });

    if (showQuickUnlock && autoTrigger && !_fallbackToPinUi) {
      await _authenticateWithPhoneLock();
    }
  }

  Future<void> _authenticateWithPhoneLock() async {
    final settingsProvider = context.read<SettingsProvider>();
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
      _pinFieldError = '';
    });

    final result = await _authService.authenticateWithPhoneLock();
    if (!mounted) return;

    if (result.isSuccess) {
      if (settingsProvider.needsMandatoryPinMigrationSync) {
        setState(() {
          _isAuthenticating = false;
          _isPinSetupFlowActive = true;
        });
        await _showMandatoryPinSetup(settingsProvider);
        if (!mounted) return;
        setState(() => _isPinSetupFlowActive = false);
        return;
      }

      await settingsProvider.handleQuickUnlockResult(result);
      if (!mounted) return;
      await _unlockApp();
      return;
    }

    await settingsProvider.handleQuickUnlockResult(result);
    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _fallbackToPinUi = true;
      _errorMessage = _mapQuickUnlockError(settingsProvider, result);
    });
  }

  String _mapQuickUnlockError(
    SettingsProvider settingsProvider,
    LocalAuthResult result,
  ) {
    if (settingsProvider.pinRequiredReason != PinRequiredReason.none) {
      return settingsProvider.pinRequiredMessage;
    }

    switch (result.outcome) {
      case LocalAuthOutcome.failure:
        return 'Phone Screen Lock failed';
      case LocalAuthOutcome.canceled:
        return 'Phone Screen Lock was canceled';
      case LocalAuthOutcome.lockedOut:
        return 'Phone Screen Lock is temporarily locked out';
      case LocalAuthOutcome.notAvailable:
        return 'Phone Screen Lock is not available on this device';
      case LocalAuthOutcome.error:
        return 'Unable to verify Phone Screen Lock';
      case LocalAuthOutcome.success:
        return '';
    }
  }

  void _startLockoutCountdown(int seconds) {
    _lockoutTimer?.cancel();
    setState(() => _lockoutSeconds = seconds);

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _lockoutSeconds--;
        if (_lockoutSeconds <= 0) {
          _lockoutSeconds = 0;
          _pinFieldError = '';
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyPin() async {
    if (_lockoutSeconds > 0) return;

    final settingsProvider = context.read<SettingsProvider>();

    if (_pinController.text.isEmpty) {
      setState(() => _pinFieldError = 'Please enter your App PIN');
      return;
    }

    final existingLockout = await settingsProvider.getLockoutRemainingSeconds();
    if (existingLockout > 0) {
      setState(() {
        _pinFieldError =
            'Too many failed attempts. Try again in $existingLockout seconds.';
      });
      _startLockoutCountdown(existingLockout);
      _pinController.clear();
      return;
    }

    final valid = await settingsProvider.verifyPin(_pinController.text);
    if (!mounted) return;

    if (valid) {
      await settingsProvider.handleSuccessfulAppPinUnlock();
      if (!mounted) return;
      await _unlockApp();
    } else {
      final lockout = await settingsProvider.getLockoutRemainingSeconds();
      final attempts = await settingsProvider.getFailedAttempts();

      if (!mounted) return;

      if (lockout > 0) {
        setState(() {
          _pinFieldError =
              'Too many failed attempts. Try again in $lockout seconds.';
        });
        _startLockoutCountdown(lockout);
      } else {
        final remaining = AuthService.maxAttempts - attempts;
        setState(() {
          _pinFieldError = remaining > 0
              ? 'Incorrect App PIN. $remaining attempt${remaining == 1 ? '' : 's'} remaining'
              : 'Incorrect App PIN';
        });
      }
      _pinController.clear();
    }
  }

  Future<void> _handleForgotPin() async {
    final settingsProvider = context.read<SettingsProvider>();

    final hasKey = await settingsProvider.hasRecoveryKey();
    if (!hasKey) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Recovery Key'),
          content: const Text(
            'No recovery key was set up for this App PIN. Unfortunately, there is no way to recover access without it.\n\nYou can reinstall the app, but all accounts will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;

    final recoveryController = TextEditingController();
    final recovered = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Recovery Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the recovery key you saved when setting up your App PIN.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: recoveryController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontFamily: 'monospace',
                letterSpacing: 1.5,
              ),
              decoration: const InputDecoration(
                labelText: 'Recovery Key',
                hintText: 'XXXX-XXXX-XXXX-XXXX',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = recoveryController.text.trim();
              if (key.isEmpty) return;

              final valid = await settingsProvider
                  .validateAndResetWithRecoveryKey(key);
              if (dialogContext.mounted) {
                if (valid) {
                  Navigator.pop(dialogContext, true);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: const Text('Invalid recovery key'),
                      backgroundColor: Theme.of(
                        dialogContext,
                      ).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Recover'),
          ),
        ],
      ),
    );

    if (recovered != true || !mounted) return;
    await _showNewPinSetup(settingsProvider);
  }

  Future<void> _showMandatoryPinSetup(SettingsProvider provider) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    final pinSet = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Set Up App PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create your App PIN to finish securing the app. App PIN is always required for secret access.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'New App PIN (4-6 digits)',
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
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (pinController.text.length < 4) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'App PIN must be at least 4 digits',
                                ),
                                backgroundColor: Theme.of(
                                  dialogContext,
                                ).colorScheme.error,
                              ),
                            );
                            return;
                          }
                          if (pinController.text != confirmController.text) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: const Text('App PINs do not match'),
                                backgroundColor: Theme.of(
                                  dialogContext,
                                ).colorScheme.error,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            await provider.setAppLockPin(pinController.text);
                            final recoveryKey = await provider
                                .generateRecoveryKey();
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                            if (mounted) {
                              await _showRecoveryKeyInfo(recoveryKey);
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

    if (pinSet == true && mounted) {
      await _refreshUnlockOptions(autoTrigger: false);
      await _unlockApp();
    }
  }

  Future<void> _showNewPinSetup(SettingsProvider provider) async {
    final pinController2 = TextEditingController();
    final confirmController = TextEditingController();

    final pinSet = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Set New App PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your old App PIN has been cleared. Please set a new App PIN.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController2,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'New App PIN (4-6 digits)',
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
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (pinController2.text.length < 4) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'App PIN must be at least 4 digits',
                                ),
                                backgroundColor: Theme.of(
                                  dialogContext,
                                ).colorScheme.error,
                              ),
                            );
                            return;
                          }
                          if (pinController2.text != confirmController.text) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: const Text('App PINs do not match'),
                                backgroundColor: Theme.of(
                                  dialogContext,
                                ).colorScheme.error,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            await provider.setAppLockPin(pinController2.text);
                            final recoveryKey = await provider
                                .generateRecoveryKey();
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                            if (mounted) {
                              await _showRecoveryKeyInfo(recoveryKey);
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

    if (pinSet == true && mounted) {
      await _unlockApp();
    }
  }

  Future<void> _showRecoveryKeyInfo(String recoveryKey) async {
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
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
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
                  const SnackBar(
                    content: Text('Recovery key copied to clipboard'),
                  ),
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

  Future<void> _unlockApp() async {
    final settingsProvider = context.read<SettingsProvider>();
    final accountsProvider = context.read<AccountsProvider>();
    final groupsProvider = context.read<GroupsProvider>();

    await settingsProvider.setLocked(false);
    await accountsProvider.loadAccounts();
    await groupsProvider.loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();

    final boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: theme.brightness == Brightness.dark
            ? [const Color(0xFF0D1117), const Color(0xFF161B22)]
            : [Colors.white, const Color(0xFFF0F4F8)],
      ),
    );

    if (!_unlockOptionsReady) {
      return Scaffold(
        body: Container(
          decoration: boxDecoration,
          child: const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    final eligiblePhoneFirst =
        settingsProvider.canUsePhoneLockQuickUnlock ||
        settingsProvider.needsMandatoryPinMigrationSync;
    final showPinPath =
        settingsProvider.hasPinSet &&
        (_fallbackToPinUi ||
            !eligiblePhoneFirst ||
            settingsProvider.requiresAppPinForUnlock);
    final showPhonePrimary =
        eligiblePhoneFirst &&
        (!settingsProvider.hasPinSet || !_fallbackToPinUi);
    final showPhoneLockOption = eligiblePhoneFirst;

    final title = settingsProvider.needsMandatoryPinMigrationSync
        ? 'Set up your App PIN'
        : settingsProvider.requiresAppPinForUnlock
        ? 'Enter your App PIN'
        : 'Unlock Authenticator';
    final subtitle = showPhonePrimary && !showPinPath
        ? (settingsProvider.needsMandatoryPinMigrationSync
              ? 'Use your Phone Screen Lock to set up your App PIN'
              : 'Use your Phone Screen Lock to unlock')
        : settingsProvider.unlockInstructionText;
    final showReasonBanner =
        settingsProvider.pinRequiredReason != PinRequiredReason.none;
    final showPhoneErrorBanner =
        _errorMessage.isNotEmpty &&
        (showPhonePrimary || (showPinPath && showPhoneLockOption));

    return Scaffold(
      body: Container(
        decoration: boxDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.secondary.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (showReasonBanner) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        settingsProvider.pinRequiredMessage,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  if (showPinPath) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _pinController,
                        obscureText: true,
                        enabled: _lockoutSeconds == 0,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                          decimal: false,
                        ),
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: theme.textTheme.headlineSmall,
                        decoration: InputDecoration(
                          hintText: _lockoutSeconds > 0
                              ? 'Locked for $_lockoutSeconds s'
                              : 'Enter App PIN',
                          errorText:
                              _lockoutSeconds == 0 && _pinFieldError.isNotEmpty
                              ? _pinFieldError
                              : null,
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                        ),
                        onSubmitted: (_) => _verifyPin(),
                      ),
                    ),
                    if (_lockoutSeconds > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lock_clock,
                              size: 18,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Too many attempts. Try again in $_lockoutSeconds s',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _lockoutSeconds > 0 ? null : _verifyPin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Unlock with App PIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _handleForgotPin,
                      child: Text(
                        'Forgot App PIN?',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (showPhoneErrorBanner) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (showPhonePrimary) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isAuthenticating
                          ? null
                          : _authenticateWithPhoneLock,
                      icon: Icon(
                        Icons.security,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        _isAuthenticating
                            ? 'Checking Phone Screen Lock...'
                            : 'Use Phone Screen Lock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                  if (!showPhonePrimary &&
                      showPinPath &&
                      showPhoneLockOption) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'OR',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isAuthenticating
                          ? null
                          : _authenticateWithPhoneLock,
                      icon: Icon(
                        Icons.security,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        _isAuthenticating
                            ? 'Checking Phone Screen Lock...'
                            : 'Use Phone Screen Lock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
