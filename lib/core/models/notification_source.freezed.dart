// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationSource {
  /// Unique identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Human-readable name of the source app (e.g. `'Google Pay'`).
  ///
  /// Also used as the matching key against [Expense.notificationSource]
  /// in the notification pipeline.
  String get appName => throw _privateConstructorUsedError;

  /// User-defined pattern with `{importe}` and `{concepto}` placeholders.
  String get pattern => throw _privateConstructorUsedError;

  /// Whether this source is currently active in the pipeline.
  bool get isEnabled => throw _privateConstructorUsedError;

  /// Timestamp of creation (UTC).
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSourceCopyWith<NotificationSource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSourceCopyWith<$Res> {
  factory $NotificationSourceCopyWith(
          NotificationSource value, $Res Function(NotificationSource) then) =
      _$NotificationSourceCopyWithImpl<$Res, NotificationSource>;
  @useResult
  $Res call(
      {String id,
      String appName,
      String pattern,
      bool isEnabled,
      DateTime createdAt});
}

/// @nodoc
class _$NotificationSourceCopyWithImpl<$Res, $Val extends NotificationSource>
    implements $NotificationSourceCopyWith<$Res> {
  _$NotificationSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? appName = null,
    Object? pattern = null,
    Object? isEnabled = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      appName: null == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String,
      pattern: null == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSourceImplCopyWith<$Res>
    implements $NotificationSourceCopyWith<$Res> {
  factory _$$NotificationSourceImplCopyWith(_$NotificationSourceImpl value,
          $Res Function(_$NotificationSourceImpl) then) =
      __$$NotificationSourceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String appName,
      String pattern,
      bool isEnabled,
      DateTime createdAt});
}

/// @nodoc
class __$$NotificationSourceImplCopyWithImpl<$Res>
    extends _$NotificationSourceCopyWithImpl<$Res, _$NotificationSourceImpl>
    implements _$$NotificationSourceImplCopyWith<$Res> {
  __$$NotificationSourceImplCopyWithImpl(_$NotificationSourceImpl _value,
      $Res Function(_$NotificationSourceImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? appName = null,
    Object? pattern = null,
    Object? isEnabled = null,
    Object? createdAt = null,
  }) {
    return _then(_$NotificationSourceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      appName: null == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String,
      pattern: null == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$NotificationSourceImpl extends _NotificationSource {
  const _$NotificationSourceImpl(
      {required this.id,
      required this.appName,
      required this.pattern,
      required this.isEnabled,
      required this.createdAt})
      : super._();

  /// Unique identifier (UUID v4).
  @override
  final String id;

  /// Human-readable name of the source app (e.g. `'Google Pay'`).
  ///
  /// Also used as the matching key against [Expense.notificationSource]
  /// in the notification pipeline.
  @override
  final String appName;

  /// User-defined pattern with `{importe}` and `{concepto}` placeholders.
  @override
  final String pattern;

  /// Whether this source is currently active in the pipeline.
  @override
  final bool isEnabled;

  /// Timestamp of creation (UTC).
  @override
  final DateTime createdAt;

  /// Create a copy of NotificationSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSourceImplCopyWith<_$NotificationSourceImpl> get copyWith =>
      __$$NotificationSourceImplCopyWithImpl<_$NotificationSourceImpl>(
          this, _$identity);
}

abstract class _NotificationSource extends NotificationSource {
  const factory _NotificationSource(
      {required final String id,
      required final String appName,
      required final String pattern,
      required final bool isEnabled,
      required final DateTime createdAt}) = _$NotificationSourceImpl;
  const _NotificationSource._() : super._();

  /// Unique identifier (UUID v4).
  @override
  String get id;

  /// Human-readable name of the source app (e.g. `'Google Pay'`).
  ///
  /// Also used as the matching key against [Expense.notificationSource]
  /// in the notification pipeline.
  @override
  String get appName;

  /// User-defined pattern with `{importe}` and `{concepto}` placeholders.
  @override
  String get pattern;

  /// Whether this source is currently active in the pipeline.
  @override
  bool get isEnabled;

  /// Timestamp of creation (UTC).
  @override
  DateTime get createdAt;

  /// Create a copy of NotificationSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSourceImplCopyWith<_$NotificationSourceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
