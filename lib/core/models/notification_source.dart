import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nudget/core/services/notification_parser.dart';

part 'notification_source.freezed.dart';

/// A user-configured app whose notifications are parsed as expenses.
///
/// The [pattern] field stores a human-readable template such as
/// `"Pago de {importe}€ en {concepto}"`. At runtime [toRegex] converts it to
/// a named-group regex; [parse] applies that regex to extract amount and
/// merchant from a raw notification body.
@Freezed(equal: false)
class NotificationSource with _$NotificationSource {
  const NotificationSource._();

  /// Creates a [NotificationSource].
  const factory NotificationSource({
    /// Unique identifier (UUID v4).
    required String id,

    /// Human-readable name of the source app (e.g. `'Google Pay'`).
    ///
    /// Also used as the matching key against [Expense.notificationSource]
    /// in the notification pipeline.
    required String appName,

    /// User-defined pattern with `{importe}` and `{concepto}` placeholders.
    required String pattern,

    /// Whether this source is currently active in the pipeline.
    required bool isEnabled,

    /// Timestamp of creation (UTC).
    required DateTime createdAt,
  }) = _NotificationSource;

  /// Deserializes a [NotificationSource] from a SQLite row [map].
  factory NotificationSource.fromMap(Map<String, dynamic> map) =>
      NotificationSource(
        id: map['id'] as String,
        appName: map['app_name'] as String,
        pattern: map['pattern'] as String,
        isEnabled: (map['is_enabled'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  /// Serializes this [NotificationSource] to a SQLite row map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'app_name': appName,
        'pattern': pattern,
        'is_enabled': isEnabled ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  /// Converts the user-defined [pattern] to a compiled [RegExp].
  ///
  /// Returns `null` if [pattern] does not contain the `{importe}` placeholder,
  /// since an amount is required for a valid expense record.
  ///
  /// Conversion rules:
  /// - `{importe}` → named group `(?<amount>\d+[,\.]\d{1,2})`
  /// - `{concepto}` → named group `(?<merchant>.+?)`
  /// - All other characters are regex-escaped so literal text matches exactly.
  RegExp? toRegex() {
    if (!pattern.contains('{importe}')) return null;

    // Split on the two known placeholders, keeping the delimiters.
    final parts = pattern.split(RegExp(r'\{importe\}|\{concepto\}'));
    final placeholders = RegExp(r'\{importe\}|\{concepto\}')
        .allMatches(pattern)
        .map((m) => m.group(0)!)
        .toList();

    final buffer = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      buffer.write(RegExp.escape(parts[i]));
      if (i < placeholders.length) {
        buffer.write(switch (placeholders[i]) {
          '{importe}' => r'(?<amount>\d+[,\.]\d{1,2})',
          '{concepto}' => r'(?<merchant>.+?)',
          _ => '',
        });
      }
    }

    return RegExp(buffer.toString(), caseSensitive: false);
  }

  /// Attempts to parse [text] using [toRegex].
  ///
  /// Returns `null` if [pattern] is invalid or [text] does not match.
  ParsedExpenseData? parse(String text, {required String source}) {
    final regex = toRegex();
    if (regex == null) return null;

    final match = regex.firstMatch(text);
    if (match == null) return null;

    final rawAmount = match.namedGroup('amount');
    if (rawAmount == null) return null;
    final amount = double.tryParse(rawAmount.replaceAll(',', '.'));
    if (amount == null) return null;

    final merchant =
        match.namedGroup('merchant')?.trim() ?? source;

    return ParsedExpenseData(
      amount: amount,
      description: merchant,
      source: source,
    );
  }

  /// Equality is determined solely by [id].
  @override
  bool operator ==(Object other) =>
      other is NotificationSource && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'NotificationSource(id: $id, appName: $appName, '
      'pattern: $pattern, isEnabled: $isEnabled)';
}
