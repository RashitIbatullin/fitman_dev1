// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainerProfile _$TrainerProfileFromJson(Map<String, dynamic> json) {
  return _TrainerProfile.fromJson(json);
}

/// @nodoc
mixin _$TrainerProfile {
  int get userId => throw _privateConstructorUsedError;

  /// Serializes this TrainerProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerProfileCopyWith<TrainerProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerProfileCopyWith<$Res> {
  factory $TrainerProfileCopyWith(
    TrainerProfile value,
    $Res Function(TrainerProfile) then,
  ) = _$TrainerProfileCopyWithImpl<$Res, TrainerProfile>;
  @useResult
  $Res call({int userId});
}

/// @nodoc
class _$TrainerProfileCopyWithImpl<$Res, $Val extends TrainerProfile>
    implements $TrainerProfileCopyWith<$Res> {
  _$TrainerProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerProfileImplCopyWith<$Res>
    implements $TrainerProfileCopyWith<$Res> {
  factory _$$TrainerProfileImplCopyWith(
    _$TrainerProfileImpl value,
    $Res Function(_$TrainerProfileImpl) then,
  ) = __$$TrainerProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId});
}

/// @nodoc
class __$$TrainerProfileImplCopyWithImpl<$Res>
    extends _$TrainerProfileCopyWithImpl<$Res, _$TrainerProfileImpl>
    implements _$$TrainerProfileImplCopyWith<$Res> {
  __$$TrainerProfileImplCopyWithImpl(
    _$TrainerProfileImpl _value,
    $Res Function(_$TrainerProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$TrainerProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainerProfileImpl implements _TrainerProfile {
  const _$TrainerProfileImpl({required this.userId});

  factory _$TrainerProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainerProfileImplFromJson(json);

  @override
  final int userId;

  @override
  String toString() {
    return 'TrainerProfile(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of TrainerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerProfileImplCopyWith<_$TrainerProfileImpl> get copyWith =>
      __$$TrainerProfileImplCopyWithImpl<_$TrainerProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainerProfileImplToJson(this);
  }
}

abstract class _TrainerProfile implements TrainerProfile {
  const factory _TrainerProfile({required final int userId}) =
      _$TrainerProfileImpl;

  factory _TrainerProfile.fromJson(Map<String, dynamic> json) =
      _$TrainerProfileImpl.fromJson;

  @override
  int get userId;

  /// Create a copy of TrainerProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerProfileImplCopyWith<_$TrainerProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
