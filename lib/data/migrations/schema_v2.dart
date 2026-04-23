/// DDL statements for schema version 2.
///
/// Executed during [DatabaseHelper._onUpgrade] when upgrading from v1,
/// and also during [DatabaseHelper._onCreate] for fresh installs.
abstract class SchemaV2 {
  SchemaV2._();

  /// Schema version introduced by this migration.
  static const int version = 2;

  /// Notification sources table DDL.
  ///
  /// Each row represents a user-configured app whose notifications should be
  /// parsed as expenses. The [pattern] field stores a user-friendly template
  /// with `{importe}` and `{concepto}` placeholders that the app converts to
  /// a named-group regex at runtime.
  static const String createNotificationSourcesTable = '''
    CREATE TABLE notification_sources (
      id          TEXT PRIMARY KEY,
      app_name    TEXT NOT NULL,
      pattern     TEXT NOT NULL,
      is_enabled  INTEGER NOT NULL DEFAULT 1,
      created_at  TEXT NOT NULL
    )
  ''';
}
