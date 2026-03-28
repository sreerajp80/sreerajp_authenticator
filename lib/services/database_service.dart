//File Path: sreerajp_authenticator/lib/services/database_service.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 October 01
// Description: This file contains the DatabaseService class which handles all database operations using sqflite.

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/account.dart';
import '../models/group.dart';
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        color TEXT NOT NULL,
        icon TEXT,
        sortOrder INTEGER DEFAULT 0,
        createdAt INTEGER
      )
    ''');

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
        createdAt TEXT NOT NULL,
        sortOrder INTEGER DEFAULT 0,
        FOREIGN KEY (groupId) REFERENCES groups (id) ON DELETE SET NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add icon and createdAt columns to groups table
      await db.execute('ALTER TABLE groups ADD COLUMN icon TEXT');
      await db.execute('ALTER TABLE groups ADD COLUMN createdAt INTEGER');
    }
  }

  // Account CRUD operations
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

  // Group CRUD operations
  Future<int> createGroup(Group group) async {
    final db = await database;
    return await db.insert('groups', group.toMap());
  }

  Future<List<Group>> getAllGroups() async {
    final db = await database;
    final result = await db.query('groups', orderBy: 'sortOrder, name');
    return result.map((json) => Group.fromMap(json)).toList();
  }

  Future<int> updateGroup(Group group) async {
    final db = await database;
    return await db.update(
      'groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteGroup(int id) async {
    final db = await database;
    return await db.delete('groups', where: 'id = ?', whereArgs: [id]);
  }
}
