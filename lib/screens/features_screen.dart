// File Path: sreerajp_authenticator/lib/screens/features_screen.dart
// Author: Sreeraj P
// Description: Showcase screen listing all features and capabilities of SreerajP Authenticator with auto-lock monitoring

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

/// Comprehensive features catalog for SreerajP Authenticator.
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  static const List<_FeatureCategory> _categories = [
    _FeatureCategory(
      name: 'Core 2FA & OTP Tools',
      subtitle: 'Standards-compliant code generation and scanning',
      icon: Icons.key_outlined,
      features: [
        _AppFeature(
          title: 'TOTP Time-Based Codes',
          description:
              'Generate secure time-based one-time passwords compliant with RFC 6238. Supports custom periods (30s, 60s), 6 or 8 digits, and SHA-1, SHA-256, or SHA-512 algorithms.',
          icon: Icons.timer_outlined,
          highlights: [
            'RFC 6238 Standard',
            'SHA-1/256/512',
            'Custom Intervals',
            'Live Ring Timer',
          ],
        ),
        _AppFeature(
          title: 'HOTP Counter-Based Codes',
          description:
              'Generate counter-based one-time passwords compliant with RFC 4226. Increment your event counter and produce fresh tokens on demand with one tap.',
          icon: Icons.pin_outlined,
          highlights: [
            'RFC 4226 Standard',
            'Manual Counter Increment',
            'Instant Refresh',
          ],
        ),
        _AppFeature(
          title: 'Instant QR Code Scanner',
          description:
              'Easily onboard accounts by pointing your camera at standard 2FA QR codes (otpauth://). Equipped with flashlight toggle and instant validation.',
          icon: Icons.qr_code_scanner_outlined,
          highlights: [
            'Fast Detection',
            'Flashlight Support',
            'Safe Input Validation',
          ],
        ),
        _AppFeature(
          title: 'Brand Detection & Custom Icons',
          description:
              'Automatically detects popular services (Google, GitHub, Microsoft, AWS, Discord, and 100+ others) and displays high-definition brand logos or colorful initials.',
          icon: Icons.branding_watermark_outlined,
          highlights: [
            '100+ Built-in Brands',
            'Colorful Fallback Avatars',
            'Automatic Match',
          ],
        ),
        _AppFeature(
          title: 'Quick Copy & Token Countdown',
          description:
              'Tap any code to instantly copy it to your clipboard with haptic feedback. Visual circular timer indicators clearly show remaining token validity.',
          icon: Icons.copy_outlined,
          highlights: [
            'One-Tap Copy',
            'Haptic Feedback',
            'Smooth Progress Ring',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Vault Security & Privacy',
      subtitle: 'Hardware-backed encryption, biometrics, and zero tracking',
      icon: Icons.security_outlined,
      features: [
        _AppFeature(
          title: 'AES-256-GCM Vault Encryption',
          description:
              'All account secrets and seed keys are encrypted at rest with military-grade AES-256-GCM. The master device key is safeguarded in the hardware-backed Android Keystore.',
          icon: Icons.enhanced_encryption_outlined,
          highlights: [
            'AES-256-GCM',
            'Hardware Keystore',
            'Zero Plaintext at Rest',
          ],
        ),
        _AppFeature(
          title: 'Biometric & Screen App Lock',
          description:
              'Lock the authenticator behind your fingerprint, face authentication, or device screen lock PIN/passcode. Keeps your sensitive tokens secure from unauthorized access.',
          icon: Icons.fingerprint_outlined,
          highlights: [
            'Fingerprint / Face ID',
            'Device PIN Fallback',
            'Instant Unlock',
          ],
        ),
        _AppFeature(
          title: 'Automatic Inactivity Lock',
          description:
              'Automatically locks the vault and clears decrypted OTP seeds from memory whenever you switch apps, minimize the app, or let the device sleep.',
          icon: Icons.lock_clock_outlined,
          highlights: [
            'Background Auto-Lock',
            'Memory Cleanup',
            'Configurable Timeout',
          ],
        ),
        _AppFeature(
          title: 'Screenshot Guard (FLAG_SECURE)',
          description:
              'Blocks screen captures, screen recording tools, and Android recent apps switcher thumbnails to prevent visual eavesdropping and credential leakage.',
          icon: Icons.screenshot_outlined,
          highlights: [
            'Hardware FLAG_SECURE',
            'No Recents Preview',
            'Anti-Screen Capture',
          ],
        ),
        _AppFeature(
          title: '100% Offline & Zero Telemetry',
          description:
              'Operates fully on-device without any internet backends, cloud logins, third-party analytics, crash beacons, or tracking SDKs.',
          icon: Icons.wifi_off_outlined,
          highlights: [
            'Fully Offline',
            'No Analytics',
            'No Cloud Accounts',
            'Zero Data Leakage',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Organization & Productivity',
      subtitle: 'Categorize, search, and manage your two-factor accounts',
      icon: Icons.label_outlined,
      features: [
        _AppFeature(
          title: 'Multi-Tag Labeling System',
          description:
              'Assign multiple tags (Work, Personal, Finance, Crypto, Social) to any account. Filter your account list by tag with a single tap on the filter bar.',
          icon: Icons.local_offer_outlined,
          highlights: [
            'Multiple Tags per Account',
            'Color-Coded Chips',
            'One-Tap Filtering',
          ],
        ),
        _AppFeature(
          title: 'Interactive Tag Cloud',
          description:
              'Visual tag cloud interface showing all active tags and account distributions. Tap any tag bubble to instantly isolate matching accounts.',
          icon: Icons.bubble_chart_outlined,
          highlights: [
            'Visual Tag Explorer',
            'Account Counts',
            'Fast Navigation',
          ],
        ),
        _AppFeature(
          title: 'Instant Live Search',
          description:
              'Quickly locate any token by typing account names, usernames, issuer services, or assigned tags with real-time matching.',
          icon: Icons.search_outlined,
          highlights: [
            'Real-Time Search',
            'Matches Names & Tags',
            'Instant Results',
          ],
        ),
        _AppFeature(
          title: 'Account Ordering & Editing',
          description:
              'Reorder your accounts as you prefer, update account labels and issuers, or modify algorithm parameters whenever required.',
          icon: Icons.edit_note_outlined,
          highlights: [
            'Drag-and-Drop Order',
            'Edit Metadata',
            'Batch Management',
          ],
        ),
      ],
    ),
    _FeatureCategory(
      name: 'Sync, Air-Gap & Backups',
      subtitle: 'Transfer accounts securely and export encrypted backups',
      icon: Icons.sync_alt_outlined,
      features: [
        _AppFeature(
          title: 'Direct Local P2P Wi-Fi Sync',
          description:
              'Wirelessly transfer accounts between two devices on your local Wi-Fi network. Protected with an out-of-band QR pairing handshake and end-to-end encryption with zero internet.',
          icon: Icons.wifi_tethering_outlined,
          highlights: [
            'Local Wi-Fi Only',
            'End-to-End Encrypted',
            'No Cloud Middleman',
          ],
        ),
        _AppFeature(
          title: 'Optical Air-Gap Sync',
          description:
              'Transfer accounts to completely air-gapped or offline devices using an animated sequence of high-density QR codes without using Wi-Fi or Bluetooth.',
          icon: Icons.qr_code_2_outlined,
          highlights: [
            '100% Air-Gapped',
            'Animated QR Stream',
            'Zero Network Required',
          ],
        ),
        _AppFeature(
          title: 'Password-Protected Encrypted Backups',
          description:
              'Export your complete account vault into an encrypted backup file secured by PBKDF2 key derivation and your chosen password.',
          icon: Icons.backup_outlined,
          highlights: [
            'AES-256 Encrypted',
            'Password Protected',
            'Portable File Export',
          ],
        ),
        _AppFeature(
          title: 'Safe Conflict Resolution & Import',
          description:
              'Import backups or receive sync bundles safely. Existing accounts are preserved and new accounts are merged seamlessly without overwriting existing data.',
          icon: Icons.merge_type_outlined,
          highlights: [
            'Add-Only Merging',
            'Duplicate Protection',
            'Import Statistics',
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isAppLockEnabled && settingsProvider.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Features')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 20),
              for (final category in _categories) ...[
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
                    'SreerajP Authenticator Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore every security safeguard, OTP tool, and vault capability designed for you.',
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
              Text(
                category.name.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
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
