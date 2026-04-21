import 'package:flutter_test/flutter_test.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/utils/app_exception.dart';
import 'package:nudget/data/local/database_helper.dart';
import 'package:nudget/data/local/sqlite_expense_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SqliteExpenseRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper.forTesting(inMemoryDatabasePath);
    repo = SqliteExpenseRepository(dbHelper);
    await dbHelper.database;
  });

  tearDown(() => dbHelper.close());

  Expense makeExpense({
    String id = 'exp-1',
    DateTime? date,
    String? categoryId,
    bool autoClassified = false,
  }) =>
      Expense(
        id: id,
        amount: 25.0,
        description: 'Mercadona',
        categoryId: categoryId,
        date: date ?? DateTime(2024, 6, 15),
        notificationSource: 'es.lacaixa.mobile.android',
        autoClassified: autoClassified,
        rawNotificationText: 'Pago de 25,00€ en Mercadona',
        createdAt: DateTime(2024, 6, 15),
      );

  group('save / findById', () {
    test('persists and retrieves an expense', () async {
      final exp = makeExpense();
      await repo.save(exp);
      final found = await repo.findById(exp.id);
      expect(found, isNotNull);
      expect(found!.description, 'Mercadona');
    });

    test('findById returns null for unknown id', () async {
      expect(await repo.findById('nope'), isNull);
    });
  });

  group('findAll', () {
    test('returns expenses ordered by date descending', () async {
      await repo.save(makeExpense(id: 'a', date: DateTime(2024, 1)));
      await repo.save(makeExpense(id: 'b', date: DateTime(2024, 6)));
      final all = await repo.findAll();
      expect(all.first.id, 'b');
      expect(all.last.id, 'a');
    });
  });

  group('update', () {
    test('persists changes', () async {
      final exp = makeExpense();
      await repo.save(exp);
      await repo.update(exp.copyWith(amount: 99.0));
      final found = await repo.findById(exp.id);
      expect(found!.amount, 99.0);
    });

    test('throws NotFoundException for missing id', () async {
      await expectLater(
        repo.update(makeExpense(id: 'ghost')),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('delete', () {
    test('removes the expense', () async {
      final exp = makeExpense();
      await repo.save(exp);
      await repo.delete(exp.id);
      expect(await repo.findById(exp.id), isNull);
    });
  });

  group('findByDateRange', () {
    test('returns only expenses within the range', () async {
      await repo.save(makeExpense(id: 'jan', date: DateTime(2024, 1, 10)));
      await repo.save(makeExpense(id: 'mar', date: DateTime(2024, 3, 5)));
      await repo.save(makeExpense(id: 'dec', date: DateTime(2024, 12, 20)));

      final results = await repo.findByDateRange(
        DateTime(2024, 2),
        DateTime(2024, 11, 30),
      );
      expect(results.map((e) => e.id), contains('mar'));
      expect(results.map((e) => e.id), isNot(contains('jan')));
      expect(results.map((e) => e.id), isNot(contains('dec')));
    });
  });

  group('findUnclassified', () {
    test('returns only expenses with null categoryId', () async {
      await repo.save(makeExpense(id: 'u1', categoryId: null));
      await repo.save(makeExpense(id: 'c1', categoryId: 'some-cat'));
      final unclassified = await repo.findUnclassified();
      expect(unclassified.map((e) => e.id), contains('u1'));
      expect(unclassified.map((e) => e.id), isNot(contains('c1')));
    });
  });

  group('findByCategoryId', () {
    test('returns only expenses for the given category', () async {
      await repo.save(makeExpense(id: 'a', categoryId: 'cat-A'));
      await repo.save(makeExpense(id: 'b', categoryId: 'cat-B'));
      final results = await repo.findByCategoryId('cat-A');
      expect(results.length, 1);
      expect(results.first.id, 'a');
    });
  });
}
