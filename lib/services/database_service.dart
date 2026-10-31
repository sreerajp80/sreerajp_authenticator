// File Path: sreerajp_authenticator/lib/services/database_service.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2026 August 01
// Description: Database service.

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
    );
  }

  /// Creates a fresh database schema.
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
        tags TEXT,
        createdAt TEXT NOT NULL,
        sortOrder INTEGER DEFAULT 0
      )
    ''');
  }

  /// Closes the database and removes its file. The next use creates a new,
  /// empty one.
  Future<void> deleteAllData() async {
    final path =
        testDbPath ?? join(await getDatabasesPath(), AppConstants.databaseName);
    await _database?.close();
    _database = null;
    await deleteDatabase(path);
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

  /// Move an HOTP counter from [expected] to [next]. Returns the rows changed:
  /// 0 means the counter had already moved, or this is not an HOTP account.
  Future<int> setHotpCounter(int id, int expected, int next) async {
    final db = await database;
    return await db.rawUpdate(
      "UPDATE accounts SET counter = ? "
      "WHERE id = ? AND COALESCE(counter, 0) = ? AND LOWER(type) = 'hotp'",
      [next, id, expected],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
