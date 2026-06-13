// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_status_history_record.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MaintenanceStatusHistoryRecord _$MaintenanceStatusHistoryRecordFromJson(
  Map<String, dynamic> json,
) {
  return _MaintenanceStatusHistoryRecord.fromJson(json);
}

/// @nodoc
mixin _$MaintenanceStatusHistoryRecord {
  String get id => throw _privateConstructorUsedError;
  String get maintenanceId => throw _privateConstructorUsedError;
  MaintenanceStatus? get oldStatus => throw _privateConstructorUsedError;
  MaintenanceStatus get newStatus => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime get changedAt => throw _privateConstructorUsedError;
  String get changedBy => throw _privateConstructorUsedError;
  String? get changedByName => throw _privateConstructorUsedError;

  /// Serializes this MaintenanceStatusHistoryRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaintenanceStatusHistoryRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaintenanceStatusHistoryRecordCopyWith<MaintenanceStatusHistoryRecord>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaintenanceStatusHistoryRecordCopyWith<$Res> {
  factory $MaintenanceStatusHistoryRecordCopyWith(
    MaintenanceStatusHistoryRecord value,
    $Res Function(MaintenanceStatusHistoryRecord) then,
  ) =
      _$MaintenanceStatusHistoryRecordCopyWithImpl<
        $Res,
        MaintenanceStatusHistoryRecord
      >;
  @useResult
  $Res call({
    String id,
    String maintenanceId,
    MaintenanceStatus? oldStatus,
    MaintenanceStatus newStatus,
    String? comment,
    DateTime changedAt,
    String changedBy,
    String? changedByName,
  });
}

/// @nodoc
class _$MaintenanceStatusHistoryRecordCopyWithImpl<
  $Res,
  $Val extends MaintenanceStatusHistoryRecord
>
    implements $MaintenanceStatusHistoryRecordCopyWith<$Res> {
  _$MaintenanceStatusHistoryRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaintenanceStatusHistoryRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? maintenanceId = null,
    Object? oldStatus = freezed,
    Object? newStatus = null,
    Object? comment = freezed,
    Object? changedAt = null,
    Object? changedBy = null,
    Object? changedByName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            maintenanceId: null == maintenanceId
                ? _value.maintenanceId
                : maintenanceId // ignore: cast_nullable_to_non_nullable
                      as String,
            oldStatus: freezed == oldStatus
                ? _value.oldStatus
                : oldStatus // ignore: cast_nullable_to_non_nullable
                      as MaintenanceStatus?,
            newStatus: null == newStatus
                ? _value.newStatus
                : newStatus // ignore: cast_nullable_to_non_nullable
                      as MaintenanceStatus,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            changedAt: null == changedAt
                ? _value.changedAt
                : changedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            changedBy: null == changedBy
                ? _value.changedBy
                : changedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            changedByName: freezed == changedByName
                ? _value.changedByName
                : changedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MaintenanceStatusHistoryRecordImplCopyWith<$Res>
    implements $MaintenanceStatusHistoryRecordCopyWith<$Res> {
  factory _$$MaintenanceStatusHistoryRecordImplCopyWith(
    _$MaintenanceStatusHistoryRecordImpl value,
    $Res Function(_$MaintenanceStatusHistoryRecordImpl) then,
  ) = __$$MaintenanceStatusHistoryRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String maintenanceId,
    MaintenanceStatus? oldStatus,
    MaintenanceStatus newStatus,
    String? comment,
    DateTime changedAt,
    String changedBy,
    String? changedByName,
  });
}

