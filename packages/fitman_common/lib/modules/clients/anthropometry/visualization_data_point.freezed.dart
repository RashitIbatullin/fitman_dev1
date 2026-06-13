// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visualization_data_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VisualizationDataPoint _$VisualizationDataPointFromJson(
  Map<String, dynamic> json,
) {
  return _VisualizationDataPoint.fromJson(json);
}

/// @nodoc
mixin _$VisualizationDataPoint {
  DateTime get dateTime => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int get shouldersCirc => throw _privateConstructorUsedError;
  int get breastCirc => throw _privateConstructorUsedError;
  int get waistCirc => throw _privateConstructorUsedError;
  int get hipsCirc => throw _privateConstructorUsedError;
  double? get fatPercentage => throw _privateConstructorUsedError;
  double? get muscleMass =>
      throw _privateConstructorUsedError; // Calculated values
  double? get whtrRatio => throw _privateConstructorUsedError;
  double? get bmr => throw _privateConstructorUsedError;
  double? get tdee => throw _privateConstructorUsedError;

  /// Serializes this VisualizationDataPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisualizationDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisualizationDataPointCopyWith<VisualizationDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisualizationDataPointCopyWith<$Res> {
  factory $VisualizationDataPointCopyWith(
    VisualizationDataPoint value,
    $Res Function(VisualizationDataPoint) then,
  ) = _$VisualizationDataPointCopyWithImpl<$Res, VisualizationDataPoint>;
  @useResult
  $Res call({
    DateTime dateTime,
    double weight,
    int shouldersCirc,
    int breastCirc,
    int waistCirc,
    int hipsCirc,
    double? fatPercentage,
    double? muscleMass,
    double? whtrRatio,
    double? bmr,
    double? tdee,
  });
}

/// @nodoc
class _$VisualizationDataPointCopyWithImpl<
  $Res,
  $Val extends VisualizationDataPoint
