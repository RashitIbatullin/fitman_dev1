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
  String get id => throw _privateConstructorUsedError;
  String get maintenanceId => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  PhotoTiming get timing => throw _privateConstructorUsedError;
  DateTime? get takenAt => throw _privateConstructorUsedError;
  String? get takenBy => throw _privateConstructorUsedError;

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
  $Res call({
    String id,
    String maintenanceId,
    String url,
    String? comment,
    PhotoTiming timing,
    DateTime? takenAt,
    String? takenBy,
  });
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
  $Res call({
    Object? id = null,
    Object? maintenanceId = null,
    Object? url = null,
    Object? comment = freezed,
    Object? timing = null,
    Object? takenAt = freezed,
    Object? takenBy = freezed,
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
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            timing: null == timing
                ? _value.timing
                : timing // ignore: cast_nullable_to_non_nullable
                      as PhotoTiming,
            takenAt: freezed == takenAt
                ? _value.takenAt
                : takenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            takenBy: freezed == takenBy
                ? _value.takenBy
                : takenBy // ignore: cast_nullable_to_non_nullable
                      as String?,
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
  $Res call({
    String id,
    String maintenanceId,
    String url,
    String? comment,
    PhotoTiming timing,
    DateTime? takenAt,
    String? takenBy,
  });
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
  $Res call({
    Object? id = null,
    Object? maintenanceId = null,
    Object? url = null,
    Object? comment = freezed,
    Object? timing = null,
    Object? takenAt = freezed,
    Object? takenBy = freezed,
  }) {
    return _then(
      _$MaintenancePhotoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        maintenanceId: null == maintenanceId
            ? _value.maintenanceId
            : maintenanceId // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        timing: null == timing
            ? _value.timing
            : timing // ignore: cast_nullable_to_non_nullable
                  as PhotoTiming,
        takenAt: freezed == takenAt
            ? _value.takenAt
            : takenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        takenBy: freezed == takenBy
            ? _value.takenBy
            : takenBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MaintenancePhotoImpl implements _MaintenancePhoto {
  const _$MaintenancePhotoImpl({
    required this.id,
    required this.maintenanceId,
    required this.url,
    this.comment,
    required this.timing,
    this.takenAt,
    this.takenBy,
  });

  factory _$MaintenancePhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaintenancePhotoImplFromJson(json);

  @override
  final String id;
  @override
  final String maintenanceId;
  @override
  final String url;
  @override
  final String? comment;
  @override
  final PhotoTiming timing;
  @override
  final DateTime? takenAt;
  @override
  final String? takenBy;

  @override
  String toString() {
    return 'MaintenancePhoto(id: $id, maintenanceId: $maintenanceId, url: $url, comment: $comment, timing: $timing, takenAt: $takenAt, takenBy: $takenBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaintenancePhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.maintenanceId, maintenanceId) ||
                other.maintenanceId == maintenanceId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.timing, timing) || other.timing == timing) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.takenBy, takenBy) || other.takenBy == takenBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    maintenanceId,
    url,
    comment,
    timing,
    takenAt,
    takenBy,
  );

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
    required final String id,
    required final String maintenanceId,
    required final String url,
    final String? comment,
    required final PhotoTiming timing,
    final DateTime? takenAt,
    final String? takenBy,
  }) = _$MaintenancePhotoImpl;

  factory _MaintenancePhoto.fromJson(Map<String, dynamic> json) =
      _$MaintenancePhotoImpl.fromJson;

  @override
  String get id;
  @override
  String get maintenanceId;
  @override
  String get url;
  @override
  String? get comment;
  @override
  PhotoTiming get timing;
  @override
  DateTime? get takenAt;
  @override
  String? get takenBy;

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
  String? get id => throw _privateConstructorUsedError;
  String get equipmentItemId => throw _privateConstructorUsedError;
  String? get equipmentName => throw _privateConstructorUsedError;
  MaintenanceType get type => throw _privateConstructorUsedError;
  MaintenanceStatus get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get equipmentAvailableFrom => throw _privateConstructorUsedError;
  String get reportedProblem => throw _privateConstructorUsedError;
  String? get workDescription => throw _privateConstructorUsedError;
  String get reportedBy => throw _privateConstructorUsedError;
  String? get executorId => throw _privateConstructorUsedError;
  ExecutorType? get executorType => throw _privateConstructorUsedError;
  String? get executorName => throw _privateConstructorUsedError;
  String? get relatedBookingId => throw _privateConstructorUsedError;
  bool get causedDowntime => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedReason => throw _privateConstructorUsedError;
  List<MaintenancePhoto>? get photos => throw _privateConstructorUsedError;

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
    String? id,
    String equipmentItemId,
    String? equipmentName,
    MaintenanceType type,
    MaintenanceStatus status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? equipmentAvailableFrom,
    String reportedProblem,
    String? workDescription,
    String reportedBy,
    String? executorId,
    ExecutorType? executorType,
    String? executorName,
    String? relatedBookingId,
    bool causedDowntime,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
    List<MaintenancePhoto>? photos,
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
    Object? id = freezed,
    Object? equipmentItemId = null,
    Object? equipmentName = freezed,
    Object? type = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? equipmentAvailableFrom = freezed,
    Object? reportedProblem = null,
    Object? workDescription = freezed,
    Object? reportedBy = null,
    Object? executorId = freezed,
    Object? executorType = freezed,
    Object? executorName = freezed,
    Object? relatedBookingId = freezed,
    Object? causedDowntime = null,
    Object? updatedAt = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
    Object? photos = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            equipmentItemId: null == equipmentItemId
                ? _value.equipmentItemId
                : equipmentItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            equipmentName: freezed == equipmentName
                ? _value.equipmentName
                : equipmentName // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MaintenanceType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MaintenanceStatus,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            equipmentAvailableFrom: freezed == equipmentAvailableFrom
                ? _value.equipmentAvailableFrom
                : equipmentAvailableFrom // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            reportedProblem: null == reportedProblem
                ? _value.reportedProblem
                : reportedProblem // ignore: cast_nullable_to_non_nullable
                      as String,
            workDescription: freezed == workDescription
                ? _value.workDescription
                : workDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            reportedBy: null == reportedBy
                ? _value.reportedBy
                : reportedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            executorId: freezed == executorId
                ? _value.executorId
                : executorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            executorType: freezed == executorType
                ? _value.executorType
                : executorType // ignore: cast_nullable_to_non_nullable
                      as ExecutorType?,
            executorName: freezed == executorName
                ? _value.executorName
                : executorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            relatedBookingId: freezed == relatedBookingId
                ? _value.relatedBookingId
                : relatedBookingId // ignore: cast_nullable_to_non_nullable
                      as String?,
            causedDowntime: null == causedDowntime
                ? _value.causedDowntime
                : causedDowntime // ignore: cast_nullable_to_non_nullable
                      as bool,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
            photos: freezed == photos
                ? _value.photos
                : photos // ignore: cast_nullable_to_non_nullable
                      as List<MaintenancePhoto>?,
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
    String? id,
    String equipmentItemId,
    String? equipmentName,
    MaintenanceType type,
    MaintenanceStatus status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? equipmentAvailableFrom,
    String reportedProblem,
    String? workDescription,
    String reportedBy,
    String? executorId,
    ExecutorType? executorType,
    String? executorName,
    String? relatedBookingId,
    bool causedDowntime,
    DateTime? updatedAt,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
    List<MaintenancePhoto>? photos,
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
    Object? id = freezed,
    Object? equipmentItemId = null,
    Object? equipmentName = freezed,
    Object? type = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? equipmentAvailableFrom = freezed,
    Object? reportedProblem = null,
    Object? workDescription = freezed,
    Object? reportedBy = null,
    Object? executorId = freezed,
    Object? executorType = freezed,
    Object? executorName = freezed,
    Object? relatedBookingId = freezed,
    Object? causedDowntime = null,
    Object? updatedAt = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
    Object? photos = freezed,
  }) {
    return _then(
      _$EquipmentMaintenanceHistoryImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        equipmentItemId: null == equipmentItemId
            ? _value.equipmentItemId
            : equipmentItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        equipmentName: freezed == equipmentName
            ? _value.equipmentName
            : equipmentName // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MaintenanceType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MaintenanceStatus,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        equipmentAvailableFrom: freezed == equipmentAvailableFrom
            ? _value.equipmentAvailableFrom
            : equipmentAvailableFrom // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        reportedProblem: null == reportedProblem
            ? _value.reportedProblem
            : reportedProblem // ignore: cast_nullable_to_non_nullable
                  as String,
        workDescription: freezed == workDescription
            ? _value.workDescription
            : workDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        reportedBy: null == reportedBy
            ? _value.reportedBy
            : reportedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        executorId: freezed == executorId
            ? _value.executorId
            : executorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        executorType: freezed == executorType
            ? _value.executorType
            : executorType // ignore: cast_nullable_to_non_nullable
                  as ExecutorType?,
        executorName: freezed == executorName
            ? _value.executorName
            : executorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        relatedBookingId: freezed == relatedBookingId
            ? _value.relatedBookingId
            : relatedBookingId // ignore: cast_nullable_to_non_nullable
                  as String?,
        causedDowntime: null == causedDowntime
            ? _value.causedDowntime
            : causedDowntime // ignore: cast_nullable_to_non_nullable
                  as bool,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
        photos: freezed == photos
            ? _value._photos
            : photos // ignore: cast_nullable_to_non_nullable
                  as List<MaintenancePhoto>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquipmentMaintenanceHistoryImpl
    implements _EquipmentMaintenanceHistory {
  const _$EquipmentMaintenanceHistoryImpl({
    this.id,
    required this.equipmentItemId,
    this.equipmentName,
    required this.type,
    required this.status,
    this.createdAt,
    this.startedAt,
    this.completedAt,
    this.equipmentAvailableFrom,
    required this.reportedProblem,
    this.workDescription,
    required this.reportedBy,
    this.executorId,
    this.executorType,
    this.executorName,
    this.relatedBookingId,
    this.causedDowntime = false,
    this.updatedAt,
    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
    final List<MaintenancePhoto>? photos,
  }) : _photos = photos;

  factory _$EquipmentMaintenanceHistoryImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$EquipmentMaintenanceHistoryImplFromJson(json);

  @override
  final String? id;
  @override
  final String equipmentItemId;
  @override
  final String? equipmentName;
  @override
  final MaintenanceType type;
  @override
  final MaintenanceStatus status;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? equipmentAvailableFrom;
  @override
  final String reportedProblem;
  @override
  final String? workDescription;
  @override
  final String reportedBy;
  @override
  final String? executorId;
  @override
  final ExecutorType? executorType;
  @override
  final String? executorName;
  @override
  final String? relatedBookingId;
  @override
  @JsonKey()
  final bool causedDowntime;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? archivedAt;
  @override
  final String? archivedBy;
  @override
  final String? archivedReason;
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
  String toString() {
    return 'EquipmentMaintenanceHistory(id: $id, equipmentItemId: $equipmentItemId, equipmentName: $equipmentName, type: $type, status: $status, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, equipmentAvailableFrom: $equipmentAvailableFrom, reportedProblem: $reportedProblem, workDescription: $workDescription, reportedBy: $reportedBy, executorId: $executorId, executorType: $executorType, executorName: $executorName, relatedBookingId: $relatedBookingId, causedDowntime: $causedDowntime, updatedAt: $updatedAt, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedReason: $archivedReason, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentMaintenanceHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.equipmentItemId, equipmentItemId) ||
                other.equipmentItemId == equipmentItemId) &&
            (identical(other.equipmentName, equipmentName) ||
                other.equipmentName == equipmentName) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.equipmentAvailableFrom, equipmentAvailableFrom) ||
                other.equipmentAvailableFrom == equipmentAvailableFrom) &&
            (identical(other.reportedProblem, reportedProblem) ||
                other.reportedProblem == reportedProblem) &&
            (identical(other.workDescription, workDescription) ||
                other.workDescription == workDescription) &&
            (identical(other.reportedBy, reportedBy) ||
                other.reportedBy == reportedBy) &&
            (identical(other.executorId, executorId) ||
                other.executorId == executorId) &&
            (identical(other.executorType, executorType) ||
                other.executorType == executorType) &&
            (identical(other.executorName, executorName) ||
                other.executorName == executorName) &&
            (identical(other.relatedBookingId, relatedBookingId) ||
                other.relatedBookingId == relatedBookingId) &&
            (identical(other.causedDowntime, causedDowntime) ||
                other.causedDowntime == causedDowntime) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedBy, archivedBy) ||
                other.archivedBy == archivedBy) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    equipmentItemId,
    equipmentName,
    type,
    status,
    createdAt,
    startedAt,
    completedAt,
    equipmentAvailableFrom,
    reportedProblem,
    workDescription,
    reportedBy,
    executorId,
    executorType,
    executorName,
    relatedBookingId,
    causedDowntime,
    updatedAt,
    archivedAt,
    archivedBy,
    archivedReason,
    const DeepCollectionEquality().hash(_photos),
  ]);

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
    final String? id,
    required final String equipmentItemId,
    final String? equipmentName,
    required final MaintenanceType type,
    required final MaintenanceStatus status,
    final DateTime? createdAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final DateTime? equipmentAvailableFrom,
    required final String reportedProblem,
    final String? workDescription,
    required final String reportedBy,
    final String? executorId,
    final ExecutorType? executorType,
    final String? executorName,
    final String? relatedBookingId,
    final bool causedDowntime,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
    final String? archivedBy,
    final String? archivedReason,
    final List<MaintenancePhoto>? photos,
  }) = _$EquipmentMaintenanceHistoryImpl;

  factory _EquipmentMaintenanceHistory.fromJson(Map<String, dynamic> json) =
      _$EquipmentMaintenanceHistoryImpl.fromJson;

  @override
  String? get id;
  @override
  String get equipmentItemId;
  @override
  String? get equipmentName;
  @override
  MaintenanceType get type;
  @override
  MaintenanceStatus get status;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get equipmentAvailableFrom;
  @override
  String get reportedProblem;
  @override
  String? get workDescription;
  @override
  String get reportedBy;
  @override
  String? get executorId;
  @override
  ExecutorType? get executorType;
  @override
  String? get executorName;
  @override
  String? get relatedBookingId;
  @override
  bool get causedDowntime;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get archivedAt;
  @override
  String? get archivedBy;
  @override
  String? get archivedReason;
  @override
  List<MaintenancePhoto>? get photos;

  /// Create a copy of EquipmentMaintenanceHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentMaintenanceHistoryImplCopyWith<_$EquipmentMaintenanceHistoryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
