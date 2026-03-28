// File Path: sreerajp_authenticator/lib/screens/backup_restore_screen.dart
// Author: Sreeraj P
// Last Modified: 2025 October 14
// Description: Screen for encrypted backup and restore only

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../providers/group_provider.dart';
import '../services/export_import_service.dart';
import '../providers/settings_provider.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _exportImportService = ExportImportService();
  bool _isProcessing = false;

  Future<void> _handleExportEncrypted() async {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.setBackupInProgress(true);

    // Password validation
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set Backup Password'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create a strong password to encrypt your backup. You will need this password to restore your accounts.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    helperText: 'Minimum 8 characters',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final password = passwordController.text;
              final confirm = confirmPasswordController.text;

              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password cannot be empty')),
                );
                return;
              }

              if (password.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 8 characters'),
                  ),
                );
                return;
              }

              if (password != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              Navigator.pop(context, password);
            },
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );

    if (password == null || password.isEmpty) {
      settingsProvider.setBackupInProgress(false);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      if (!mounted) return;
      final accountProvider = context.read<AccountsProvider>();
      final accounts = accountProvider.accounts;
      final groups = context.read<GroupsProvider>().groups;

      if (accounts.isEmpty) {
        _showMessage('No accounts to backup', isError: true);
        return;
      }

      final result = await _exportImportService.exportAccountsEncrypted(
        accounts,
        groups,
        password,
      );

      if (result && mounted) {
        _showMessage('Encrypted backup created successfully');
        _showBackupSavedDialog();
      } else if (mounted) {
        _showMessage('Backup cancelled or failed', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error creating backup: $e', isError: true);
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
      'Restore Accounts',
      'Import accounts from an encrypted backup file. Existing accounts will not be affected.',
    );

    if (!confirmed) {
      settingsProvider.setBackupInProgress(false);
      return;
    }

    if (!mounted) return;

    final TextEditingController passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Backup Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the password you used when creating this backup:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              onSubmitted: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (password == null || password.isEmpty) {
      settingsProvider.setBackupInProgress(false);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final backupData = await _exportImportService.importAccountsEncrypted(
        password,
      );

      if (backupData == null) {
        _showMessage(
          'No data imported. Check your password and try again.',
          isError: true,
        );
        return;
      }

      final accounts = backupData['accounts'] as List? ?? [];
      if (accounts.isEmpty) {
        _showMessage(
          'No accounts found in backup. Check your password and try again.',
          isError: true,
        );
        return;
      }

      if (!mounted) return;
      final accountProvider = context.read<AccountsProvider>();
      final groupsProvider = context.read<GroupsProvider>();
      await accountProvider.importData(
        backupData,
        existingGroups: groupsProvider.groups,
        onGroupsChanged: () => groupsProvider.loadGroups(),
      );

      final groups = backupData['groups'] as List? ?? [];
      if (mounted) {
        _showMessage(
          'Successfully restored ${accounts.length} account(s)'
          '${groups.isNotEmpty ? ' and ${groups.length} group(s)' : ''}',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error restoring backup: $e', isError: true);
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
            const Text('Backup Created'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your encrypted backup has been saved successfully.'),
            SizedBox(height: 16),
            Text(
              '⚠️ Important:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Store your backup file in a safe location'),
            Text('• Remember your backup password'),
            Text('• Without the password, you cannot restore'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It'),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
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
          appBar: AppBar(title: const Text('Backup & Restore')),
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
                                'All backups are encrypted with a password for maximum security',
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
                      'CREATE BACKUP',
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
                        title: const Text('Create Encrypted Backup'),
                        subtitle: const Text(
                          'Export all accounts with password protection',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _handleExportEncrypted,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Restore Backup Section
                    Text(
                      'RESTORE BACKUP',
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
                        title: const Text('Restore from Backup'),
                        subtitle: const Text(
                          'Import accounts from encrypted backup file',
                        ),
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
                                Text(
                                  'Best Practices',
                                  style: TextStyle(
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '• Create backups regularly\n'
                              '• Use a strong, unique password\n'
                              '• Store backups in multiple secure locations\n'
                              '• Keep your password in a password manager\n'
                              '• Test your backups by restoring them',
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
                                'Never share your backup files or passwords. Anyone with access to both can generate your authentication codes.',
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
