// File Path: sreerajp_authenticator/lib/screens/security_screen.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2026 May 27
// Description: Screen for configuring app PIN, phone lock quick unlock, and adaptive authentication

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/account_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/clipboard_service.dart';
import '../utils/constants.dart';
import '../utils/screen_protection.dart';
import '../widgets/pin_verification_dialog.dart';

enum _UnlockMethodChoice { pin, phoneLock }

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _authService = AuthService();

  /// Localized strings. Read only while the screen is mounted.
  AppLocalizations get _l10n => AppLocalizations.of(context);
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
      if (!provider.hasAnyUnlockMethod) {
        final method = await _showInitialMethodChoiceDialog();
        if (method == null || !mounted) return;

        if (method == _UnlockMethodChoice.pin) {
          final pinSet = await _showPinSetupDialog(
            provider,
            isInitialSetup: true,
          );
          if (!pinSet || !mounted) return;
        } else {
          if (!_isPhoneLockAvailable) {
            _showMessage(_l10n.errorPhoneLockUnavailable, isError: true);
            return;
          }
          final result = await _authService.authenticateWithPhoneLock(
            reason: _l10n.descAuthReasonPhoneLock,
          );
          if (!mounted) return;
          if (!result.isSuccess) {
            _showMessage(_mapQuickUnlockError(result), isError: true);
            return;
          }
          await provider.setPhoneLockQuickUnlockEnabled(true);
        }
      }

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
      _showMessage(
        provider.hasPinSet
            ? _l10n.descAppLockEnabledPin
            : _l10n.descAppLockEnabledPhone,
      );
    } else {
      final confirmed = await _showConfirmDialog(
        _l10n.titleDisableAppLock,
        _l10n.descDisableAppLock,
      );
      if (confirmed && mounted) {
        await provider.setAppLockEnabled(false);
        _showMessage(_l10n.descAppLockDisabled);
      }
    }
  }

  Future<_UnlockMethodChoice?> _showInitialMethodChoiceDialog() async {
    return showDialog<_UnlockMethodChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_l10n.titleChooseUnlockMethod),
        content: Text(_l10n.descChooseUnlockMethod),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_l10n.actionCancel),
          ),
          TextButton(
            onPressed: _isPhoneLockAvailable
                ? () => Navigator.pop(
                    dialogContext,
                    _UnlockMethodChoice.phoneLock,
                  )
                : null,
            child: Text(_l10n.actionPhoneLock),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _UnlockMethodChoice.pin),
            child: Text(_l10n.actionAppPin),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUseAppPinToggle(
    bool value,
    SettingsProvider provider,
  ) async {
    if (value) {
      final pinSet = await _showPinSetupDialog(provider, isInitialSetup: true);
      if (!pinSet || !mounted) return;

      if (!await provider.hasRecoveryKey()) {
        if (!mounted) return;
        setState(() => _isLoading = true);
        final recoveryKey = await provider.generateRecoveryKey();
        if (!mounted) return;
        setState(() => _isLoading = false);
        await _showRecoveryKeyDialog(recoveryKey);
      }
      if (mounted) _showMessage(_l10n.descAppPinEnabled);
    } else {
      if (!provider.phoneLockQuickUnlockEnabled) {
        _showMessage(_l10n.errorEnablePhoneLockFirst, isError: true);
        return;
      }
      final confirmed = await _showConfirmDialog(
        _l10n.titleRemoveAppPin,
        _l10n.descRemoveAppPin,
      );
      if (!confirmed || !mounted) return;
      await provider.setAppLockPin(null);
      _showMessage(_l10n.descAppPinRemoved);
    }
  }

  Future<void> _handleQuickUnlockToggle(
    bool value,
    SettingsProvider provider,
  ) async {
    if (!value) {
      if (!provider.hasPinSet) {
        _showMessage(_l10n.errorSetAppPinFirst, isError: true);
        return;
      }
      await provider.setPhoneLockQuickUnlockEnabled(false);
      _showMessage(_l10n.descQuickUnlockDisabled);
      return;
    }

    final result = await _authService.authenticateWithPhoneLock(
      reason: _l10n.descAuthReasonPhoneLock,
    );
    if (!mounted) return;

    if (result.isSuccess) {
      await provider.setPhoneLockQuickUnlockEnabled(true);
      _showMessage(
        provider.hasPinSet
            ? _l10n.descQuickUnlockEnabled
            : _l10n.descPhoneLockEnabled,
      );
      return;
    }

    _showMessage(_mapQuickUnlockError(result), isError: true);
  }

  String _mapQuickUnlockError(LocalAuthResult result) {
    switch (result.outcome) {
      case LocalAuthOutcome.notAvailable:
        return _l10n.errorPhoneLockUnavailable;
      case LocalAuthOutcome.lockedOut:
        return _l10n.errorPhoneLockLockedOut;
      case LocalAuthOutcome.canceled:
        return _l10n.errorPhoneLockCanceled;
      case LocalAuthOutcome.failure:
        return _l10n.errorPhoneLockFailed;
      case LocalAuthOutcome.error:
        return _l10n.errorPhoneLockUnverified;
      case LocalAuthOutcome.success:
        return '';
    }
  }

  Future<void> _handleAutoLockTimeoutChange(SettingsProvider provider) async {
    final timeouts = {
      for (final seconds in const [0, 30, 60, 300, 600])
        _getAutoLockTimeoutText(seconds): seconds,
    };

    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        final currentTimeout = provider.autoLockTimeout;
        return SimpleDialog(
          title: Text(_l10n.titleAutoLockTimeout),
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
    final currentPin = await _showPinInputDialog(_l10n.titleCurrentPin);
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
      if (mounted) _showMessage(_l10n.errorPinIncorrect, isError: true);
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
      _showMessage(_l10n.descAppPinChanged);
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
              title: Text(
                isInitialSetup ? _l10n.titleSetAppPin : _l10n.titleChangeAppPin,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_l10n.descPinRequiredForProtection),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: _l10n.labelNewPin,
                      helperText: _l10n.descPinDigitsHint,
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
                      labelText: _l10n.labelConfirmPin,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: Text(_l10n.actionCancel),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (pinController.text.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_l10n.errorPinTooShort),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .error,
                              ),
                            );
                            return;
                          }
                          if (pinController.text != confirmController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_l10n.errorPinMismatch),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .error,
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
                      : Text(_l10n.actionSavePin),
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
          decoration: InputDecoration(
            labelText: _l10n.labelAppPin,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(_l10n.actionOk),
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
        title: Text(_l10n.titleRecoveryKey),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _l10n.descRecoveryKeySave,
              style: const TextStyle(fontSize: 13),
            ),
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
                  SnackBar(content: Text(_l10n.descRecoveryKeyCopied)),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(_l10n.actionCopy),
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
                    _l10n.descRecoveryKeyOnce,
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
            child: Text(_l10n.actionSavedIt),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetRecoveryKey(SettingsProvider provider) async {
    final currentPin = await _showPinInputDialog(_l10n.titleCurrentPin);
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
      if (mounted) _showMessage(_l10n.errorPinIncorrect, isError: true);
      return;
    }

    if (mounted) {
      await _showRecoveryKeyDialog(recoveryKey);
    }
  }

  Future<void> _handleBlockScreenshotsToggle(
    bool value,
    SettingsProvider settingsProvider,
  ) async {
    if (!value) {
      final confirmed = await _showConfirmDialog(
        _l10n.titleAllowScreenshots,
        _l10n.descAllowScreenshotsWarning,
      );
      if (!confirmed) return;
    }
    try {
      await settingsProvider.setBlockScreenshots(value);
    } catch (_) {
      _showMessage(_l10n.errorBlockScreenshotsFailed, isError: true);
    }
  }

  /// App PIN if one is set, otherwise the phone lock. With neither, there is
  /// nothing to check, so the warning needs a ticked box instead.
  Future<void> _handleDeleteAllData(SettingsProvider settingsProvider) async {
    final usePin =
        settingsProvider.hasPinSet && settingsProvider.isAppLockEnabled;
    final usePhoneLock =
        !usePin && await _authService.isPhoneLockQuickUnlockAvailable();
    if (!mounted) return;

    final confirmed = await _showDeleteAllWarning(
      requireTick: !usePin && !usePhoneLock,
    );
    if (!confirmed || !mounted) return;

    // The phone-lock prompt must not lock the app halfway through.
    settingsProvider.setBackupInProgress(true);
    try {
      if (usePin) {
        final verified = await showPinVerificationDialog(
          context: context,
          purpose: _l10n.descPinPurposeDeleteAllData,
          settingsProvider: settingsProvider,
          authService: _authService,
        );
        if (!verified || !mounted) return;
      } else if (usePhoneLock) {
        final result = await _authService.authenticateWithPhoneLock(
          reason: _l10n.descAuthReasonDeleteAllData,
        );
        if (!mounted) return;
        if (result.outcome == LocalAuthOutcome.notAvailable) {
          // The phone reported a lock, but it has none to check.
          final ticked = await _showDeleteAllWarning(requireTick: true);
          if (!ticked || !mounted) return;
        } else if (!result.isSuccess) {
          _showMessage(_mapQuickUnlockError(result), isError: true);
          return;
        }
      }
      await _deleteAllData(settingsProvider);
    } finally {
      settingsProvider.setBackupInProgress(false);
    }
  }

  Future<void> _deleteAllData(SettingsProvider settingsProvider) async {
    final accounts = context.read<AccountsProvider>();
    final theme = context.read<ThemeProvider>();
    final locales = context.read<LocaleProvider>();
    final sync = context.read<SyncProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final deletedMessage = _l10n.descAllDataDeleted;

    setState(() => _isLoading = true);
    await sync.reset();
    await ClipboardService.clearPendingSecret();
    final success = await settingsProvider.deleteAllData();
    await accounts.reloadAfterDataDelete();
    await theme.reload();
    locales.reload();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(SnackBar(content: Text(deletedMessage)));
    } else {
      _showMessage(_l10n.errorDeleteAllDataFailed, isError: true);
    }
  }

  Future<bool> _showDeleteAllWarning({required bool requireTick}) async {
    var ticked = false;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(_l10n.titleDeleteAllData),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_l10n.descDeleteAllDataWarning),
                if (requireTick)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_l10n.descDeleteAllDataUnderstand),
                    value: ticked,
                    onChanged: (value) =>
                        setDialogState(() => ticked = value ?? false),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(_l10n.actionCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: requireTick && !ticked
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: Text(_l10n.actionDeleteAll),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
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
            child: Text(_l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_l10n.actionConfirm),
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
    if (seconds == 0) return _l10n.labelLockImmediately;
    if (seconds < 60) return _l10n.labelSecondsCount(seconds);
    return _l10n.labelMinutesCount(seconds ~/ 60);
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
          appBar: AppBar(title: Text(_l10n.titleSecurity)),
          body: (_isCheckingPhoneLock || _isLoading)
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        _l10n.titleAppLockSection.toUpperCase(),
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
                            title: Text(_l10n.labelEnableAppLock),
                            subtitle: Text(_l10n.descEnableAppLock),
                            value: settingsProvider.isAppLockEnabled,
                            onChanged: (value) =>
                                _handleAppLockToggle(value, settingsProvider),
                          ),
                          if (settingsProvider.isAppLockEnabled) ...[
                            const Divider(height: 1),
                            ListTile(
                              title: Text(_l10n.titleAutoLockTimeout),
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
                    if (settingsProvider.isAppLockEnabled) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          _l10n.titleAppPinSection.toUpperCase(),
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
                              title: Text(_l10n.labelUseAppPin),
                              subtitle: Text(
                                settingsProvider.hasPinSet
                                    ? _l10n.descAppPinIsSet
                                    : _l10n.descSetPinHint,
                              ),
                              value: settingsProvider.hasPinSet,
                              onChanged: (value) => _handleUseAppPinToggle(
                                value,
                                settingsProvider,
                              ),
                            ),
                            if (settingsProvider.hasPinSet) ...[
                              const Divider(height: 1),
                              ListTile(
                                title: Text(_l10n.titleChangeAppPin),
                                subtitle: Text(_l10n.descUpdateAppPin),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _handleChangePIN(settingsProvider),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                title: Text(_l10n.labelResetRecoveryKey),
                                subtitle: Text(_l10n.descResetRecoveryKey),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () =>
                                    _handleResetRecoveryKey(settingsProvider),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          _l10n.titlePhoneLockSection.toUpperCase(),
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
                          title: Text(_l10n.labelUsePhoneLock),
                          subtitle: Text(
                            !_isPhoneLockAvailable
                                ? _l10n.errorPhoneLockUnavailable
                                : settingsProvider.hasPinSet
                                ? _l10n.descPhoneLockOptional
                                : _l10n.descPhoneLockOnly,
                          ),
                          value: settingsProvider.phoneLockQuickUnlockEnabled,
                          onChanged: _isPhoneLockAvailable
                              ? (value) => _handleQuickUnlockToggle(
                                  value,
                                  settingsProvider,
                                )
                              : null,
                        ),
                      ),
                      if (settingsProvider.hasPinSet) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            _l10n.titleLockdownSection.toUpperCase(),
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
                            title: Text(_l10n.labelLockdownMode),
                            subtitle: Text(_l10n.descLockdownMode),
                            value: settingsProvider.lockdownEnabled,
                            onChanged: (value) =>
                                settingsProvider.setLockdownEnabled(value),
                          ),
                        ),
                      ],
                    ],
                    if (isScreenProtectionSupported) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          _l10n.titleScreenPrivacySection.toUpperCase(),
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
                          title: Text(_l10n.labelBlockScreenshots),
                          subtitle: Text(_l10n.descBlockScreenshots),
                          value: settingsProvider.blockScreenshots,
                          onChanged: (value) => _handleBlockScreenshotsToggle(
                            value,
                            settingsProvider,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        _l10n.titleDataSection.toUpperCase(),
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
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_forever,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          _l10n.labelDeleteAllData,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        subtitle: Text(_l10n.descDeleteAllDataEntry),
                        onTap: () => _handleDeleteAllData(settingsProvider),
                      ),
                    ),
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
                                    settingsProvider.hasPinSet
                                        ? _l10n.descInfoPhoneOptional
                                        : _l10n.descInfoPhoneOnly,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _l10n.descInfoPhoneLockTypes,
                              style: theme.textTheme.bodySmall,
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
