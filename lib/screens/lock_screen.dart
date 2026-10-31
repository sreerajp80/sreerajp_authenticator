// File Path: sreerajp_authenticator/lib/screens/lock_screen.dart
// Author: Sreeraj P
// Created: 2025 October 01
// Last Modified: 2026 May 27
// Description: Lock screen for app security with optional App PIN and/or Phone Screen Lock

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';

import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../services/clipboard_service.dart';
import '../utils/constants.dart';

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
  bool _isVerifyingPin = false;
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
      _refreshUnlockOptions();
    }
  }

  Future<void> _refreshUnlockOptions({bool autoTrigger = true}) async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.reevaluateUnlockPolicy(notify: false);

    final showQuickUnlock = settingsProvider.canUsePhoneLockQuickUnlock;

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
    final l10n = AppLocalizations.of(context);
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
      _pinFieldError = '';
    });

    final result = await _authService.authenticateWithPhoneLock(
      reason: l10n.descAuthReasonPhoneLock,
    );
    if (!mounted) return;

    if (result.isSuccess) {
      await settingsProvider.handleQuickUnlockResult(result);
      if (!mounted) return;
      await _unlockApp();
      return;
    }

    await settingsProvider.handleQuickUnlockResult(result);
    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _fallbackToPinUi = settingsProvider.hasPinSet;
      _errorMessage = _mapQuickUnlockError(l10n, settingsProvider, result);
    });
  }

  String _mapQuickUnlockError(
    AppLocalizations l10n,
    SettingsProvider settingsProvider,
    LocalAuthResult result,
  ) {
    if (settingsProvider.pinRequiredReason != PinRequiredReason.none) {
      return _pinRequiredText(l10n, settingsProvider.pinRequiredReason);
    }

    switch (result.outcome) {
      case LocalAuthOutcome.failure:
        return l10n.errorPhoneLockFailed;
      case LocalAuthOutcome.canceled:
        return l10n.errorPhoneLockCanceled;
      case LocalAuthOutcome.lockedOut:
        return l10n.errorPhoneLockLockedOut;
      case LocalAuthOutcome.notAvailable:
        return l10n.errorPhoneLockUnavailable;
      case LocalAuthOutcome.error:
        return l10n.errorPhoneLockUnverified;
      case LocalAuthOutcome.success:
        return '';
    }
  }

  /// Why the app PIN is needed now (`SettingsProvider.pinRequiredReason`).
  String _pinRequiredText(AppLocalizations l10n, PinRequiredReason reason) {
    switch (reason) {
      case PinRequiredReason.idleTimeout:
        return l10n.descPinRequiredIdle;
      case PinRequiredReason.reboot:
        return l10n.descPinRequiredReboot;
      case PinRequiredReason.quickUnlockFailures:
        return l10n.descPinRequiredFailures;
      case PinRequiredReason.lockdown:
        return l10n.descPinRequiredLockdown;
      case PinRequiredReason.none:
        return '';
    }
  }

  /// The unlock instruction (`SettingsProvider.unlockInstruction`).
  String _unlockInstructionText(
    AppLocalizations l10n,
    UnlockInstruction instruction,
  ) {
    switch (instruction) {
      case UnlockInstruction.phoneLockOnly:
        return l10n.descUnlockPhoneOnly;
      case UnlockInstruction.phoneLockOrPin:
        return l10n.descUnlockPhoneOrPin;
      case UnlockInstruction.pinOnly:
        return l10n.descUnlockPinOnly;
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
    if (_lockoutSeconds > 0 || _isVerifyingPin) return;

    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context);

    if (_pinController.text.isEmpty) {
      setState(() => _pinFieldError = l10n.errorPinEmpty);
      return;
    }

    setState(() => _isVerifyingPin = true);

    final existingLockout = await settingsProvider.getLockoutRemainingSeconds();
    if (existingLockout > 0) {
      setState(() {
        _isVerifyingPin = false;
        _pinFieldError = l10n.errorPinLockedOut(existingLockout);
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
          _isVerifyingPin = false;
          _pinFieldError = l10n.errorPinLockedOut(lockout);
        });
        _startLockoutCountdown(lockout);
      } else {
        final remaining = AuthService.maxAttempts - attempts;
        setState(() {
          _isVerifyingPin = false;
          _pinFieldError = remaining > 0
              ? l10n.errorPinIncorrectRemaining(remaining)
              : l10n.errorPinIncorrect;
        });
      }
      _pinController.clear();
    }
  }

  Future<void> _handleForgotPin() async {
    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context);

    final hasKey = await settingsProvider.hasRecoveryKey();
    if (!hasKey) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.titleNoRecoveryKey),
          content: Text(l10n.descNoRecoveryKey),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionOk),
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
        title: Text(l10n.titleEnterRecoveryKey),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.descEnterRecoveryKey,
              style: const TextStyle(fontSize: 13),
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
              decoration: InputDecoration(
                labelText: l10n.labelRecoveryKey,
                hintText: 'XXXX-XXXX-XXXX-XXXX',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.actionCancel),
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
                      content: Text(l10n.errorRecoveryKeyInvalid),
                      backgroundColor: Theme.of(dialogContext)
                          .colorScheme
                          .error,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.actionRecover),
          ),
        ],
      ),
    );

    if (recovered != true || !mounted) return;
    await _showNewPinSetup(settingsProvider);
  }

  Future<void> _showNewPinSetup(SettingsProvider provider) async {
    final l10n = AppLocalizations.of(context);
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
              title: Text(l10n.titleSetNewPin),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.descSetNewPin),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController2,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.labelNewPin,
                      helperText: l10n.descPinDigitsHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: l10n.labelConfirmPin,
                      border: const OutlineInputBorder(),
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
                                content: Text(l10n.errorPinTooShort),
                                backgroundColor: Theme.of(dialogContext)
                                    .colorScheme
                                    .error,
                              ),
                            );
                            return;
                          }
                          if (pinController2.text != confirmController.text) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(l10n.errorPinMismatch),
                                backgroundColor: Theme.of(dialogContext)
                                    .colorScheme
                                    .error,
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
                      : Text(l10n.actionSavePin),
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
    final l10n = AppLocalizations.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.titleRecoveryKey),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.descRecoveryKeySave, style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline
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
                ClipboardService.copySecret(
                  recoveryKey,
                  clearAfter: AppConstants.clipboardClearLong,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.descRecoveryKeyCopied)),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(l10n.actionCopy),
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
                Expanded(
                  child: Text(
                    l10n.descRecoveryKeyOnce,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionSavedIt),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockApp() async {
    final settingsProvider = context.read<SettingsProvider>();
    final accountsProvider = context.read<AccountsProvider>();

    await settingsProvider.setLocked(false);
    await accountsProvider.loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context);

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

    final eligiblePhoneFirst = settingsProvider.canUsePhoneLockQuickUnlock;
    final showPinPath =
        settingsProvider.hasPinSet &&
        (_fallbackToPinUi ||
            !eligiblePhoneFirst ||
            settingsProvider.requiresAppPinForUnlock);
    final showPhonePrimary =
        eligiblePhoneFirst &&
        (!settingsProvider.hasPinSet || !_fallbackToPinUi);
    final showPhoneLockOption = eligiblePhoneFirst;

    final title = settingsProvider.requiresAppPinForUnlock
        ? l10n.titleEnterYourPin
        : !settingsProvider.hasPinSet
        ? l10n.titleUseDeviceLock
        : l10n.titleUnlockApp;
    final subtitle = showPhonePrimary && !showPinPath
        ? l10n.descUnlockWithPhone
        : _unlockInstructionText(l10n, settingsProvider.unlockInstruction);
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
                        _pinRequiredText(
                          l10n,
                          settingsProvider.pinRequiredReason,
                        ),
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
                        enabled: _lockoutSeconds == 0 && !_isVerifyingPin,
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
                              ? l10n.labelPinLockedFor(_lockoutSeconds)
                              : l10n.labelEnterPin,
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
                                l10n.errorTooManyAttempts(_lockoutSeconds),
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
                        onPressed: (_lockoutSeconds > 0 || _isVerifyingPin)
                            ? null
                            : _verifyPin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isVerifyingPin
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                l10n.actionUnlockWithPin,
                                style: const TextStyle(
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
                        l10n.actionForgotPin,
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
                            ? l10n.labelCheckingPhoneLock
                            : l10n.actionUsePhoneLock,
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
                    Text(
                      l10n.labelOr,
                      style: const TextStyle(
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
                            ? l10n.labelCheckingPhoneLock
                            : l10n.actionUsePhoneLock,
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
