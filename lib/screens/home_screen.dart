// File Path: sreerajp_authenticator/lib/screens/home_screen.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 14
// Description: Home screen displaying list of accounts with search, filter, and sort functionalities with immediate lock check.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/account_provider.dart';
import '../providers/group_provider.dart';
import '../providers/settings_provider.dart';
import '../models/account.dart';
import '../widgets/account_tile.dart';
import 'add_account_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';
import 'group_management_screen.dart';
// import 'lock_screen.dart';
import '../utils/theme.dart';
import '../widgets/home/home_empty_state.dart';
import '../widgets/home/home_fab_button.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/home_group_tabs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _sortBy = 'manual'; // manual, name, date
  int? _selectedGroupId;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animations
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();

    // Load accounts only if not locked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>();

      // Don't load accounts if locked
      if (!settingsProvider.isLocked) {
        context.read<AccountsProvider>().loadAccounts();
        context.read<GroupsProvider>().loadGroups();
        context.read<SettingsProvider>().resetActivityTimer();
      }
    });

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final settingsProvider = context.read<SettingsProvider>();

    if (state == AppLifecycleState.resumed) {
      // App came to foreground
      settingsProvider.onAppResumed();
      // The _AppRoot wrapper will handle navigation automatically
    } else if (state == AppLifecycleState.paused) {
      // App went to background
      settingsProvider.onAppPaused();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fabAnimationController.dispose();
    super.dispose();
  }

  // Reset activity timer on user interactions
  void _onUserInteraction() {
    context.read<SettingsProvider>().resetActivityTimer();
  }

  List<Account> _getFilteredAndSortedAccounts(List<Account> accounts) {
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      accounts = accounts
          .where(
            (account) =>
                account.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (account.issuer?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // Apply group filter
    if (_selectedGroupId != null) {
      accounts = accounts
          .where((account) => account.groupId == _selectedGroupId)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'issuer':
        accounts.sort((a, b) {
          final issuerA = (a.issuer ?? '').toLowerCase();
          final issuerB = (b.issuer ?? '').toLowerCase();
          if (issuerA.isEmpty && issuerB.isEmpty) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          }
          if (issuerA.isEmpty) {
            return 1; // Put accounts without issuer at the end
          }
          if (issuerB.isEmpty) return -1;
          return issuerA.compareTo(issuerB);
        });
        break;
      case 'account':
        accounts.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case 'date':
        accounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default: // manual
        accounts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return accounts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      // Reset activity timer on any tap
      onTap: _onUserInteraction,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
                    : [AppTheme.primaryBlue, AppTheme.deepBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : AppTheme.deepBlue.withValues(alpha: 0.2),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Sreeraj P Authenticator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      offset: const Offset(0, -1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white, size: 24),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_outlined, size: 20),
                  ),
                  onPressed: () async {
                    _onUserInteraction();
                    final selectedGroup = await Navigator.push<int?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GroupManagementScreen(),
                      ),
                    );
                    if (selectedGroup != null && mounted) {
                      setState(() => _selectedGroupId = selectedGroup);
                    }
                  },
                  tooltip: 'Groups',
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.sort,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  tooltip: 'Sort',
                  onSelected: (value) {
                    _onUserInteraction();
                    setState(() => _sortBy = value);
                    if (value == 'manual') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Long press and drag to reorder accounts',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    _buildPopupMenuItem(
                      value: 'manual',
                      icon: Icons.drag_handle,
                      label: 'Manual',
                      isSelected: _sortBy == 'manual',
                    ),
                    _buildPopupMenuItem(
                      value: 'issuer',
                      icon: Icons.business,
                      label: 'By Issuer',
                      isSelected: _sortBy == 'issuer',
                    ),
                    _buildPopupMenuItem(
                      value: 'account',
                      icon: Icons.sort_by_alpha,
                      label: 'By Account Name',
                      isSelected: _sortBy == 'account',
                    ),
                    _buildPopupMenuItem(
                      value: 'date',
                      icon: Icons.calendar_today,
                      label: 'By Date Added',
                      isSelected: _sortBy == 'date',
                    ),
                  ],
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.settings_outlined, size: 20),
                  ),
                  onPressed: () {
                    _onUserInteraction();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  tooltip: 'Settings',
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0D1117), const Color(0xFF161B22)]
                  : [
                      const Color.fromARGB(255, 255, 255, 255),
                      const Color.fromARGB(255, 106, 128, 161),
                    ],
            ),
          ),
          child: SafeArea(
            top: true,
            child: Column(
              children: [
                // Search Bar
                HomeSearchBar(
                  searchQuery: _searchQuery,
                  onChanged: (value) {
                    _onUserInteraction();
                    setState(() => _searchQuery = value);
                  },
                  onClear: () {
                    _onUserInteraction();
                    setState(() => _searchQuery = '');
                  },
                ),

                // Group Tabs
                HomeGroupTabs(
                  selectedGroupId: _selectedGroupId,
                  onGroupSelected: (groupId) {
                    _onUserInteraction();
                    setState(() => _selectedGroupId = groupId);
                  },
                ),

                // Info Banner
                if (_sortBy == 'manual')
                  Consumer<AccountsProvider>(
                    builder: (context, provider, _) {
                      if (provider.accounts.isNotEmpty) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(
                                        0xFF1E3A5F,
                                      ).withValues(alpha: 0.3),
                                      const Color(
                                        0xFF2D4A3D,
                                      ).withValues(alpha: 0.3),
                                    ]
                                  : [
                                      AppTheme.primaryBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                      AppTheme.mintGreen.withValues(alpha: 0.1),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF30363D)
                                  : AppTheme.primaryBlue.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: isDark
                                    ? const Color(0xFF64B5F6)
                                    : AppTheme.primaryBlue,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Long press and drag to reorder • Swipe left for options.\nDouble Tap will copy the code to clipboard.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFFB1BAC4)
                                        : AppTheme.deepBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms);
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                // Account List
                Expanded(
                  child: Consumer<AccountsProvider>(
                    builder: (context, provider, _) {
                      final accounts = _getFilteredAndSortedAccounts(
                        provider.accounts,
                      );

                      if (accounts.isEmpty) {
                        return HomeEmptyState(searchQuery: _searchQuery);
                      }

                      if (_sortBy == 'manual') {
                        return ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: accounts.length,
                          onReorder: (oldIndex, newIndex) {
                            _onUserInteraction();
                            if (newIndex > oldIndex) newIndex--;
                            provider.reorderAccounts(oldIndex, newIndex);
                          },
                          proxyDecorator: (child, index, animation) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                final double animValue = Curves.easeInOut
                                    .transform(animation.value);
                                final double elevation = (1 - animValue) * 6;
                                return Material(
                                  elevation: elevation,
                                  borderRadius: BorderRadius.circular(12),
                                  child: child,
                                );
                              },
                              child: child,
                            );
                          },
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            return _buildAccountItem(account, index);
                          },
                        );
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: accounts.length,
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            return _buildAccountItem(account, index);
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: HomeFabButton(
          onQrScan: () {
            _onUserInteraction();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrScannerScreen()),
            );
          },
          onManualEntry: () {
            _onUserInteraction();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddAccountScreen()),
            );
          },
          fabAnimation: _fabAnimation,
        ),
      ),
    );
  }

  Widget _buildAccountItem(Account account, int index) {
    return Slidable(
      key: ValueKey(account.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              _onUserInteraction();
              _editAccount(account);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          SlidableAction(
            onPressed: (_) {
              _onUserInteraction();
              _deleteAccount(account);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: AccountTile(account: account)
          .animate()
          .fadeIn(duration: 300.ms, delay: (50 * index).ms)
          .slideX(begin: -0.2, end: 0),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  void _editAccount(Account account) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddAccountScreen(accountToEdit: account),
        ),
      );
    }
  }

  void _deleteAccount(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${account.name}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AccountsProvider>().deleteAccount(account.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account "${account.name}" deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
