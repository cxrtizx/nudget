import 'package:nudget/core/models/classification_rule.dart';
import 'package:nudget/core/repositories/i_classification_rule_repository.dart';
import 'package:nudget/core/utils/app_exception.dart';
import 'package:nudget/core/utils/logger.dart';
import 'package:nudget/data/local/database_helper.dart';

/// SQLite-backed implementation of [IClassificationRuleRepository].
class SqliteClassificationRuleRepository
    implements IClassificationRuleRepository {
  /// Creates a [SqliteClassificationRuleRepository] using [dbHelper] for all I/O.
  const SqliteClassificationRuleRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;
  static const Logger _log = Logger('SqliteClassificationRuleRepository');
  static const String _table = 'classification_rules';

  @override
  Future<List<ClassificationRule>> findAll() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(_table, orderBy: 'match_count DESC');
      return rows.map(ClassificationRule.fromMap).toList();
    } catch (e, st) {
      _log.error('findAll failed', e, st);
      throw DatabaseException('Failed to fetch classification rules', cause: e);
    }
  }

  @override
  Future<ClassificationRule?> findById(String id) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return ClassificationRule.fromMap(rows.first);
    } catch (e, st) {
      _log.error('findById($id) failed', e, st);
      throw DatabaseException('Failed to fetch rule $id', cause: e);
    }
  }

  @override
  Future<void> save(ClassificationRule entity) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(_table, entity.toMap());
    } catch (e, st) {
      _log.error('save(${entity.id}) failed', e, st);
      throw DatabaseException('Failed to save classification rule', cause: e);
    }
  }

  @override
  Future<void> update(ClassificationRule entity) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        _table,
        entity.toMap(),
        where: 'id = ?',
        whereArgs: [entity.id],
      );
      if (count == 0) throw NotFoundException('ClassificationRule', entity.id);
    } catch (NotFoundException) {
      rethrow;
    } catch (e, st) {
      _log.error('update(${entity.id}) failed', e, st);
      throw DatabaseException('Failed to update classification rule', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    } catch (e, st) {
      _log.error('delete($id) failed', e, st);
      throw DatabaseException(
        'Failed to delete classification rule $id',
        cause: e,
      );
    }
  }

  @override
  Future<void> incrementMatchCount(String ruleId) async {
    try {
      final db = await _dbHelper.database;
      await db.rawUpdate(
        'UPDATE $_table SET match_count = match_count + 1 WHERE id = ?',
        [ruleId],
      );
    } catch (e, st) {
      _log.error('incrementMatchCount($ruleId) failed', e, st);
      throw DatabaseException('Failed to increment match count', cause: e);
    }
  }
}
