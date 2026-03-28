// File Path: sreerajp_authenticator/lib/screens/permissions_screen.dart
// Author: Sreeraj P
// Created: 2026 March 20
// Description: Permissions screen showing all app permissions with status and auto-lock monitoring

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';

class _PermissionInfo {
  final String name;
  final String description;
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

  static const _explicitPermissions = [
    _PermissionInfo(
      name: 'Camera',
      description: 'Used to scan QR codes for adding accounts',
      icon: Icons.camera_alt_outlined,
      permission: Permission.camera,
    ),
  ];

  static const _implicitPermissions = [
    _PermissionInfo(
      name: 'Biometric / Device Lock',
      description: 'Used for app lock authentication via fingerprint or device credentials',
      icon: Icons.fingerprint,
      isImplicit: true,
    ),
    _PermissionInfo(
      name: 'Vibration',
      description: 'Used for haptic feedback during QR code scanning',
      icon: Icons.vibration,
      isImplicit: true,
    ),
    _PermissionInfo(
      name: 'Secure Storage',
      description: 'Uses Android Keystore to securely store encryption keys',
      icon: Icons.enhanced_encryption_outlined,
      isImplicit: true,
    ),
    _PermissionInfo(
      name: 'Local Database',
      description: 'Stores encrypted account data locally on your device',
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
          appBar: AppBar(title: const Text('Permissions')),
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
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.2),
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
                                'This app only requests permissions when needed and never collects data.',
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
                    _buildSectionHeader('Runtime Permissions', theme),
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
                                    .map((perm) => _buildExplicitPermissionTile(
                                          context: context,
                                          info: perm,
                                          status: _statuses[perm.permission],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Implicit Permissions Section
                    _buildSectionHeader('Built-in Capabilities', theme),
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
                                  for (int i = 0;
                                      i < _implicitPermissions.length;
                                      i++) ...[
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
                                          color: theme.dividerColor
                                              .withValues(alpha: 0.3),
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
                    _buildSectionHeader('Privacy', theme),
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
                                        color: AppTheme.successGreen
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.wifi_off_outlined,
                                        color: AppTheme.successGreen,
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
                                            'No Internet Access',
                                            style: theme
                                                .textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'This app works completely offline. Your data never leaves your device.',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.colorScheme
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
                    const Color.fromARGB(255, 78, 78, 78)
                        .withValues(alpha: 0.85),
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
    final isGranted = status?.isGranted ?? false;
    final isDenied = status?.isDenied ?? false;
    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isGranted) {
      statusColor = AppTheme.successGreen;
      statusText = 'Granted';
      statusIcon = Icons.check_circle;
    } else if (isPermanentlyDenied) {
      statusColor = AppTheme.errorCoral;
      statusText = 'Denied';
      statusIcon = Icons.cancel;
    } else if (isDenied) {
      statusColor = AppTheme.warningAmber;
      statusText = 'Not granted';
      statusIcon = Icons.remove_circle_outline;
    } else {
      statusColor = theme.colorScheme.onSurfaceVariant;
      statusText = 'Not requested';
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
                child:
                    Icon(info.icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
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
                  info.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Built-in',
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
