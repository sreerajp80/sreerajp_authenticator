// File Path: sreerajp_authenticator/lib/screens/lock_screen.dart
// Author: Sreeraj P
// Created: 2025 October 01
// Last Modified: 2025 October 12
// Description: Lock screen for app security with biometric support and device lock option

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../providers/group_provider.dart';
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
  bool _isAuthenticating = false;
  bool _isBiometricAvailable = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricAndAuthenticate();
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
    // When app comes to foreground, try biometric/device lock again
    if (state == AppLifecycleState.resumed) {
      _checkBiometricAndAuthenticate();
    }
  }

  Future<void> _checkBiometricAndAuthenticate() async {
    final settingsProvider = context.read<SettingsProvider>();

    if (settingsProvider.lockType == 'device_lock') {
      // Use device lock
      setState(() {
        _isBiometricAvailable = true;
      });
      // Auto-trigger device lock authentication
      _authenticateWithDeviceLock();
    } else if (settingsProvider.isBiometricEnabled) {
      // Use app's biometric setting
      final isAvailable = await _authService.isBiometricAvailable();
      setState(() {
        _isBiometricAvailable = isAvailable;
      });
      if (isAvailable && mounted) {
        _authenticateWithBiometric();
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final authenticated = await _authService.authenticateWithBiometric();

      if (authenticated && mounted) {
        _unlockApp();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Biometric authentication failed';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _authenticateWithDeviceLock() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final authenticated = await _authService.authenticateWithDeviceLock();

      if (authenticated && mounted) {
        _unlockApp();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Authentication failed';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isAuthenticating = false;
        });
      }
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
          _errorMessage = '';
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyPin() async {
    if (_lockoutSeconds > 0) return;

    final settingsProvider = context.read<SettingsProvider>();

    if (_pinController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter PIN');
      return;
    }

    // Check whether a lockout is already active before even trying
    final existingLockout = await settingsProvider.getLockoutRemainingSeconds();
    if (existingLockout > 0) {
      setState(() {
        _errorMessage =
            'Too many failed attempts. Try again in $existingLockout seconds.';
      });
      _startLockoutCountdown(existingLockout);
      _pinController.clear();
      return;
    }

    final valid = await settingsProvider.verifyPin(_pinController.text);

    if (!mounted) return;

    if (valid) {
      _unlockApp();
    } else {
      // Check whether this failure triggered a new lockout
      final lockout = await settingsProvider.getLockoutRemainingSeconds();
      final attempts = await settingsProvider.getFailedAttempts();

      if (!mounted) return;

      if (lockout > 0) {
        setState(() {
          _errorMessage =
              'Too many failed attempts. Try again in $lockout seconds.';
        });
        _startLockoutCountdown(lockout);
      } else {
        final remaining = AuthService.maxAttempts - attempts;
        setState(() {
          _errorMessage = remaining > 0
              ? 'Incorrect PIN — $remaining attempt${remaining == 1 ? '' : 's'} remaining'
              : 'Incorrect PIN';
        });
      }
      _pinController.clear();
    }
  }

  Future<void> _handleForgotPin() async {
    final settingsProvider = context.read<SettingsProvider>();

    // Check if recovery key exists
    final hasKey = await settingsProvider.hasRecoveryKey();
    if (!hasKey) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Recovery Key'),
          content: const Text(
            'No recovery key was set up for this PIN. Unfortunately, there is no way to recover access without it.\n\nYou can reinstall the app, but all accounts will be lost.',
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

    // Show recovery key input dialog
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
              'Enter the recovery key you saved when setting up your PIN.',
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
                      backgroundColor:
                          Theme.of(dialogContext).colorScheme.error,
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

    // Recovery succeeded — PIN is cleared. Ask user to set a new PIN.
    await _showNewPinSetup(settingsProvider);
  }

  Future<void> _showNewPinSetup(SettingsProvider provider) async {
    final pinController2 = TextEditingController();
    final confirmController = TextEditingController();

    final pinSet = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set New PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your old PIN has been cleared. Please set a new PIN.'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController2,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'New PIN (4-6 digits)',
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
                labelText: 'Confirm PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (pinController2.text.length < 4) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: const Text('PIN must be at least 4 digits'),
                    backgroundColor:
                        Theme.of(dialogContext).colorScheme.error,
                  ),
                );
                return;
              }
              if (pinController2.text != confirmController.text) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: const Text('PINs do not match'),
                    backgroundColor:
                        Theme.of(dialogContext).colorScheme.error,
                  ),
                );
                return;
              }
              await provider.setAppLockPin(pinController2.text);
              final recoveryKey = await provider.generateRecoveryKey();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
              // Show the new recovery key
              if (mounted) {
                await _showRecoveryKeyInfo(recoveryKey);
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );

    if (pinSet == true && mounted) {
      _unlockApp();
    }
  }

  Future<void> _showRecoveryKeyInfo(String recoveryKey) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('New Recovery Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Save this recovery key in a safe place. It is the only way to regain access if you forget your PIN.',
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
                  const SnackBar(
                      content: Text('Recovery key copied to clipboard')),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'This key will NOT be shown again.',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  void _unlockApp() async {
    final settingsProvider = context.read<SettingsProvider>();
    final accountsProvider = context.read<AccountsProvider>();
    final groupsProvider = context.read<GroupsProvider>();

    // Set app as unlocked
    await settingsProvider.setLocked(false);

    // Load accounts and groups after unlocking
    await accountsProvider.loadAccounts();
    await groupsProvider.loadGroups();

    // Set app as unlocked - _AppRoot will automatically switch to HomeScreen
    await settingsProvider.setLocked(false);

    // No navigation needed! _AppRoot handles it automatically
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF0D1117), const Color(0xFF161B22)]
                : [Colors.white, const Color(0xFFF0F4F8)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock Icon
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

                // Title
                Text(
                  'Authenticator Locked',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  settingsProvider.lockType == 'device_lock'
                      ? 'Use your device lock to continue'
                      : 'Enter your PIN to continue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // PIN Input Field (only for app_pin mode)
                if (settingsProvider.lockType == 'app_pin') ...[
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: theme.textTheme.headlineSmall,
                      decoration: InputDecoration(
                        hintText: _lockoutSeconds > 0
                            ? 'Locked for $_lockoutSeconds s'
                            : 'Enter PIN',
                        errorText: _lockoutSeconds == 0 && _errorMessage.isNotEmpty
                            ? _errorMessage
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

                  // Lockout countdown banner
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_clock,
                            size: 18,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Too many attempts — try again in $_lockoutSeconds s',
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Unlock Button
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
                        'Unlock',
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
                      'Forgot PIN?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                // Error message for device lock
                if (settingsProvider.lockType == 'device_lock' &&
                    _errorMessage.isNotEmpty) ...[
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

                // Biometric/Device Lock Button
                if ((settingsProvider.lockType == 'device_lock' ||
                    (settingsProvider.lockType == 'app_pin' &&
                        settingsProvider.isBiometricEnabled &&
                        _isBiometricAvailable))) ...[
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
                        : (settingsProvider.lockType == 'device_lock'
                              ? _authenticateWithDeviceLock
                              : _authenticateWithBiometric),
                    icon: Icon(
                      settingsProvider.lockType == 'device_lock'
                          ? Icons.security
                          : Icons.fingerprint,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      _isAuthenticating
                          ? 'Authenticating...'
                          : (settingsProvider.lockType == 'device_lock'
                                ? 'Use Device Lock'
                                : 'Use Biometric'),
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
    );
  }
}
