// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_item.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScheduleItem _$ScheduleItemFromJson(Map<String, dynamic> json) {
  return _ScheduleItem.fromJson(json);
}

/// @nodoc
mixin _$ScheduleItem {
  String get id => throw _privateConstructorUsedError;
  String get trainingPlanName => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get trainerName => throw _privateConstructorUsedError;

  /// Serializes this ScheduleItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleItemCopyWith<ScheduleItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleItemCopyWith<$Res> {
  factory $ScheduleItemCopyWith(
    ScheduleItem value,
    $Res Function(ScheduleItem) then,
  ) = _$ScheduleItemCopyWithImpl<$Res, ScheduleItem>;
  @useResult
  $Res call({
    String id,
    String trainingPlanName,
    DateTime startTime,
    DateTime endTime,
    String status,
    String trainerName,
  });
}

/// @nodoc
class _$ScheduleItemCopyWithImpl<$Res, $Val extends ScheduleItem>
    implements $ScheduleItemCopyWith<$Res> {
  _$ScheduleItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainingPlanName = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
    Object? trainerName = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            trainingPlanName: null == trainingPlanName
                ? _value.trainingPlanName
                : trainingPlanName // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            trainerName: null == trainerName
                ? _value.trainerName
                : trainerName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleItemImplCopyWith<$Res>
    implements $ScheduleItemCopyWith<$Res> {
  factory _$$ScheduleItemImplCopyWith(
    _$ScheduleItemImpl value,
    $Res Function(_$ScheduleItemImpl) then,
  ) = __$$ScheduleItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String trainingPlanName,
    DateTime startTime,
    DateTime endTime,
    String status,
    String trainerName,
  });
}

/// @nodoc
class __$$ScheduleItemImplCopyWithImpl<$Res>
    extends _$ScheduleItemCopyWithImpl<$Res, _$ScheduleItemImpl>
    implements _$$ScheduleItemImplCopyWith<$Res> {
  __$$ScheduleItemImplCopyWithImpl(
    _$ScheduleItemImpl _value,
    $Res Function(_$ScheduleItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainingPlanName = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
    Object? trainerName = null,
  }) {
    return _then(
      _$ScheduleItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        trainingPlanName: null == trainingPlanName
            ? _value.trainingPlanName
            : trainingPlanName // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        trainerName: null == trainerName
            ? _value.trainerName
            : trainerName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleItemImpl implements _ScheduleItem {
  const _$ScheduleItemImpl({
    required this.id,
    required this.trainingPlanName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.trainerName,
  });

  factory _$ScheduleItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleItemImplFromJson(json);

  @override
  final String id;
  @override
  final String trainingPlanName;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final String status;
  @override
  final String trainerName;

  @override
  String toString() {
    return 'ScheduleItem(id: $id, trainingPlanName: $trainingPlanName, startTime: $startTime, endTime: $endTime, status: $status, trainerName: $trainerName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trainingPlanName, trainingPlanName) ||
                other.trainingPlanName == trainingPlanName) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.trainerName, trainerName) ||
                other.trainerName == trainerName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    trainingPlanName,
    startTime,
    endTime,
    status,
    trainerName,
  );

  /// Create a copy of ScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleItemImplCopyWith<_$ScheduleItemImpl> get copyWith =>
      __$$ScheduleItemImplCopyWithImpl<_$ScheduleItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleItemImplToJson(this);
  }
}

abstract class _ScheduleItem implements ScheduleItem {
  const factory _ScheduleItem({
    required final String id,
    required final String trainingPlanName,
    required final DateTime startTime,
    required final DateTime endTime,
    required final String status,
    required final String trainerName,
  }) = _$ScheduleItemImpl;

  factory _ScheduleItem.fromJson(Map<String, dynamic> json) =
      _$ScheduleItemImpl.fromJson;

  @override
  String get id;
  @override
  String get trainingPlanName;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  String get status;
  @override
  String get trainerName;

  /// Create a copy of ScheduleItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleItemImplCopyWith<_$ScheduleItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
