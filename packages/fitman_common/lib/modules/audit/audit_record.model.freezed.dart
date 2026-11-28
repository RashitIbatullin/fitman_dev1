// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_record.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuditRecord _$AuditRecordFromJson(Map<String, dynamic> json) {
  return _AuditRecord.fromJson(json);
}

/// @nodoc
mixin _$AuditRecord {
  String get id => throw _privateConstructorUsedError;
  String get tableName => throw _privateConstructorUsedError;
  String get rowPk => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  DateTime get changedAt => throw _privateConstructorUsedError;
  String? get changedBy => throw _privateConstructorUsedError;
  String? get changedByName => throw _privateConstructorUsedError;
  String? get actorRole => throw _privateConstructorUsedError;
  String? get requestId => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  Map<String, dynamic>? get oldValues => throw _privateConstructorUsedError;
  Map<String, dynamic>? get newValues => throw _privateConstructorUsedError;

  /// Serializes this AuditRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditRecordCopyWith<AuditRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditRecordCopyWith<$Res> {
  factory $AuditRecordCopyWith(
    AuditRecord value,
    $Res Function(AuditRecord) then,
  ) = _$AuditRecordCopyWithImpl<$Res, AuditRecord>;
  @useResult
  $Res call({
    String id,
    String tableName,
    String rowPk,
    String action,
    DateTime changedAt,
    String? changedBy,
    String? changedByName,
    String? actorRole,
    String? requestId,
    String source,
    String? reason,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  });
}

/// @nodoc
class _$AuditRecordCopyWithImpl<$Res, $Val extends AuditRecord>
    implements $AuditRecordCopyWith<$Res> {
  _$AuditRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tableName = null,
    Object? rowPk = null,
    Object? action = null,
    Object? changedAt = null,
    Object? changedBy = freezed,
    Object? changedByName = freezed,
    Object? actorRole = freezed,
    Object? requestId = freezed,
    Object? source = null,
    Object? reason = freezed,
    Object? oldValues = freezed,
    Object? newValues = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tableName: null == tableName
                ? _value.tableName
                : tableName // ignore: cast_nullable_to_non_nullable
                      as String,
            rowPk: null == rowPk
                ? _value.rowPk
                : rowPk // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            changedAt: null == changedAt
                ? _value.changedAt
                : changedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            changedBy: freezed == changedBy
                ? _value.changedBy
                : changedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            changedByName: freezed == changedByName
                ? _value.changedByName
                : changedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            actorRole: freezed == actorRole
                ? _value.actorRole
                : actorRole // ignore: cast_nullable_to_non_nullable
                      as String?,
            requestId: freezed == requestId
                ? _value.requestId
                : requestId // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            oldValues: freezed == oldValues
                ? _value.oldValues
                : oldValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            newValues: freezed == newValues
                ? _value.newValues
                : newValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuditRecordImplCopyWith<$Res>
    implements $AuditRecordCopyWith<$Res> {
  factory _$$AuditRecordImplCopyWith(
    _$AuditRecordImpl value,
    $Res Function(_$AuditRecordImpl) then,
  ) = __$$AuditRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tableName,
    String rowPk,
    String action,
    DateTime changedAt,
    String? changedBy,
    String? changedByName,
    String? actorRole,
    String? requestId,
    String source,
    String? reason,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  });
}

