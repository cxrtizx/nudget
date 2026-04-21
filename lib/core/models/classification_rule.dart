import 'package:freezed_annotation/freezed_annotation.dart';

part 'classification_rule.freezed.dart';

/// A rule that automatically assigns a [Category] to an [Expense] whose
/// description matches [pattern].
///
/// Patterns are stored as plain strings and compiled to [RegExp] at runtime
/// by [ClassificationService] to avoid storing non-serializable objects.
@Freezed(equal: false)
class ClassificationRule with _$ClassificationRule {
  /// Private constructor enabling custom method definitions on the frozen class.
  const ClassificationRule._();

  /// Creates a [ClassificationRule].
  const factory ClassificationRule({
    /// Unique identifier (UUID v4).
    required String id,

    /// Plain-string regex pattern compiled case-insensitively at runtime.
    required String pattern,

    /// Foreign key referencing the [Category] to assign on match.
    required String categoryId,

    /// Timestamp of creation (UTC).
    required DateTime createdAt,

    /// Number of times this rule has successfully matched an expense.
    /// Used to sort rules so the most relevant ones are tested first.
    required int matchCount,
  }) = _ClassificationRule;

  /// Deserializes a [ClassificationRule] from a SQLite row [map].
  factory ClassificationRule.fromMap(Map<String, dynamic> map) =>
      ClassificationRule(
        id: map['id'] as String,
        pattern: map['pattern'] as String,
        categoryId: map['category_id'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        matchCount: map['match_count'] as int,
      );

  /// Serializes this [ClassificationRule] to a SQLite row map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'pattern': pattern,
        'category_id': categoryId,
        'created_at': createdAt.toIso8601String(),
        'match_count': matchCount,
      };

  /// Equality is determined solely by [id].
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  @override
  bool operator ==(Object other) =>
      other is ClassificationRule && other.id == id;

  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ClassificationRule(id: $id, pattern: $pattern, '
      'categoryId: $categoryId, matchCount: $matchCount)';
}
