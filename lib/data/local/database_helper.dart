import 'package:flutter/material.dart';
import 'package:nudget/core/utils/logger.dart';
import 'package:nudget/data/migrations/schema_v1.dart';
import 'package:nudget/data/migrations/schema_v2.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Singleton that owns the SQLite [Database] lifecycle.
///
/// Usage:
/// ```dart
/// final db = await DatabaseHelper.instance.database;
/// ```
///
/// For tests, construct a [DatabaseHelper.forTesting] instance backed by an
/// in-memory database so the singleton is not polluted.
class DatabaseHelper {
  DatabaseHelper._({String? overridePath}) : _overridePath = overridePath;

  /// Application-wide singleton backed by the on-device SQLite file.
  static final DatabaseHelper instance = DatabaseHelper._();

  /// Creates an isolated [DatabaseHelper] pointing at [path].
  ///
  /// Pass [inMemoryDatabasePath] from `sqflite_common_ffi` for unit tests.
  factory DatabaseHelper.forTesting(String path) =>
      DatabaseHelper._(overridePath: path);

  static const Logger _log = Logger('DatabaseHelper');
  static const Uuid _uuid = Uuid();

  final String? _overridePath;
  Database? _db;

  /// Returns the open [Database], initializing it on first access.
  Future<Database> get database async {
    return _db ??= await _initDatabase();
  }

  /// Closes and nulls the database reference. Primarily for test teardown.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<Database> _initDatabase() async {
    final path = _overridePath ?? join(await getDatabasesPath(), 'nudget.db');
    _log.info('Opening database at $path');

    return openDatabase(
      path,
      version: SchemaV2.version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Enables foreign key enforcement, which SQLite disables by default.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Runs on first launch: creates all tables, indexes, and seed data.
  Future<void> _onCreate(Database db, int version) async {
    _log.info('Creating schema v$version');

    await db.execute(SchemaV1.createCategoriesTable);
    await db.execute(SchemaV1.createExpensesTable);
    await db.execute(SchemaV1.createClassificationRulesTable);
    await db.execute(SchemaV1.createExpensesCategoryIndex);
    await db.execute(SchemaV1.createExpensesDateIndex);
    await db.execute(SchemaV1.createRulesMatchCountIndex);
    await db.execute(SchemaV2.createNotificationSourcesTable);

    await _insertSeedCategories(db);
  }

  /// Called when [SchemaV1.version] increases. Add ALTER TABLE statements here
  /// for each version bump; never mutate existing case blocks.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _log.info('Upgrading schema from v$oldVersion to v$newVersion');
    if (oldVersion < 2) {
      await db.execute(SchemaV2.createNotificationSourcesTable);
    }
  }

  /// Inserts the five built-in categories on first launch.
  ///
  /// Detection is implicit: this method is only called from [_onCreate], which
  /// SQLite fires only when the database file does not yet exist.
  Future<void> _insertSeedCategories(Database db) async {
    _log.info('Inserting seed categories');
    final now = DateTime.now().toUtc().toIso8601String();

    final seeds = <Map<String, dynamic>>[
      {
        'id': _uuid.v4(),
        'name': 'Groceries',
        'icon': 'shopping_cart',
        'color': const Color(0xFF4CAF50).toARGB32(),
        'spending_limit': null,
        'created_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Transport',
        'icon': 'directions_car',
        'color': const Color(0xFF2196F3).toARGB32(),
        'spending_limit': null,
        'created_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Leisure',
        'icon': 'sports_esports',
        'color': const Color(0xFF9C27B0).toARGB32(),
        'spending_limit': null,
        'created_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Health',
        'icon': 'local_hospital',
        'color': const Color(0xFFF44336).toARGB32(),
        'spending_limit': null,
        'created_at': now,
      },
      {
        'id': _uuid.v4(),
        'name': 'Home',
        'icon': 'home',
        'color': const Color(0xFFFF9800).toARGB32(),
        'spending_limit': null,
        'created_at': now,
      },
    ];

    final batch = db.batch();
    for (final row in seeds) {
      batch.insert('categories', row);
    }
    await batch.commit(noResult: true);
  }
}
