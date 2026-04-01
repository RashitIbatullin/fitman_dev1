// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anthropometry_data.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnthropometryData _$AnthropometryDataFromJson(Map<String, dynamic> json) {
  return _AnthropometryData.fromJson(json);
}

/// @nodoc
mixin _$AnthropometryData {
  AnthropometryFixed get fixed => throw _privateConstructorUsedError;
  AnthropometryMeasurements get start => throw _privateConstructorUsedError;
  AnthropometryMeasurements get finish => throw _privateConstructorUsedError;

  /// Serializes this AnthropometryData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnthropometryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnthropometryDataCopyWith<AnthropometryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnthropometryDataCopyWith<$Res> {
  factory $AnthropometryDataCopyWith(
          AnthropometryData value, $Res Function(AnthropometryData) then) =
      _$AnthropometryDataCopyWithImpl<$Res, AnthropometryData>;
  @useResult
  $Res call(
      {AnthropometryFixed fixed,
      AnthropometryMeasurements start,
      AnthropometryMeasurements finish});

  $AnthropometryFixedCopyWith<$Res> get fixed;
  $AnthropometryMeasurementsCopyWith<$Res> get start;
  $AnthropometryMeasurementsCopyWith<$Res> get finish;
}

/// @nodoc
class _$AnthropometryDataCopyWithImpl<$Res, $Val extends AnthropometryData>
    implements $AnthropometryDataCopyWith<$Res> {
  _$AnthropometryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnthropometryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fixed = null,
    Object? start = null,
    Object? finish = null,
  }) {
    return _then(_value.copyWith(
      fixed: null == fixed
          ? _value.fixed
          : fixed // ignore: cast_nullable_to_non_nullable
              as AnthropometryFixed,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as AnthropometryMeasurements,
      finish: null == finish
          ? _value.finish
          : finish // ignore: cast_nullable_to_non_nullable
              as AnthropometryMeasurements,
    ) as $Val);
  }

  /// Create a copy of AnthropometryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnthropometryFixedCopyWith<$Res> get fixed {
    return $AnthropometryFixedCopyWith<$Res>(_value.fixed, (value) {
      return _then(_value.copyWith(fixed: value) as $Val);
    });
  }

  /// Create a copy of AnthropometryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnthropometryMeasurementsCopyWith<$Res> get start {
    return $AnthropometryMeasurementsCopyWith<$Res>(_value.start, (value) {
      return _then(_value.copyWith(start: value) as $Val);
    });
  }

  /// Create a copy of AnthropometryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnthropometryMeasurementsCopyWith<$Res> get finish {
    return $AnthropometryMeasurementsCopyWith<$Res>(_value.finish, (value) {
      return _then(_value.copyWith(finish: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnthropometryDataImplCopyWith<$Res>
    implements $AnthropometryDataCopyWith<$Res> {
  factory _$$AnthropometryDataImplCopyWith(_$AnthropometryDataImpl value,
          $Res Function(_$AnthropometryDataImpl) then) =
      __$$AnthropometryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AnthropometryFixed fixed,
      AnthropometryMeasurements start,
      AnthropometryMeasurements finish});

  @override
  $AnthropometryFixedCopyWith<$Res> get fixed;
  @override
  $AnthropometryMeasurementsCopyWith<$Res> get start;
  @override
  $AnthropometryMeasurementsCopyWith<$Res> get finish;
}

/// @nodoc
class __$$AnthropometryDataImplCopyWithImpl<$Res>
    extends _$AnthropometryDataCopyWithImpl<$Res, _$AnthropometryDataImpl>
    implements _$$AnthropometryDataImplCopyWith<$Res> {
  __$$AnthropometryDataImplCopyWithImpl(_$AnthropometryDataImpl _value,
      $Res Function(_$AnthropometryDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnthropometryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fixed = null,
    Object? start = null,
    Object? finish = null,
  }) {
    return _then(_$AnthropometryDataImpl(
      fixed: null == fixed
          ? _value.fixed
          : fixed // ignore: cast_nullable_to_non_nullable
              as AnthropometryFixed,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as AnthropometryMeasurements,
      finish: null == finish
          ? _value.finish
          : finish // ignore: cast_nullable_to_non_nullable
              as AnthropometryMeasurements,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnthropometryDataImpl implements _AnthropometryData {
  const _$AnthropometryDataImpl(
      {required this.fixed, required this.start, required this.finish});

  factory _$AnthropometryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnthropometryDataImplFromJson(json);

  @override
  final AnthropometryFixed fixed;
  @override
  final AnthropometryMeasurements start;
  @override
  final AnthropometryMeasurements finish;

  @override
  String toString() {
    return 'AnthropometryData(fixed: $fixed, start: $start, finish: $finish)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnthropometryDataImpl &&
            (identical(other.fixed, fixed) || other.fixed == fixed) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.finish, finish) || other.finish == finish));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fixed, start, finish);

  /// Create a copy of AnthropometryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnthropometryDataImplCopyWith<_$AnthropometryDataImpl> get copyWith =>
      __$$AnthropometryDataImplCopyWithImpl<_$AnthropometryDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnthropometryDataImplToJson(
      this,
    );
  }
}

abstract class _AnthropometryData implements AnthropometryData {
  const factory _AnthropometryData(
          {required final AnthropometryFixed fixed,
          required final AnthropometryMeasurements start,
          required final AnthropometryMeasurements finish}) =
      _$AnthropometryDataImpl;

  factory _AnthropometryData.fromJson(Map<String, dynamic> json) =
      _$AnthropometryDataImpl.fromJson;

  @override
  AnthropometryFixed get fixed;
  @override
  AnthropometryMeasurements get start;
  @override
  AnthropometryMeasurements get finish;

  /// Create a copy of AnthropometryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnthropometryDataImplCopyWith<_$AnthropometryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnthropometryFixed _$AnthropometryFixedFromJson(Map<String, dynamic> json) {
  return _AnthropometryFixed.fromJson(json);
}

/// @nodoc
mixin _$AnthropometryFixed {
  int? get height => throw _privateConstructorUsedError;
  int? get wristCirc => throw _privateConstructorUsedError;
  int? get ankleCirc => throw _privateConstructorUsedError;

  /// Serializes this AnthropometryFixed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnthropometryFixed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnthropometryFixedCopyWith<AnthropometryFixed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnthropometryFixedCopyWith<$Res> {
  factory $AnthropometryFixedCopyWith(
          AnthropometryFixed value, $Res Function(AnthropometryFixed) then) =
      _$AnthropometryFixedCopyWithImpl<$Res, AnthropometryFixed>;
  @useResult
  $Res call({int? height, int? wristCirc, int? ankleCirc});
}

/// @nodoc
class _$AnthropometryFixedCopyWithImpl<$Res, $Val extends AnthropometryFixed>
    implements $AnthropometryFixedCopyWith<$Res> {
  _$AnthropometryFixedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnthropometryFixed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = freezed,
    Object? wristCirc = freezed,
    Object? ankleCirc = freezed,
  }) {
    return _then(_value.copyWith(
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      wristCirc: freezed == wristCirc
          ? _value.wristCirc
          : wristCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      ankleCirc: freezed == ankleCirc
          ? _value.ankleCirc
          : ankleCirc // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnthropometryFixedImplCopyWith<$Res>
    implements $AnthropometryFixedCopyWith<$Res> {
  factory _$$AnthropometryFixedImplCopyWith(_$AnthropometryFixedImpl value,
          $Res Function(_$AnthropometryFixedImpl) then) =
      __$$AnthropometryFixedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? height, int? wristCirc, int? ankleCirc});
}

/// @nodoc
class __$$AnthropometryFixedImplCopyWithImpl<$Res>
    extends _$AnthropometryFixedCopyWithImpl<$Res, _$AnthropometryFixedImpl>
    implements _$$AnthropometryFixedImplCopyWith<$Res> {
  __$$AnthropometryFixedImplCopyWithImpl(_$AnthropometryFixedImpl _value,
      $Res Function(_$AnthropometryFixedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnthropometryFixed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = freezed,
    Object? wristCirc = freezed,
    Object? ankleCirc = freezed,
  }) {
    return _then(_$AnthropometryFixedImpl(
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      wristCirc: freezed == wristCirc
          ? _value.wristCirc
          : wristCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      ankleCirc: freezed == ankleCirc
          ? _value.ankleCirc
          : ankleCirc // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnthropometryFixedImpl implements _AnthropometryFixed {
  const _$AnthropometryFixedImpl({this.height, this.wristCirc, this.ankleCirc});

  factory _$AnthropometryFixedImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnthropometryFixedImplFromJson(json);

  @override
  final int? height;
  @override
  final int? wristCirc;
  @override
  final int? ankleCirc;

  @override
  String toString() {
    return 'AnthropometryFixed(height: $height, wristCirc: $wristCirc, ankleCirc: $ankleCirc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnthropometryFixedImpl &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.wristCirc, wristCirc) ||
                other.wristCirc == wristCirc) &&
            (identical(other.ankleCirc, ankleCirc) ||
                other.ankleCirc == ankleCirc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, height, wristCirc, ankleCirc);

  /// Create a copy of AnthropometryFixed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnthropometryFixedImplCopyWith<_$AnthropometryFixedImpl> get copyWith =>
      __$$AnthropometryFixedImplCopyWithImpl<_$AnthropometryFixedImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnthropometryFixedImplToJson(
      this,
    );
  }
}

abstract class _AnthropometryFixed implements AnthropometryFixed {
  const factory _AnthropometryFixed(
      {final int? height,
      final int? wristCirc,
      final int? ankleCirc}) = _$AnthropometryFixedImpl;

  factory _AnthropometryFixed.fromJson(Map<String, dynamic> json) =
      _$AnthropometryFixedImpl.fromJson;

  @override
  int? get height;
  @override
  int? get wristCirc;
  @override
  int? get ankleCirc;

  /// Create a copy of AnthropometryFixed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnthropometryFixedImplCopyWith<_$AnthropometryFixedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnthropometryMeasurements _$AnthropometryMeasurementsFromJson(
    Map<String, dynamic> json) {
  return _AnthropometryMeasurements.fromJson(json);
}

/// @nodoc
mixin _$AnthropometryMeasurements {
  double? get weight => throw _privateConstructorUsedError;
  int? get shouldersCirc => throw _privateConstructorUsedError;
  int? get breastCirc => throw _privateConstructorUsedError;
  int? get waistCirc => throw _privateConstructorUsedError;
  int? get hipsCirc => throw _privateConstructorUsedError;
  String? get photo => throw _privateConstructorUsedError;
  DateTime? get photoDateTime => throw _privateConstructorUsedError;
  String? get profilePhoto => throw _privateConstructorUsedError;
  DateTime? get profilePhotoDateTime => throw _privateConstructorUsedError;

  /// Serializes this AnthropometryMeasurements to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnthropometryMeasurements
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnthropometryMeasurementsCopyWith<AnthropometryMeasurements> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnthropometryMeasurementsCopyWith<$Res> {
  factory $AnthropometryMeasurementsCopyWith(AnthropometryMeasurements value,
          $Res Function(AnthropometryMeasurements) then) =
      _$AnthropometryMeasurementsCopyWithImpl<$Res, AnthropometryMeasurements>;
  @useResult
  $Res call(
      {double? weight,
      int? shouldersCirc,
      int? breastCirc,
      int? waistCirc,
      int? hipsCirc,
      String? photo,
      DateTime? photoDateTime,
      String? profilePhoto,
      DateTime? profilePhotoDateTime});
}

/// @nodoc
class _$AnthropometryMeasurementsCopyWithImpl<$Res,
        $Val extends AnthropometryMeasurements>
    implements $AnthropometryMeasurementsCopyWith<$Res> {
  _$AnthropometryMeasurementsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnthropometryMeasurements
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = freezed,
    Object? shouldersCirc = freezed,
    Object? breastCirc = freezed,
    Object? waistCirc = freezed,
    Object? hipsCirc = freezed,
    Object? photo = freezed,
    Object? photoDateTime = freezed,
    Object? profilePhoto = freezed,
    Object? profilePhotoDateTime = freezed,
  }) {
    return _then(_value.copyWith(
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      shouldersCirc: freezed == shouldersCirc
          ? _value.shouldersCirc
          : shouldersCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      breastCirc: freezed == breastCirc
          ? _value.breastCirc
          : breastCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      waistCirc: freezed == waistCirc
          ? _value.waistCirc
          : waistCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      hipsCirc: freezed == hipsCirc
          ? _value.hipsCirc
          : hipsCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      photo: freezed == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      photoDateTime: freezed == photoDateTime
          ? _value.photoDateTime
          : photoDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      profilePhoto: freezed == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePhotoDateTime: freezed == profilePhotoDateTime
          ? _value.profilePhotoDateTime
          : profilePhotoDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnthropometryMeasurementsImplCopyWith<$Res>
    implements $AnthropometryMeasurementsCopyWith<$Res> {
  factory _$$AnthropometryMeasurementsImplCopyWith(
          _$AnthropometryMeasurementsImpl value,
          $Res Function(_$AnthropometryMeasurementsImpl) then) =
      __$$AnthropometryMeasurementsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double? weight,
      int? shouldersCirc,
      int? breastCirc,
      int? waistCirc,
      int? hipsCirc,
      String? photo,
      DateTime? photoDateTime,
      String? profilePhoto,
      DateTime? profilePhotoDateTime});
}

/// @nodoc
class __$$AnthropometryMeasurementsImplCopyWithImpl<$Res>
    extends _$AnthropometryMeasurementsCopyWithImpl<$Res,
        _$AnthropometryMeasurementsImpl>
    implements _$$AnthropometryMeasurementsImplCopyWith<$Res> {
  __$$AnthropometryMeasurementsImplCopyWithImpl(
      _$AnthropometryMeasurementsImpl _value,
      $Res Function(_$AnthropometryMeasurementsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnthropometryMeasurements
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = freezed,
    Object? shouldersCirc = freezed,
    Object? breastCirc = freezed,
    Object? waistCirc = freezed,
    Object? hipsCirc = freezed,
    Object? photo = freezed,
    Object? photoDateTime = freezed,
    Object? profilePhoto = freezed,
    Object? profilePhotoDateTime = freezed,
  }) {
    return _then(_$AnthropometryMeasurementsImpl(
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      shouldersCirc: freezed == shouldersCirc
          ? _value.shouldersCirc
          : shouldersCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      breastCirc: freezed == breastCirc
          ? _value.breastCirc
          : breastCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      waistCirc: freezed == waistCirc
          ? _value.waistCirc
          : waistCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      hipsCirc: freezed == hipsCirc
          ? _value.hipsCirc
          : hipsCirc // ignore: cast_nullable_to_non_nullable
              as int?,
      photo: freezed == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      photoDateTime: freezed == photoDateTime
          ? _value.photoDateTime
          : photoDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      profilePhoto: freezed == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePhotoDateTime: freezed == profilePhotoDateTime
          ? _value.profilePhotoDateTime
          : profilePhotoDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnthropometryMeasurementsImpl implements _AnthropometryMeasurements {
  const _$AnthropometryMeasurementsImpl(
      {this.weight,
      this.shouldersCirc,
      this.breastCirc,
      this.waistCirc,
      this.hipsCirc,
      this.photo,
      this.photoDateTime,
      this.profilePhoto,
      this.profilePhotoDateTime});

  factory _$AnthropometryMeasurementsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnthropometryMeasurementsImplFromJson(json);

  @override
  final double? weight;
  @override
  final int? shouldersCirc;
  @override
  final int? breastCirc;
  @override
  final int? waistCirc;
  @override
  final int? hipsCirc;
  @override
  final String? photo;
  @override
  final DateTime? photoDateTime;
  @override
  final String? profilePhoto;
  @override
  final DateTime? profilePhotoDateTime;

  @override
  String toString() {
    return 'AnthropometryMeasurements(weight: $weight, shouldersCirc: $shouldersCirc, breastCirc: $breastCirc, waistCirc: $waistCirc, hipsCirc: $hipsCirc, photo: $photo, photoDateTime: $photoDateTime, profilePhoto: $profilePhoto, profilePhotoDateTime: $profilePhotoDateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnthropometryMeasurementsImpl &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.shouldersCirc, shouldersCirc) ||
                other.shouldersCirc == shouldersCirc) &&
            (identical(other.breastCirc, breastCirc) ||
                other.breastCirc == breastCirc) &&
            (identical(other.waistCirc, waistCirc) ||
                other.waistCirc == waistCirc) &&
            (identical(other.hipsCirc, hipsCirc) ||
                other.hipsCirc == hipsCirc) &&
            (identical(other.photo, photo) || other.photo == photo) &&
            (identical(other.photoDateTime, photoDateTime) ||
                other.photoDateTime == photoDateTime) &&
            (identical(other.profilePhoto, profilePhoto) ||
                other.profilePhoto == profilePhoto) &&
            (identical(other.profilePhotoDateTime, profilePhotoDateTime) ||
                other.profilePhotoDateTime == profilePhotoDateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      weight,
      shouldersCirc,
      breastCirc,
      waistCirc,
      hipsCirc,
      photo,
      photoDateTime,
      profilePhoto,
      profilePhotoDateTime);

  /// Create a copy of AnthropometryMeasurements
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnthropometryMeasurementsImplCopyWith<_$AnthropometryMeasurementsImpl>
      get copyWith => __$$AnthropometryMeasurementsImplCopyWithImpl<
          _$AnthropometryMeasurementsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnthropometryMeasurementsImplToJson(
      this,
    );
  }
}

abstract class _AnthropometryMeasurements implements AnthropometryMeasurements {
  const factory _AnthropometryMeasurements(
      {final double? weight,
      final int? shouldersCirc,
      final int? breastCirc,
      final int? waistCirc,
      final int? hipsCirc,
      final String? photo,
      final DateTime? photoDateTime,
      final String? profilePhoto,
      final DateTime? profilePhotoDateTime}) = _$AnthropometryMeasurementsImpl;

  factory _AnthropometryMeasurements.fromJson(Map<String, dynamic> json) =
      _$AnthropometryMeasurementsImpl.fromJson;

  @override
  double? get weight;
  @override
  int? get shouldersCirc;
  @override
  int? get breastCirc;
  @override
  int? get waistCirc;
  @override
  int? get hipsCirc;
  @override
  String? get photo;
  @override
  DateTime? get photoDateTime;
  @override
  String? get profilePhoto;
  @override
  DateTime? get profilePhotoDateTime;

  /// Create a copy of AnthropometryMeasurements
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnthropometryMeasurementsImplCopyWith<_$AnthropometryMeasurementsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
