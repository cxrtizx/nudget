import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// A spending category that groups related [Expense] entries.
///
/// [color] is stored as an integer hex value in the persistence layer
/// and reconstructed via [Color] on deserialization.
/// [icon] is stored as a Material icon name string (e.g. `'shopping_cart'`).
@Freezed(equal: false)
class Category with _$Category {
  /// Private constructor enabling custom method definitions on the frozen class.
  const Category._();

  /// Creates a [Category].
  const factory Category({
    /// Unique identifier (UUID v4).
    required String id,

    /// Human-readable display name.
    required String name,

    /// Material icon name key. Resolved to [IconData] via [CategoryIconMapper].
    required String icon,

    /// Display color. Persisted as [Color.value] (ARGB int).
    required Color color,

    /// Optional monthly spending cap in euros. `null` means no limit.
    double? spendingLimit,

    /// Timestamp of creation (UTC).
    required DateTime createdAt,
  }) = _Category;

  /// Deserializes a [Category] from a SQLite row [map].
  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        icon: map['icon'] as String,
        color: Color(map['color'] as int),
        spendingLimit: map['spending_limit'] as double?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  /// Serializes this [Category] to a SQLite row map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color.toARGB32(),
        'spending_limit': spendingLimit,
        'created_at': createdAt.toIso8601String(),
      };

  /// Equality is determined solely by [id] so that two instances representing
  /// the same category compare equal even if their fields differ (e.g. after
  /// an in-memory edit prior to persistence).
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Category(id: $id, name: $name, icon: $icon, '
      'color: 0x${color.toARGB32().toRadixString(16).padLeft(8, '0')}, '
      'spendingLimit: $spendingLimit, createdAt: $createdAt)';
}
