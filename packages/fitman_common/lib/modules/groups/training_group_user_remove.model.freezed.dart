// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_group_user_remove.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainingGroupUserRemove _$TrainingGroupUserRemoveFromJson(
  Map<String, dynamic> json,
) {
  return _TrainingGroupUserRemove.fromJson(json);
}

/// @nodoc
mixin _$TrainingGroupUserRemove {
  String? get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userRole => throw _privateConstructorUsedError;
  @CustomDateTimeConverter()
  DateTime get removedAt => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get initiatorId => throw _privateConstructorUsedError;
  @NullableCustomDateTimeConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TrainingGroupUserRemove to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingGroupUserRemove
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingGroupUserRemoveCopyWith<TrainingGroupUserRemove> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingGroupUserRemoveCopyWith<$Res> {
  factory $TrainingGroupUserRemoveCopyWith(
    TrainingGroupUserRemove value,
    $Res Function(TrainingGroupUserRemove) then,
  ) = _$TrainingGroupUserRemoveCopyWithImpl<$Res, TrainingGroupUserRemove>;
  @useResult
  $Res call({
    String? id,
    String groupId,
    String userId,
    String userRole,
    @CustomDateTimeConverter() DateTime removedAt,
    String reason,
    String initiatorId,
    @NullableCustomDateTimeConverter() DateTime? createdAt,
  });
}

/// @nodoc
class _$TrainingGroupUserRemoveCopyWithImpl<
  $Res,
  $Val extends TrainingGroupUserRemove
>
    implements $TrainingGroupUserRemoveCopyWith<$Res> {
  _$TrainingGroupUserRemoveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingGroupUserRemove
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? groupId = null,
    Object? userId = null,
    Object? userRole = null,
    Object? removedAt = null,
    Object? reason = null,
    Object? initiatorId = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userRole: null == userRole
                ? _value.userRole
                : userRole // ignore: cast_nullable_to_non_nullable
                      as String,
            removedAt: null == removedAt
                ? _value.removedAt
                : removedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            initiatorId: null == initiatorId
                ? _value.initiatorId
                : initiatorId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainingGroupUserRemoveImplCopyWith<$Res>
    implements $TrainingGroupUserRemoveCopyWith<$Res> {
  factory _$$TrainingGroupUserRemoveImplCopyWith(
    _$TrainingGroupUserRemoveImpl value,
    $Res Function(_$TrainingGroupUserRemoveImpl) then,
  ) = __$$TrainingGroupUserRemoveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String groupId,
    String userId,
    String userRole,
    @CustomDateTimeConverter() DateTime removedAt,
    String reason,
    String initiatorId,
    @NullableCustomDateTimeConverter() DateTime? createdAt,
  });
}

/// @nodoc
class __$$TrainingGroupUserRemoveImplCopyWithImpl<$Res>
    extends
        _$TrainingGroupUserRemoveCopyWithImpl<
          $Res,
          _$TrainingGroupUserRemoveImpl
        >
    implements _$$TrainingGroupUserRemoveImplCopyWith<$Res> {
  __$$TrainingGroupUserRemoveImplCopyWithImpl(
    _$TrainingGroupUserRemoveImpl _value,
    $Res Function(_$TrainingGroupUserRemoveImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingGroupUserRemove
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? groupId = null,
    Object? userId = null,
    Object? userRole = null,
    Object? removedAt = null,
    Object? reason = null,
    Object? initiatorId = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TrainingGroupUserRemoveImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userRole: null == userRole
            ? _value.userRole
            : userRole // ignore: cast_nullable_to_non_nullable
                  as String,
        removedAt: null == removedAt
            ? _value.removedAt
            : removedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        initiatorId: null == initiatorId
            ? _value.initiatorId
            : initiatorId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingGroupUserRemoveImpl implements _TrainingGroupUserRemove {
  const _$TrainingGroupUserRemoveImpl({
    this.id,
    required this.groupId,
    required this.userId,
    required this.userRole,
    @CustomDateTimeConverter() required this.removedAt,
    required this.reason,
    required this.initiatorId,
    @NullableCustomDateTimeConverter() this.createdAt,
  });

  factory _$TrainingGroupUserRemoveImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingGroupUserRemoveImplFromJson(json);

  @override
  final String? id;
  @override
  final String groupId;
  @override
  final String userId;
  @override
  final String userRole;
  @override
  @CustomDateTimeConverter()
  final DateTime removedAt;
  @override
  final String reason;
  @override
  final String initiatorId;
  @override
  @NullableCustomDateTimeConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TrainingGroupUserRemove(id: $id, groupId: $groupId, userId: $userId, userRole: $userRole, removedAt: $removedAt, reason: $reason, initiatorId: $initiatorId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingGroupUserRemoveImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole) &&
            (identical(other.removedAt, removedAt) ||
                other.removedAt == removedAt) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.initiatorId, initiatorId) ||
                other.initiatorId == initiatorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    groupId,
    userId,
    userRole,
    removedAt,
    reason,
    initiatorId,
    createdAt,
  );

  /// Create a copy of TrainingGroupUserRemove
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingGroupUserRemoveImplCopyWith<_$TrainingGroupUserRemoveImpl>
  get copyWith =>
      __$$TrainingGroupUserRemoveImplCopyWithImpl<
        _$TrainingGroupUserRemoveImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingGroupUserRemoveImplToJson(this);
  }
}

abstract class _TrainingGroupUserRemove implements TrainingGroupUserRemove {
  const factory _TrainingGroupUserRemove({
    final String? id,
    required final String groupId,
    required final String userId,
    required final String userRole,
    @CustomDateTimeConverter() required final DateTime removedAt,
    required final String reason,
    required final String initiatorId,
    @NullableCustomDateTimeConverter() final DateTime? createdAt,
  }) = _$TrainingGroupUserRemoveImpl;

  factory _TrainingGroupUserRemove.fromJson(Map<String, dynamic> json) =
      _$TrainingGroupUserRemoveImpl.fromJson;

  @override
  String? get id;
  @override
  String get groupId;
  @override
  String get userId;
  @override
  String get userRole;
  @override
  @CustomDateTimeConverter()
  DateTime get removedAt;
  @override
  String get reason;
  @override
  String get initiatorId;
  @override
  @NullableCustomDateTimeConverter()
  DateTime? get createdAt;

  /// Create a copy of TrainingGroupUserRemove
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingGroupUserRemoveImplCopyWith<_$TrainingGroupUserRemoveImpl>
  get copyWith => throw _privateConstructorUsedError;
}
