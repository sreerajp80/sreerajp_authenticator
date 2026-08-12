// File Path: sreerajp_authenticator/lib/screens/home_screen.dart
// Author: Sreeraj P
// Description: Home screen with 2-tab navigation (Accounts and Tag Cloud) with search, filter, and sort functionalities.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../models/account.dart';
import '../services/auth_service.dart';
import '../services/export_import_service.dart';
import '../widgets/account_tile.dart';
import '../widgets/pin_verification_dialog.dart';
import 'add_account_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';

import '../utils/theme.dart';
import '../widgets/home/home_empty_state.dart';
import '../widgets/home/home_fab_button.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/home_tag_cloud_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  String _searchQuery = '';
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late TabController _tabController;

  bool _isSelectionMode = false;
  final Set<int> _selectedAccountIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);

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
        context.read<SettingsProvider>().resetActivityTimer();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final settingsProvider = context.read<SettingsProvider>();

    if (state == AppLifecycleState.resumed) {
      settingsProvider.onAppResumed();
    } else if (state == AppLifecycleState.paused) {
      settingsProvider.onAppPaused();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fabAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Reset activity timer on user interactions
  void _onUserInteraction() {
    context.read<SettingsProvider>().resetActivityTimer();
  }

  void _enterSelectionMode(Account account) {
    if (account.id == null) return;
    setState(() {
      _isSelectionMode = true;
      _selectedAccountIds.add(account.id!);
    });
  }

  void _toggleAccountSelection(Account account) {
    if (account.id == null) return;
    setState(() {
      if (_selectedAccountIds.contains(account.id)) {
        _selectedAccountIds.remove(account.id);
      } else {
        _selectedAccountIds.add(account.id!);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedAccountIds.clear();
    });
  }

  void _selectAllAccounts(List<Account> accounts) {
    final validIds = accounts.map((a) => a.id).whereType<int>().toSet();
    setState(() {
      if (_selectedAccountIds.length == validIds.length) {
        _selectedAccountIds.clear();
      } else {
        _selectedAccountIds.addAll(validIds);
      }
    });
  }

  List<Account> _getFilteredAndSortedAccounts(
    List<Account> accounts,
    String sortBy,
    Set<String> selectedTags,
  ) {
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      accounts = accounts
          .where(
            (account) =>
                account.name.toLowerCase().contains(query) ||
                (account.issuer?.toLowerCase().contains(query) ?? false) ||
                account.tags.any((t) => t.toLowerCase().contains(query)),
          )
          .toList();
    }

    // Apply active tags filter
    if (selectedTags.isNotEmpty) {
      accounts = accounts.where((account) {
        return selectedTags.every(
          (selTag) => account.tags.any(
            (accTag) => accTag.toLowerCase() == selTag.toLowerCase(),
          ),
        );
      }).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'issuer':
        accounts.sort((a, b) {
          final issuerA = (a.issuer ?? '').toLowerCase();
          final issuerB = (b.issuer ?? '').toLowerCase();
          if (issuerA.isEmpty && issuerB.isEmpty) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          }
          if (issuerA.isEmpty) {
            return 1;
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
    final sortBy = context.watch<SettingsProvider>().sortBy;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isSelectionMode) {
          _exitSelectionMode();
        }
      },
      child: GestureDetector(
        onTap: _onUserInteraction,
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 46.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isSelectionMode
                      ? (isDark
                            ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                            : [AppTheme.deepBlue, const Color(0xFF0D47A1)])
                      : (isDark
                            ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
                            : [AppTheme.primaryBlue, AppTheme.deepBlue]),
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
                leading: _isSelectionMode
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'Cancel selection',
                        onPressed: _exitSelectionMode,
                      )
                    : null,
                title: Text(
                  _isSelectionMode
                      ? '${_selectedAccountIds.length} Selected'
                      : 'Sreeraj P Authenticator',
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
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.shield_outlined, size: 20),
                      text: 'Accounts',
                    ),
                    Tab(
                      icon: Icon(Icons.style_outlined, size: 20),
                      text: 'Tags',
                    ),
                  ],
                ),
                actions: [
                  if (_isSelectionMode)
                    Consumer<AccountsProvider>(
                      builder: (context, provider, _) {
                        final visibleAccounts = _getFilteredAndSortedAccounts(
                          provider.accounts,
                          sortBy,
                          provider.selectedTags,
                        );
                        final allSelected =
                            visibleAccounts.isNotEmpty &&
                            visibleAccounts.every(
                              (a) =>
                                  a.id != null &&
                                  _selectedAccountIds.contains(a.id),
                            );
                        return IconButton(
                          icon: Icon(
                            allSelected ? Icons.deselect : Icons.select_all,
                            color: Colors.white,
                          ),
                          tooltip: allSelected ? 'Deselect All' : 'Select All',
                          onPressed: () => _selectAllAccounts(visibleAccounts),
                        );
                      },
                    )
                  else ...[
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
                        context.read<SettingsProvider>().setSortBy(value);
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
                          isSelected: sortBy == 'manual',
                        ),
                        _buildPopupMenuItem(
                          value: 'issuer',
                          icon: Icons.business,
                          label: 'By Issuer',
                          isSelected: sortBy == 'issuer',
                        ),
                        _buildPopupMenuItem(
                          value: 'account',
                          icon: Icons.sort_by_alpha,
                          label: 'By Account Name',
                          isSelected: sortBy == 'account',
                        ),
                        _buildPopupMenuItem(
                          value: 'date',
                          icon: Icons.calendar_today,
                          label: 'By Date Added',
                          isSelected: sortBy == 'date',
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
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      tooltip: 'Settings',
                    ),
                  ],
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: ACCOUNTS LIST
                  Column(
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

                      // Active Tag Filter Banner
                      Consumer<AccountsProvider>(
                        builder: (context, provider, _) {
                          if (provider.selectedTags.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final tagsText = provider.selectedTags
                              .map((t) => t.startsWith('#') ? t : '#$t')
                              .join(', ');
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E3A5F)
                                  : AppTheme.primaryBlue.withValues(
                                      alpha: 0.12,
                                    ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? const Color(
                                        0xFF64B5F6,
                                      ).withValues(alpha: 0.4)
                                    : AppTheme.primaryBlue.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_alt,
                                  size: 18,
                                  color: isDark
                                      ? const Color(0xFF64B5F6)
                                      : AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Filtered by: $tagsText',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.deepBlue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    _onUserInteraction();
                                    provider.clearSelectedTags();
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Clear Filter',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 200.ms);
                        },
                      ),

                      // Info Banner for Manual Sort
                      if (sortBy == 'manual' && !_isSelectionMode)
                        Consumer<AccountsProvider>(
                          builder: (context, provider, _) {
                            if (provider.accounts.isNotEmpty) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                padding: const EdgeInsets.all(10),
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
                                            AppTheme.mintGreen.withValues(
                                              alpha: 0.1,
                                            ),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF30363D)
                                        : AppTheme.primaryBlue.withValues(
                                            alpha: 0.2,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: isDark
                                          ? const Color(0xFF64B5F6)
                                          : AppTheme.primaryBlue,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Long press to enter multi-select • Drag to reorder.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? const Color(0xFFB1BAC4)
                                              : AppTheme.deepBlue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 200.ms);
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
                              sortBy,
                              provider.selectedTags,
                            );

                            if (accounts.isEmpty) {
                              return HomeEmptyState(searchQuery: _searchQuery);
                            }

                            if (sortBy == 'manual' && !_isSelectionMode) {
                              return ReorderableListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  80,
                                ),
                                itemCount: accounts.length,
                                onReorderItem: (oldIndex, newIndex) {
                                  _onUserInteraction();
                                  provider.reorderAccounts(oldIndex, newIndex);
                                },
                                proxyDecorator: (child, index, animation) {
                                  return AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, child) {
                                      final double animValue = Curves.easeInOut
                                          .transform(animation.value);
                                      final double elevation =
                                          (1 - animValue) * 6;
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
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  80,
                                ),
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

                  // TAB 2: TAG CLOUD VIEW
                  HomeTagCloudView(
                    onTagSelected: () {
                      _onUserInteraction();
                      _tabController.animateTo(0); // Switch to Accounts tab
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _isSelectionMode
              ? Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBatchActionButton(
                          icon: Icons.style_outlined,
                          label: 'Reassign Tags',
                          onPressed: _selectedAccountIds.isEmpty
                              ? null
                              : _showBatchTagDialog,
                        ),
                        _buildBatchActionButton(
                          icon: Icons.upload_file_outlined,
                          label: 'Export Selected',
                          onPressed: _selectedAccountIds.isEmpty
                              ? null
                              : _showBatchExportDialog,
                        ),
                        _buildBatchActionButton(
                          icon: Icons.delete_outline,
                          label: 'Delete Selected',
                          color: Colors.redAccent,
                          onPressed: _selectedAccountIds.isEmpty
                              ? null
                              : _showBatchDeleteDialog,
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          floatingActionButton: _isSelectionMode
              ? null
              : HomeFabButton(
                  onQrScan: _navigateToQrScanner,
                  onManualEntry: () => _navigateToAddAccount(),
                  fabAnimation: _fabAnimation,
                ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? AppTheme.primaryBlue : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryBlue : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(Account account, int index) {
    final isSelected =
        account.id != null && _selectedAccountIds.contains(account.id);
    final tile = AccountTile(
      account: account,
      isSelectionMode: _isSelectionMode,
      isSelected: isSelected,
      onTap: () {
        _onUserInteraction();
        if (_isSelectionMode) {
          _toggleAccountSelection(account);
        }
      },
      onLongPress: () {
        _onUserInteraction();
        if (!_isSelectionMode) {
          _enterSelectionMode(account);
        } else {
          _toggleAccountSelection(account);
        }
      },
    );

    return Padding(
      key: ValueKey(account.id ?? account.name),
      padding: const EdgeInsets.only(bottom: 12),
      child: _isSelectionMode
          ? tile
          : Slidable(
              key: ValueKey(account.id ?? account.name),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.45,
                children: [
                  CustomSlidableAction(
                    onPressed: (context) {
                      _onUserInteraction();
                      _navigateToAddAccount(accountToEdit: account);
                    },
                    backgroundColor: AppTheme.mintGreen,
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(height: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) {
                      _onUserInteraction();
                      _showDeleteDialog(account);
                    },
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              child: tile,
            ),
    );
  }

  void _navigateToQrScanner() {
    _onUserInteraction();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
  }

  void _navigateToAddAccount({Account? accountToEdit}) {
    _onUserInteraction();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAccountScreen(accountToEdit: accountToEdit),
      ),
    );
  }

  void _showDeleteDialog(Account account) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete ${account.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (account.id != null) {
                context.read<AccountsProvider>().deleteAccount(account.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${account.name} deleted'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor =
        color ?? (isDark ? const Color(0xFF64B5F6) : AppTheme.primaryBlue);
    final disabledColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onPressed != null ? activeColor : disabledColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: onPressed != null ? activeColor : disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatchTagDialog() {
    if (_selectedAccountIds.isEmpty) return;
    final TextEditingController tagController = TextEditingController();
    bool isReplace = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setDialogState) => AlertDialog(
          title: Text('Reassign Tags (${_selectedAccountIds.length})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter tags separated by commas (e.g. Work, VIP):',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Work, Personal',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isReplace,
                    onChanged: (val) {
                      setDialogState(() => isReplace = val ?? false);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setDialogState(() => isReplace = !isReplace);
                      },
                      child: const Text(
                        'Replace existing tags (instead of appending)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final rawInput = tagController.text.trim();
                if (rawInput.isEmpty) return;
                final tags = rawInput
                    .split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();
                if (tags.isEmpty) return;

                Navigator.pop(dialogContext);
                final ids = _selectedAccountIds.toList();
                await context.read<AccountsProvider>().bulkUpdateTags(
                  ids,
                  tags,
                  replace: isReplace,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated tags for ${ids.length} accounts'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  _exitSelectionMode();
                }
              },
              child: const Text('Apply Tags'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatchExportDialog() {
    if (_selectedAccountIds.isEmpty) return;
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setDialogState) => AlertDialog(
          title: Text('Export Selected (${_selectedAccountIds.length})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Set a password to encrypt this backup file.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setDialogState(
                      () => isPasswordVisible = !isPasswordVisible,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: !isPasswordVisible,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = passwordController.text;
                final confirm = confirmPasswordController.text;

                if (password.length < 6) {
                  ScaffoldMessenger.of(statefulContext).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (password != confirm) {
                  ScaffoldMessenger.of(statefulContext).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                final provider = context.read<AccountsProvider>();
                final selectedAccounts = provider.accounts
                    .where(
                      (a) => a.id != null && _selectedAccountIds.contains(a.id),
                    )
                    .toList();

                final service = ExportImportService();
                final success = await service.exportAccountsEncrypted(
                  selectedAccounts,
                  password,
                );

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Exported ${selectedAccounts.length} selected accounts',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    _exitSelectionMode();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to export selected accounts'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatchDeleteDialog() {
    if (_selectedAccountIds.isEmpty) return;
    final count = _selectedAccountIds.length;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Selected Accounts'),
        content: Text(
          'Are you sure you want to delete $count accounts? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final ids = _selectedAccountIds.toList();

              final verified = await _verifyBiometricOrPinForBulkDelete();
              if (!verified) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Authentication failed. Deletion canceled.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              if (mounted) {
                await context.read<AccountsProvider>().deleteMultipleAccounts(
                  ids,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count accounts deleted'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                _exitSelectionMode();
              }
            },
            child: Text('Delete ($count)'),
          ),
        ],
      ),
    );
  }

  Future<bool> _verifyBiometricOrPinForBulkDelete() async {
    final authService = AuthService();
    final isBioAvailable = await authService.isBiometricAvailable();
    if (isBioAvailable) {
      final bioResult = await authService.authenticateWithBiometric();
      if (bioResult.isSuccess) return true;
      if (bioResult.outcome == LocalAuthOutcome.canceled) return false;
    }

    if (!mounted) return false;
    final settingsProvider = context.read<SettingsProvider>();
    if (settingsProvider.isAppLockEnabled) {
      return await showPinVerificationDialog(
        context: context,
        purpose: 'delete selected accounts',
        settingsProvider: settingsProvider,
        authService: authService,
      );
    }

    final phoneResult = await authService.authenticateWithPhoneLock();
    if (phoneResult.isSuccess) return true;

    return true;
  }
}
