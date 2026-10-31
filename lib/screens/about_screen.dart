// File Path: sreerajp_authenticator/lib/screens/about_screen.dart
// Author: Sreeraj P
// Description: About screen displaying app information dynamically from AppConfig with auto-lock monitoring

import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/widgets/made_with_love.dart';

import '../config/app_config.dart';
import '../config/app_flavor_config.dart';
import '../providers/settings_provider.dart';
import '../services/config_service.dart';
import '../utils/build_date.g.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;
  AppConfig _config = AppConfig.fallback;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final config = await ConfigService().loadAndVerify(packageInfo: info);
      if (mounted) {
        setState(() {
          _packageInfo = info;
          _config = config;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _languageCode => Localizations.localeOf(context).languageCode;

  void _showLicensesDialog() {
    final l10n = AppLocalizations.of(context);
    showLicensePage(
      context: context,
      applicationName: _config.appName.resolve(_languageCode),
      applicationVersion: _packageInfo?.version ?? _config.version,
      applicationIcon: const Icon(Icons.security, size: 48),
      applicationLegalese: l10n.descCopyright,
    );
  }

  /// Row label for an `app_config.json` details key, from ARB
  /// `aboutDetail<Key>` (guideline.md §1.6). The raw key is the last-resort
  /// fallback, so a newly added key still renders.
  String _detailLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'author':
        return l10n.aboutDetailAuthor;
      case 'email':
        return l10n.aboutDetailEmail;
      case 'website':
        return l10n.aboutDetailWebsite;
      case 'privacyPolicy':
        return l10n.aboutDetailPrivacyPolicy;
      case 'license':
        return l10n.aboutDetailLicense;
      case 'aiUsed':
        return l10n.aboutDetailAiUsed;
      case 'ideUsed':
        return l10n.aboutDetailIdeUsed;
      default:
        return key;
    }
  }

  /// Email rows open the mail app; https rows open the browser.
  VoidCallback? _detailAction(String key, String value) {
    if (key.trim().toLowerCase() == 'email') {
      return () => _openMail(value);
    }
    final uri = Uri.tryParse(value);
    if (uri != null && uri.scheme == 'https') {
      return () => _openUrl(uri);
    }
    return null;
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _openMail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openUrl(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPrivacyPolicy() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.titlePrivacyPolicy),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.titlePrivacyStorage,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(l10n.descPrivacyStorage),
              const SizedBox(height: 16),
              Text(
                l10n.titlePrivacyPermissions,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(l10n.descPrivacyPermissions),
              const SizedBox(height: 16),
              Text(
                l10n.titlePrivacySecurity,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(l10n.descPrivacySecurity),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lang = _languageCode;
    final description = _config.description.resolve(lang);

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
          appBar: AppBar(title: Text(l10n.titleAbout)),
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
                            _config.appName.resolve(lang),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.labelVersionNumber(
                              _packageInfo?.version ?? _config.version,
                            ),
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
                                label: Text(
                                  AppFlavorConfig.instance.isDev
                                      ? l10n.labelEnvDevelopment
                                      : l10n.labelEnvProduction,
                                ),
                              ),
                              Chip(
                                avatar: const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  _packageInfo?.packageName ??
                                      _config.appName.resolve(lang),
                                ),
                              ),
                              const Chip(
                                avatar: Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                ),
                                label: Text(kBuildDate),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (description.trim().isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.titleAbout,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(description),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.titleFeatures,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                              Icons.qr_code_scanner,
                              l10n.descFeatureQr,
                            ),
                            _buildFeatureItem(
                              Icons.lock,
                              l10n.descFeatureEncrypted,
                            ),
                            _buildFeatureItem(
                              Icons.backup,
                              l10n.descFeatureBackup,
                            ),
                            _buildFeatureItem(
                              Icons.folder,
                              l10n.descFeatureOrganize,
                            ),
                            _buildFeatureItem(
                              Icons.fingerprint,
                              l10n.descFeatureBiometric,
                            ),
                            _buildFeatureItem(
                              Icons.dark_mode,
                              l10n.descFeatureDarkMode,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_config.details.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          l10n.titleDeveloper.toUpperCase(),
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
                            for (final entry in _config.details.entries)
                              if (entry.key.trim().isNotEmpty &&
                                  entry.value.resolve(lang).trim().isNotEmpty)
                                ListTile(
                                  title: Text(_detailLabel(l10n, entry.key)),
                                  subtitle: Text(entry.value.resolve(lang)),
                                  onTap: _detailAction(
                                    entry.key,
                                    entry.value.resolve(lang),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        l10n.titleLinks.toUpperCase(),
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
                            title: Text(l10n.titlePrivacyPolicy),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showPrivacyPolicy(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.article),
                            title: Text(l10n.titleOpenSourceLicenses),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _showLicensesDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        l10n.descCopyright,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Signature badge: last element, ≥ 24 dp above it.
                    const MadeWithLove(),
                    SizedBox(height: 8 + MediaQuery.paddingOf(context).bottom),
                  ],
                ),
        );
      },
    );
  }
}
