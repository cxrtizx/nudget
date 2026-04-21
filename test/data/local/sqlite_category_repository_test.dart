import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/utils/app_exception.dart';
import 'package:nudget/data/local/database_helper.dart';
import 'package:nudget/data/local/sqlite_category_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SqliteCategoryRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper.forTesting(inMemoryDatabasePath);
    repo = SqliteCategoryRepository(dbHelper);
    // Warm up the database (runs onCreate with seed data).
    await dbHelper.database;
  });

  tearDown(() => dbHelper.close());

  Category makeCategory({String id = 'cat-1', String name = 'Test'}) =>
      Category(
        id: id,
        name: name,
        icon: 'home',
        color: const Color(0xFF4CAF50),
        createdAt: DateTime(2024),
      );

  group('findAll', () {
    test('returns seed categories on first launch', () async {
      final all = await repo.findAll();
      expect(all.length, 5);
    });

    test('is sorted by name ascending', () async {
      final all = await repo.findAll();
      final names = all.map((c) => c.name).toList();
      expect(names, equals([...names]..sort()));
    });
  });

  group('save / findById', () {
    test('persists a new category and retrieves it by id', () async {
      final cat = makeCategory();
      await repo.save(cat);
      final found = await repo.findById(cat.id);
      expect(found, isNotNull);
      expect(found!.name, cat.name);
    });

    test('findById returns null for unknown id', () async {
      final found = await repo.findById('does-not-exist');
      expect(found, isNull);
    });
  });

  group('update', () {
    test('persists field changes', () async {
      final cat = makeCategory();
      await repo.save(cat);
      final updated = cat.copyWith(name: 'Updated');
      await repo.update(updated);
      final found = await repo.findById(cat.id);
      expect(found!.name, 'Updated');
    });

    test('throws NotFoundException for unknown id', () async {
      final cat = makeCategory(id: 'ghost');
      await expectLater(
        repo.update(cat),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('delete', () {
    test('removes the category', () async {
      final cat = makeCategory();
      await repo.save(cat);
      await repo.delete(cat.id);
      final found = await repo.findById(cat.id);
      expect(found, isNull);
    });

    test('no-op for unknown id', () async {
      await expectLater(repo.delete('ghost'), completes);
    });
  });
}
