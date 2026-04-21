import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/repositories/i_expense_repository.dart';
import 'package:nudget/core/utils/app_exception.dart';
import 'package:nudget/core/utils/logger.dart';
import 'package:nudget/data/local/database_helper.dart';

/// SQLite-backed implementation of [IExpenseRepository].
class SqliteExpenseRepository implements IExpenseRepository {
  /// Creates a [SqliteExpenseRepository] using [dbHelper] for all I/O.
  const SqliteExpenseRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;
  static const Logger _log = Logger('SqliteExpenseRepository');
  static const String _table = 'expenses';

  @override
  Future<List<Expense>> findAll() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(_table, orderBy: 'date DESC');
      return rows.map(Expense.fromMap).toList();
    } catch (e, st) {
      _log.error('findAll failed', e, st);
      throw DatabaseException('Failed to fetch expenses', cause: e);
    }
  }

  @override
  Future<Expense?> findById(String id) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return Expense.fromMap(rows.first);
    } catch (e, st) {
      _log.error('findById($id) failed', e, st);
      throw DatabaseException('Failed to fetch expense $id', cause: e);
    }
  }

  @override
  Future<void> save(Expense entity) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(_table, entity.toMap());
    } catch (e, st) {
      _log.error('save(${entity.id}) failed', e, st);
      throw DatabaseException('Failed to save expense', cause: e);
    }
  }

  @override
  Future<void> update(Expense entity) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        _table,
        entity.toMap(),
        where: 'id = ?',
        whereArgs: [entity.id],
      );
      if (count == 0) throw NotFoundException('Expense', entity.id);
    } catch (NotFoundException) {
      rethrow;
    } catch (e, st) {
      _log.error('update(${entity.id}) failed', e, st);
      throw DatabaseException('Failed to update expense', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    } catch (e, st) {
      _log.error('delete($id) failed', e, st);
      throw DatabaseException('Failed to delete expense $id', cause: e);
    }
  }

  @override
  Future<List<Expense>> findByDateRange(DateTime from, DateTime to) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: 'date >= ? AND date <= ?',
        whereArgs: [from.toIso8601String(), to.toIso8601String()],
        orderBy: 'date DESC',
      );
      return rows.map(Expense.fromMap).toList();
    } catch (e, st) {
      _log.error('findByDateRange failed', e, st);
      throw DatabaseException('Failed to fetch expenses by date range', cause: e);
    }
  }

  @override
  Future<List<Expense>> findUnclassified() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: 'category_id IS NULL',
        orderBy: 'date DESC',
      );
      return rows.map(Expense.fromMap).toList();
    } catch (e, st) {
      _log.error('findUnclassified failed', e, st);
      throw DatabaseException('Failed to fetch unclassified expenses', cause: e);
    }
  }

  @override
  Future<List<Expense>> findByCategoryId(String categoryId) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'date DESC',
      );
      return rows.map(Expense.fromMap).toList();
    } catch (e, st) {
      _log.error('findByCategoryId($categoryId) failed', e, st);
      throw DatabaseException(
        'Failed to fetch expenses for category $categoryId',
        cause: e,
      );
    }
  }
}
