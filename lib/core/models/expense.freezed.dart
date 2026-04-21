// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Expense {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Transaction amount in euros (always positive).
  double get amount => throw _privateConstructorUsedError;

  /// Human-readable description — merchant name when parsed from a notification,
  /// or free text when entered manually.
  String get description => throw _privateConstructorUsedError;

  /// Foreign key referencing the assigned [Category]. `null` when the expense
  /// has not yet been classified.
  String? get categoryId => throw _privateConstructorUsedError;

  /// Date the transaction occurred (may differ from [createdAt] when backdated).
  DateTime get date => throw _privateConstructorUsedError;

  /// Package name or label of the app that emitted the source notification
  /// (e.g. `'es.lacaixa.mobile.android'`). Set to `'manual'` for manual entries.
  String get notificationSource => throw _privateConstructorUsedError;

  /// `true` when a [ClassificationRule] matched this expense automatically.
  bool get autoClassified => throw _privateConstructorUsedError;

  /// Verbatim notification body kept for auditing and rule debugging.
  String get rawNotificationText => throw _privateConstructorUsedError;

  /// Timestamp of record creation in the local database (UTC).
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCopyWith<Expense> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCopyWith<$Res> {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) then) =
      _$ExpenseCopyWithImpl<$Res, Expense>;
  @useResult
  $Res call(
      {String id,
      double amount,
      String description,
      String? categoryId,
      DateTime date,
      String notificationSource,
      bool autoClassified,
      String rawNotificationText,
      DateTime createdAt});
}

/// @nodoc
class _$ExpenseCopyWithImpl<$Res, $Val extends Expense>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? description = null,
    Object? categoryId = freezed,
    Object? date = null,
    Object? notificationSource = null,
    Object? autoClassified = null,
    Object? rawNotificationText = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notificationSource: null == notificationSource
          ? _value.notificationSource
          : notificationSource // ignore: cast_nullable_to_non_nullable
              as String,
      autoClassified: null == autoClassified
          ? _value.autoClassified
          : autoClassified // ignore: cast_nullable_to_non_nullable
              as bool,
      rawNotificationText: null == rawNotificationText
          ? _value.rawNotificationText
          : rawNotificationText // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenseImplCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$$ExpenseImplCopyWith(
          _$ExpenseImpl value, $Res Function(_$ExpenseImpl) then) =
      __$$ExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double amount,
      String description,
      String? categoryId,
      DateTime date,
      String notificationSource,
      bool autoClassified,
      String rawNotificationText,
      DateTime createdAt});
}

/// @nodoc
class __$$ExpenseImplCopyWithImpl<$Res>
    extends _$ExpenseCopyWithImpl<$Res, _$ExpenseImpl>
    implements _$$ExpenseImplCopyWith<$Res> {
  __$$ExpenseImplCopyWithImpl(
      _$ExpenseImpl _value, $Res Function(_$ExpenseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? description = null,
    Object? categoryId = freezed,
    Object? date = null,
    Object? notificationSource = null,
    Object? autoClassified = null,
    Object? rawNotificationText = null,
    Object? createdAt = null,
  }) {
    return _then(_$ExpenseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notificationSource: null == notificationSource
          ? _value.notificationSource
          : notificationSource // ignore: cast_nullable_to_non_nullable
              as String,
      autoClassified: null == autoClassified
          ? _value.autoClassified
          : autoClassified // ignore: cast_nullable_to_non_nullable
              as bool,
      rawNotificationText: null == rawNotificationText
          ? _value.rawNotificationText
          : rawNotificationText // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$ExpenseImpl extends _Expense {
  const _$ExpenseImpl(
      {required this.id,
      required this.amount,
      required this.description,
      this.categoryId,
      required this.date,
      required this.notificationSource,
      required this.autoClassified,
      required this.rawNotificationText,
      required this.createdAt})
      : super._();

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// Transaction amount in euros (always positive).
  @override
  final double amount;

  /// Human-readable description — merchant name when parsed from a notification,
  /// or free text when entered manually.
  @override
  final String description;

  /// Foreign key referencing the assigned [Category]. `null` when the expense
  /// has not yet been classified.
  @override
  final String? categoryId;

  /// Date the transaction occurred (may differ from [createdAt] when backdated).
  @override
  final DateTime date;

  /// Package name or label of the app that emitted the source notification
  /// (e.g. `'es.lacaixa.mobile.android'`). Set to `'manual'` for manual entries.
  @override
  final String notificationSource;

  /// `true` when a [ClassificationRule] matched this expense automatically.
  @override
  final bool autoClassified;

  /// Verbatim notification body kept for auditing and rule debugging.
  @override
  final String rawNotificationText;

  /// Timestamp of record creation in the local database (UTC).
  @override
  final DateTime createdAt;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      __$$ExpenseImplCopyWithImpl<_$ExpenseImpl>(this, _$identity);
}

abstract class _Expense extends Expense {
  const factory _Expense(
      {required final String id,
      required final double amount,
      required final String description,
      final String? categoryId,
      required final DateTime date,
      required final String notificationSource,
      required final bool autoClassified,
      required final String rawNotificationText,
      required final DateTime createdAt}) = _$ExpenseImpl;
  const _Expense._() : super._();

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// Transaction amount in euros (always positive).
  @override
  double get amount;

  /// Human-readable description — merchant name when parsed from a notification,
  /// or free text when entered manually.
  @override
  String get description;

  /// Foreign key referencing the assigned [Category]. `null` when the expense
  /// has not yet been classified.
  @override
  String? get categoryId;

  /// Date the transaction occurred (may differ from [createdAt] when backdated).
  @override
  DateTime get date;

  /// Package name or label of the app that emitted the source notification
  /// (e.g. `'es.lacaixa.mobile.android'`). Set to `'manual'` for manual entries.
  @override
  String get notificationSource;

  /// `true` when a [ClassificationRule] matched this expense automatically.
  @override
  bool get autoClassified;

  /// Verbatim notification body kept for auditing and rule debugging.
  @override
  String get rawNotificationText;

  /// Timestamp of record creation in the local database (UTC).
  @override
  DateTime get createdAt;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
