// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_maintenance_history.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MaintenancePhoto _$MaintenancePhotoFromJson(Map<String, dynamic> json) {
  return _MaintenancePhoto.fromJson(json);
}

/// @nodoc
mixin _$MaintenancePhoto {
  String get url => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;

  /// Serializes this MaintenancePhoto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaintenancePhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaintenancePhotoCopyWith<MaintenancePhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaintenancePhotoCopyWith<$Res> {
  factory $MaintenancePhotoCopyWith(
    MaintenancePhoto value,
    $Res Function(MaintenancePhoto) then,
  ) = _$MaintenancePhotoCopyWithImpl<$Res, MaintenancePhoto>;
  @useResult
  $Res call({String url, String note});
}

/// @nodoc
class _$MaintenancePhotoCopyWithImpl<$Res, $Val extends MaintenancePhoto>
    implements $MaintenancePhotoCopyWith<$Res> {
  _$MaintenancePhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaintenancePhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? url = null, Object? note = null}) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MaintenancePhotoImplCopyWith<$Res>
    implements $MaintenancePhotoCopyWith<$Res> {
  factory _$$MaintenancePhotoImplCopyWith(
    _$MaintenancePhotoImpl value,
    $Res Function(_$MaintenancePhotoImpl) then,
  ) = __$$MaintenancePhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String note});
}

