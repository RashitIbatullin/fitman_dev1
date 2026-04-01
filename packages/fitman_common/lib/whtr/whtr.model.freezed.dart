// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whtr.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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
          WhtrProfile value, $Res Function(WhtrProfile) then) =
      _$WhtrProfileCopyWithImpl<$Res, WhtrProfile>;
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
  $Res call({
    Object? ratio = null,
    Object? gradation = null,
  }) {
    return _then(_value.copyWith(
      ratio: null == ratio
          ? _value.ratio
          : ratio // ignore: cast_nullable_to_non_nullable
              as double,
      gradation: null == gradation
          ? _value.gradation
          : gradation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WhtrProfileImplCopyWith<$Res>
    implements $WhtrProfileCopyWith<$Res> {
  factory _$$WhtrProfileImplCopyWith(
          _$WhtrProfileImpl value, $Res Function(_$WhtrProfileImpl) then) =
      __$$WhtrProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double ratio, String gradation});
}

/// @nodoc
class __$$WhtrProfileImplCopyWithImpl<$Res>
    extends _$WhtrProfileCopyWithImpl<$Res, _$WhtrProfileImpl>
    implements _$$WhtrProfileImplCopyWith<$Res> {
  __$$WhtrProfileImplCopyWithImpl(
      _$WhtrProfileImpl _value, $Res Function(_$WhtrProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of WhtrProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ratio = null,
    Object? gradation = null,
  }) {
    return _then(_$WhtrProfileImpl(
      ratio: null == ratio
          ? _value.ratio
          : ratio // ignore: cast_nullable_to_non_nullable
              as double,
      gradation: null == gradation
          ? _value.gradation
          : gradation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
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
    return _$$WhtrProfileImplToJson(
      this,
    );
  }
}

abstract class _WhtrProfile implements WhtrProfile {
  const factory _WhtrProfile(
      {required final double ratio,
      required final String gradation}) = _$WhtrProfileImpl;

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

WhtrProfiles _$WhtrProfilesFromJson(Map<String, dynamic> json) {
  return _WhtrProfiles.fromJson(json);
}

/// @nodoc
mixin _$WhtrProfiles {
  WhtrProfile get start => throw _privateConstructorUsedError;
  WhtrProfile get finish => throw _privateConstructorUsedError;

  /// Serializes this WhtrProfiles to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WhtrProfiles
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WhtrProfilesCopyWith<WhtrProfiles> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhtrProfilesCopyWith<$Res> {
  factory $WhtrProfilesCopyWith(
          WhtrProfiles value, $Res Function(WhtrProfiles) then) =
      _$WhtrProfilesCopyWithImpl<$Res, WhtrProfiles>;
  @useResult
  $Res call({WhtrProfile start, WhtrProfile finish});

  $WhtrProfileCopyWith<$Res> get start;
  $WhtrProfileCopyWith<$Res> get finish;
}

/// @nodoc
class _$WhtrProfilesCopyWithImpl<$Res, $Val extends WhtrProfiles>
    implements $WhtrProfilesCopyWith<$Res> {
  _$WhtrProfilesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WhtrProfiles
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? finish = null,
  }) {
    return _then(_value.copyWith(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as WhtrProfile,
      finish: null == finish
          ? _value.finish
          : finish // ignore: cast_nullable_to_non_nullable
              as WhtrProfile,
    ) as $Val);
  }

  /// Create a copy of WhtrProfiles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WhtrProfileCopyWith<$Res> get start {
    return $WhtrProfileCopyWith<$Res>(_value.start, (value) {
      return _then(_value.copyWith(start: value) as $Val);
    });
  }

  /// Create a copy of WhtrProfiles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WhtrProfileCopyWith<$Res> get finish {
    return $WhtrProfileCopyWith<$Res>(_value.finish, (value) {
      return _then(_value.copyWith(finish: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WhtrProfilesImplCopyWith<$Res>
    implements $WhtrProfilesCopyWith<$Res> {
  factory _$$WhtrProfilesImplCopyWith(
          _$WhtrProfilesImpl value, $Res Function(_$WhtrProfilesImpl) then) =
      __$$WhtrProfilesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({WhtrProfile start, WhtrProfile finish});

  @override
  $WhtrProfileCopyWith<$Res> get start;
  @override
  $WhtrProfileCopyWith<$Res> get finish;
}

/// @nodoc
class __$$WhtrProfilesImplCopyWithImpl<$Res>
    extends _$WhtrProfilesCopyWithImpl<$Res, _$WhtrProfilesImpl>
    implements _$$WhtrProfilesImplCopyWith<$Res> {
  __$$WhtrProfilesImplCopyWithImpl(
      _$WhtrProfilesImpl _value, $Res Function(_$WhtrProfilesImpl) _then)
      : super(_value, _then);

  /// Create a copy of WhtrProfiles
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? finish = null,
  }) {
    return _then(_$WhtrProfilesImpl(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as WhtrProfile,
      finish: null == finish
          ? _value.finish
          : finish // ignore: cast_nullable_to_non_nullable
              as WhtrProfile,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WhtrProfilesImpl implements _WhtrProfiles {
  const _$WhtrProfilesImpl({required this.start, required this.finish});

  factory _$WhtrProfilesImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhtrProfilesImplFromJson(json);

  @override
  final WhtrProfile start;
  @override
  final WhtrProfile finish;

  @override
  String toString() {
    return 'WhtrProfiles(start: $start, finish: $finish)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhtrProfilesImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.finish, finish) || other.finish == finish));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, start, finish);

  /// Create a copy of WhtrProfiles
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WhtrProfilesImplCopyWith<_$WhtrProfilesImpl> get copyWith =>
      __$$WhtrProfilesImplCopyWithImpl<_$WhtrProfilesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WhtrProfilesImplToJson(
      this,
    );
  }
}

abstract class _WhtrProfiles implements WhtrProfiles {
  const factory _WhtrProfiles(
      {required final WhtrProfile start,
      required final WhtrProfile finish}) = _$WhtrProfilesImpl;

  factory _WhtrProfiles.fromJson(Map<String, dynamic> json) =
      _$WhtrProfilesImpl.fromJson;

  @override
  WhtrProfile get start;
  @override
  WhtrProfile get finish;

  /// Create a copy of WhtrProfiles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WhtrProfilesImplCopyWith<_$WhtrProfilesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
