// File Path: sreerajp_authenticator/lib/screens/add_account_screen.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2025 October 09
// Description: Screen for adding or editing authenticator accounts with PIN protection for sensitive fields

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import 'qr_scanner_screen.dart';
import '../services/auth_service.dart';
import '../utils/app_logger.dart';
import '../widgets/pin_verification_dialog.dart';
import '../widgets/add_account/account_info_card.dart';
import '../widgets/add_account/advanced_settings_card.dart';

class AddAccountScreen extends StatefulWidget {
  final Account? accountToEdit;

  const AddAccountScreen({super.key, this.accountToEdit});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _secretController = TextEditingController();
  final _authService = AuthService();

  int _digits = 6;
  int _period = 30;
  String _algorithm = 'SHA1';
  int? _selectedGroupId;
  bool _isProcessing = false;
  bool _isLoadingSecret = false;
  String? _originalSecret; // Store original secret to check if changed

  // Original values to track changes
  int? _originalDigits;
  int? _originalPeriod;
  String? _originalAlgorithm;

  // New fields for PIN protection
  bool _isSecretUnlocked = false;
  bool _isAdvancedUnlocked = false;

  @override
  void initState() {
    super.initState();
    if (widget.accountToEdit != null) {
      _loadAccountData(widget.accountToEdit!);
    }
  }

  Future<void> _loadAccountData(Account account) async {
    // Load non-sensitive data immediately
    _nameController.text = account.name;
    _issuerController.text = account.issuer ?? '';
    _selectedGroupId = account.groupId;

    // Store original values for comparison later
    _originalDigits = account.digits;
    _originalPeriod = account.period;
    _originalAlgorithm = account.algorithm;

    // Set current values to originals
    _digits = account.digits;
    _period = account.period;
    _algorithm = account.algorithm;

    // IMPORTANT: Never load secret automatically when editing
    // Secret will only be loaded after PIN verification
  }

  Future<void> _loadSecretAfterPin() async {
    if (widget.accountToEdit == null) return;

    setState(() => _isLoadingSecret = true);

    try {
      final provider = context.read<AccountsProvider>();
      final account = widget.accountToEdit!;

      // Check if the secret looks encrypted
      final isEncrypted = _isSecretEncrypted(account.secret);

      if (isEncrypted) {
        // Decrypt the secret for display
        final decryptedSecret = await provider.getDecryptedSecret(
          account.secret,
        );
        _secretController.text = decryptedSecret;
        _originalSecret = decryptedSecret;
      } else {
        // Secret is not encrypted (backward compatibility)
        _secretController.text = account.secret;
        _originalSecret = account.secret;
      }
    } catch (e) {
      AppLogger.error('Failed to decrypt account secret for editing', e);
      _secretController.text = widget.accountToEdit!.secret;
      _originalSecret = widget.accountToEdit!.secret;
    } finally {
      setState(() => _isLoadingSecret = false);
    }
  }

  bool _isSecretEncrypted(String secret) {
    final base32OnlyRegex = RegExp(r'^[A-Z2-7\s]+$');

    if (secret.contains('=') || secret.contains('+') || secret.contains('/')) {
      return true;
    }

    if (secret != secret.toUpperCase()) {
      return true;
    }

    return !base32OnlyRegex.hasMatch(secret.replaceAll(' ', ''));
  }

