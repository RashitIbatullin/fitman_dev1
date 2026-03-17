// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manager_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ManagerProfile _$ManagerProfileFromJson(Map<String, dynamic> json) {
  return _ManagerProfile.fromJson(json);
}

/// @nodoc
mixin _$ManagerProfile {
  int get userId => throw _privateConstructorUsedError;
  bool get isDuty => throw _privateConstructorUsedError;

  /// Serializes this ManagerProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ManagerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ManagerProfileCopyWith<ManagerProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManagerProfileCopyWith<$Res> {
  factory $ManagerProfileCopyWith(
    ManagerProfile value,
    $Res Function(ManagerProfile) then,
  ) = _$ManagerProfileCopyWithImpl<$Res, ManagerProfile>;
  @useResult
  $Res call({int userId, bool isDuty});
}

/// @nodoc
class _$ManagerProfileCopyWithImpl<$Res, $Val extends ManagerProfile>
    implements $ManagerProfileCopyWith<$Res> {
  _$ManagerProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ManagerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? isDuty = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            isDuty: null == isDuty
                ? _value.isDuty
                : isDuty // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ManagerProfileImplCopyWith<$Res>
    implements $ManagerProfileCopyWith<$Res> {
  factory _$$ManagerProfileImplCopyWith(
    _$ManagerProfileImpl value,
    $Res Function(_$ManagerProfileImpl) then,
  ) = __$$ManagerProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, bool isDuty});
}

/// @nodoc
class __$$ManagerProfileImplCopyWithImpl<$Res>
    extends _$ManagerProfileCopyWithImpl<$Res, _$ManagerProfileImpl>
    implements _$$ManagerProfileImplCopyWith<$Res> {
  __$$ManagerProfileImplCopyWithImpl(
    _$ManagerProfileImpl _value,
    $Res Function(_$ManagerProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ManagerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? isDuty = null}) {
    return _then(
      _$ManagerProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        isDuty: null == isDuty
            ? _value.isDuty
            : isDuty // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ManagerProfileImpl implements _ManagerProfile {
  const _$ManagerProfileImpl({required this.userId, this.isDuty = false});

  factory _$ManagerProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ManagerProfileImplFromJson(json);

  @override
  final int userId;
  @override
  @JsonKey()
  final bool isDuty;

  @override
  String toString() {
    return 'ManagerProfile(userId: $userId, isDuty: $isDuty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManagerProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isDuty, isDuty) || other.isDuty == isDuty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, isDuty);

  /// Create a copy of ManagerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ManagerProfileImplCopyWith<_$ManagerProfileImpl> get copyWith =>
      __$$ManagerProfileImplCopyWithImpl<_$ManagerProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ManagerProfileImplToJson(this);
  }
}

abstract class _ManagerProfile implements ManagerProfile {
  const factory _ManagerProfile({
    required final int userId,
    final bool isDuty,
  }) = _$ManagerProfileImpl;

  factory _ManagerProfile.fromJson(Map<String, dynamic> json) =
      _$ManagerProfileImpl.fromJson;

  @override
  int get userId;
  @override
  bool get isDuty;

  /// Create a copy of ManagerProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ManagerProfileImplCopyWith<_$ManagerProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
