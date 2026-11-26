// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Appointment _$AppointmentFromJson(Map<String, dynamic> json) {
  return _Appointment.fromJson(json);
}

/// @nodoc
mixin _$Appointment {
  String get id => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String? get clientName => throw _privateConstructorUsedError;
  String get serviceId => throw _privateConstructorUsedError;
  String get serviceName => throw _privateConstructorUsedError;
  String? get serviceDescription => throw _privateConstructorUsedError;
  String? get executorId => throw _privateConstructorUsedError;
  String? get executorName => throw _privateConstructorUsedError;
  DateTime get startAt => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int? get skipParty => throw _privateConstructorUsedError;
  int? get skipReason => throw _privateConstructorUsedError;
  String? get purchaseId => throw _privateConstructorUsedError;

  /// Serializes this Appointment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppointmentCopyWith<Appointment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentCopyWith<$Res> {
  factory $AppointmentCopyWith(
    Appointment value,
    $Res Function(Appointment) then,
  ) = _$AppointmentCopyWithImpl<$Res, Appointment>;
  @useResult
  $Res call({
    String id,
    String clientId,
    String? clientName,
    String serviceId,
    String serviceName,
    String? serviceDescription,
    String? executorId,
    String? executorName,
    DateTime startAt,
    int? durationMinutes,
    int status,
    String? note,
    int? skipParty,
    int? skipReason,
    String? purchaseId,
  });
}

/// @nodoc
class _$AppointmentCopyWithImpl<$Res, $Val extends Appointment>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? clientName = freezed,
    Object? serviceId = null,
    Object? serviceName = null,
    Object? serviceDescription = freezed,
    Object? executorId = freezed,
    Object? executorName = freezed,
    Object? startAt = null,
    Object? durationMinutes = freezed,
    Object? status = null,
    Object? note = freezed,
    Object? skipParty = freezed,
    Object? skipReason = freezed,
    Object? purchaseId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            clientName: freezed == clientName
                ? _value.clientName
                : clientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceId: null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceName: null == serviceName
                ? _value.serviceName
                : serviceName // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceDescription: freezed == serviceDescription
                ? _value.serviceDescription
                : serviceDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            executorId: freezed == executorId
                ? _value.executorId
                : executorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            executorName: freezed == executorName
                ? _value.executorName
                : executorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            startAt: null == startAt
                ? _value.startAt
                : startAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as int,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            skipParty: freezed == skipParty
                ? _value.skipParty
                : skipParty // ignore: cast_nullable_to_non_nullable
                      as int?,
            skipReason: freezed == skipReason
                ? _value.skipReason
                : skipReason // ignore: cast_nullable_to_non_nullable
                      as int?,
            purchaseId: freezed == purchaseId
                ? _value.purchaseId
                : purchaseId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppointmentImplCopyWith<$Res>
    implements $AppointmentCopyWith<$Res> {
  factory _$$AppointmentImplCopyWith(
    _$AppointmentImpl value,
    $Res Function(_$AppointmentImpl) then,
  ) = __$$AppointmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String clientId,
    String? clientName,
    String serviceId,
    String serviceName,
    String? serviceDescription,
    String? executorId,
    String? executorName,
    DateTime startAt,
    int? durationMinutes,
    int status,
    String? note,
    int? skipParty,
    int? skipReason,
    String? purchaseId,
  });
}

