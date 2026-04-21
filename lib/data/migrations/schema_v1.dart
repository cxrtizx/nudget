/// DDL statements for schema version 1.
///
/// Executed once during database creation via [DatabaseHelper._onCreate].
/// Foreign key constraints are declared but enforcement requires
/// `PRAGMA foreign_keys = ON` (set in [DatabaseHelper._onConfigure]).
abstract class SchemaV1 {
  SchemaV1._();

  /// Current schema version. Increment when adding a migration.
  static const int version = 1;

  /// Categories table DDL.
  static const String createCategoriesTable = '''
    CREATE TABLE categories (
      id                TEXT PRIMARY KEY,
      name              TEXT NOT NULL,
      icon              TEXT NOT NULL,
      color             INTEGER NOT NULL,
      spending_limit    REAL,
      created_at        TEXT NOT NULL
    )
  ''';

  /// Expenses table DDL.
  static const String createExpensesTable = '''
    CREATE TABLE expenses (
      id                      TEXT PRIMARY KEY,
      amount                  REAL NOT NULL,
      description             TEXT NOT NULL,
      category_id             TEXT,
      date                    TEXT NOT NULL,
      notification_source     TEXT NOT NULL,
      auto_classified         INTEGER NOT NULL DEFAULT 0,
      raw_notification_text   TEXT NOT NULL,
      created_at              TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
    )
  ''';

  /// Classification rules table DDL.
  static const String createClassificationRulesTable = '''
    CREATE TABLE classification_rules (
      id            TEXT PRIMARY KEY,
      pattern       TEXT NOT NULL,
      category_id   TEXT NOT NULL,
      created_at    TEXT NOT NULL,
      match_count   INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
    )
  ''';

  /// Index to speed up unclassified expense queries used by the pending screen.
  static const String createExpensesCategoryIndex = '''
    CREATE INDEX idx_expenses_category_id ON expenses (category_id)
  ''';

  /// Index to speed up date-range queries used by the dashboard and statistics.
  static const String createExpensesDateIndex = '''
    CREATE INDEX idx_expenses_date ON expenses (date)
  ''';

  /// Index to speed up rule lookups sorted by relevance.
  static const String createRulesMatchCountIndex = '''
    CREATE INDEX idx_rules_match_count ON classification_rules (match_count DESC)
  ''';
}
