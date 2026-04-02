// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calorie_tracking_data.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalorieTrackingData _$CalorieTrackingDataFromJson(Map<String, dynamic> json) {
  return _CalorieTrackingData.fromJson(json);
}

/// @nodoc
mixin _$CalorieTrackingData {
  DateTime get date => throw _privateConstructorUsedError;
  String get training => throw _privateConstructorUsedError;
  int get consumed => throw _privateConstructorUsedError;
  int get burned => throw _privateConstructorUsedError;
  int get balance => throw _privateConstructorUsedError;

  /// Serializes this CalorieTrackingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalorieTrackingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalorieTrackingDataCopyWith<CalorieTrackingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalorieTrackingDataCopyWith<$Res> {
  factory $CalorieTrackingDataCopyWith(
          CalorieTrackingData value, $Res Function(CalorieTrackingData) then) =
      _$CalorieTrackingDataCopyWithImpl<$Res, CalorieTrackingData>;
  @useResult
  $Res call(
      {DateTime date, String training, int consumed, int burned, int balance});
}

/// @nodoc
class _$CalorieTrackingDataCopyWithImpl<$Res, $Val extends CalorieTrackingData>
    implements $CalorieTrackingDataCopyWith<$Res> {
  _$CalorieTrackingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalorieTrackingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? training = null,
    Object? consumed = null,
    Object? burned = null,
    Object? balance = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      training: null == training
          ? _value.training
          : training // ignore: cast_nullable_to_non_nullable
              as String,
      consumed: null == consumed
          ? _value.consumed
          : consumed // ignore: cast_nullable_to_non_nullable
              as int,
      burned: null == burned
          ? _value.burned
          : burned // ignore: cast_nullable_to_non_nullable
              as int,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalorieTrackingDataImplCopyWith<$Res>
    implements $CalorieTrackingDataCopyWith<$Res> {
  factory _$$CalorieTrackingDataImplCopyWith(_$CalorieTrackingDataImpl value,
          $Res Function(_$CalorieTrackingDataImpl) then) =
      __$$CalorieTrackingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date, String training, int consumed, int burned, int balance});
}

/// @nodoc
class __$$CalorieTrackingDataImplCopyWithImpl<$Res>
    extends _$CalorieTrackingDataCopyWithImpl<$Res, _$CalorieTrackingDataImpl>
    implements _$$CalorieTrackingDataImplCopyWith<$Res> {
  __$$CalorieTrackingDataImplCopyWithImpl(_$CalorieTrackingDataImpl _value,
      $Res Function(_$CalorieTrackingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalorieTrackingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? training = null,
    Object? consumed = null,
    Object? burned = null,
    Object? balance = null,
  }) {
    return _then(_$CalorieTrackingDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      training: null == training
          ? _value.training
          : training // ignore: cast_nullable_to_non_nullable
              as String,
      consumed: null == consumed
          ? _value.consumed
          : consumed // ignore: cast_nullable_to_non_nullable
              as int,
      burned: null == burned
          ? _value.burned
          : burned // ignore: cast_nullable_to_non_nullable
              as int,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalorieTrackingDataImpl implements _CalorieTrackingData {
  const _$CalorieTrackingDataImpl(
      {required this.date,
      required this.training,
      required this.consumed,
      required this.burned,
      required this.balance});

  factory _$CalorieTrackingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalorieTrackingDataImplFromJson(json);

  @override
  final DateTime date;
  @override
  final String training;
  @override
  final int consumed;
  @override
  final int burned;
  @override
  final int balance;

  @override
  String toString() {
    return 'CalorieTrackingData(date: $date, training: $training, consumed: $consumed, burned: $burned, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalorieTrackingDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.training, training) ||
                other.training == training) &&
            (identical(other.consumed, consumed) ||
                other.consumed == consumed) &&
            (identical(other.burned, burned) || other.burned == burned) &&
            (identical(other.balance, balance) || other.balance == balance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, training, consumed, burned, balance);

  /// Create a copy of CalorieTrackingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalorieTrackingDataImplCopyWith<_$CalorieTrackingDataImpl> get copyWith =>
      __$$CalorieTrackingDataImplCopyWithImpl<_$CalorieTrackingDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalorieTrackingDataImplToJson(
      this,
    );
  }
}

abstract class _CalorieTrackingData implements CalorieTrackingData {
  const factory _CalorieTrackingData(
      {required final DateTime date,
      required final String training,
      required final int consumed,
      required final int burned,
      required final int balance}) = _$CalorieTrackingDataImpl;

  factory _CalorieTrackingData.fromJson(Map<String, dynamic> json) =
      _$CalorieTrackingDataImpl.fromJson;

  @override
  DateTime get date;
  @override
  String get training;
  @override
  int get consumed;
  @override
  int get burned;
  @override
  int get balance;

  /// Create a copy of CalorieTrackingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalorieTrackingDataImplCopyWith<_$CalorieTrackingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
