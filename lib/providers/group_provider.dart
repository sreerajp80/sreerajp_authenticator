// File Path: sreerajp_authenticator/lib/providers/group_provider.dart
// Description: Provider for managing account groups

import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../models/account.dart';
import '../services/database_service.dart';
import '../utils/app_logger.dart';

class GroupsProvider extends ChangeNotifier {
  List<Group> _groups = [];
  final DatabaseService _db = DatabaseService.instance;

  List<Group> get groups => _groups;

  GroupsProvider() {
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      _groups = await _db.getAllGroups();
      _groups.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load groups', e);
    }
  }

  Future<void> addGroup(Group group) async {
    try {
      final newGroup = Group(
        id: group.id,
        name: group.name,
        description: group.description,
        color: group.color,
        sortOrder: group.sortOrder,
      );

      await _db.createGroup(newGroup);
      await loadGroups();
    } catch (e) {
      AppLogger.error('Failed to add group', e);
      rethrow;
    }
  }

  Future<void> updateGroup(Group group) async {
    try {
      await _db.updateGroup(group);
      await loadGroups();
    } catch (e) {
      AppLogger.error('Failed to update group', e);
      rethrow;
    }
  }

  Future<void> deleteGroup(int id, {VoidCallback? onAccountsUnassigned}) async {
    try {
      final accountsInGroup = await _db.getAllAccounts();
      for (final account in accountsInGroup.where((a) => a.groupId == id)) {
        await _db.updateAccount(
          Account(
            id: account.id,
            name: account.name,
            secret: account.secret,
            issuer: account.issuer,
            description: account.description,
            type: account.type,
            counter: account.counter,
            digits: account.digits,
            period: account.period,
            algorithm: account.algorithm,
            groupId: null,
            createdAt: account.createdAt,
            sortOrder: account.sortOrder,
          ),
        );
      }

      await _db.deleteGroup(id);
      await loadGroups();

      onAccountsUnassigned?.call();
    } catch (e) {
      AppLogger.error('Failed to delete group', e);
      rethrow;
    }
  }

  void reorderGroups(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Group item = _groups.removeAt(oldIndex);
    _groups.insert(newIndex, item);
    notifyListeners();
    _saveGroupOrder();
  }

  Future<void> _saveGroupOrder() async {
    for (int i = 0; i < _groups.length; i++) {
      final group = _groups[i];
      final updatedGroup = Group(
        id: group.id,
        name: group.name,
        description: group.description,
        color: group.color,
        sortOrder: i,
      );
      await _db.updateGroup(updatedGroup);
    }
  }
}
