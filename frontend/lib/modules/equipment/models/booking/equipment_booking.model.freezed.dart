// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_booking.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EquipmentBooking _$EquipmentBookingFromJson(Map<String, dynamic> json) {
  return _EquipmentBooking.fromJson(json);
}

/// @nodoc
mixin _$EquipmentBooking {
  String get id => throw _privateConstructorUsedError;
  String get equipmentItemId => throw _privateConstructorUsedError;
  String get bookedById => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  String? get lessonId => throw _privateConstructorUsedError;
  String? get trainingGroupId => throw _privateConstructorUsedError;
  String get purpose => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this EquipmentBooking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentBooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentBookingCopyWith<EquipmentBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentBookingCopyWith<$Res> {
  factory $EquipmentBookingCopyWith(
    EquipmentBooking value,
    $Res Function(EquipmentBooking) then,
  ) = _$EquipmentBookingCopyWithImpl<$Res, EquipmentBooking>;
  @useResult
  $Res call({
    String id,
    String equipmentItemId,
    String bookedById,
    DateTime startTime,
    DateTime endTime,
    String? lessonId,
    String? trainingGroupId,
    String purpose,
    BookingStatus status,
    String? notes,
  });
}

/// @nodoc
class _$EquipmentBookingCopyWithImpl<$Res, $Val extends EquipmentBooking>
    implements $EquipmentBookingCopyWith<$Res> {
  _$EquipmentBookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentBooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? equipmentItemId = null,
    Object? bookedById = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? lessonId = freezed,
    Object? trainingGroupId = freezed,
    Object? purpose = null,
    Object? status = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            equipmentItemId: null == equipmentItemId
                ? _value.equipmentItemId
                : equipmentItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            bookedById: null == bookedById
                ? _value.bookedById
                : bookedById // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lessonId: freezed == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as String?,
            trainingGroupId: freezed == trainingGroupId
                ? _value.trainingGroupId
                : trainingGroupId // ignore: cast_nullable_to_non_nullable
                      as String?,
            purpose: null == purpose
                ? _value.purpose
                : purpose // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BookingStatus,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EquipmentBookingImplCopyWith<$Res>
    implements $EquipmentBookingCopyWith<$Res> {
  factory _$$EquipmentBookingImplCopyWith(
    _$EquipmentBookingImpl value,
    $Res Function(_$EquipmentBookingImpl) then,
  ) = __$$EquipmentBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String equipmentItemId,
    String bookedById,
    DateTime startTime,
    DateTime endTime,
    String? lessonId,
    String? trainingGroupId,
    String purpose,
    BookingStatus status,
    String? notes,
  });
}

/// @nodoc
class __$$EquipmentBookingImplCopyWithImpl<$Res>
    extends _$EquipmentBookingCopyWithImpl<$Res, _$EquipmentBookingImpl>
    implements _$$EquipmentBookingImplCopyWith<$Res> {
  __$$EquipmentBookingImplCopyWithImpl(
    _$EquipmentBookingImpl _value,
    $Res Function(_$EquipmentBookingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipmentBooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? equipmentItemId = null,
    Object? bookedById = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? lessonId = freezed,
    Object? trainingGroupId = freezed,
    Object? purpose = null,
    Object? status = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$EquipmentBookingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        equipmentItemId: null == equipmentItemId
            ? _value.equipmentItemId
            : equipmentItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        bookedById: null == bookedById
            ? _value.bookedById
            : bookedById // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lessonId: freezed == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as String?,
        trainingGroupId: freezed == trainingGroupId
            ? _value.trainingGroupId
            : trainingGroupId // ignore: cast_nullable_to_non_nullable
                  as String?,
        purpose: null == purpose
            ? _value.purpose
            : purpose // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BookingStatus,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquipmentBookingImpl implements _EquipmentBooking {
  const _$EquipmentBookingImpl({
    required this.id,
    required this.equipmentItemId,
    required this.bookedById,
    required this.startTime,
    required this.endTime,
    this.lessonId,
    this.trainingGroupId,
    required this.purpose,
    required this.status,
    this.notes,
  });

  factory _$EquipmentBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentBookingImplFromJson(json);

  @override
  final String id;
  @override
  final String equipmentItemId;
  @override
  final String bookedById;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final String? lessonId;
  @override
  final String? trainingGroupId;
  @override
  final String purpose;
  @override
  final BookingStatus status;
  @override
  final String? notes;

  @override
  String toString() {
    return 'EquipmentBooking(id: $id, equipmentItemId: $equipmentItemId, bookedById: $bookedById, startTime: $startTime, endTime: $endTime, lessonId: $lessonId, trainingGroupId: $trainingGroupId, purpose: $purpose, status: $status, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentBookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.equipmentItemId, equipmentItemId) ||
                other.equipmentItemId == equipmentItemId) &&
            (identical(other.bookedById, bookedById) ||
                other.bookedById == bookedById) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.trainingGroupId, trainingGroupId) ||
                other.trainingGroupId == trainingGroupId) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    equipmentItemId,
    bookedById,
    startTime,
    endTime,
    lessonId,
    trainingGroupId,
    purpose,
    status,
    notes,
  );

  /// Create a copy of EquipmentBooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentBookingImplCopyWith<_$EquipmentBookingImpl> get copyWith =>
      __$$EquipmentBookingImplCopyWithImpl<_$EquipmentBookingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentBookingImplToJson(this);
  }
}

abstract class _EquipmentBooking implements EquipmentBooking {
  const factory _EquipmentBooking({
    required final String id,
    required final String equipmentItemId,
    required final String bookedById,
    required final DateTime startTime,
    required final DateTime endTime,
    final String? lessonId,
    final String? trainingGroupId,
    required final String purpose,
    required final BookingStatus status,
    final String? notes,
  }) = _$EquipmentBookingImpl;

  factory _EquipmentBooking.fromJson(Map<String, dynamic> json) =
      _$EquipmentBookingImpl.fromJson;

  @override
  String get id;
  @override
  String get equipmentItemId;
  @override
  String get bookedById;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  String? get lessonId;
  @override
  String? get trainingGroupId;
  @override
  String get purpose;
  @override
  BookingStatus get status;
  @override
  String? get notes;

  /// Create a copy of EquipmentBooking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentBookingImplCopyWith<_$EquipmentBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