/// @nodoc
class __$$MaintenanceStatusHistoryRecordImplCopyWithImpl<$Res>
    extends
        _$MaintenanceStatusHistoryRecordCopyWithImpl<
          $Res,
          _$MaintenanceStatusHistoryRecordImpl
        >
    implements _$$MaintenanceStatusHistoryRecordImplCopyWith<$Res> {
  __$$MaintenanceStatusHistoryRecordImplCopyWithImpl(
    _$MaintenanceStatusHistoryRecordImpl _value,
    $Res Function(_$MaintenanceStatusHistoryRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MaintenanceStatusHistoryRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? maintenanceId = null,
    Object? oldStatus = freezed,
    Object? newStatus = null,
    Object? comment = freezed,
    Object? changedAt = null,
    Object? changedBy = null,
    Object? changedByName = freezed,
  }) {
    return _then(
      _$MaintenanceStatusHistoryRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        maintenanceId: null == maintenanceId
            ? _value.maintenanceId
            : maintenanceId // ignore: cast_nullable_to_non_nullable
                  as String,
        oldStatus: freezed == oldStatus
            ? _value.oldStatus
            : oldStatus // ignore: cast_nullable_to_non_nullable
                  as MaintenanceStatus?,
        newStatus: null == newStatus
            ? _value.newStatus
            : newStatus // ignore: cast_nullable_to_non_nullable
                  as MaintenanceStatus,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        changedAt: null == changedAt
            ? _value.changedAt
            : changedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        changedBy: null == changedBy
            ? _value.changedBy
            : changedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        changedByName: freezed == changedByName
            ? _value.changedByName
            : changedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MaintenanceStatusHistoryRecordImpl
    implements _MaintenanceStatusHistoryRecord {
  const _$MaintenanceStatusHistoryRecordImpl({
    required this.id,
    required this.maintenanceId,
    this.oldStatus,
    required this.newStatus,
    this.comment,
    required this.changedAt,
    required this.changedBy,
    this.changedByName,
  });

  factory _$MaintenanceStatusHistoryRecordImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MaintenanceStatusHistoryRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String maintenanceId;
  @override
  final MaintenanceStatus? oldStatus;
  @override
  final MaintenanceStatus newStatus;
  @override
  final String? comment;
  @override
  final DateTime changedAt;
  @override
  final String changedBy;
  @override
  final String? changedByName;

  @override
  String toString() {
    return 'MaintenanceStatusHistoryRecord(id: $id, maintenanceId: $maintenanceId, oldStatus: $oldStatus, newStatus: $newStatus, comment: $comment, changedAt: $changedAt, changedBy: $changedBy, changedByName: $changedByName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaintenanceStatusHistoryRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.maintenanceId, maintenanceId) ||
                other.maintenanceId == maintenanceId) &&
            (identical(other.oldStatus, oldStatus) ||
                other.oldStatus == oldStatus) &&
            (identical(other.newStatus, newStatus) ||
                other.newStatus == newStatus) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.changedAt, changedAt) ||
                other.changedAt == changedAt) &&
            (identical(other.changedBy, changedBy) ||
                other.changedBy == changedBy) &&
            (identical(other.changedByName, changedByName) ||
                other.changedByName == changedByName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    maintenanceId,
    oldStatus,
    newStatus,
    comment,
    changedAt,
    changedBy,
    changedByName,
  );

  /// Create a copy of MaintenanceStatusHistoryRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaintenanceStatusHistoryRecordImplCopyWith<
    _$MaintenanceStatusHistoryRecordImpl
  >
  get copyWith =>
      __$$MaintenanceStatusHistoryRecordImplCopyWithImpl<
        _$MaintenanceStatusHistoryRecordImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MaintenanceStatusHistoryRecordImplToJson(this);
  }
}

abstract class _MaintenanceStatusHistoryRecord
    implements MaintenanceStatusHistoryRecord {
  const factory _MaintenanceStatusHistoryRecord({
    required final String id,
    required final String maintenanceId,
    final MaintenanceStatus? oldStatus,
    required final MaintenanceStatus newStatus,
    final String? comment,
    required final DateTime changedAt,
    required final String changedBy,
    final String? changedByName,
  }) = _$MaintenanceStatusHistoryRecordImpl;

  factory _MaintenanceStatusHistoryRecord.fromJson(Map<String, dynamic> json) =
      _$MaintenanceStatusHistoryRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get maintenanceId;
  @override
  MaintenanceStatus? get oldStatus;
  @override
  MaintenanceStatus get newStatus;
  @override
  String? get comment;
  @override
  DateTime get changedAt;
  @override
  String get changedBy;
  @override
  String? get changedByName;

  /// Create a copy of MaintenanceStatusHistoryRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaintenanceStatusHistoryRecordImplCopyWith<
    _$MaintenanceStatusHistoryRecordImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
