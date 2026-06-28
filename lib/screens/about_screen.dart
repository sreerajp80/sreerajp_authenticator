// File Path: sreerajp_authenticator/lib/screens/about_screen.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2025 October 15
// Description: About screen displaying app information with auto-lock monitoring

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../config/app_flavor_config.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLicensesDialog() {
    showLicensePage(
      context: context,
      applicationName: AppFlavorConfig.instance.appName,
      applicationVersion: _packageInfo?.version ?? 'Unknown',
      applicationIcon: const Icon(Icons.security, size: 48),
      applicationLegalese: AppConstants.licensesLegalese,
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.privacyPolicyTitle),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.privacyPolicyStorageTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(AppConstants.privacyPolicyStorageDescription),
              SizedBox(height: 16),
              Text(
                AppConstants.privacyPolicyPermissionsTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(AppConstants.privacyPolicyPermissionsDescription),
              SizedBox(height: 16),
              Text(
                AppConstants.privacyPolicySecurityTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(AppConstants.privacyPolicySecurityDescription),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppConstants.closeButtonText),
          ),
        ],
      ),
    );
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
          appBar: AppBar(title: const Text('About')),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.security,
                              size: 60,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppFlavorConfig.instance.appName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Version ${_packageInfo?.version ?? '1.0.0'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              Chip(
                                avatar: const Icon(
                                  Icons.flag_outlined,
                                  size: 18,
                                ),
                                label: Text(AppFlavorConfig.instance.environmentName),
                              ),
                              Chip(
                                avatar: const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  _packageInfo?.packageName ??
                                      AppFlavorConfig.instance.appName,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.aboutSectionTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(AppConstants.aboutDescription),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.featuresSectionTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                              Icons.qr_code_scanner,
                              AppConstants.qrScanningFeature,
                            ),
                            _buildFeatureItem(
                              Icons.lock,
                              AppConstants.encryptedStorageFeature,
                            ),
                            _buildFeatureItem(
                              Icons.backup,
                              AppConstants.backupRestoreFeature,
                            ),
                            _buildFeatureItem(
                              Icons.folder,
                              AppConstants.accountOrganizationFeature,
                            ),
                            _buildFeatureItem(
                              Icons.fingerprint,
                              AppConstants.biometricAuthFeature,
                            ),
                            _buildFeatureItem(
                              Icons.dark_mode,
                              AppConstants.darkModeFeature,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        AppConstants.linksSectionTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.privacy_tip),
                            title: const Text(
                              AppConstants.privacyPolicyTitle,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showPrivacyPolicy(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.article),
                            title: const Text(
                              AppConstants.openSourceLicensesTitle,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _showLicensesDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        AppConstants.developerSectionTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                AppConstants.developerInitials,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...AppConstants.developerInfo
                                .where((entry) => entry.value.isNotEmpty)
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '${entry.label}: ${entry.value}',
                                      style:
                                          entry.label ==
                                              AppConstants.designConceptLabel
                                          ? theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                )
                                          : theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        AppConstants.copyrightText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        AppConstants.footerText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
        );
      },
    );
  }
}
