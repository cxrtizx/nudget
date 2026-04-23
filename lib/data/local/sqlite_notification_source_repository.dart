import 'package:nudget/core/models/notification_source.dart';
import 'package:nudget/core/repositories/i_notification_source_repository.dart';
import 'package:nudget/core/utils/app_exception.dart';
import 'package:nudget/core/utils/logger.dart';
import 'package:nudget/data/local/database_helper.dart';

/// SQLite-backed implementation of [INotificationSourceRepository].
class SqliteNotificationSourceRepository
    implements INotificationSourceRepository {
  /// Creates a [SqliteNotificationSourceRepository] using [dbHelper].
  const SqliteNotificationSourceRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;
  static const Logger _log = Logger('SqliteNotificationSourceRepository');
  static const String _table = 'notification_sources';

  @override
  Future<List<NotificationSource>> findAll() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(_table, orderBy: 'created_at ASC');
      return rows.map(NotificationSource.fromMap).toList();
    } catch (e, st) {
      _log.error('findAll failed', e, st);
      throw DatabaseException('Failed to fetch notification sources', cause: e);
    }
  }

  @override
  Future<List<NotificationSource>> findEnabled() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: 'is_enabled = 1',
        orderBy: 'created_at ASC',
      );
      return rows.map(NotificationSource.fromMap).toList();
    } catch (e, st) {
      _log.error('findEnabled failed', e, st);
      throw DatabaseException(
        'Failed to fetch enabled notification sources',
        cause: e,
      );
    }
  }

  @override
  Future<NotificationSource?> findById(String id) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        _table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return NotificationSource.fromMap(rows.first);
    } catch (e, st) {
      _log.error('findById($id) failed', e, st);
      throw DatabaseException(
        'Failed to fetch notification source $id',
        cause: e,
      );
    }
  }

  @override
  Future<void> save(NotificationSource entity) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(_table, entity.toMap());
    } catch (e, st) {
      _log.error('save(${entity.id}) failed', e, st);
      throw DatabaseException(
        'Failed to save notification source',
        cause: e,
      );
    }
  }

  @override
  Future<void> update(NotificationSource entity) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        _table,
        entity.toMap(),
        where: 'id = ?',
        whereArgs: [entity.id],
      );
      if (count == 0) throw NotFoundException('NotificationSource', entity.id);
    } catch (NotFoundException) {
      rethrow;
    } catch (e, st) {
      _log.error('update(${entity.id}) failed', e, st);
      throw DatabaseException(
        'Failed to update notification source',
        cause: e,
      );
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
        'Failed to delete notification source $id',
        cause: e,
      );
    }
  }
}
