// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Category {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Human-readable display name.
  String get name => throw _privateConstructorUsedError;

  /// Material icon name key. Resolved to [IconData] via [CategoryIconMapper].
  String get icon => throw _privateConstructorUsedError;

  /// Display color. Persisted as [Color.value] (ARGB int).
  Color get color => throw _privateConstructorUsedError;

  /// Optional monthly spending cap in euros. `null` means no limit.
  double? get spendingLimit => throw _privateConstructorUsedError;

  /// Timestamp of creation (UTC).
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res, Category>;
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      Color color,
      double? spendingLimit,
      DateTime createdAt});
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res, $Val extends Category>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? spendingLimit = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      spendingLimit: freezed == spendingLimit
          ? _value.spendingLimit
          : spendingLimit // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryImplCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$$CategoryImplCopyWith(
          _$CategoryImpl value, $Res Function(_$CategoryImpl) then) =
      __$$CategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      Color color,
      double? spendingLimit,
      DateTime createdAt});
}

/// @nodoc
class __$$CategoryImplCopyWithImpl<$Res>
    extends _$CategoryCopyWithImpl<$Res, _$CategoryImpl>
    implements _$$CategoryImplCopyWith<$Res> {
  __$$CategoryImplCopyWithImpl(
      _$CategoryImpl _value, $Res Function(_$CategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? spendingLimit = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$CategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      spendingLimit: freezed == spendingLimit
          ? _value.spendingLimit
          : spendingLimit // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$CategoryImpl extends _Category {
  const _$CategoryImpl(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color,
      this.spendingLimit,
      required this.createdAt})
      : super._();

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// Human-readable display name.
  @override
  final String name;

  /// Material icon name key. Resolved to [IconData] via [CategoryIconMapper].
  @override
  final String icon;

  /// Display color. Persisted as [Color.value] (ARGB int).
  @override
  final Color color;

  /// Optional monthly spending cap in euros. `null` means no limit.
  @override
  final double? spendingLimit;

  /// Timestamp of creation (UTC).
  @override
  final DateTime createdAt;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      __$$CategoryImplCopyWithImpl<_$CategoryImpl>(this, _$identity);
}

abstract class _Category extends Category {
  const factory _Category(
      {required final String id,
      required final String name,
      required final String icon,
      required final Color color,
      final double? spendingLimit,
      required final DateTime createdAt}) = _$CategoryImpl;
  const _Category._() : super._();

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// Human-readable display name.
  @override
  String get name;

  /// Material icon name key. Resolved to [IconData] via [CategoryIconMapper].
  @override
  String get icon;

  /// Display color. Persisted as [Color.value] (ARGB int).
  @override
  Color get color;

  /// Optional monthly spending cap in euros. `null` means no limit.
  @override
  double? get spendingLimit;

  /// Timestamp of creation (UTC).
  @override
  DateTime get createdAt;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
