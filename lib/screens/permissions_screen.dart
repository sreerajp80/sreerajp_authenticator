// File Path: sreerajp_authenticator/lib/screens/permissions_screen.dart
// Author: Sreeraj P
// Created: 2026 March 20
// Description: Permissions screen showing all app permissions with status and auto-lock monitoring

import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../utils/theme.dart';

class _PermissionInfo {
  /// Localized name and description, read with the active AppLocalizations.
  final String Function(AppLocalizations l10n) name;
  final String Function(AppLocalizations l10n) description;
  final IconData icon;
  final Permission? permission;
  final bool isImplicit;

  const _PermissionInfo({
    required this.name,
    required this.description,
    required this.icon,
    this.permission,
    this.isImplicit = false,
  });
}

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  final Map<Permission, PermissionStatus> _statuses = {};
  bool _isLoading = true;

  static final _explicitPermissions = [
    _PermissionInfo(
      name: (l10n) => l10n.labelPermCamera,
      description: (l10n) => l10n.descPermCamera,
      icon: Icons.camera_alt_outlined,
      permission: Permission.camera,
    ),
  ];

  static final _implicitPermissions = [
    _PermissionInfo(
      name: (l10n) => l10n.labelPermBiometric,
      description: (l10n) => l10n.descPermBiometric,
      icon: Icons.fingerprint,
      isImplicit: true,
    ),
    _PermissionInfo(
      name: (l10n) => l10n.labelPermVibration,
      description: (l10n) => l10n.descPermVibration,
      icon: Icons.vibration,
      isImplicit: true,
    ),
    _PermissionInfo(
      name: (l10n) => l10n.labelPermSecureStorage,
      description: (l10n) => l10n.descPermSecureStorage,
      icon: Icons.enhanced_encryption_outlined,
      isImplicit: true,
    ),
    _PermissionInfo(
      name: (l10n) => l10n.labelPermLocalDatabase,
      description: (l10n) => l10n.descPermLocalDatabase,
      icon: Icons.storage_outlined,
      isImplicit: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final statuses = <Permission, PermissionStatus>{};
    for (final perm in _explicitPermissions) {
      if (perm.permission != null) {
        statuses[perm.permission!] = await perm.permission!.status;
      }
    }
    if (mounted) {
      setState(() {
        _statuses.addAll(statuses);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
          appBar: AppBar(title: Text(l10n.titlePermissions)),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Info banner
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.descPermissionsIntro,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Explicit Permissions Section
                    _buildSectionHeader(l10n.titleRuntimePermissions, theme),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: AppTheme.get3DDecoration(context: context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              _buildGlossyOverlay(theme),
                              Column(
                                children: _explicitPermissions
                                    .map(
                                      (perm) => _buildExplicitPermissionTile(
                                        context: context,
                                        info: perm,
                                        status: _statuses[perm.permission],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Implicit Permissions Section
                    _buildSectionHeader(l10n.titleBuiltInCapabilities, theme),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: AppTheme.get3DDecoration(context: context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              _buildGlossyOverlay(theme),
                              Column(
                                children: [
                                  for (
                                    int i = 0;
                                    i < _implicitPermissions.length;
                                    i++
                                  ) ...[
                                    _buildImplicitPermissionTile(
                                      context: context,
                                      info: _implicitPermissions[i],
                                    ),
                                    if (i < _implicitPermissions.length - 1)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          color: theme.dividerColor.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // No network access note
                    _buildSectionHeader(l10n.titlePrivacy, theme),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: AppTheme.get3DDecoration(context: context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              _buildGlossyOverlay(theme),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.statusSuccess(
                                          theme.brightness,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.wifi_off_outlined,
                                        color: AppTheme.statusSuccess(
                                          theme.brightness,
                                        ),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.labelNoCloudService,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            l10n.descNoCloudService,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildGlossyOverlay(ThemeData theme) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.03),
                  ]
                : [
                    const Color.fromARGB(
                      255,
                      78,
                      78,
                      78,
                    ).withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.4),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplicitPermissionTile({
    required BuildContext context,
    required _PermissionInfo info,
    PermissionStatus? status,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isGranted = status?.isGranted ?? false;
    final isDenied = status?.isDenied ?? false;
    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isGranted) {
      statusColor = AppTheme.statusSuccess(theme.brightness);
      statusText = l10n.labelStatusGranted;
      statusIcon = Icons.check_circle;
    } else if (isPermanentlyDenied) {
      statusColor = AppTheme.statusError(theme.brightness);
      statusText = l10n.labelStatusDenied;
      statusIcon = Icons.cancel;
    } else if (isDenied) {
      statusColor = AppTheme.statusWarning(theme.brightness);
      statusText = l10n.labelStatusNotGranted;
      statusIcon = Icons.remove_circle_outline;
    } else {
      statusColor = theme.colorScheme.onSurfaceVariant;
      statusText = l10n.labelStatusNotRequested;
      statusIcon = Icons.help_outline;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (isPermanentlyDenied) {
            await openAppSettings();
          } else if (!isGranted) {
            final result = await info.permission!.request();
            if (mounted) {
              setState(() {
                _statuses[info.permission!] = result;
              });
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  info.icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name(l10n),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description(l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImplicitPermissionTile({
    required BuildContext context,
    required _PermissionInfo info,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(info.icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name(AppLocalizations.of(context)),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.description(AppLocalizations.of(context)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppLocalizations.of(context).labelBuiltIn,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
