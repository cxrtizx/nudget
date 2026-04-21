import 'package:flutter_test/flutter_test.dart';
import 'package:nudget/core/models/classification_rule.dart';
import 'package:nudget/data/local/database_helper.dart';
import 'package:nudget/data/local/sqlite_category_repository.dart';
import 'package:nudget/data/local/sqlite_classification_rule_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SqliteClassificationRuleRepository repo;
  late String seedCategoryId;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper.forTesting(inMemoryDatabasePath);
    repo = SqliteClassificationRuleRepository(dbHelper);
    await dbHelper.database;

    // Grab a real seed category id to satisfy the FK constraint.
    final catRepo = SqliteCategoryRepository(dbHelper);
    final cats = await catRepo.findAll();
    seedCategoryId = cats.first.id;
  });

  tearDown(() => dbHelper.close());

  ClassificationRule makeRule({
    String id = 'rule-1',
    String pattern = 'mercadona',
    int matchCount = 0,
  }) =>
      ClassificationRule(
        id: id,
        pattern: pattern,
        categoryId: seedCategoryId,
        createdAt: DateTime(2024),
        matchCount: matchCount,
      );

  group('save / findById', () {
    test('persists and retrieves a rule', () async {
      final rule = makeRule();
      await repo.save(rule);
      final found = await repo.findById(rule.id);
      expect(found, isNotNull);
      expect(found!.pattern, 'mercadona');
    });

    test('findById returns null for unknown id', () async {
      expect(await repo.findById('nope'), isNull);
    });
  });

  group('findAll', () {
    test('returns rules ordered by matchCount descending', () async {
      await repo.save(makeRule(id: 'low', pattern: 'carrefour', matchCount: 2));
      await repo.save(makeRule(id: 'high', pattern: 'mercadona', matchCount: 10));
      final all = await repo.findAll();
      expect(all.first.id, 'high');
    });
  });

  group('incrementMatchCount', () {
    test('increments counter by 1 each call', () async {
      final rule = makeRule(matchCount: 0);
      await repo.save(rule);
      await repo.incrementMatchCount(rule.id);
      await repo.incrementMatchCount(rule.id);
      final found = await repo.findById(rule.id);
      expect(found!.matchCount, 2);
    });
  });

  group('delete', () {
    test('removes the rule', () async {
      final rule = makeRule();
      await repo.save(rule);
      await repo.delete(rule.id);
      expect(await repo.findById(rule.id), isNull);
    });
  });
}
