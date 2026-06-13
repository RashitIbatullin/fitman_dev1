// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_movement.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupMovement _$GroupMovementFromJson(Map<String, dynamic> json) {
  return _GroupMovement.fromJson(json);
}

/// @nodoc
mixin _$GroupMovement {
  String? get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userRole => throw _privateConstructorUsedError;
  String? get fromGroupId => throw _privateConstructorUsedError;
  String? get toGroupId => throw _privateConstructorUsedError;
  @CustomDateTimeConverter()
  DateTime get movementDate => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String get movedByUserId => throw _privateConstructorUsedError;
  @NullableCustomDateTimeConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GroupMovement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupMovementCopyWith<GroupMovement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMovementCopyWith<$Res> {
  factory $GroupMovementCopyWith(
    GroupMovement value,
    $Res Function(GroupMovement) then,
  ) = _$GroupMovementCopyWithImpl<$Res, GroupMovement>;
  @useResult
  $Res call({
    String? id,
    String userId,
    String userRole,
    String? fromGroupId,
    String? toGroupId,
    @CustomDateTimeConverter() DateTime movementDate,
    String? reason,
    String movedByUserId,
    @NullableCustomDateTimeConverter() DateTime? createdAt,
  });
}

/// @nodoc
class _$GroupMovementCopyWithImpl<$Res, $Val extends GroupMovement>
    implements $GroupMovementCopyWith<$Res> {
  _$GroupMovementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? userRole = null,
    Object? fromGroupId = freezed,
    Object? toGroupId = freezed,
    Object? movementDate = null,
    Object? reason = freezed,
    Object? movedByUserId = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userRole: null == userRole
                ? _value.userRole
                : userRole // ignore: cast_nullable_to_non_nullable
                      as String,
            fromGroupId: freezed == fromGroupId
                ? _value.fromGroupId
                : fromGroupId // ignore: cast_nullable_to_non_nullable
                      as String?,
            toGroupId: freezed == toGroupId
                ? _value.toGroupId
                : toGroupId // ignore: cast_nullable_to_non_nullable
                      as String?,
            movementDate: null == movementDate
                ? _value.movementDate
                : movementDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            movedByUserId: null == movedByUserId
                ? _value.movedByUserId
                : movedByUserId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$GroupMovementImplCopyWith<$Res>
    implements $GroupMovementCopyWith<$Res> {
  factory _$$GroupMovementImplCopyWith(
    _$GroupMovementImpl value,
    $Res Function(_$GroupMovementImpl) then,
  ) = __$$GroupMovementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String userId,
    String userRole,
    String? fromGroupId,
    String? toGroupId,
    @CustomDateTimeConverter() DateTime movementDate,
    String? reason,
    String movedByUserId,
    @NullableCustomDateTimeConverter() DateTime? createdAt,
  });
}

/// @nodoc
class __$$GroupMovementImplCopyWithImpl<$Res>
    extends _$GroupMovementCopyWithImpl<$Res, _$GroupMovementImpl>
    implements _$$GroupMovementImplCopyWith<$Res> {
  __$$GroupMovementImplCopyWithImpl(
    _$GroupMovementImpl _value,
    $Res Function(_$GroupMovementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? userRole = null,
    Object? fromGroupId = freezed,
    Object? toGroupId = freezed,
    Object? movementDate = null,
    Object? reason = freezed,
    Object? movedByUserId = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$GroupMovementImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userRole: null == userRole
            ? _value.userRole
            : userRole // ignore: cast_nullable_to_non_nullable
                  as String,
        fromGroupId: freezed == fromGroupId
            ? _value.fromGroupId
            : fromGroupId // ignore: cast_nullable_to_non_nullable
                  as String?,
        toGroupId: freezed == toGroupId
            ? _value.toGroupId
            : toGroupId // ignore: cast_nullable_to_non_nullable
                  as String?,
        movementDate: null == movementDate
            ? _value.movementDate
            : movementDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        movedByUserId: null == movedByUserId
            ? _value.movedByUserId
            : movedByUserId // ignore: cast_nullable_to_non_nullable
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
class _$GroupMovementImpl implements _GroupMovement {
  const _$GroupMovementImpl({
    this.id,
    required this.userId,
    required this.userRole,
    this.fromGroupId,
    this.toGroupId,
    @CustomDateTimeConverter() required this.movementDate,
    this.reason,
    required this.movedByUserId,
    @NullableCustomDateTimeConverter() this.createdAt,
  });

  factory _$GroupMovementImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupMovementImplFromJson(json);

  @override
  final String? id;
  @override
  final String userId;
  @override
  final String userRole;
  @override
  final String? fromGroupId;
  @override
  final String? toGroupId;
  @override
  @CustomDateTimeConverter()
  final DateTime movementDate;
  @override
  final String? reason;
  @override
  final String movedByUserId;
  @override
  @NullableCustomDateTimeConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'GroupMovement(id: $id, userId: $userId, userRole: $userRole, fromGroupId: $fromGroupId, toGroupId: $toGroupId, movementDate: $movementDate, reason: $reason, movedByUserId: $movedByUserId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMovementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole) &&
            (identical(other.fromGroupId, fromGroupId) ||
                other.fromGroupId == fromGroupId) &&
            (identical(other.toGroupId, toGroupId) ||
                other.toGroupId == toGroupId) &&
            (identical(other.movementDate, movementDate) ||
                other.movementDate == movementDate) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.movedByUserId, movedByUserId) ||
                other.movedByUserId == movedByUserId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    userRole,
    fromGroupId,
    toGroupId,
    movementDate,
    reason,
    movedByUserId,
    createdAt,
  );

  /// Create a copy of GroupMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMovementImplCopyWith<_$GroupMovementImpl> get copyWith =>
      __$$GroupMovementImplCopyWithImpl<_$GroupMovementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupMovementImplToJson(this);
  }
}

abstract class _GroupMovement implements GroupMovement {
  const factory _GroupMovement({
    final String? id,
    required final String userId,
    required final String userRole,
    final String? fromGroupId,
    final String? toGroupId,
    @CustomDateTimeConverter() required final DateTime movementDate,
    final String? reason,
    required final String movedByUserId,
    @NullableCustomDateTimeConverter() final DateTime? createdAt,
  }) = _$GroupMovementImpl;

  factory _GroupMovement.fromJson(Map<String, dynamic> json) =
      _$GroupMovementImpl.fromJson;

  @override
  String? get id;
  @override
  String get userId;
  @override
  String get userRole;
  @override
  String? get fromGroupId;
  @override
  String? get toGroupId;
  @override
  @CustomDateTimeConverter()
  DateTime get movementDate;
  @override
  String? get reason;
  @override
  String get movedByUserId;
  @override
  @NullableCustomDateTimeConverter()
  DateTime? get createdAt;

  /// Create a copy of GroupMovement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupMovementImplCopyWith<_$GroupMovementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
