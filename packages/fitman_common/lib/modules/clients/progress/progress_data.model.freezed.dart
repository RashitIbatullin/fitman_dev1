// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_data.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgressData _$ProgressDataFromJson(Map<String, dynamic> json) {
  return _ProgressData.fromJson(json);
}

/// @nodoc
mixin _$ProgressData {
  List<ChartDataPoint> get weight => throw _privateConstructorUsedError;
  List<ChartDataPoint> get calories => throw _privateConstructorUsedError;
  List<ChartDataPoint> get balance => throw _privateConstructorUsedError;
  KpiData get kpi => throw _privateConstructorUsedError;
  String get recommendations => throw _privateConstructorUsedError;

  /// Serializes this ProgressData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressDataCopyWith<ProgressData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressDataCopyWith<$Res> {
  factory $ProgressDataCopyWith(
          ProgressData value, $Res Function(ProgressData) then) =
      _$ProgressDataCopyWithImpl<$Res, ProgressData>;
  @useResult
  $Res call(
      {List<ChartDataPoint> weight,
      List<ChartDataPoint> calories,
      List<ChartDataPoint> balance,
      KpiData kpi,
      String recommendations});

  $KpiDataCopyWith<$Res> get kpi;
}

/// @nodoc
class _$ProgressDataCopyWithImpl<$Res, $Val extends ProgressData>
    implements $ProgressDataCopyWith<$Res> {
  _$ProgressDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? calories = null,
    Object? balance = null,
    Object? kpi = null,
    Object? recommendations = null,
  }) {
    return _then(_value.copyWith(
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      kpi: null == kpi
          ? _value.kpi
          : kpi // ignore: cast_nullable_to_non_nullable
              as KpiData,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $KpiDataCopyWith<$Res> get kpi {
    return $KpiDataCopyWith<$Res>(_value.kpi, (value) {
      return _then(_value.copyWith(kpi: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProgressDataImplCopyWith<$Res>
    implements $ProgressDataCopyWith<$Res> {
  factory _$$ProgressDataImplCopyWith(
          _$ProgressDataImpl value, $Res Function(_$ProgressDataImpl) then) =
      __$$ProgressDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ChartDataPoint> weight,
      List<ChartDataPoint> calories,
      List<ChartDataPoint> balance,
      KpiData kpi,
      String recommendations});

  @override
  $KpiDataCopyWith<$Res> get kpi;
}

/// @nodoc
class __$$ProgressDataImplCopyWithImpl<$Res>
    extends _$ProgressDataCopyWithImpl<$Res, _$ProgressDataImpl>
    implements _$$ProgressDataImplCopyWith<$Res> {
  __$$ProgressDataImplCopyWithImpl(
      _$ProgressDataImpl _value, $Res Function(_$ProgressDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? calories = null,
    Object? balance = null,
    Object? kpi = null,
    Object? recommendations = null,
  }) {
    return _then(_$ProgressDataImpl(
      weight: null == weight
          ? _value._weight
          : weight // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      calories: null == calories
          ? _value._calories
          : calories // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      balance: null == balance
          ? _value._balance
          : balance // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      kpi: null == kpi
          ? _value.kpi
          : kpi // ignore: cast_nullable_to_non_nullable
              as KpiData,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressDataImpl implements _ProgressData {
  const _$ProgressDataImpl(
      {required final List<ChartDataPoint> weight,
      required final List<ChartDataPoint> calories,
      required final List<ChartDataPoint> balance,
      required this.kpi,
      required this.recommendations})
      : _weight = weight,
        _calories = calories,
        _balance = balance;

  factory _$ProgressDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressDataImplFromJson(json);

  final List<ChartDataPoint> _weight;
  @override
  List<ChartDataPoint> get weight {
    if (_weight is EqualUnmodifiableListView) return _weight;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weight);
  }

  final List<ChartDataPoint> _calories;
  @override
  List<ChartDataPoint> get calories {
    if (_calories is EqualUnmodifiableListView) return _calories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_calories);
  }

  final List<ChartDataPoint> _balance;
  @override
  List<ChartDataPoint> get balance {
    if (_balance is EqualUnmodifiableListView) return _balance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_balance);
  }

  @override
  final KpiData kpi;
  @override
  final String recommendations;

  @override
  String toString() {
    return 'ProgressData(weight: $weight, calories: $calories, balance: $balance, kpi: $kpi, recommendations: $recommendations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressDataImpl &&
            const DeepCollectionEquality().equals(other._weight, _weight) &&
            const DeepCollectionEquality().equals(other._calories, _calories) &&
            const DeepCollectionEquality().equals(other._balance, _balance) &&
            (identical(other.kpi, kpi) || other.kpi == kpi) &&
            (identical(other.recommendations, recommendations) ||
                other.recommendations == recommendations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_weight),
      const DeepCollectionEquality().hash(_calories),
      const DeepCollectionEquality().hash(_balance),
      kpi,
      recommendations);

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressDataImplCopyWith<_$ProgressDataImpl> get copyWith =>
      __$$ProgressDataImplCopyWithImpl<_$ProgressDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressDataImplToJson(
      this,
    );
  }
}

abstract class _ProgressData implements ProgressData {
  const factory _ProgressData(
      {required final List<ChartDataPoint> weight,
      required final List<ChartDataPoint> calories,
      required final List<ChartDataPoint> balance,
      required final KpiData kpi,
      required final String recommendations}) = _$ProgressDataImpl;

  factory _ProgressData.fromJson(Map<String, dynamic> json) =
      _$ProgressDataImpl.fromJson;

  @override
  List<ChartDataPoint> get weight;
  @override
  List<ChartDataPoint> get calories;
  @override
  List<ChartDataPoint> get balance;
  @override
  KpiData get kpi;
  @override
  String get recommendations;

  /// Create a copy of ProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressDataImplCopyWith<_$ProgressDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChartDataPoint _$ChartDataPointFromJson(Map<String, dynamic> json) {
  return _ChartDataPoint.fromJson(json);
}

/// @nodoc
mixin _$ChartDataPoint {
  DateTime get date => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;

  /// Serializes this ChartDataPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChartDataPointCopyWith<ChartDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartDataPointCopyWith<$Res> {
  factory $ChartDataPointCopyWith(
          ChartDataPoint value, $Res Function(ChartDataPoint) then) =
      _$ChartDataPointCopyWithImpl<$Res, ChartDataPoint>;
  @useResult
  $Res call({DateTime date, double value});
}

/// @nodoc
class _$ChartDataPointCopyWithImpl<$Res, $Val extends ChartDataPoint>
    implements $ChartDataPointCopyWith<$Res> {
  _$ChartDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChartDataPointImplCopyWith<$Res>
    implements $ChartDataPointCopyWith<$Res> {
  factory _$$ChartDataPointImplCopyWith(_$ChartDataPointImpl value,
          $Res Function(_$ChartDataPointImpl) then) =
      __$$ChartDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double value});
}

/// @nodoc
class __$$ChartDataPointImplCopyWithImpl<$Res>
    extends _$ChartDataPointCopyWithImpl<$Res, _$ChartDataPointImpl>
    implements _$$ChartDataPointImplCopyWith<$Res> {
  __$$ChartDataPointImplCopyWithImpl(
      _$ChartDataPointImpl _value, $Res Function(_$ChartDataPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
  }) {
    return _then(_$ChartDataPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChartDataPointImpl implements _ChartDataPoint {
  const _$ChartDataPointImpl({required this.date, required this.value});

  factory _$ChartDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChartDataPointImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double value;

  @override
  String toString() {
    return 'ChartDataPoint(date: $date, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChartDataPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, value);

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChartDataPointImplCopyWith<_$ChartDataPointImpl> get copyWith =>
      __$$ChartDataPointImplCopyWithImpl<_$ChartDataPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChartDataPointImplToJson(
      this,
    );
  }
}

abstract class _ChartDataPoint implements ChartDataPoint {
  const factory _ChartDataPoint(
      {required final DateTime date,
      required final double value}) = _$ChartDataPointImpl;

  factory _ChartDataPoint.fromJson(Map<String, dynamic> json) =
      _$ChartDataPointImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get value;

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChartDataPointImplCopyWith<_$ChartDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KpiData _$KpiDataFromJson(Map<String, dynamic> json) {
  return _KpiData.fromJson(json);
}

/// @nodoc
mixin _$KpiData {
  double? get avgWeight => throw _privateConstructorUsedError;
  double? get weightChange => throw _privateConstructorUsedError;
  int? get avgCalories => throw _privateConstructorUsedError;

  /// Serializes this KpiData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KpiDataCopyWith<KpiData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KpiDataCopyWith<$Res> {
  factory $KpiDataCopyWith(KpiData value, $Res Function(KpiData) then) =
      _$KpiDataCopyWithImpl<$Res, KpiData>;
  @useResult
  $Res call({double? avgWeight, double? weightChange, int? avgCalories});
}

/// @nodoc
class _$KpiDataCopyWithImpl<$Res, $Val extends KpiData>
    implements $KpiDataCopyWith<$Res> {
  _$KpiDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgWeight = freezed,
    Object? weightChange = freezed,
    Object? avgCalories = freezed,
  }) {
    return _then(_value.copyWith(
      avgWeight: freezed == avgWeight
          ? _value.avgWeight
          : avgWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      weightChange: freezed == weightChange
          ? _value.weightChange
          : weightChange // ignore: cast_nullable_to_non_nullable
              as double?,
      avgCalories: freezed == avgCalories
          ? _value.avgCalories
          : avgCalories // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KpiDataImplCopyWith<$Res> implements $KpiDataCopyWith<$Res> {
  factory _$$KpiDataImplCopyWith(
          _$KpiDataImpl value, $Res Function(_$KpiDataImpl) then) =
      __$$KpiDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? avgWeight, double? weightChange, int? avgCalories});
}

/// @nodoc
class __$$KpiDataImplCopyWithImpl<$Res>
    extends _$KpiDataCopyWithImpl<$Res, _$KpiDataImpl>
    implements _$$KpiDataImplCopyWith<$Res> {
  __$$KpiDataImplCopyWithImpl(
      _$KpiDataImpl _value, $Res Function(_$KpiDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgWeight = freezed,
    Object? weightChange = freezed,
    Object? avgCalories = freezed,
  }) {
    return _then(_$KpiDataImpl(
      avgWeight: freezed == avgWeight
          ? _value.avgWeight
          : avgWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      weightChange: freezed == weightChange
          ? _value.weightChange
          : weightChange // ignore: cast_nullable_to_non_nullable
              as double?,
      avgCalories: freezed == avgCalories
          ? _value.avgCalories
          : avgCalories // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KpiDataImpl implements _KpiData {
  const _$KpiDataImpl({this.avgWeight, this.weightChange, this.avgCalories});

  factory _$KpiDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$KpiDataImplFromJson(json);

  @override
  final double? avgWeight;
  @override
  final double? weightChange;
  @override
  final int? avgCalories;

  @override
  String toString() {
    return 'KpiData(avgWeight: $avgWeight, weightChange: $weightChange, avgCalories: $avgCalories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KpiDataImpl &&
            (identical(other.avgWeight, avgWeight) ||
                other.avgWeight == avgWeight) &&
            (identical(other.weightChange, weightChange) ||
                other.weightChange == weightChange) &&
            (identical(other.avgCalories, avgCalories) ||
                other.avgCalories == avgCalories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, avgWeight, weightChange, avgCalories);

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KpiDataImplCopyWith<_$KpiDataImpl> get copyWith =>
      __$$KpiDataImplCopyWithImpl<_$KpiDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KpiDataImplToJson(
      this,
    );
  }
}

abstract class _KpiData implements KpiData {
  const factory _KpiData(
      {final double? avgWeight,
      final double? weightChange,
      final int? avgCalories}) = _$KpiDataImpl;

  factory _KpiData.fromJson(Map<String, dynamic> json) = _$KpiDataImpl.fromJson;

  @override
  double? get avgWeight;
  @override
  double? get weightChange;
  @override
  int? get avgCalories;

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KpiDataImplCopyWith<_$KpiDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
