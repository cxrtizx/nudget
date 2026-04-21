import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/repositories/i_category_repository.dart';
import 'package:nudget/core/utils/app_exception.dart';
import 'package:nudget/core/utils/logger.dart';
import 'package:nudget/data/local/database_helper.dart';

/// SQLite-backed implementation of [ICategoryRepository].
class SqliteCategoryRepository implements ICategoryRepository {
  /// Creates a [SqliteCategoryRepository] using [dbHelper] for all I/O.
  const SqliteCategoryRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;
  static const Logger _log = Logger('SqliteCategoryRepository');
  static const String _table = 'categories';

  @override
  Future<List<Category>> findAll() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(_table, orderBy: 'name ASC');
      return rows.map(Category.fromMap).toList();
    } catch (e, st) {
      _log.error('findAll failed', e, st);
      throw DatabaseException('Failed to fetch categories', cause: e);
    }
  }

  @override
  Future<Category?> findById(String id) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return Category.fromMap(rows.first);
    } catch (e, st) {
      _log.error('findById($id) failed', e, st);
      throw DatabaseException('Failed to fetch category $id', cause: e);
    }
  }

  @override
  Future<void> save(Category entity) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(_table, entity.toMap());
    } catch (e, st) {
      _log.error('save(${entity.id}) failed', e, st);
      throw DatabaseException('Failed to save category', cause: e);
    }
  }

  @override
  Future<void> update(Category entity) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        _table,
        entity.toMap(),
        where: 'id = ?',
        whereArgs: [entity.id],
      );
      if (count == 0) throw NotFoundException('Category', entity.id);
    } catch (NotFoundException) {
      rethrow;
    } catch (e, st) {
      _log.error('update(${entity.id}) failed', e, st);
      throw DatabaseException('Failed to update category', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    } catch (e, st) {
      _log.error('delete($id) failed', e, st);
      throw DatabaseException('Failed to delete category $id', cause: e);
    }
  }
}
