// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EmployeeProfile _$EmployeeProfileFromJson(Map<String, dynamic> json) {
  return _EmployeeProfile.fromJson(json);
}

/// @nodoc
mixin _$EmployeeProfile {
  String get userId => throw _privateConstructorUsedError;
  String? get specialization => throw _privateConstructorUsedError;
  int? get workExperience => throw _privateConstructorUsedError;
  bool get canMaintainEquipment => throw _privateConstructorUsedError;

  /// Serializes this EmployeeProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmployeeProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmployeeProfileCopyWith<EmployeeProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmployeeProfileCopyWith<$Res> {
  factory $EmployeeProfileCopyWith(
    EmployeeProfile value,
    $Res Function(EmployeeProfile) then,
  ) = _$EmployeeProfileCopyWithImpl<$Res, EmployeeProfile>;
  @useResult
  $Res call({
    String userId,
    String? specialization,
    int? workExperience,
    bool canMaintainEquipment,
  });
}

/// @nodoc
class _$EmployeeProfileCopyWithImpl<$Res, $Val extends EmployeeProfile>
    implements $EmployeeProfileCopyWith<$Res> {
  _$EmployeeProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmployeeProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? specialization = freezed,
    Object? workExperience = freezed,
    Object? canMaintainEquipment = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            specialization: freezed == specialization
                ? _value.specialization
                : specialization // ignore: cast_nullable_to_non_nullable
                      as String?,
            workExperience: freezed == workExperience
                ? _value.workExperience
                : workExperience // ignore: cast_nullable_to_non_nullable
                      as int?,
            canMaintainEquipment: null == canMaintainEquipment
                ? _value.canMaintainEquipment
                : canMaintainEquipment // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmployeeProfileImplCopyWith<$Res>
    implements $EmployeeProfileCopyWith<$Res> {
  factory _$$EmployeeProfileImplCopyWith(
    _$EmployeeProfileImpl value,
    $Res Function(_$EmployeeProfileImpl) then,
  ) = __$$EmployeeProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String? specialization,
    int? workExperience,
    bool canMaintainEquipment,
  });
}

/// @nodoc
class __$$EmployeeProfileImplCopyWithImpl<$Res>
    extends _$EmployeeProfileCopyWithImpl<$Res, _$EmployeeProfileImpl>
    implements _$$EmployeeProfileImplCopyWith<$Res> {
  __$$EmployeeProfileImplCopyWithImpl(
    _$EmployeeProfileImpl _value,
    $Res Function(_$EmployeeProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmployeeProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? specialization = freezed,
    Object? workExperience = freezed,
    Object? canMaintainEquipment = null,
  }) {
    return _then(
      _$EmployeeProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        specialization: freezed == specialization
            ? _value.specialization
            : specialization // ignore: cast_nullable_to_non_nullable
                  as String?,
        workExperience: freezed == workExperience
            ? _value.workExperience
            : workExperience // ignore: cast_nullable_to_non_nullable
                  as int?,
        canMaintainEquipment: null == canMaintainEquipment
            ? _value.canMaintainEquipment
            : canMaintainEquipment // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmployeeProfileImpl implements _EmployeeProfile {
  const _$EmployeeProfileImpl({
    required this.userId,
    this.specialization,
    this.workExperience,
    this.canMaintainEquipment = false,
  });

  factory _$EmployeeProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmployeeProfileImplFromJson(json);

  @override
  final String userId;
  @override
  final String? specialization;
  @override
  final int? workExperience;
  @override
  @JsonKey()
  final bool canMaintainEquipment;

  @override
  String toString() {
    return 'EmployeeProfile(userId: $userId, specialization: $specialization, workExperience: $workExperience, canMaintainEquipment: $canMaintainEquipment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmployeeProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.specialization, specialization) ||
                other.specialization == specialization) &&
            (identical(other.workExperience, workExperience) ||
                other.workExperience == workExperience) &&
            (identical(other.canMaintainEquipment, canMaintainEquipment) ||
                other.canMaintainEquipment == canMaintainEquipment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    specialization,
    workExperience,
    canMaintainEquipment,
  );

  /// Create a copy of EmployeeProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmployeeProfileImplCopyWith<_$EmployeeProfileImpl> get copyWith =>
      __$$EmployeeProfileImplCopyWithImpl<_$EmployeeProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EmployeeProfileImplToJson(this);
  }
}

abstract class _EmployeeProfile implements EmployeeProfile {
  const factory _EmployeeProfile({
    required final String userId,
    final String? specialization,
    final int? workExperience,
    final bool canMaintainEquipment,
  }) = _$EmployeeProfileImpl;

  factory _EmployeeProfile.fromJson(Map<String, dynamic> json) =
      _$EmployeeProfileImpl.fromJson;

  @override
  String get userId;
  @override
  String? get specialization;
  @override
  int? get workExperience;
  @override
  bool get canMaintainEquipment;

  /// Create a copy of EmployeeProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmployeeProfileImplCopyWith<_$EmployeeProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
