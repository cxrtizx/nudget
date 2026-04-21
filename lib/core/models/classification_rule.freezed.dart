// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classification_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ClassificationRule {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Plain-string regex pattern compiled case-insensitively at runtime.
  String get pattern => throw _privateConstructorUsedError;

  /// Foreign key referencing the [Category] to assign on match.
  String get categoryId => throw _privateConstructorUsedError;

  /// Timestamp of creation (UTC).
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Number of times this rule has successfully matched an expense.
  /// Used to sort rules so the most relevant ones are tested first.
  int get matchCount => throw _privateConstructorUsedError;

  /// Create a copy of ClassificationRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassificationRuleCopyWith<ClassificationRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassificationRuleCopyWith<$Res> {
  factory $ClassificationRuleCopyWith(
          ClassificationRule value, $Res Function(ClassificationRule) then) =
      _$ClassificationRuleCopyWithImpl<$Res, ClassificationRule>;
  @useResult
  $Res call(
      {String id,
      String pattern,
      String categoryId,
      DateTime createdAt,
      int matchCount});
}

/// @nodoc
class _$ClassificationRuleCopyWithImpl<$Res, $Val extends ClassificationRule>
    implements $ClassificationRuleCopyWith<$Res> {
  _$ClassificationRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassificationRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pattern = null,
    Object? categoryId = null,
    Object? createdAt = null,
    Object? matchCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pattern: null == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      matchCount: null == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassificationRuleImplCopyWith<$Res>
    implements $ClassificationRuleCopyWith<$Res> {
  factory _$$ClassificationRuleImplCopyWith(_$ClassificationRuleImpl value,
          $Res Function(_$ClassificationRuleImpl) then) =
      __$$ClassificationRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String pattern,
      String categoryId,
      DateTime createdAt,
      int matchCount});
}

/// @nodoc
class __$$ClassificationRuleImplCopyWithImpl<$Res>
    extends _$ClassificationRuleCopyWithImpl<$Res, _$ClassificationRuleImpl>
    implements _$$ClassificationRuleImplCopyWith<$Res> {
  __$$ClassificationRuleImplCopyWithImpl(_$ClassificationRuleImpl _value,
      $Res Function(_$ClassificationRuleImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassificationRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pattern = null,
    Object? categoryId = null,
    Object? createdAt = null,
    Object? matchCount = null,
  }) {
    return _then(_$ClassificationRuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pattern: null == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      matchCount: null == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ClassificationRuleImpl extends _ClassificationRule {
  const _$ClassificationRuleImpl(
      {required this.id,
      required this.pattern,
      required this.categoryId,
      required this.createdAt,
      required this.matchCount})
      : super._();

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// Plain-string regex pattern compiled case-insensitively at runtime.
  @override
  final String pattern;

  /// Foreign key referencing the [Category] to assign on match.
  @override
  final String categoryId;

  /// Timestamp of creation (UTC).
  @override
  final DateTime createdAt;

  /// Number of times this rule has successfully matched an expense.
  /// Used to sort rules so the most relevant ones are tested first.
  @override
  final int matchCount;

  /// Create a copy of ClassificationRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassificationRuleImplCopyWith<_$ClassificationRuleImpl> get copyWith =>
      __$$ClassificationRuleImplCopyWithImpl<_$ClassificationRuleImpl>(
          this, _$identity);
}

abstract class _ClassificationRule extends ClassificationRule {
  const factory _ClassificationRule(
      {required final String id,
      required final String pattern,
      required final String categoryId,
      required final DateTime createdAt,
      required final int matchCount}) = _$ClassificationRuleImpl;
  const _ClassificationRule._() : super._();

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// Plain-string regex pattern compiled case-insensitively at runtime.
  @override
  String get pattern;

  /// Foreign key referencing the [Category] to assign on match.
  @override
  String get categoryId;

  /// Timestamp of creation (UTC).
  @override
  DateTime get createdAt;

  /// Number of times this rule has successfully matched an expense.
  /// Used to sort rules so the most relevant ones are tested first.
  @override
  int get matchCount;

  /// Create a copy of ClassificationRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassificationRuleImplCopyWith<_$ClassificationRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
