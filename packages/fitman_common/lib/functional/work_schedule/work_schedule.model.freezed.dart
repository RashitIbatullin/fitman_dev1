// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_schedule.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkSchedule _$WorkScheduleFromJson(Map<String, dynamic> json) {
  return _WorkSchedule.fromJson(json);
}

/// @nodoc
mixin _$WorkSchedule {
  String get id => throw _privateConstructorUsedError;
  int get dayOfWeek => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  bool get isDayOff => throw _privateConstructorUsedError;

  /// Serializes this WorkSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkScheduleCopyWith<WorkSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkScheduleCopyWith<$Res> {
  factory $WorkScheduleCopyWith(
    WorkSchedule value,
    $Res Function(WorkSchedule) then,
  ) = _$WorkScheduleCopyWithImpl<$Res, WorkSchedule>;
  @useResult
  $Res call({
    String id,
    int dayOfWeek,
    String startTime,
    String endTime,
    bool isDayOff,
  });
}

/// @nodoc
class _$WorkScheduleCopyWithImpl<$Res, $Val extends WorkSchedule>
    implements $WorkScheduleCopyWith<$Res> {
  _$WorkScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isDayOff = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            dayOfWeek: null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String,
            isDayOff: null == isDayOff
                ? _value.isDayOff
                : isDayOff // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkScheduleImplCopyWith<$Res>
    implements $WorkScheduleCopyWith<$Res> {
  factory _$$WorkScheduleImplCopyWith(
    _$WorkScheduleImpl value,
    $Res Function(_$WorkScheduleImpl) then,
  ) = __$$WorkScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int dayOfWeek,
    String startTime,
    String endTime,
    bool isDayOff,
  });
}

/// @nodoc
class __$$WorkScheduleImplCopyWithImpl<$Res>
    extends _$WorkScheduleCopyWithImpl<$Res, _$WorkScheduleImpl>
    implements _$$WorkScheduleImplCopyWith<$Res> {
  __$$WorkScheduleImplCopyWithImpl(
    _$WorkScheduleImpl _value,
    $Res Function(_$WorkScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isDayOff = null,
  }) {
    return _then(
      _$WorkScheduleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dayOfWeek: null == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String,
        isDayOff: null == isDayOff
            ? _value.isDayOff
            : isDayOff // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkScheduleImpl implements _WorkSchedule {
  const _$WorkScheduleImpl({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isDayOff,
  });

  factory _$WorkScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final int dayOfWeek;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  final bool isDayOff;

  @override
  String toString() {
    return 'WorkSchedule(id: $id, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isDayOff: $isDayOff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isDayOff, isDayOff) ||
                other.isDayOff == isDayOff));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, dayOfWeek, startTime, endTime, isDayOff);

  /// Create a copy of WorkSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkScheduleImplCopyWith<_$WorkScheduleImpl> get copyWith =>
      __$$WorkScheduleImplCopyWithImpl<_$WorkScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkScheduleImplToJson(this);
  }
}

abstract class _WorkSchedule implements WorkSchedule {
  const factory _WorkSchedule({
    required final String id,
    required final int dayOfWeek,
    required final String startTime,
    required final String endTime,
    required final bool isDayOff,
  }) = _$WorkScheduleImpl;

  factory _WorkSchedule.fromJson(Map<String, dynamic> json) =
      _$WorkScheduleImpl.fromJson;

  @override
  String get id;
  @override
  int get dayOfWeek;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  bool get isDayOff;

  /// Create a copy of WorkSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkScheduleImplCopyWith<_$WorkScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
