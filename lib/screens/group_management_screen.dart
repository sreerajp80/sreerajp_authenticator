// File Path: sreerajp_authenticator/lib/screens/group_management_screen.dart
// Author: Sreeraj P
// Created: 2025 September 30
// Last Modified: 2025 October 12
// Description: Group management with professional 3D styling

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/group.dart';
import '../providers/account_provider.dart';
import '../providers/group_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedColor = 'blue';
  String _selectedIcon = 'folder';

  @override
  void initState() {
    super.initState();
    context.read<GroupsProvider>().loadGroups();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          backgroundColor: isDark
              ? const Color(0xFF0D1117)
              : AppTheme.backgroundLight,
          appBar: AppBar(
            title: const Text('Manage Groups'),
            backgroundColor: isDark
                ? const Color(0xFF0D1117)
                : AppTheme.backgroundLight,
          ),
          body: Consumer<GroupsProvider>(
            builder: (context, provider, _) {
              final groups = provider.groups;

              if (groups.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                              theme.colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.folder_outlined,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No groups yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create groups to organize your accounts',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final accountCount = context.read<AccountsProvider>()
                      .getAccountCountForGroup(group.id);

                  return Slidable(
                    key: ValueKey(group.id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => _editGroup(group),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        SlidableAction(
                          onPressed: (_) => _deleteGroup(group),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                      ],
                    ),
                    child: _build3DGroupTile(
                      context: context,
                      group: group,
                      accountCount: accountCount,
                      index: index,
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: _build3DFAB(context),
        );
      },
    );
  }

  Widget _build3DGroupTile({
    required BuildContext context,
    required Group group,
    required int accountCount,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.get3DDecoration(context: context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Glossy 3D overlay at the top
                Positioned(
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
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.03),
                              ]
                            : [
                                const Color.fromARGB(
                                  255,
                                  114,
                                  114,
                                  114,
                                ).withValues(alpha: 0.85),
                                const Color.fromARGB(
                                  255,
                                  250,
                                  249,
                                  249,
                                ).withValues(alpha: 0.2),
                              ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, group.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // 3D Avatar
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getColorFromString(group.color),
                                  _getColorFromString(group.color).withValues(
                                    alpha:
                                        (_getColorFromString(group.color).a *
                                                0.7)
                                            .clamp(0.0, 1.0),
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _getColorFromString(
                                    group.color,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Glossy overlay on avatar
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 28,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.3),
                                          Colors.white.withValues(alpha: 0.05),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    _getIconFromString(group.icon),
                                    color: Colors.white,
                                    size: 28,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$accountCount account${accountCount != 1 ? 's' : ''}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow with 3D container
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.06,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .slideX(begin: -0.2, end: 0);
  }

  Widget _build3DFAB(BuildContext context) {
    return Container(
          decoration: AppTheme.get3DButtonDecoration(
            context: context,
            color: AppTheme.mintGreen,
          ),
          child: FloatingActionButton.extended(
            onPressed: _addGroup,
            icon: const Icon(Icons.add),
            label: const Text('Add Group'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  // Helper methods - Accept nullable strings and provide defaults
  Color _getColorFromString(String? colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconFromString(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'personal':
        return Icons.person;
      case 'finance':
        return Icons.account_balance;
      case 'social':
        return Icons.people;
      case 'shopping':
        return Icons.shopping_cart;
      case 'gaming':
        return Icons.sports_esports;
      case 'development':
        return Icons.code;
      default:
        return Icons.folder;
    }
  }

  // Add Group Dialog
  Future<void> _addGroup() async {
    _nameController.clear();
    _selectedColor = 'blue';
    _selectedIcon = 'folder';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _buildGroupDialog(title: 'Add Group', confirmText: 'Add'),
    );

    if (result == true && mounted) {
      final provider = context.read<GroupsProvider>();
      final newGroup = Group(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text.trim(),
        color: _selectedColor,
        icon: _selectedIcon,
      );

      await provider.addGroup(newGroup);
      if (mounted) {
        _showMessage('Group added successfully');
      }
    }
  }

  // Edit Group Dialog
  Future<void> _editGroup(Group group) async {
    _nameController.text = group.name;
    _selectedColor = group.color;
    _selectedIcon = group.icon ?? 'folder';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _buildGroupDialog(title: 'Edit Group', confirmText: 'Save'),
    );

    if (result == true && mounted) {
      final provider = context.read<GroupsProvider>();
      final updatedGroup = Group(
        id: group.id!,
        name: _nameController.text.trim(),
        color: _selectedColor,
        icon: _selectedIcon,
      );

      await provider.updateGroup(updatedGroup);
      if (mounted) {
        _showMessage('Group updated successfully');
      }
    }
  }

  // Delete Group
  Future<void> _deleteGroup(Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          'Are you sure you want to delete "${group.name}"?\n\n'
          'Accounts in this group will be moved to "All Accounts".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && group.id != null) {
      final provider = context.read<GroupsProvider>();
      await provider.deleteGroup(
        group.id!,
        onAccountsUnassigned: () => context.read<AccountsProvider>().loadAccounts(),
      );
      if (mounted) {
        _showMessage('Group deleted successfully');
      }
    }
  }

  // Group Dialog Builder
  Widget _buildGroupDialog({
    required String title,
    required String confirmText,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: Text(title),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g., Work, Personal',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a group name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Color selection
                  Text('Color', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children:
                        [
                          'blue',
                          'red',
                          'green',
                          'orange',
                          'purple',
                          'teal',
                        ].map((color) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getColorFromString(color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColor == color
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Icon selection
                  Text('Icon', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        [
                          'folder',
                          'work',
                          'home',
                          'personal',
                          'finance',
                          'social',
                          'shopping',
                          'gaming',
                          'development',
                        ].map((icon) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = icon),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _selectedIcon == icon
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      )
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedIcon == icon
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _getIconFromString(icon),
                                color: _selectedIcon == icon
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  // Show message snackbar
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
