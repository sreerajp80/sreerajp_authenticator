// File Path: sreerajp_authenticator/lib/screens/security_screen.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2025 October 15
// Description: Screen for configuring security settings with auto-lock monitoring

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
  bool _isBiometricAvailable = false;
  bool _isCheckingBiometric = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _authService.isBiometricAvailable();
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _isCheckingBiometric = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _isCheckingBiometric = false;
        });
      }
    }
  }

  Future<void> _handleAppLockToggle(
    bool value,
    SettingsProvider provider,
  ) async {
    if (value) {
      // Enabling app lock - show lock type selection first
      final lockType = await _showLockTypeDialog();
      if (lockType == null) return;

      bool success = false;
      if (lockType == 'app_pin') {
        success = await _showPinSetupDialog(provider);
      } else if (lockType == 'device_lock') {
        success = await _testDeviceLock();
      }

      if (success && mounted) {
        await provider.setLockType(lockType);
        await provider.setAppLockEnabled(true);
        _showMessage(
          'App lock enabled with ${lockType == 'app_pin' ? 'App PIN' : 'Device Lock'}',
        );
      }
    } else {
      // Disabling app lock
      final confirmed = await _showConfirmDialog(
        'Disable App Lock',
        'Are you sure you want to disable app lock?',
      );
      if (confirmed && mounted) {
        await provider.setAppLockEnabled(false);
        await provider.setBiometricEnabled(false);
        _showMessage('App lock disabled');
      }
    }
  }

  Future<String?> _showLockTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Lock Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('App PIN'),
              subtitle: const Text('Use a separate PIN for this app'),
              onTap: () => Navigator.pop(context, 'app_pin'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Phone Screen Lock'),
              subtitle: const Text('Use device PIN/pattern/biometric'),
              onTap: () => Navigator.pop(context, 'device_lock'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<bool> _testDeviceLock() async {
    try {
      final isSupported = await _authService.isDeviceSupported();
      if (!isSupported) {
        if (mounted) {
          _showMessage(
            'Device lock not supported on this device',
            isError: true,
          );
        }
        return false;
      }

      final canCheck = await _authService.canCheckBiometrics();
      if (!canCheck) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Screen Lock'),
              content: const Text(
                'Please set up a screen lock (PIN, pattern, or password) in your device Settings > Security before using this feature.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return false;
      }

      final authenticated = await _authService.authenticateWithDeviceLock();
      if (!authenticated && mounted) {
        _showMessage('Authentication failed. Please try again.', isError: true);
      }
      return authenticated;
    } catch (e) {
      if (mounted) {
        _showMessage('Error: $e', isError: true);
      }
      return false;
    }
  }

  Future<void> _handleBiometricToggle(
    bool value,
    SettingsProvider provider,
  ) async {
    if (value) {
      try {
        final authenticated = await _authService.authenticateWithBiometric();
        if (authenticated && mounted) {
          await provider.setBiometricEnabled(true);
          _showMessage('Biometric authentication enabled');
        } else if (mounted) {
          _showMessage('Biometric authentication failed', isError: true);
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Error enabling biometric: $e', isError: true);
        }
      }
    } else {
      await provider.setBiometricEnabled(false);
      _showMessage('Biometric authentication disabled');
    }
  }

  Future<void> _handleLockTypeChange(
    String value,
    SettingsProvider provider,
  ) async {
    if (value == 'app_pin') {
      final pinSet = await _showPinSetupDialog(provider);
      if (pinSet && mounted) {
        await provider.setLockType(value);
        _showMessage('Switched to App PIN');
      }
    } else if (value == 'device_lock') {
      final canAuth = await _testDeviceLock();
      if (canAuth && mounted) {
        await provider.setLockType(value);
        _showMessage('Switched to Device Lock');
      }
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
    final currentPin = await _showPinInputDialog('Enter Current PIN');
    if (currentPin == null) return;

    if (!await provider.verifyPin(currentPin)) {
      if (mounted) {
        _showMessage('Incorrect PIN', isError: true);
      }
      return;
    }

    final newPin = await _showPinSetupDialog(provider);
    if (newPin && mounted) {
      _showMessage('PIN changed successfully');
    }
  }

  Future<bool> _showPinSetupDialog(SettingsProvider provider) async {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Enter PIN (4-6 digits)',
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('PIN must be at least 4 digits'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }
              if (pinController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('PINs do not match'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }
              await provider.setAppLockPin(pinController.text);
              final recoveryKey = await provider.generateRecoveryKey();
              if (context.mounted) {
                Navigator.pop(context, true);
              }
              // Show recovery key after dialog closes
              if (mounted) {
                await _showRecoveryKeyDialog(recoveryKey);
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
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
            labelText: 'PIN',
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
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: Theme.of(context).colorScheme.error),
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
    final currentPin = await _showPinInputDialog('Enter Current PIN');
    if (currentPin == null) return;

    if (!await provider.verifyPin(currentPin)) {
      if (mounted) {
        _showMessage('Incorrect PIN', isError: true);
      }
      return;
    }

    final recoveryKey = await provider.generateRecoveryKey();
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

    // ✅ Monitor lock state and auto-pop when locked
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // If app gets locked while on this screen, pop back
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Security')),
          body: _isCheckingBiometric
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    // App Lock Section
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
                              'Require authentication to open app',
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
                              onTap: () => _handleAutoLockTimeoutChange(
                                settingsProvider,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Lock Type Section
                    if (settingsProvider.isAppLockEnabled) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'LOCK TYPE',
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
                        child: RadioGroup<String>(
                          groupValue: settingsProvider.lockType,
                          onChanged: (value) async {
                            if (value != null) {
                              await _handleLockTypeChange(
                                value,
                                settingsProvider,
                              );
                            }
                          },
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: const Text('App PIN'),
                                subtitle: const Text(
                                  'Use a separate PIN for this app',
                                ),
                                value: 'app_pin',
                              ),
                              const Divider(height: 1),
                              RadioListTile<String>(
                                title: const Text('Phone Screen Lock'),
                                subtitle: const Text(
                                  'Use device PIN/pattern/biometric',
                                ),
                                value: 'device_lock',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // PIN Management
                    if (settingsProvider.isAppLockEnabled &&
                        settingsProvider.lockType == 'app_pin') ...[
                      const SizedBox(height: 16),
                      Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Change PIN'),
                              subtitle: const Text('Update your security PIN'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _handleChangePIN(settingsProvider),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              title: const Text('Reset Recovery Key'),
                              subtitle: const Text(
                                'Generate a new recovery key',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _handleResetRecoveryKey(
                                settingsProvider,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Biometric Section
                    if (_isBiometricAvailable &&
                        settingsProvider.lockType == 'app_pin') ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'BIOMETRIC',
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
                          title: const Text('Use Biometric Authentication'),
                          subtitle: const Text(
                            'Use fingerprint or face recognition',
                          ),
                          value: settingsProvider.isBiometricEnabled,
                          onChanged: settingsProvider.isAppLockEnabled
                              ? (value) => _handleBiometricToggle(
                                  value,
                                  settingsProvider,
                                )
                              : null,
                        ),
                      ),
                    ],

                    // Info Section
                    const SizedBox(height: 16),
                    Card(
                      margin: const EdgeInsets.all(16),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                settingsProvider.lockType == 'device_lock'
                                    ? 'Using your phone\'s screen lock (PIN/pattern/biometric) to protect your authenticator. Change your lock type above to use a separate app PIN.'
                                    : 'Enable app lock to protect your authentication codes with a PIN or biometric authentication.',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
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
