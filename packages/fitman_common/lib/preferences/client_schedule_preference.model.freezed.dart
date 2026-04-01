// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_schedule_preference.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClientSchedulePreference _$ClientSchedulePreferenceFromJson(
    Map<String, dynamic> json) {
  return _ClientSchedulePreference.fromJson(json);
}

/// @nodoc
mixin _$ClientSchedulePreference {
  int? get id => throw _privateConstructorUsedError;
  int get clientId => throw _privateConstructorUsedError;
  int get dayOfWeek => throw _privateConstructorUsedError;
  String get preferredStartTime => throw _privateConstructorUsedError;
  String get preferredEndTime => throw _privateConstructorUsedError;

  /// Serializes this ClientSchedulePreference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientSchedulePreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientSchedulePreferenceCopyWith<ClientSchedulePreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientSchedulePreferenceCopyWith<$Res> {
  factory $ClientSchedulePreferenceCopyWith(ClientSchedulePreference value,
          $Res Function(ClientSchedulePreference) then) =
      _$ClientSchedulePreferenceCopyWithImpl<$Res, ClientSchedulePreference>;
  @useResult
  $Res call(
      {int? id,
      int clientId,
      int dayOfWeek,
      String preferredStartTime,
      String preferredEndTime});
}

/// @nodoc
class _$ClientSchedulePreferenceCopyWithImpl<$Res,
        $Val extends ClientSchedulePreference>
    implements $ClientSchedulePreferenceCopyWith<$Res> {
  _$ClientSchedulePreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientSchedulePreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? clientId = null,
    Object? dayOfWeek = null,
    Object? preferredStartTime = null,
    Object? preferredEndTime = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      preferredStartTime: null == preferredStartTime
          ? _value.preferredStartTime
          : preferredStartTime // ignore: cast_nullable_to_non_nullable
              as String,
      preferredEndTime: null == preferredEndTime
          ? _value.preferredEndTime
          : preferredEndTime // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientSchedulePreferenceImplCopyWith<$Res>
    implements $ClientSchedulePreferenceCopyWith<$Res> {
  factory _$$ClientSchedulePreferenceImplCopyWith(
          _$ClientSchedulePreferenceImpl value,
          $Res Function(_$ClientSchedulePreferenceImpl) then) =
      __$$ClientSchedulePreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int clientId,
      int dayOfWeek,
      String preferredStartTime,
      String preferredEndTime});
}

/// @nodoc
class __$$ClientSchedulePreferenceImplCopyWithImpl<$Res>
    extends _$ClientSchedulePreferenceCopyWithImpl<$Res,
        _$ClientSchedulePreferenceImpl>
    implements _$$ClientSchedulePreferenceImplCopyWith<$Res> {
  __$$ClientSchedulePreferenceImplCopyWithImpl(
      _$ClientSchedulePreferenceImpl _value,
      $Res Function(_$ClientSchedulePreferenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientSchedulePreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? clientId = null,
    Object? dayOfWeek = null,
    Object? preferredStartTime = null,
    Object? preferredEndTime = null,
  }) {
    return _then(_$ClientSchedulePreferenceImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as int,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      preferredStartTime: null == preferredStartTime
          ? _value.preferredStartTime
          : preferredStartTime // ignore: cast_nullable_to_non_nullable
              as String,
      preferredEndTime: null == preferredEndTime
          ? _value.preferredEndTime
          : preferredEndTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientSchedulePreferenceImpl implements _ClientSchedulePreference {
  const _$ClientSchedulePreferenceImpl(
      {this.id,
      required this.clientId,
      required this.dayOfWeek,
      required this.preferredStartTime,
      required this.preferredEndTime});

  factory _$ClientSchedulePreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientSchedulePreferenceImplFromJson(json);

  @override
  final int? id;
  @override
  final int clientId;
  @override
  final int dayOfWeek;
  @override
  final String preferredStartTime;
  @override
  final String preferredEndTime;

  @override
  String toString() {
    return 'ClientSchedulePreference(id: $id, clientId: $clientId, dayOfWeek: $dayOfWeek, preferredStartTime: $preferredStartTime, preferredEndTime: $preferredEndTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientSchedulePreferenceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.preferredStartTime, preferredStartTime) ||
                other.preferredStartTime == preferredStartTime) &&
            (identical(other.preferredEndTime, preferredEndTime) ||
                other.preferredEndTime == preferredEndTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, clientId, dayOfWeek,
      preferredStartTime, preferredEndTime);

  /// Create a copy of ClientSchedulePreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientSchedulePreferenceImplCopyWith<_$ClientSchedulePreferenceImpl>
      get copyWith => __$$ClientSchedulePreferenceImplCopyWithImpl<
          _$ClientSchedulePreferenceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientSchedulePreferenceImplToJson(
      this,
    );
  }
}

abstract class _ClientSchedulePreference implements ClientSchedulePreference {
  const factory _ClientSchedulePreference(
      {final int? id,
      required final int clientId,
      required final int dayOfWeek,
      required final String preferredStartTime,
      required final String preferredEndTime}) = _$ClientSchedulePreferenceImpl;

  factory _ClientSchedulePreference.fromJson(Map<String, dynamic> json) =
      _$ClientSchedulePreferenceImpl.fromJson;

  @override
  int? get id;
  @override
  int get clientId;
  @override
  int get dayOfWeek;
  @override
  String get preferredStartTime;
  @override
  String get preferredEndTime;

  /// Create a copy of ClientSchedulePreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientSchedulePreferenceImplCopyWith<_$ClientSchedulePreferenceImpl>
      get copyWith => throw _privateConstructorUsedError;
}