/// @nodoc
class __$$MaintenancePhotoImplCopyWithImpl<$Res>
    extends _$MaintenancePhotoCopyWithImpl<$Res, _$MaintenancePhotoImpl>
    implements _$$MaintenancePhotoImplCopyWith<$Res> {
  __$$MaintenancePhotoImplCopyWithImpl(
    _$MaintenancePhotoImpl _value,
    $Res Function(_$MaintenancePhotoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MaintenancePhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? url = null, Object? note = null}) {
    return _then(
      _$MaintenancePhotoImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MaintenancePhotoImpl implements _MaintenancePhoto {
  const _$MaintenancePhotoImpl({required this.url, required this.note});

  factory _$MaintenancePhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaintenancePhotoImplFromJson(json);

  @override
  final String url;
  @override
  final String note;

  @override
  String toString() {
    return 'MaintenancePhoto(url: $url, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaintenancePhotoImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, note);

  /// Create a copy of MaintenancePhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaintenancePhotoImplCopyWith<_$MaintenancePhotoImpl> get copyWith =>
      __$$MaintenancePhotoImplCopyWithImpl<_$MaintenancePhotoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MaintenancePhotoImplToJson(this);
  }
}

abstract class _MaintenancePhoto implements MaintenancePhoto {
  const factory _MaintenancePhoto({
    required final String url,
    required final String note,
  }) = _$MaintenancePhotoImpl;

  factory _MaintenancePhoto.fromJson(Map<String, dynamic> json) =
      _$MaintenancePhotoImpl.fromJson;

  @override
  String get url;
  @override
  String get note;

  /// Create a copy of MaintenancePhoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaintenancePhotoImplCopyWith<_$MaintenancePhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EquipmentMaintenanceHistory _$EquipmentMaintenanceHistoryFromJson(
  Map<String, dynamic> json,
) {
  return _EquipmentMaintenanceHistory.fromJson(json);
}

/// @nodoc
mixin _$EquipmentMaintenanceHistory {
  String get id => throw _privateConstructorUsedError;
  String get equipmentItemId => throw _privateConstructorUsedError;
  DateTime get dateSent => throw _privateConstructorUsedError;
  DateTime? get dateReturned => throw _privateConstructorUsedError;
  String get descriptionOfWork => throw _privateConstructorUsedError;
  double? get cost => throw _privateConstructorUsedError;
  String? get performedBy => throw _privateConstructorUsedError;
  List<MaintenancePhoto>? get photos => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedReason => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this EquipmentMaintenanceHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentMaintenanceHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentMaintenanceHistoryCopyWith<EquipmentMaintenanceHistory>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentMaintenanceHistoryCopyWith<$Res> {
  factory $EquipmentMaintenanceHistoryCopyWith(
    EquipmentMaintenanceHistory value,
    $Res Function(EquipmentMaintenanceHistory) then,
  ) =
      _$EquipmentMaintenanceHistoryCopyWithImpl<
        $Res,
        EquipmentMaintenanceHistory
      >;
  @useResult
  $Res call({
    String id,
    String equipmentItemId,
    DateTime dateSent,
    DateTime? dateReturned,
    String descriptionOfWork,
    double? cost,
    String? performedBy,
    List<MaintenancePhoto>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
    String? note,
  });
}

/// @nodoc
class _$EquipmentMaintenanceHistoryCopyWithImpl<
  $Res,
  $Val extends EquipmentMaintenanceHistory
>
    implements $EquipmentMaintenanceHistoryCopyWith<$Res> {
  _$EquipmentMaintenanceHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentMaintenanceHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? equipmentItemId = null,
    Object? dateSent = null,
    Object? dateReturned = freezed,
    Object? descriptionOfWork = null,
    Object? cost = freezed,
    Object? performedBy = freezed,
    Object? photos = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
    Object? note = freezed,
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
            dateSent: null == dateSent
                ? _value.dateSent
                : dateSent // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dateReturned: freezed == dateReturned
                ? _value.dateReturned
                : dateReturned // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            descriptionOfWork: null == descriptionOfWork
                ? _value.descriptionOfWork
                : descriptionOfWork // ignore: cast_nullable_to_non_nullable
                      as String,
            cost: freezed == cost
                ? _value.cost
                : cost // ignore: cast_nullable_to_non_nullable
                      as double?,
            performedBy: freezed == performedBy
                ? _value.performedBy
                : performedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            photos: freezed == photos
                ? _value.photos
                : photos // ignore: cast_nullable_to_non_nullable
                      as List<MaintenancePhoto>?,
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
            archivedAt: freezed == archivedAt
                ? _value.archivedAt
                : archivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            archivedBy: freezed == archivedBy
                ? _value.archivedBy
                : archivedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            archivedReason: freezed == archivedReason
                ? _value.archivedReason
                : archivedReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EquipmentMaintenanceHistoryImplCopyWith<$Res>
    implements $EquipmentMaintenanceHistoryCopyWith<$Res> {
  factory _$$EquipmentMaintenanceHistoryImplCopyWith(
    _$EquipmentMaintenanceHistoryImpl value,
    $Res Function(_$EquipmentMaintenanceHistoryImpl) then,
  ) = __$$EquipmentMaintenanceHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String equipmentItemId,
    DateTime dateSent,
    DateTime? dateReturned,
    String descriptionOfWork,
    double? cost,
    String? performedBy,
    List<MaintenancePhoto>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
    String? note,
  });
}

/// @nodoc
class __$$EquipmentMaintenanceHistoryImplCopyWithImpl<$Res>
    extends
        _$EquipmentMaintenanceHistoryCopyWithImpl<
          $Res,
          _$EquipmentMaintenanceHistoryImpl
        >
    implements _$$EquipmentMaintenanceHistoryImplCopyWith<$Res> {
  __$$EquipmentMaintenanceHistoryImplCopyWithImpl(
    _$EquipmentMaintenanceHistoryImpl _value,
    $Res Function(_$EquipmentMaintenanceHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipmentMaintenanceHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? equipmentItemId = null,
    Object? dateSent = null,
    Object? dateReturned = freezed,
    Object? descriptionOfWork = null,
    Object? cost = freezed,
    Object? performedBy = freezed,
    Object? photos = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
    Object? note = freezed,
  }) {
    return _then(
      _$EquipmentMaintenanceHistoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        equipmentItemId: null == equipmentItemId
            ? _value.equipmentItemId
            : equipmentItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        dateSent: null == dateSent
            ? _value.dateSent
            : dateSent // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dateReturned: freezed == dateReturned
            ? _value.dateReturned
            : dateReturned // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        descriptionOfWork: null == descriptionOfWork
            ? _value.descriptionOfWork
            : descriptionOfWork // ignore: cast_nullable_to_non_nullable
                  as String,
        cost: freezed == cost
            ? _value.cost
            : cost // ignore: cast_nullable_to_non_nullable
                  as double?,
        performedBy: freezed == performedBy
            ? _value.performedBy
            : performedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        photos: freezed == photos
            ? _value._photos
            : photos // ignore: cast_nullable_to_non_nullable
                  as List<MaintenancePhoto>?,
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
        archivedAt: freezed == archivedAt
            ? _value.archivedAt
            : archivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        archivedBy: freezed == archivedBy
            ? _value.archivedBy
            : archivedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        archivedReason: freezed == archivedReason
            ? _value.archivedReason
            : archivedReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquipmentMaintenanceHistoryImpl
    implements _EquipmentMaintenanceHistory {
  const _$EquipmentMaintenanceHistoryImpl({
    required this.id,
    required this.equipmentItemId,
    required this.dateSent,
    this.dateReturned,
    required this.descriptionOfWork,
    this.cost,
    this.performedBy,
    final List<MaintenancePhoto>? photos,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
    this.note,
  }) : _photos = photos;

  factory _$EquipmentMaintenanceHistoryImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$EquipmentMaintenanceHistoryImplFromJson(json);

  @override
  final String id;
  @override
  final String equipmentItemId;
  @override
  final DateTime dateSent;
  @override
  final DateTime? dateReturned;
  @override
  final String descriptionOfWork;
  @override
  final double? cost;
  @override
  final String? performedBy;
  final List<MaintenancePhoto>? _photos;
  @override
  List<MaintenancePhoto>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;
  @override
  final DateTime? archivedAt;
  @override
  final String? archivedBy;
  @override
  final String? archivedReason;
  @override
  final String? note;

  @override
  String toString() {
    return 'EquipmentMaintenanceHistory(id: $id, equipmentItemId: $equipmentItemId, dateSent: $dateSent, dateReturned: $dateReturned, descriptionOfWork: $descriptionOfWork, cost: $cost, performedBy: $performedBy, photos: $photos, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedReason: $archivedReason, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentMaintenanceHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.equipmentItemId, equipmentItemId) ||
                other.equipmentItemId == equipmentItemId) &&
            (identical(other.dateSent, dateSent) ||
                other.dateSent == dateSent) &&
            (identical(other.dateReturned, dateReturned) ||
                other.dateReturned == dateReturned) &&
            (identical(other.descriptionOfWork, descriptionOfWork) ||
                other.descriptionOfWork == descriptionOfWork) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedBy, archivedBy) ||
                other.archivedBy == archivedBy) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    equipmentItemId,
    dateSent,
    dateReturned,
    descriptionOfWork,
    cost,
    performedBy,
    const DeepCollectionEquality().hash(_photos),
    createdAt,
    updatedAt,
    createdBy,
    updatedBy,
    archivedAt,
    archivedBy,
    archivedReason,
    note,
  );

  /// Create a copy of EquipmentMaintenanceHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentMaintenanceHistoryImplCopyWith<_$EquipmentMaintenanceHistoryImpl>
  get copyWith =>
      __$$EquipmentMaintenanceHistoryImplCopyWithImpl<
        _$EquipmentMaintenanceHistoryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentMaintenanceHistoryImplToJson(this);
  }
}

abstract class _EquipmentMaintenanceHistory
    implements EquipmentMaintenanceHistory {
  const factory _EquipmentMaintenanceHistory({
    required final String id,
    required final String equipmentItemId,
    required final DateTime dateSent,
    final DateTime? dateReturned,
    required final String descriptionOfWork,
    final double? cost,
    final String? performedBy,
    final List<MaintenancePhoto>? photos,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? createdBy,
    final String? updatedBy,
    final DateTime? archivedAt,
    final String? archivedBy,
    final String? archivedReason,
    final String? note,
  }) = _$EquipmentMaintenanceHistoryImpl;

  factory _EquipmentMaintenanceHistory.fromJson(Map<String, dynamic> json) =
      _$EquipmentMaintenanceHistoryImpl.fromJson;

  @override
  String get id;
  @override
  String get equipmentItemId;
  @override
  DateTime get dateSent;
  @override
  DateTime? get dateReturned;
  @override
  String get descriptionOfWork;
  @override
  double? get cost;
  @override
  String? get performedBy;
  @override
  List<MaintenancePhoto>? get photos;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get createdBy;
  @override
  String? get updatedBy;
  @override
  DateTime? get archivedAt;
  @override
  String? get archivedBy;
  @override
  String? get archivedReason;
  @override
  String? get note;

  /// Create a copy of EquipmentMaintenanceHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentMaintenanceHistoryImplCopyWith<_$EquipmentMaintenanceHistoryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
