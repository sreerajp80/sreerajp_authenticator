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
import '../utils/about_screen_content.dart';

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
      applicationName: AboutScreenContent.appName,
      applicationVersion: _packageInfo?.version ?? 'Unknown',
      applicationIcon: const Icon(Icons.security, size: 48),
      applicationLegalese: AboutScreenContent.licensesLegalese,
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
        title: const Text(AboutScreenContent.privacyPolicyTitle),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AboutScreenContent.privacyPolicyStorageTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(AboutScreenContent.privacyPolicyStorageDescription),
              SizedBox(height: 16),
              Text(
                AboutScreenContent.privacyPolicyPermissionsTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(AboutScreenContent.privacyPolicyPermissionsDescription),
              SizedBox(height: 16),
              Text(
                AboutScreenContent.privacyPolicySecurityTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(AboutScreenContent.privacyPolicySecurityDescription),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AboutScreenContent.closeButtonText),
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
                            AboutScreenContent.appName,
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
                                label: Text(AboutScreenContent.environmentName),
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
                              AboutScreenContent.aboutSectionTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(AboutScreenContent.aboutDescription),
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
                              AboutScreenContent.featuresSectionTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                              Icons.qr_code_scanner,
                              AboutScreenContent.qrScanningFeature,
                            ),
                            _buildFeatureItem(
                              Icons.lock,
                              AboutScreenContent.encryptedStorageFeature,
                            ),
                            _buildFeatureItem(
                              Icons.backup,
                              AboutScreenContent.backupRestoreFeature,
                            ),
                            _buildFeatureItem(
                              Icons.folder,
                              AboutScreenContent.accountOrganizationFeature,
                            ),
                            _buildFeatureItem(
                              Icons.fingerprint,
                              AboutScreenContent.biometricAuthFeature,
                            ),
                            _buildFeatureItem(
                              Icons.dark_mode,
                              AboutScreenContent.darkModeFeature,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        AboutScreenContent.linksSectionTitle,
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
                              AboutScreenContent.privacyPolicyTitle,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showPrivacyPolicy(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.article),
                            title: const Text(
                              AboutScreenContent.openSourceLicensesTitle,
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
                        AboutScreenContent.developerSectionTitle,
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
                                AboutScreenContent.developerInitials,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...AboutScreenContent.developerInfo
                                .where((entry) => entry.value.isNotEmpty)
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '${entry.label}: ${entry.value}',
                                      style:
                                          entry.label ==
                                              AboutScreenContent
                                                  .designConceptLabel
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
                        AboutScreenContent.copyrightText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        AboutScreenContent.footerText,
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