/// @nodoc
class __$$AppointmentImplCopyWithImpl<$Res>
    extends _$AppointmentCopyWithImpl<$Res, _$AppointmentImpl>
    implements _$$AppointmentImplCopyWith<$Res> {
  __$$AppointmentImplCopyWithImpl(
    _$AppointmentImpl _value,
    $Res Function(_$AppointmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? clientName = freezed,
    Object? serviceId = null,
    Object? serviceName = null,
    Object? serviceDescription = freezed,
    Object? executorId = freezed,
    Object? executorName = freezed,
    Object? startAt = null,
    Object? durationMinutes = freezed,
    Object? status = null,
    Object? note = freezed,
    Object? skipParty = freezed,
    Object? skipReason = freezed,
    Object? purchaseId = freezed,
  }) {
    return _then(
      _$AppointmentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        clientName: freezed == clientName
            ? _value.clientName
            : clientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceId: null == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceName: null == serviceName
            ? _value.serviceName
            : serviceName // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceDescription: freezed == serviceDescription
            ? _value.serviceDescription
            : serviceDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        executorId: freezed == executorId
            ? _value.executorId
            : executorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        executorName: freezed == executorName
            ? _value.executorName
            : executorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        startAt: null == startAt
            ? _value.startAt
            : startAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as int,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        skipParty: freezed == skipParty
            ? _value.skipParty
            : skipParty // ignore: cast_nullable_to_non_nullable
                  as int?,
        skipReason: freezed == skipReason
            ? _value.skipReason
            : skipReason // ignore: cast_nullable_to_non_nullable
                  as int?,
        purchaseId: freezed == purchaseId
            ? _value.purchaseId
            : purchaseId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentImpl implements _Appointment {
  const _$AppointmentImpl({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.serviceId,
    required this.serviceName,
    this.serviceDescription,
    this.executorId,
    this.executorName,
    required this.startAt,
    this.durationMinutes,
    required this.status,
    this.note,
    this.skipParty,
    this.skipReason,
    this.purchaseId,
  });

  factory _$AppointmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentImplFromJson(json);

  @override
  final String id;
  @override
  final String clientId;
  @override
  final String? clientName;
  @override
  final String serviceId;
  @override
  final String serviceName;
  @override
  final String? serviceDescription;
  @override
  final String? executorId;
  @override
  final String? executorName;
  @override
  final DateTime startAt;
  @override
  final int? durationMinutes;
  @override
  final int status;
  @override
  final String? note;
  @override
  final int? skipParty;
  @override
  final int? skipReason;
  @override
  final String? purchaseId;

  @override
  String toString() {
    return 'Appointment(id: $id, clientId: $clientId, clientName: $clientName, serviceId: $serviceId, serviceName: $serviceName, serviceDescription: $serviceDescription, executorId: $executorId, executorName: $executorName, startAt: $startAt, durationMinutes: $durationMinutes, status: $status, note: $note, skipParty: $skipParty, skipReason: $skipReason, purchaseId: $purchaseId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.serviceDescription, serviceDescription) ||
                other.serviceDescription == serviceDescription) &&
            (identical(other.executorId, executorId) ||
                other.executorId == executorId) &&
            (identical(other.executorName, executorName) ||
                other.executorName == executorName) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.skipParty, skipParty) ||
                other.skipParty == skipParty) &&
            (identical(other.skipReason, skipReason) ||
                other.skipReason == skipReason) &&
            (identical(other.purchaseId, purchaseId) ||
                other.purchaseId == purchaseId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    clientId,
    clientName,
    serviceId,
    serviceName,
    serviceDescription,
    executorId,
    executorName,
    startAt,
    durationMinutes,
    status,
    note,
    skipParty,
    skipReason,
    purchaseId,
  );

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentImplCopyWith<_$AppointmentImpl> get copyWith =>
      __$$AppointmentImplCopyWithImpl<_$AppointmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentImplToJson(this);
  }
}

abstract class _Appointment implements Appointment {
  const factory _Appointment({
    required final String id,
    required final String clientId,
    final String? clientName,
    required final String serviceId,
    required final String serviceName,
    final String? serviceDescription,
    final String? executorId,
    final String? executorName,
    required final DateTime startAt,
    final int? durationMinutes,
    required final int status,
    final String? note,
    final int? skipParty,
    final int? skipReason,
    final String? purchaseId,
  }) = _$AppointmentImpl;

  factory _Appointment.fromJson(Map<String, dynamic> json) =
      _$AppointmentImpl.fromJson;

  @override
  String get id;
  @override
  String get clientId;
  @override
  String? get clientName;
  @override
  String get serviceId;
  @override
  String get serviceName;
  @override
  String? get serviceDescription;
  @override
  String? get executorId;
  @override
  String? get executorName;
  @override
  DateTime get startAt;
  @override
  int? get durationMinutes;
  @override
  int get status;
  @override
  String? get note;
  @override
  int? get skipParty;
  @override
  int? get skipReason;
  @override
  String? get purchaseId;

  /// Create a copy of Appointment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppointmentImplCopyWith<_$AppointmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
