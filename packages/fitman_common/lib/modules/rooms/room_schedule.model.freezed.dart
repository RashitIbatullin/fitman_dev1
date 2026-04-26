// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_schedule.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoomSchedule _$RoomScheduleFromJson(Map<String, dynamic> json) {
  return _RoomSchedule.fromJson(json);
}

/// @nodoc
mixin _$RoomSchedule {
  String get id => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  int get dayOfWeek => throw _privateConstructorUsedError;
  bool get isWorkingDay => throw _privateConstructorUsedError;
  TimeOfDayCustom? get openTime => throw _privateConstructorUsedError;
  TimeOfDayCustom? get closeTime => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;

  /// Serializes this RoomSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomScheduleCopyWith<RoomSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomScheduleCopyWith<$Res> {
  factory $RoomScheduleCopyWith(
          RoomSchedule value, $Res Function(RoomSchedule) then) =
      _$RoomScheduleCopyWithImpl<$Res, RoomSchedule>;
  @useResult
  $Res call(
      {String id,
      String roomId,
      int dayOfWeek,
      bool isWorkingDay,
      TimeOfDayCustom? openTime,
      TimeOfDayCustom? closeTime,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? createdBy,
      String? updatedBy});
}

/// @nodoc
class _$RoomScheduleCopyWithImpl<$Res, $Val extends RoomSchedule>
    implements $RoomScheduleCopyWith<$Res> {
  _$RoomScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? dayOfWeek = null,
    Object? isWorkingDay = null,
    Object? openTime = freezed,
    Object? closeTime = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      isWorkingDay: null == isWorkingDay
          ? _value.isWorkingDay
          : isWorkingDay // ignore: cast_nullable_to_non_nullable
              as bool,
      openTime: freezed == openTime
          ? _value.openTime
          : openTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDayCustom?,
      closeTime: freezed == closeTime
          ? _value.closeTime
          : closeTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDayCustom?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomScheduleImplCopyWith<$Res>
    implements $RoomScheduleCopyWith<$Res> {
  factory _$$RoomScheduleImplCopyWith(
          _$RoomScheduleImpl value, $Res Function(_$RoomScheduleImpl) then) =
      __$$RoomScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String roomId,
      int dayOfWeek,
      bool isWorkingDay,
      TimeOfDayCustom? openTime,
      TimeOfDayCustom? closeTime,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? createdBy,
      String? updatedBy});
}

/// @nodoc
class __$$RoomScheduleImplCopyWithImpl<$Res>
    extends _$RoomScheduleCopyWithImpl<$Res, _$RoomScheduleImpl>
    implements _$$RoomScheduleImplCopyWith<$Res> {
  __$$RoomScheduleImplCopyWithImpl(
      _$RoomScheduleImpl _value, $Res Function(_$RoomScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoomSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? dayOfWeek = null,
    Object? isWorkingDay = null,
    Object? openTime = freezed,
    Object? closeTime = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_$RoomScheduleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      isWorkingDay: null == isWorkingDay
          ? _value.isWorkingDay
          : isWorkingDay // ignore: cast_nullable_to_non_nullable
              as bool,
      openTime: freezed == openTime
          ? _value.openTime
          : openTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDayCustom?,
      closeTime: freezed == closeTime
          ? _value.closeTime
          : closeTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDayCustom?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomScheduleImpl implements _RoomSchedule {
  const _$RoomScheduleImpl(
      {required this.id,
      required this.roomId,
      required this.dayOfWeek,
      this.isWorkingDay = true,
      this.openTime,
      this.closeTime,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.updatedBy});

  factory _$RoomScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String roomId;
  @override
  final int dayOfWeek;
  @override
  @JsonKey()
  final bool isWorkingDay;
  @override
  final TimeOfDayCustom? openTime;
  @override
  final TimeOfDayCustom? closeTime;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;

  @override
  String toString() {
    return 'RoomSchedule(id: $id, roomId: $roomId, dayOfWeek: $dayOfWeek, isWorkingDay: $isWorkingDay, openTime: $openTime, closeTime: $closeTime, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.isWorkingDay, isWorkingDay) ||
                other.isWorkingDay == isWorkingDay) &&
            (identical(other.openTime, openTime) ||
                other.openTime == openTime) &&
            (identical(other.closeTime, closeTime) ||
                other.closeTime == closeTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      roomId,
      dayOfWeek,
      isWorkingDay,
      openTime,
      closeTime,
      createdAt,
      updatedAt,
      createdBy,
      updatedBy);

  /// Create a copy of RoomSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomScheduleImplCopyWith<_$RoomScheduleImpl> get copyWith =>
      __$$RoomScheduleImplCopyWithImpl<_$RoomScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomScheduleImplToJson(
      this,
    );
  }
}

abstract class _RoomSchedule implements RoomSchedule {
  const factory _RoomSchedule(
      {required final String id,
      required final String roomId,
      required final int dayOfWeek,
      final bool isWorkingDay,
      final TimeOfDayCustom? openTime,
      final TimeOfDayCustom? closeTime,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String? createdBy,
      final String? updatedBy}) = _$RoomScheduleImpl;

  factory _RoomSchedule.fromJson(Map<String, dynamic> json) =
      _$RoomScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get roomId;
  @override
  int get dayOfWeek;
  @override
  bool get isWorkingDay;
  @override
  TimeOfDayCustom? get openTime;
  @override
  TimeOfDayCustom? get closeTime;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get createdBy;
  @override
  String? get updatedBy;

  /// Create a copy of RoomSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomScheduleImplCopyWith<_$RoomScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
