// File Path: sreerajp_authenticator/lib/screens/backup_restore_screen.dart
// Author: Sreeraj P
// Last Modified: 2025 October 14
// Description: Screen for encrypted backup and restore only

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/account_provider.dart';
import '../services/export_import_service.dart';
import '../utils/app_logger.dart';
import '../providers/settings_provider.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _exportImportService = ExportImportService();
  bool _isProcessing = false;

  /// Localized strings. Read only while the screen is mounted.
  AppLocalizations get _l10n => AppLocalizations.of(context);

  Future<void> _handleExportEncrypted() async {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.setBackupInProgress(true);

    // Password validation
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_l10n.titleSetBackupPassword),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _l10n.descSetBackupPassword,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: _l10n.labelPassword,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    helperText: _l10n.descPasswordMin8,
                    suffixIcon: IconButton(
                      tooltip: obscurePassword
                          ? _l10n.tooltipShowPassword
                          : _l10n.tooltipHidePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: _l10n.labelConfirmPassword,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: obscureConfirm
                          ? _l10n.tooltipShowPassword
                          : _l10n.tooltipHidePassword,
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final password = passwordController.text;
              final confirm = confirmPasswordController.text;

              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_l10n.errorPasswordEmpty)),
                );
                return;
              }

              if (password.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_l10n.errorPasswordTooShort8)),
                );
                return;
              }

              if (password != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_l10n.errorPasswordMismatch)),
                );
                return;
              }

              Navigator.pop(context, password);
            },
            child: Text(_l10n.actionCreateBackup),
          ),
        ],
      ),
    );

    if (password == null || password.isEmpty) {
      settingsProvider.setBackupInProgress(false);
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(Duration.zero);

    try {
      if (!mounted) return;
      final accountProvider = context.read<AccountsProvider>();
      final accounts = accountProvider.accounts;

      if (accounts.isEmpty) {
        _showMessage(_l10n.errorNoAccountsToBackup, isError: true);
        return;
      }

      final result = await _exportImportService.exportAccountsEncrypted(
        accounts,
        password,
      );

      if (result && mounted) {
        _showMessage(_l10n.descBackupCreated);
        _showBackupSavedDialog();
      } else if (mounted) {
        _showMessage(_l10n.errorBackupCanceledOrFailed, isError: true);
      }
    } catch (e) {
      AppLogger.error('Failed to create backup', e);
      if (mounted) {
        _showMessage(_l10n.errorBackupFailed, isError: true);
      }
    } finally {
      settingsProvider.setBackupInProgress(false);
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleImportEncrypted() async {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.setBackupInProgress(true);

    final confirmed = await _showConfirmDialog(
      _l10n.titleRestoreAccounts,
      _l10n.descRestoreAccounts,
    );

    if (!confirmed) {
      settingsProvider.setBackupInProgress(false);
      return;
    }

    if (!mounted) return;

    final TextEditingController passwordController = TextEditingController();
    bool obscurePassword = true;
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.titleEnterBackupPassword),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_l10n.descEnterBackupPassword),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: _l10n.labelPassword,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      tooltip: obscurePassword
                          ? _l10n.tooltipShowPassword
                          : _l10n.tooltipHidePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  onSubmitted: (value) => Navigator.pop(context, value),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: Text(_l10n.actionRestore),
          ),
        ],
      ),
    );

    if (password == null || password.isEmpty) {
      settingsProvider.setBackupInProgress(false);
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(Duration.zero);

    try {
      final backupData = await _exportImportService.importAccountsEncrypted(
        password,
      );

      // The user cancelled the file picker.
      if (backupData == null) return;

      final accounts = backupData['accounts'] as List? ?? [];
      if (accounts.isEmpty) {
        _showMessage(_l10n.errorNoAccountsInBackup, isError: true);
        return;
      }

      if (!mounted) return;
      final accountProvider = context.read<AccountsProvider>();
      final result = await accountProvider.importData(backupData);

      if (mounted) {
        _showMessage(_l10n.descAccountsRestored(result.accountsAdded));
      }
    } on BackupPasswordException {
      if (mounted) _showMessage(_l10n.errorBackupPassword, isError: true);
    } on BackupFileTooLargeException {
      if (mounted) _showMessage(_l10n.errorBackupTooLarge, isError: true);
    } on BackupContentException {
      if (mounted) _showMessage(_l10n.errorBackupInvalid, isError: true);
    } catch (e) {
      AppLogger.error('Failed to restore backup', e);
      if (mounted) {
        _showMessage(_l10n.errorRestoreFailed, isError: true);
      }
    } finally {
      settingsProvider.setBackupInProgress(false);
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showBackupSavedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_l10n.titleBackupCreated)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_l10n.descBackupSaved),
            const SizedBox(height: 16),
            Text(
              '⚠️ ${_l10n.titleImportant}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_l10n.descBackupTips),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_l10n.actionGotIt),
          ),
        ],
      ),
    );
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
            child: Text(_l10n.actionContinue),
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
        duration: const Duration(seconds: 4),
      ),
    );
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
          appBar: AppBar(title: Text(_l10n.titleBackupRestore)),
          body: _isProcessing
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Security Info Card
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _l10n.descBackupsEncrypted,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Create Backup Section
                    Text(
                      _l10n.titleCreateBackupSection.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.backup,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(_l10n.labelCreateEncryptedBackup),
                        subtitle: Text(_l10n.descCreateEncryptedBackup),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _handleExportEncrypted,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Restore Backup Section
                    Text(
                      _l10n.titleRestoreBackupSection.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.restore,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        title: Text(_l10n.labelRestoreFromBackup),
                        subtitle: Text(_l10n.descRestoreFromBackup),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _handleImportEncrypted,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Best Practices Card
                    Card(
                      color: theme.colorScheme.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _l10n.titleBestPractices,
                                    style: TextStyle(
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _l10n.descBestPractices,
                              style: TextStyle(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Warning Card
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _l10n.descNeverShareBackups,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontSize: 12,
                                ),
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
