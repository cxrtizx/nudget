import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudget/core/models/category.dart';

void main() {
  group('Category', () {
    final createdAt = DateTime(2024, 1, 15, 10, 30);
    final category = Category(
      id: 'test-id-1',
      name: 'Groceries',
      icon: 'shopping_cart',
      color: const Color(0xFF4CAF50),
      spendingLimit: 300.0,
      createdAt: createdAt,
    );

    group('toMap / fromMap', () {
      test('round-trips all fields correctly', () {
        final map = category.toMap();
        final restored = Category.fromMap(map);

        expect(restored.id, category.id);
        expect(restored.name, category.name);
        expect(restored.icon, category.icon);
        expect(restored.color.toARGB32(), category.color.toARGB32());
        expect(restored.spendingLimit, category.spendingLimit);
        expect(restored.createdAt.toIso8601String(),
            category.createdAt.toIso8601String());
      });

      test('serializes color as integer', () {
        final map = category.toMap();
        expect(map['color'], isA<int>());
        expect(map['color'], const Color(0xFF4CAF50).toARGB32());
      });

      test('null spendingLimit round-trips as null', () {
        final noLimit = category.copyWith(spendingLimit: null);
        final map = noLimit.toMap();
        expect(map['spending_limit'], isNull);
        final restored = Category.fromMap(map);
        expect(restored.spendingLimit, isNull);
      });
    });

    group('equality', () {
      test('two instances with the same id are equal', () {
        final other = category.copyWith(name: 'Changed Name');
        expect(category, equals(other));
      });

      test('two instances with different ids are not equal', () {
        final other = category.copyWith(id: 'different-id');
        expect(category, isNot(equals(other)));
      });

      test('hashCode is consistent with equality', () {
        final other = category.copyWith(name: 'Changed');
        expect(category.hashCode, equals(other.hashCode));
      });
    });

    group('copyWith', () {
      test('updates only the specified field', () {
        final updated = category.copyWith(name: 'Transport');
        expect(updated.name, 'Transport');
        expect(updated.id, category.id);
        expect(updated.icon, category.icon);
      });
    });

    group('toString', () {
      test('contains id and name', () {
        final s = category.toString();
        expect(s, contains('test-id-1'));
        expect(s, contains('Groceries'));
      });
    });
  });
}