>
    implements $VisualizationDataPointCopyWith<$Res> {
  _$VisualizationDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisualizationDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateTime = null,
    Object? weight = null,
    Object? shouldersCirc = null,
    Object? breastCirc = null,
    Object? waistCirc = null,
    Object? hipsCirc = null,
    Object? fatPercentage = freezed,
    Object? muscleMass = freezed,
    Object? whtrRatio = freezed,
    Object? bmr = freezed,
    Object? tdee = freezed,
  }) {
    return _then(
      _value.copyWith(
            dateTime: null == dateTime
                ? _value.dateTime
                : dateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
            shouldersCirc: null == shouldersCirc
                ? _value.shouldersCirc
                : shouldersCirc // ignore: cast_nullable_to_non_nullable
                      as int,
            breastCirc: null == breastCirc
                ? _value.breastCirc
                : breastCirc // ignore: cast_nullable_to_non_nullable
                      as int,
            waistCirc: null == waistCirc
                ? _value.waistCirc
                : waistCirc // ignore: cast_nullable_to_non_nullable
                      as int,
            hipsCirc: null == hipsCirc
                ? _value.hipsCirc
                : hipsCirc // ignore: cast_nullable_to_non_nullable
                      as int,
            fatPercentage: freezed == fatPercentage
                ? _value.fatPercentage
                : fatPercentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            muscleMass: freezed == muscleMass
                ? _value.muscleMass
                : muscleMass // ignore: cast_nullable_to_non_nullable
                      as double?,
            whtrRatio: freezed == whtrRatio
                ? _value.whtrRatio
                : whtrRatio // ignore: cast_nullable_to_non_nullable
                      as double?,
            bmr: freezed == bmr
                ? _value.bmr
                : bmr // ignore: cast_nullable_to_non_nullable
                      as double?,
            tdee: freezed == tdee
                ? _value.tdee
                : tdee // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisualizationDataPointImplCopyWith<$Res>
    implements $VisualizationDataPointCopyWith<$Res> {
  factory _$$VisualizationDataPointImplCopyWith(
    _$VisualizationDataPointImpl value,
    $Res Function(_$VisualizationDataPointImpl) then,
  ) = __$$VisualizationDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime dateTime,
    double weight,
    int shouldersCirc,
    int breastCirc,
    int waistCirc,
    int hipsCirc,
    double? fatPercentage,
    double? muscleMass,
    double? whtrRatio,
    double? bmr,
    double? tdee,
  });
}

/// @nodoc
class __$$VisualizationDataPointImplCopyWithImpl<$Res>
    extends
        _$VisualizationDataPointCopyWithImpl<$Res, _$VisualizationDataPointImpl>
    implements _$$VisualizationDataPointImplCopyWith<$Res> {
  __$$VisualizationDataPointImplCopyWithImpl(
    _$VisualizationDataPointImpl _value,
    $Res Function(_$VisualizationDataPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisualizationDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateTime = null,
    Object? weight = null,
    Object? shouldersCirc = null,
    Object? breastCirc = null,
    Object? waistCirc = null,
    Object? hipsCirc = null,
    Object? fatPercentage = freezed,
    Object? muscleMass = freezed,
    Object? whtrRatio = freezed,
    Object? bmr = freezed,
    Object? tdee = freezed,
  }) {
    return _then(
      _$VisualizationDataPointImpl(
        dateTime: null == dateTime
            ? _value.dateTime
            : dateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        shouldersCirc: null == shouldersCirc
            ? _value.shouldersCirc
            : shouldersCirc // ignore: cast_nullable_to_non_nullable
                  as int,
        breastCirc: null == breastCirc
            ? _value.breastCirc
            : breastCirc // ignore: cast_nullable_to_non_nullable
                  as int,
        waistCirc: null == waistCirc
            ? _value.waistCirc
            : waistCirc // ignore: cast_nullable_to_non_nullable
                  as int,
        hipsCirc: null == hipsCirc
            ? _value.hipsCirc
            : hipsCirc // ignore: cast_nullable_to_non_nullable
                  as int,
        fatPercentage: freezed == fatPercentage
            ? _value.fatPercentage
            : fatPercentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        muscleMass: freezed == muscleMass
            ? _value.muscleMass
            : muscleMass // ignore: cast_nullable_to_non_nullable
                  as double?,
        whtrRatio: freezed == whtrRatio
            ? _value.whtrRatio
            : whtrRatio // ignore: cast_nullable_to_non_nullable
                  as double?,
        bmr: freezed == bmr
            ? _value.bmr
            : bmr // ignore: cast_nullable_to_non_nullable
                  as double?,
        tdee: freezed == tdee
            ? _value.tdee
            : tdee // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisualizationDataPointImpl implements _VisualizationDataPoint {
  const _$VisualizationDataPointImpl({
    required this.dateTime,
    required this.weight,
    required this.shouldersCirc,
    required this.breastCirc,
    required this.waistCirc,
    required this.hipsCirc,
    this.fatPercentage,
    this.muscleMass,
    this.whtrRatio,
    this.bmr,
    this.tdee,
  });

  factory _$VisualizationDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisualizationDataPointImplFromJson(json);

  @override
  final DateTime dateTime;
  @override
  final double weight;
  @override
  final int shouldersCirc;
  @override
  final int breastCirc;
  @override
  final int waistCirc;
  @override
  final int hipsCirc;
  @override
  final double? fatPercentage;
  @override
  final double? muscleMass;
  // Calculated values
  @override
  final double? whtrRatio;
  @override
  final double? bmr;
  @override
  final double? tdee;

  @override
  String toString() {
    return 'VisualizationDataPoint(dateTime: $dateTime, weight: $weight, shouldersCirc: $shouldersCirc, breastCirc: $breastCirc, waistCirc: $waistCirc, hipsCirc: $hipsCirc, fatPercentage: $fatPercentage, muscleMass: $muscleMass, whtrRatio: $whtrRatio, bmr: $bmr, tdee: $tdee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisualizationDataPointImpl &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.shouldersCirc, shouldersCirc) ||
                other.shouldersCirc == shouldersCirc) &&
            (identical(other.breastCirc, breastCirc) ||
                other.breastCirc == breastCirc) &&
            (identical(other.waistCirc, waistCirc) ||
                other.waistCirc == waistCirc) &&
            (identical(other.hipsCirc, hipsCirc) ||
                other.hipsCirc == hipsCirc) &&
            (identical(other.fatPercentage, fatPercentage) ||
                other.fatPercentage == fatPercentage) &&
            (identical(other.muscleMass, muscleMass) ||
                other.muscleMass == muscleMass) &&
            (identical(other.whtrRatio, whtrRatio) ||
                other.whtrRatio == whtrRatio) &&
            (identical(other.bmr, bmr) || other.bmr == bmr) &&
            (identical(other.tdee, tdee) || other.tdee == tdee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dateTime,
    weight,
    shouldersCirc,
    breastCirc,
    waistCirc,
    hipsCirc,
    fatPercentage,
    muscleMass,
    whtrRatio,
    bmr,
    tdee,
  );

  /// Create a copy of VisualizationDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisualizationDataPointImplCopyWith<_$VisualizationDataPointImpl>
  get copyWith =>
      __$$VisualizationDataPointImplCopyWithImpl<_$VisualizationDataPointImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VisualizationDataPointImplToJson(this);
  }
}

abstract class _VisualizationDataPoint implements VisualizationDataPoint {
  const factory _VisualizationDataPoint({
    required final DateTime dateTime,
    required final double weight,
    required final int shouldersCirc,
    required final int breastCirc,
    required final int waistCirc,
    required final int hipsCirc,
    final double? fatPercentage,
    final double? muscleMass,
    final double? whtrRatio,
    final double? bmr,
    final double? tdee,
  }) = _$VisualizationDataPointImpl;

  factory _VisualizationDataPoint.fromJson(Map<String, dynamic> json) =
      _$VisualizationDataPointImpl.fromJson;

  @override
  DateTime get dateTime;
  @override
  double get weight;
  @override
  int get shouldersCirc;
  @override
  int get breastCirc;
  @override
  int get waistCirc;
  @override
  int get hipsCirc;
  @override
  double? get fatPercentage;
  @override
  double? get muscleMass; // Calculated values
  @override
  double? get whtrRatio;
  @override
  double? get bmr;
  @override
  double? get tdee;

  /// Create a copy of VisualizationDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisualizationDataPointImplCopyWith<_$VisualizationDataPointImpl>
  get copyWith => throw _privateConstructorUsedError;
}
