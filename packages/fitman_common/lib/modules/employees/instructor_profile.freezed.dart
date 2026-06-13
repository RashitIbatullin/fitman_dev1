// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instructor_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InstructorProfile _$InstructorProfileFromJson(Map<String, dynamic> json) {
  return _InstructorProfile.fromJson(json);
}

/// @nodoc
mixin _$InstructorProfile {
  String get userId => throw _privateConstructorUsedError;
  bool get isDuty => throw _privateConstructorUsedError;
  bool get canReplaceTrainer => throw _privateConstructorUsedError;
  bool get canCreatePlan => throw _privateConstructorUsedError;

  /// Serializes this InstructorProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InstructorProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InstructorProfileCopyWith<InstructorProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstructorProfileCopyWith<$Res> {
  factory $InstructorProfileCopyWith(
    InstructorProfile value,
    $Res Function(InstructorProfile) then,
  ) = _$InstructorProfileCopyWithImpl<$Res, InstructorProfile>;
  @useResult
  $Res call({
    String userId,
    bool isDuty,
    bool canReplaceTrainer,
    bool canCreatePlan,
  });
}

/// @nodoc
class _$InstructorProfileCopyWithImpl<$Res, $Val extends InstructorProfile>
    implements $InstructorProfileCopyWith<$Res> {
  _$InstructorProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InstructorProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? isDuty = null,
    Object? canReplaceTrainer = null,
    Object? canCreatePlan = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            isDuty: null == isDuty
                ? _value.isDuty
                : isDuty // ignore: cast_nullable_to_non_nullable
                      as bool,
            canReplaceTrainer: null == canReplaceTrainer
                ? _value.canReplaceTrainer
                : canReplaceTrainer // ignore: cast_nullable_to_non_nullable
                      as bool,
            canCreatePlan: null == canCreatePlan
                ? _value.canCreatePlan
                : canCreatePlan // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InstructorProfileImplCopyWith<$Res>
    implements $InstructorProfileCopyWith<$Res> {
  factory _$$InstructorProfileImplCopyWith(
    _$InstructorProfileImpl value,
    $Res Function(_$InstructorProfileImpl) then,
  ) = __$$InstructorProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    bool isDuty,
    bool canReplaceTrainer,
    bool canCreatePlan,
  });
}

/// @nodoc
class __$$InstructorProfileImplCopyWithImpl<$Res>
    extends _$InstructorProfileCopyWithImpl<$Res, _$InstructorProfileImpl>
    implements _$$InstructorProfileImplCopyWith<$Res> {
  __$$InstructorProfileImplCopyWithImpl(
    _$InstructorProfileImpl _value,
    $Res Function(_$InstructorProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InstructorProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? isDuty = null,
    Object? canReplaceTrainer = null,
    Object? canCreatePlan = null,
  }) {
    return _then(
      _$InstructorProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        isDuty: null == isDuty
            ? _value.isDuty
            : isDuty // ignore: cast_nullable_to_non_nullable
                  as bool,
        canReplaceTrainer: null == canReplaceTrainer
            ? _value.canReplaceTrainer
            : canReplaceTrainer // ignore: cast_nullable_to_non_nullable
                  as bool,
        canCreatePlan: null == canCreatePlan
            ? _value.canCreatePlan
            : canCreatePlan // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InstructorProfileImpl implements _InstructorProfile {
  const _$InstructorProfileImpl({
    required this.userId,
    this.isDuty = false,
    this.canReplaceTrainer = false,
    this.canCreatePlan = false,
  });

  factory _$InstructorProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstructorProfileImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final bool isDuty;
  @override
  @JsonKey()
  final bool canReplaceTrainer;
  @override
  @JsonKey()
  final bool canCreatePlan;

  @override
  String toString() {
    return 'InstructorProfile(userId: $userId, isDuty: $isDuty, canReplaceTrainer: $canReplaceTrainer, canCreatePlan: $canCreatePlan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstructorProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isDuty, isDuty) || other.isDuty == isDuty) &&
            (identical(other.canReplaceTrainer, canReplaceTrainer) ||
                other.canReplaceTrainer == canReplaceTrainer) &&
            (identical(other.canCreatePlan, canCreatePlan) ||
                other.canCreatePlan == canCreatePlan));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    isDuty,
    canReplaceTrainer,
    canCreatePlan,
  );

  /// Create a copy of InstructorProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InstructorProfileImplCopyWith<_$InstructorProfileImpl> get copyWith =>
      __$$InstructorProfileImplCopyWithImpl<_$InstructorProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InstructorProfileImplToJson(this);
  }
}

abstract class _InstructorProfile implements InstructorProfile {
  const factory _InstructorProfile({
    required final String userId,
    final bool isDuty,
    final bool canReplaceTrainer,
    final bool canCreatePlan,
  }) = _$InstructorProfileImpl;

  factory _InstructorProfile.fromJson(Map<String, dynamic> json) =
      _$InstructorProfileImpl.fromJson;

  @override
  String get userId;
  @override
  bool get isDuty;
  @override
  bool get canReplaceTrainer;
  @override
  bool get canCreatePlan;

  /// Create a copy of InstructorProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InstructorProfileImplCopyWith<_$InstructorProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
