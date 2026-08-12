// File Path: sreerajp_authenticator/lib/services/database_service.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2026 August 01
// Description: Database service. Schema v4 drops the groups table after
// migrating group names to account tags.

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/account.dart';
import '../utils/constants.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  @visibleForTesting
  static String? testDbPath;

  @visibleForTesting
  static Future<void> resetForTesting() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = testDbPath ?? join(await getDatabasesPath(), filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates a fresh database schema (no groups table; groupId kept as a dead
  /// column for forward-compatibility with old backup imports).
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        secret TEXT NOT NULL,
        issuer TEXT,
        description TEXT,
        type TEXT NOT NULL,
        counter INTEGER,
        digits INTEGER NOT NULL,
        period INTEGER NOT NULL,
        algorithm TEXT NOT NULL,
        groupId INTEGER,
        tags TEXT,
        createdAt TEXT NOT NULL,
        sortOrder INTEGER DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE groups ADD COLUMN icon TEXT');
      await db.execute('ALTER TABLE groups ADD COLUMN createdAt INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE accounts ADD COLUMN tags TEXT');
    }
    if (oldVersion < 4) {
      await _migrateGroupsToTags(db);
    }
  }

  /// Schema v4: migrate each account's group membership into its tags list,
  /// then drop the groups table.
  Future<void> _migrateGroupsToTags(Database db) async {
    // Check if the groups table still exists (it may not on a fresh install).
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='groups'",
    );
    if (tables.isEmpty) return;

    // Read all groups.
    final groups = await db.query('groups', columns: ['id', 'name']);
    for (final group in groups) {
      final groupId = group['id'] as int;
      final groupName = (group['name'] as String).trim();
      if (groupName.isEmpty) continue;

      // Read accounts in this group.
      final accounts = await db.query(
        'accounts',
        columns: ['id', 'tags'],
        where: 'groupId = ?',
        whereArgs: [groupId],
      );

      for (final account in accounts) {
        final accountId = account['id'] as int;
        final existingTags = account['tags'] as String? ?? '';

        // Build the updated tag list, avoiding duplicates.
        final tagList = existingTags
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        if (!tagList.any((t) => t.toLowerCase() == groupName.toLowerCase())) {
          tagList.add(groupName);
        }

        await db.update(
          'accounts',
          {'tags': tagList.join(',')},
          where: 'id = ?',
          whereArgs: [accountId],
        );
      }
    }

    // Drop the groups table — it is no longer needed.
    await db.execute('DROP TABLE IF EXISTS groups');
  }

  // ── Account CRUD ──────────────────────────────────────────────────────────

  Future<int> createAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    final result = await db.query('accounts', orderBy: 'sortOrder, createdAt');
    return result.map((json) => Account.fromMap(json)).toList();
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