  Future<void> _handleSecretEdit() async {
    final settingsProvider = context.read<SettingsProvider>();

    // Check if app lock is enabled
    if (!settingsProvider.isAppLockEnabled) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('App Lock Required'),
          content: const Text(
            'To edit the secret key, please enable app lock from Security settings first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Navigate to security settings
                Navigator.pushNamed(context, '/security');
              },
              child: const Text('Go to Security'),
            ),
          ],
        ),
      );
      return;
    }

    if (_isSecretUnlocked) return;

    final verified = await showPinVerificationDialog(
      context: context,
      purpose: 'view and edit secret key',
      settingsProvider: settingsProvider,
      authService: _authService,
    );

    if (!mounted) return;

    if (verified) {
      setState(() {
        _isSecretUnlocked = true;
      });
      // Load the secret after PIN verification
      await _loadSecretAfterPin();

      // Show success feedback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Secret key unlocked'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Light haptic feedback for success
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _handleAdvancedEdit() async {
    final settingsProvider = context.read<SettingsProvider>();

    // Check if app lock is enabled
    if (!settingsProvider.isAppLockEnabled) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('App Lock Required'),
          content: const Text(
            'To edit advanced options, please enable app lock from Security settings first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Navigate to security settings
                Navigator.pushNamed(context, '/security');
              },
              child: const Text('Go to Security'),
            ),
          ],
        ),
      );
      return;
    }

    if (_isAdvancedUnlocked) return;

    final verified = await showPinVerificationDialog(
      context: context,
      purpose: 'view and edit advanced options',
      settingsProvider: settingsProvider,
      authService: _authService,
    );

    if (!mounted) return;

    if (verified) {
      setState(() {
        _isAdvancedUnlocked = true;
      });

      // Show success feedback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Advanced settings unlocked'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Light haptic feedback for success
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final settingsProvider = context.read<SettingsProvider>();

    // Check if we need PIN verification for changes
    if (widget.accountToEdit != null) {
      // Check if sensitive fields were changed
      final secretChanged =
          _secretController.text.isNotEmpty &&
          _secretController.text.trim().replaceAll(' ', '').toUpperCase() !=
              _originalSecret?.replaceAll(' ', '').toUpperCase();

      final advancedChanged =
          _digits != _originalDigits ||
          _period != _originalPeriod ||
          _algorithm != _originalAlgorithm;

      // If app lock is not enabled and trying to change sensitive fields, block it
      if ((secretChanged || advancedChanged) &&
          !settingsProvider.isAppLockEnabled) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('App Lock Required'),
            content: const Text(
              'To save changes to sensitive fields (secret key or advanced options), please enable app lock from Security settings first.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // If app lock is enabled and sensitive fields changed, require PIN
      if ((secretChanged || advancedChanged) &&
          settingsProvider.isAppLockEnabled) {
        final changes = <String>[];
        if (secretChanged) changes.add('secret key');
        if (advancedChanged) changes.add('advanced settings');

        final verified = await showPinVerificationDialog(
          context: context,
          purpose: 'save changes to ${changes.join(' and ')}',
          settingsProvider: settingsProvider,
          authService: _authService,
        );

        if (!mounted) return;
        if (!verified) return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final provider = context.read<AccountsProvider>();

      final cleanedSecret = _secretController.text
          .trim()
          .replaceAll(' ', '')
          .toUpperCase();

      if (widget.accountToEdit != null) {
        // UPDATING existing account

        // If secret field is empty (not unlocked), use original secret
        final secretToUse = _secretController.text.isEmpty
            ? widget.accountToEdit!.secret
            : cleanedSecret;

        final account = Account(
          id: widget.accountToEdit!.id,
          name: _nameController.text.trim(),
          issuer: _issuerController.text.trim().isEmpty
              ? null
              : _issuerController.text.trim(),
          secret: secretToUse,
          type: widget.accountToEdit!.type,
          digits: _digits,
          period: _period,
          algorithm: _algorithm,
          groupId: _selectedGroupId,
          createdAt: widget.accountToEdit!.createdAt,
          sortOrder: widget.accountToEdit!.sortOrder,
          counter: widget.accountToEdit!.counter,
        );

        // Check if secret has changed
        final secretChanged =
            _secretController.text.isNotEmpty &&
            cleanedSecret != _originalSecret?.replaceAll(' ', '').toUpperCase();

        if (secretChanged) {
          // Secret changed, need to encrypt the new secret
          final encryptedAccount = account.copyWith(
            secret: await provider.encryptSecret(cleanedSecret),
          );
          await provider.updateAccountDirect(encryptedAccount);
        } else {
          // Secret unchanged or not edited, use the original encrypted secret
          final encryptedAccount = account.copyWith(
            secret: widget.accountToEdit!.secret,
          );
          await provider.updateAccountDirect(encryptedAccount);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account updated successfully')),
        );
      } else {
        // ADDING new account
        final account = Account(
          name: _nameController.text.trim(),
          issuer: _issuerController.text.trim().isEmpty
              ? null
              : _issuerController.text.trim(),
          secret: cleanedSecret,
          type: 'totp',
          digits: _digits,
          period: _period,
          algorithm: _algorithm,
          groupId: _selectedGroupId,
          createdAt: DateTime.now(),
          sortOrder: provider.accounts.length,
        );

        await provider.addAccount(account);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account added successfully')),
        );
      }

      // Navigate back after showing message
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving account: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String? _validateSecret(String? value) {
    // If editing and secret not unlocked, don't validate (will use original)
    if (widget.accountToEdit != null && !_isSecretUnlocked) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Secret key is required';
    }

    final cleaned = value.replaceAll(' ', '').replaceAll('=', '').toUpperCase();
    final base32Regex = RegExp(r'^[A-Z2-7]+$');

    if (!base32Regex.hasMatch(cleaned)) {
      return 'Invalid secret key. Must be Base32 encoded';
    }

    if (cleaned.length < 16) {
      return 'Secret key is too short';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.accountToEdit != null;
    final settingsProvider = context.watch<SettingsProvider>();

    // When editing, always show locked state initially for sensitive fields
    final showSecretLocked = isEditing && !_isSecretUnlocked;
    final showAdvancedLocked = isEditing && !_isAdvancedUnlocked;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Account' : 'Add Account'),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                );
              },
              tooltip: 'Scan QR Code',
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AccountInfoCard(
                    isEditing: isEditing,
                    showSecretLocked: showSecretLocked,
                    isSecretUnlocked: _isSecretUnlocked,
                    isLoadingSecret: _isLoadingSecret,
                    isAppLockEnabled: settingsProvider.isAppLockEnabled,
                    nameController: _nameController,
                    issuerController: _issuerController,
                    secretController: _secretController,
                    selectedGroupId: _selectedGroupId,
                    onGroupChanged: (value) {
                      setState(() => _selectedGroupId = value);
                    },
                    onSecretEditTap: _handleSecretEdit,
                    onQrScan: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QrScannerScreen(),
                        ),
                      );

                      // FIX: Check if mounted before using context
                      if (!mounted) return;

                      if (result == true) {
                        Navigator.of(context).pop();
                      }
                    },
                    secretValidator: _validateSecret,
                  ),

                  const SizedBox(height: 16),

                  AdvancedSettingsCard(
                    isEditing: isEditing,
                    showAdvancedLocked: showAdvancedLocked,
                    isAdvancedUnlocked: _isAdvancedUnlocked,
                    isAppLockEnabled: settingsProvider.isAppLockEnabled,
                    digits: _digits,
                    period: _period,
                    algorithm: _algorithm,
                    onDigitsChanged: (value) {
                      if (value != null) {
                        setState(() => _digits = value);
                      }
                    },
                    onPeriodChanged: (value) {
                      if (value != null) {
                        setState(() => _period = value);
                      }
                    },
                    onAlgorithmChanged: (value) {
                      if (value != null) {
                        setState(() => _algorithm = value);
                      }
                    },
                    onAdvancedEditTap: _handleAdvancedEdit,
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: _saveAccount,
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Update Account' : 'Add Account'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
