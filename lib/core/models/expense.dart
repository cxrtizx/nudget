import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';

/// A single monetary transaction captured from a payment notification
/// or entered manually by the user.
@Freezed(equal: false)
class Expense with _$Expense {
  /// Private constructor enabling custom method definitions on the frozen class.
  const Expense._();

  /// Creates an [Expense].
  const factory Expense({
    /// Unique identifier (UUID v4).
    required String id,

    /// Transaction amount in euros (always positive).
    required double amount,

    /// Human-readable description — merchant name when parsed from a notification,
    /// or free text when entered manually.
    required String description,

    /// Foreign key referencing the assigned [Category]. `null` when the expense
    /// has not yet been classified.
    String? categoryId,

    /// Date the transaction occurred (may differ from [createdAt] when backdated).
    required DateTime date,

    /// Package name or label of the app that emitted the source notification
    /// (e.g. `'es.lacaixa.mobile.android'`). Set to `'manual'` for manual entries.
    required String notificationSource,

    /// `true` when a [ClassificationRule] matched this expense automatically.
    required bool autoClassified,

    /// Verbatim notification body kept for auditing and rule debugging.
    required String rawNotificationText,

    /// Timestamp of record creation in the local database (UTC).
    required DateTime createdAt,
  }) = _Expense;

  /// Deserializes an [Expense] from a SQLite row [map].
  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as String,
        amount: map['amount'] as double,
        description: map['description'] as String,
        categoryId: map['category_id'] as String?,
        date: DateTime.parse(map['date'] as String),
        notificationSource: map['notification_source'] as String,
        autoClassified: (map['auto_classified'] as int) == 1,
        rawNotificationText: map['raw_notification_text'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  /// Serializes this [Expense] to a SQLite row map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'description': description,
        'category_id': categoryId,
        'date': date.toIso8601String(),
        'notification_source': notificationSource,
        'auto_classified': autoClassified ? 1 : 0,
        'raw_notification_text': rawNotificationText,
        'created_at': createdAt.toIso8601String(),
      };

  /// Equality is determined solely by [id].
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  @override
  bool operator ==(Object other) => other is Expense && other.id == id;

  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Expense(id: $id, amount: $amount, description: $description, '
      'categoryId: $categoryId, date: $date, '
      'autoClassified: $autoClassified, source: $notificationSource)';
}
