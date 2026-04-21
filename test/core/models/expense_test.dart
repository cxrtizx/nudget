import 'package:flutter_test/flutter_test.dart';
import 'package:nudget/core/models/expense.dart';

void main() {
  group('Expense', () {
    final date = DateTime(2024, 3, 10, 14, 0);
    final createdAt = DateTime(2024, 3, 10, 14, 5);
    final expense = Expense(
      id: 'exp-id-1',
      amount: 42.50,
      description: 'Mercadona',
      categoryId: 'cat-id-1',
      date: date,
      notificationSource: 'es.lacaixa.mobile.android',
      autoClassified: true,
      rawNotificationText: 'Pago de 42,50€ en Mercadona',
      createdAt: createdAt,
    );

    group('toMap / fromMap', () {
      test('round-trips all fields correctly', () {
        final map = expense.toMap();
        final restored = Expense.fromMap(map);

        expect(restored.id, expense.id);
        expect(restored.amount, expense.amount);
        expect(restored.description, expense.description);
        expect(restored.categoryId, expense.categoryId);
        expect(restored.date.toIso8601String(), expense.date.toIso8601String());
        expect(restored.notificationSource, expense.notificationSource);
        expect(restored.autoClassified, expense.autoClassified);
        expect(restored.rawNotificationText, expense.rawNotificationText);
        expect(restored.createdAt.toIso8601String(),
            expense.createdAt.toIso8601String());
      });

      test('serializes autoClassified as 1 when true', () {
        expect(expense.toMap()['auto_classified'], 1);
      });

      test('serializes autoClassified as 0 when false', () {
        final manual = expense.copyWith(autoClassified: false);
        expect(manual.toMap()['auto_classified'], 0);
      });

      test('null categoryId round-trips as null', () {
        final unclassified = expense.copyWith(categoryId: null);
        final map = unclassified.toMap();
        expect(map['category_id'], isNull);
        final restored = Expense.fromMap(map);
        expect(restored.categoryId, isNull);
      });
    });

    group('equality', () {
      test('same id → equal regardless of other fields', () {
        final other = expense.copyWith(amount: 99.99, description: 'Other');
        expect(expense, equals(other));
      });

      test('different id → not equal', () {
        final other = expense.copyWith(id: 'different');
        expect(expense, isNot(equals(other)));
      });
    });

    group('copyWith', () {
      test('assigns categoryId', () {
        final updated = expense.copyWith(categoryId: 'new-cat');
        expect(updated.categoryId, 'new-cat');
        expect(updated.id, expense.id);
      });
    });
  });
}
