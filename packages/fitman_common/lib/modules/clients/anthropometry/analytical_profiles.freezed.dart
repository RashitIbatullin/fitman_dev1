// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytical_profiles.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WhtrProfile _$WhtrProfileFromJson(Map<String, dynamic> json) {
  return _WhtrProfile.fromJson(json);
}

/// @nodoc
mixin _$WhtrProfile {
  double get ratio => throw _privateConstructorUsedError;
  String get gradation => throw _privateConstructorUsedError;

  /// Serializes this WhtrProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WhtrProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WhtrProfileCopyWith<WhtrProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhtrProfileCopyWith<$Res> {
  factory $WhtrProfileCopyWith(
    WhtrProfile value,
    $Res Function(WhtrProfile) then,
  ) = _$WhtrProfileCopyWithImpl<$Res, WhtrProfile>;
  @useResult
  $Res call({double ratio, String gradation});
}

/// @nodoc
class _$WhtrProfileCopyWithImpl<$Res, $Val extends WhtrProfile>
    implements $WhtrProfileCopyWith<$Res> {
  _$WhtrProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WhtrProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? ratio = null, Object? gradation = null}) {
    return _then(
      _value.copyWith(
            ratio: null == ratio
                ? _value.ratio
                : ratio // ignore: cast_nullable_to_non_nullable
                      as double,
            gradation: null == gradation
                ? _value.gradation
                : gradation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WhtrProfileImplCopyWith<$Res>
    implements $WhtrProfileCopyWith<$Res> {
  factory _$$WhtrProfileImplCopyWith(
    _$WhtrProfileImpl value,
    $Res Function(_$WhtrProfileImpl) then,
  ) = __$$WhtrProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double ratio, String gradation});
}

/// @nodoc
class __$$WhtrProfileImplCopyWithImpl<$Res>
    extends _$WhtrProfileCopyWithImpl<$Res, _$WhtrProfileImpl>
    implements _$$WhtrProfileImplCopyWith<$Res> {
  __$$WhtrProfileImplCopyWithImpl(
    _$WhtrProfileImpl _value,
    $Res Function(_$WhtrProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WhtrProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? ratio = null, Object? gradation = null}) {
    return _then(
      _$WhtrProfileImpl(
        ratio: null == ratio
            ? _value.ratio
            : ratio // ignore: cast_nullable_to_non_nullable
                  as double,
        gradation: null == gradation
            ? _value.gradation
            : gradation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WhtrProfileImpl implements _WhtrProfile {
  const _$WhtrProfileImpl({required this.ratio, required this.gradation});

  factory _$WhtrProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhtrProfileImplFromJson(json);

  @override
  final double ratio;
  @override
  final String gradation;

  @override
  String toString() {
    return 'WhtrProfile(ratio: $ratio, gradation: $gradation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhtrProfileImpl &&
            (identical(other.ratio, ratio) || other.ratio == ratio) &&
            (identical(other.gradation, gradation) ||
                other.gradation == gradation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, ratio, gradation);

  /// Create a copy of WhtrProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WhtrProfileImplCopyWith<_$WhtrProfileImpl> get copyWith =>
      __$$WhtrProfileImplCopyWithImpl<_$WhtrProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WhtrProfileImplToJson(this);
  }
}

abstract class _WhtrProfile implements WhtrProfile {
  const factory _WhtrProfile({
    required final double ratio,
    required final String gradation,
  }) = _$WhtrProfileImpl;

  factory _WhtrProfile.fromJson(Map<String, dynamic> json) =
      _$WhtrProfileImpl.fromJson;

  @override
  double get ratio;
  @override
  String get gradation;

  /// Create a copy of WhtrProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WhtrProfileImplCopyWith<_$WhtrProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MetabolicProfile _$MetabolicProfileFromJson(Map<String, dynamic> json) {
  return _MetabolicProfile.fromJson(json);
}

/// @nodoc
mixin _$MetabolicProfile {
  double get bmr => throw _privateConstructorUsedError;
  double get tdee => throw _privateConstructorUsedError;

  /// Serializes this MetabolicProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MetabolicProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetabolicProfileCopyWith<MetabolicProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetabolicProfileCopyWith<$Res> {
  factory $MetabolicProfileCopyWith(
    MetabolicProfile value,
    $Res Function(MetabolicProfile) then,
  ) = _$MetabolicProfileCopyWithImpl<$Res, MetabolicProfile>;
  @useResult
  $Res call({double bmr, double tdee});
}

/// @nodoc
class _$MetabolicProfileCopyWithImpl<$Res, $Val extends MetabolicProfile>
    implements $MetabolicProfileCopyWith<$Res> {
  _$MetabolicProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MetabolicProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? bmr = null, Object? tdee = null}) {
    return _then(
      _value.copyWith(
            bmr: null == bmr
                ? _value.bmr
                : bmr // ignore: cast_nullable_to_non_nullable
                      as double,
            tdee: null == tdee
                ? _value.tdee
                : tdee // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MetabolicProfileImplCopyWith<$Res>
    implements $MetabolicProfileCopyWith<$Res> {
  factory _$$MetabolicProfileImplCopyWith(
    _$MetabolicProfileImpl value,
    $Res Function(_$MetabolicProfileImpl) then,
  ) = __$$MetabolicProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double bmr, double tdee});
}

/// @nodoc
class __$$MetabolicProfileImplCopyWithImpl<$Res>
    extends _$MetabolicProfileCopyWithImpl<$Res, _$MetabolicProfileImpl>
    implements _$$MetabolicProfileImplCopyWith<$Res> {
  __$$MetabolicProfileImplCopyWithImpl(
    _$MetabolicProfileImpl _value,
    $Res Function(_$MetabolicProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MetabolicProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? bmr = null, Object? tdee = null}) {
    return _then(
      _$MetabolicProfileImpl(
        bmr: null == bmr
            ? _value.bmr
            : bmr // ignore: cast_nullable_to_non_nullable
                  as double,
        tdee: null == tdee
            ? _value.tdee
            : tdee // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MetabolicProfileImpl implements _MetabolicProfile {
  const _$MetabolicProfileImpl({required this.bmr, required this.tdee});

  factory _$MetabolicProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetabolicProfileImplFromJson(json);

  @override
  final double bmr;
  @override
  final double tdee;

  @override
  String toString() {
    return 'MetabolicProfile(bmr: $bmr, tdee: $tdee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetabolicProfileImpl &&
            (identical(other.bmr, bmr) || other.bmr == bmr) &&
            (identical(other.tdee, tdee) || other.tdee == tdee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bmr, tdee);

  /// Create a copy of MetabolicProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetabolicProfileImplCopyWith<_$MetabolicProfileImpl> get copyWith =>
      __$$MetabolicProfileImplCopyWithImpl<_$MetabolicProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MetabolicProfileImplToJson(this);
  }
}

abstract class _MetabolicProfile implements MetabolicProfile {
  const factory _MetabolicProfile({
    required final double bmr,
    required final double tdee,
  }) = _$MetabolicProfileImpl;

  factory _MetabolicProfile.fromJson(Map<String, dynamic> json) =
      _$MetabolicProfileImpl.fromJson;

  @override
  double get bmr;
  @override
  double get tdee;

  /// Create a copy of MetabolicProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetabolicProfileImplCopyWith<_$MetabolicProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