/// @nodoc
class __$$AuditRecordImplCopyWithImpl<$Res>
    extends _$AuditRecordCopyWithImpl<$Res, _$AuditRecordImpl>
    implements _$$AuditRecordImplCopyWith<$Res> {
  __$$AuditRecordImplCopyWithImpl(
    _$AuditRecordImpl _value,
    $Res Function(_$AuditRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuditRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tableName = null,
    Object? rowPk = null,
    Object? action = null,
    Object? changedAt = null,
    Object? changedBy = freezed,
    Object? changedByName = freezed,
    Object? actorRole = freezed,
    Object? requestId = freezed,
    Object? source = null,
    Object? reason = freezed,
    Object? oldValues = freezed,
    Object? newValues = freezed,
  }) {
    return _then(
      _$AuditRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tableName: null == tableName
            ? _value.tableName
            : tableName // ignore: cast_nullable_to_non_nullable
                  as String,
        rowPk: null == rowPk
            ? _value.rowPk
            : rowPk // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        changedAt: null == changedAt
            ? _value.changedAt
            : changedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        changedBy: freezed == changedBy
            ? _value.changedBy
            : changedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        changedByName: freezed == changedByName
            ? _value.changedByName
            : changedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        actorRole: freezed == actorRole
            ? _value.actorRole
            : actorRole // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestId: freezed == requestId
            ? _value.requestId
            : requestId // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldValues: freezed == oldValues
            ? _value._oldValues
            : oldValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        newValues: freezed == newValues
            ? _value._newValues
            : newValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditRecordImpl implements _AuditRecord {
  const _$AuditRecordImpl({
    required this.id,
    required this.tableName,
    required this.rowPk,
    required this.action,
    required this.changedAt,
    this.changedBy,
    this.changedByName,
    this.actorRole,
    this.requestId,
    required this.source,
    this.reason,
    final Map<String, dynamic>? oldValues,
    final Map<String, dynamic>? newValues,
  }) : _oldValues = oldValues,
       _newValues = newValues;

  factory _$AuditRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String tableName;
  @override
  final String rowPk;
  @override
  final String action;
  @override
  final DateTime changedAt;
  @override
  final String? changedBy;
  @override
  final String? changedByName;
  @override
  final String? actorRole;
  @override
  final String? requestId;
  @override
  final String source;
  @override
  final String? reason;
  final Map<String, dynamic>? _oldValues;
  @override
  Map<String, dynamic>? get oldValues {
    final value = _oldValues;
    if (value == null) return null;
    if (_oldValues is EqualUnmodifiableMapView) return _oldValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newValues;
  @override
  Map<String, dynamic>? get newValues {
    final value = _newValues;
    if (value == null) return null;
    if (_newValues is EqualUnmodifiableMapView) return _newValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AuditRecord(id: $id, tableName: $tableName, rowPk: $rowPk, action: $action, changedAt: $changedAt, changedBy: $changedBy, changedByName: $changedByName, actorRole: $actorRole, requestId: $requestId, source: $source, reason: $reason, oldValues: $oldValues, newValues: $newValues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tableName, tableName) ||
                other.tableName == tableName) &&
            (identical(other.rowPk, rowPk) || other.rowPk == rowPk) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.changedAt, changedAt) ||
                other.changedAt == changedAt) &&
            (identical(other.changedBy, changedBy) ||
                other.changedBy == changedBy) &&
            (identical(other.changedByName, changedByName) ||
                other.changedByName == changedByName) &&
            (identical(other.actorRole, actorRole) ||
                other.actorRole == actorRole) &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            const DeepCollectionEquality().equals(
              other._oldValues,
              _oldValues,
            ) &&
            const DeepCollectionEquality().equals(
              other._newValues,
              _newValues,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tableName,
    rowPk,
    action,
    changedAt,
    changedBy,
    changedByName,
    actorRole,
    requestId,
    source,
    reason,
    const DeepCollectionEquality().hash(_oldValues),
    const DeepCollectionEquality().hash(_newValues),
  );

  /// Create a copy of AuditRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditRecordImplCopyWith<_$AuditRecordImpl> get copyWith =>
      __$$AuditRecordImplCopyWithImpl<_$AuditRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditRecordImplToJson(this);
  }
}

abstract class _AuditRecord implements AuditRecord {
  const factory _AuditRecord({
    required final String id,
    required final String tableName,
    required final String rowPk,
    required final String action,
    required final DateTime changedAt,
    final String? changedBy,
    final String? changedByName,
    final String? actorRole,
    final String? requestId,
    required final String source,
    final String? reason,
    final Map<String, dynamic>? oldValues,
    final Map<String, dynamic>? newValues,
  }) = _$AuditRecordImpl;

  factory _AuditRecord.fromJson(Map<String, dynamic> json) =
      _$AuditRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get tableName;
  @override
  String get rowPk;
  @override
  String get action;
  @override
  DateTime get changedAt;
  @override
  String? get changedBy;
  @override
  String? get changedByName;
  @override
  String? get actorRole;
  @override
  String? get requestId;
  @override
  String get source;
  @override
  String? get reason;
  @override
  Map<String, dynamic>? get oldValues;
  @override
  Map<String, dynamic>? get newValues;

  /// Create a copy of AuditRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditRecordImplCopyWith<_$AuditRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
