// File Path: sreerajp_authenticator/lib/screens/features_screen.dart
// Author: Sreeraj P
// Description: Showcase screen listing all features and capabilities of Sreeraj P Authenticator with auto-lock monitoring

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/config/app_config.dart';

import '../providers/settings_provider.dart';

class _AppFeature {
  final String title;
  final String description;
  final IconData icon;
  final List<String> highlights;

  const _AppFeature({
    required this.title,
    required this.description,
    required this.icon,
    this.highlights = const [],
  });
}

class _FeatureCategory {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<_AppFeature> features;

  const _FeatureCategory({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.features,
  });
}

/// Comprehensive features catalog for Sreeraj P Authenticator.
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  static List<_FeatureCategory> _categories(AppLocalizations l10n) => [
    _FeatureCategory(
      name: l10n.descFeatures01,
      subtitle: l10n.descFeatures02,
      icon: Icons.key_outlined,
      features: [
        _AppFeature(
          title: l10n.descFeatures03,
          description: l10n.descFeatures04,
          icon: Icons.timer_outlined,
          highlights: [
            l10n.descFeatures05,
            l10n.descFeatures06,
            l10n.descFeatures07,
            l10n.descFeatures08,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures09,
          description: l10n.descFeatures10,
          icon: Icons.pin_outlined,
          highlights: [
            l10n.descFeatures11,
            l10n.descFeatures12,
            l10n.descFeatures13,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures14,
          description: l10n.descFeatures15,
          icon: Icons.qr_code_scanner_outlined,
          highlights: [
            l10n.descFeatures16,
            l10n.descFeatures17,
            l10n.descFeatures18,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures19,
          description: l10n.descFeatures20,
          icon: Icons.branding_watermark_outlined,
          highlights: [
            l10n.descFeatures21,
            l10n.descFeatures22,
            l10n.descFeatures23,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures24,
          description: l10n.descFeatures25,
          icon: Icons.copy_outlined,
          highlights: [
            l10n.descFeatures26,
            l10n.descFeatures27,
            l10n.descFeatures28,
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.descFeatures29,
      subtitle: l10n.descFeatures30,
      icon: Icons.security_outlined,
      features: [
        _AppFeature(
          title: l10n.descFeatures31,
          description: l10n.descFeatures32,
          icon: Icons.enhanced_encryption_outlined,
          highlights: [
            l10n.descFeatures33,
            l10n.descFeatures34,
            l10n.descFeatures35,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures36,
          description: l10n.descFeatures37,
          icon: Icons.fingerprint_outlined,
          highlights: [
            l10n.descFeatures38,
            l10n.descFeatures39,
            l10n.descFeatures40,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures41,
          description: l10n.descFeatures42,
          icon: Icons.lock_clock_outlined,
          highlights: [
            l10n.descFeatures43,
            l10n.descFeatures44,
            l10n.descFeatures45,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures46,
          description: l10n.descFeatures47,
          icon: Icons.screenshot_outlined,
          highlights: [
            l10n.descFeatures48,
            l10n.descFeatures49,
            l10n.descFeatures50,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures51,
          description: l10n.descFeatures52,
          icon: Icons.wifi_off_outlined,
          highlights: [
            l10n.descFeatures53,
            l10n.descFeatures54,
            l10n.descFeatures55,
            l10n.descFeatures56,
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.descFeatures57,
      subtitle: l10n.descFeatures58,
      icon: Icons.label_outlined,
      features: [
        _AppFeature(
          title: l10n.descFeatures59,
          description: l10n.descFeatures60,
          icon: Icons.local_offer_outlined,
          highlights: [
            l10n.descFeatures61,
            l10n.descFeatures62,
            l10n.descFeatures63,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures64,
          description: l10n.descFeatures65,
          icon: Icons.bubble_chart_outlined,
          highlights: [
            l10n.descFeatures66,
            l10n.descFeatures67,
            l10n.descFeatures68,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures69,
          description: l10n.descFeatures70,
          icon: Icons.search_outlined,
          highlights: [
            l10n.descFeatures71,
            l10n.descFeatures72,
            l10n.descFeatures73,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures74,
          description: l10n.descFeatures75,
          icon: Icons.edit_note_outlined,
          highlights: [
            l10n.descFeatures76,
            l10n.descFeatures77,
            l10n.descFeatures78,
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: l10n.descFeatures79,
      subtitle: l10n.descFeatures80,
      icon: Icons.sync_alt_outlined,
      features: [
        _AppFeature(
          title: l10n.descFeatures81,
          description: l10n.descFeatures82,
          icon: Icons.wifi_tethering_outlined,
          highlights: [
            l10n.descFeatures83,
            l10n.descFeatures84,
            l10n.descFeatures85,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures86,
          description: l10n.descFeatures87,
          icon: Icons.qr_code_2_outlined,
          highlights: [
            l10n.descFeatures88,
            l10n.descFeatures89,
            l10n.descFeatures90,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures91,
          description: l10n.descFeatures92,
          icon: Icons.backup_outlined,
          highlights: [
            l10n.descFeatures93,
            l10n.descFeatures94,
            l10n.descFeatures95,
          ],
        ),
        _AppFeature(
          title: l10n.descFeatures96,
          description: l10n.descFeatures97,
          icon: Icons.merge_type_outlined,
          highlights: [
            l10n.descFeatures98,
            l10n.descFeatures99,
            l10n.descFeatures100,
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final l10n = AppLocalizations.of(context);
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.descFeatures101)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 20),
              for (final category in _categories(l10n)) ...[
                _buildCategoryHeader(context, category),
                const SizedBox(height: 10),
                _buildCategoryCard(context, category),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final appName = context.read<AppConfig>().appName.resolve(
      Localizations.localeOf(context).languageCode,
    );
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12),
              theme.colorScheme.secondary.withValues(
                alpha: isDark ? 0.1 : 0.05,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.descFeatures102(appName),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.descFeatures103,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, _FeatureCategory category) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  category.name.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            category.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _FeatureCategory category) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < category.features.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
            _buildFeatureTile(context, category.features[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, _AppFeature feature) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (feature.highlights.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: feature.highlights.map((h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          h,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
