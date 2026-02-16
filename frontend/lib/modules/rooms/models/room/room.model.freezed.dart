// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_number')
  String? get roomNumber => throw _privateConstructorUsedError;
  @RoomTypeConverter()
  RoomType get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'floor')
  int? get floor => throw _privateConstructorUsedError; // Changed to int?
  @JsonKey(name: 'building_id')
  String? get buildingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'building_name')
  String? get buildingName => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_capacity')
  int get maxCapacity => throw _privateConstructorUsedError;
  double? get area => throw _privateConstructorUsedError;
  @TimeOfDayConverter()
  @JsonKey(name: 'open_time')
  TimeOfDay? get openTime => throw _privateConstructorUsedError;
  @TimeOfDayConverter()
  @JsonKey(name: 'close_time')
  TimeOfDay? get closeTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'working_days')
  List<int> get workingDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'deactivate_reason')
  String? get deactivateReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'deactivate_at')
  DateTime? get deactivateAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deactivate_by')
  String? get deactivateBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_urls')
  List<String> get photoUrls => throw _privateConstructorUsedError;
  @JsonKey(name: 'floor_plan_url')
  String? get floorPlanUrl => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_reason')
  String? get archivedReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_by')
  String? get archivedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'archived_by_name')
  String? get archivedByName => throw _privateConstructorUsedError;

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @JsonKey(name: 'room_number') String? roomNumber,
    @RoomTypeConverter() RoomType type,
    @JsonKey(name: 'floor') int? floor,
    @JsonKey(name: 'building_id') String? buildingId,
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'max_capacity') int maxCapacity,
    double? area,
    @TimeOfDayConverter() @JsonKey(name: 'open_time') TimeOfDay? openTime,
    @TimeOfDayConverter() @JsonKey(name: 'close_time') TimeOfDay? closeTime,
    @JsonKey(name: 'working_days') List<int> workingDays,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'deactivate_reason') String? deactivateReason,
    @JsonKey(name: 'deactivate_at') DateTime? deactivateAt,
    @JsonKey(name: 'deactivate_by') String? deactivateBy,
    @JsonKey(name: 'photo_urls') List<String> photoUrls,
    @JsonKey(name: 'floor_plan_url') String? floorPlanUrl,
    String? note,
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
    @JsonKey(name: 'archived_reason') String? archivedReason,
    @JsonKey(name: 'archived_by') String? archivedBy,
    @JsonKey(name: 'archived_by_name') String? archivedByName,
  });
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? roomNumber = freezed,
    Object? type = null,
    Object? floor = freezed,
    Object? buildingId = freezed,
    Object? buildingName = freezed,
    Object? maxCapacity = null,
    Object? area = freezed,
    Object? openTime = freezed,
    Object? closeTime = freezed,
    Object? workingDays = null,
    Object? isActive = null,
    Object? deactivateReason = freezed,
    Object? deactivateAt = freezed,
    Object? deactivateBy = freezed,
    Object? photoUrls = null,
    Object? floorPlanUrl = freezed,
    Object? note = freezed,
    Object? archivedAt = freezed,
    Object? archivedReason = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            roomNumber: freezed == roomNumber
                ? _value.roomNumber
                : roomNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as RoomType,
            floor: freezed == floor
                ? _value.floor
                : floor // ignore: cast_nullable_to_non_nullable
                      as int?,
            buildingId: freezed == buildingId
                ? _value.buildingId
                : buildingId // ignore: cast_nullable_to_non_nullable
                      as String?,
            buildingName: freezed == buildingName
                ? _value.buildingName
                : buildingName // ignore: cast_nullable_to_non_nullable
                      as String?,
            maxCapacity: null == maxCapacity
                ? _value.maxCapacity
                : maxCapacity // ignore: cast_nullable_to_non_nullable
                      as int,
            area: freezed == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as double?,
            openTime: freezed == openTime
                ? _value.openTime
                : openTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDay?,
            closeTime: freezed == closeTime
                ? _value.closeTime
                : closeTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDay?,
            workingDays: null == workingDays
                ? _value.workingDays
                : workingDays // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            deactivateReason: freezed == deactivateReason
                ? _value.deactivateReason
                : deactivateReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            deactivateAt: freezed == deactivateAt
                ? _value.deactivateAt
                : deactivateAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deactivateBy: freezed == deactivateBy
                ? _value.deactivateBy
                : deactivateBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrls: null == photoUrls
                ? _value.photoUrls
                : photoUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            floorPlanUrl: freezed == floorPlanUrl
                ? _value.floorPlanUrl
                : floorPlanUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            archivedAt: freezed == archivedAt
                ? _value.archivedAt
                : archivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            archivedReason: freezed == archivedReason
                ? _value.archivedReason
                : archivedReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            archivedBy: freezed == archivedBy
                ? _value.archivedBy
                : archivedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            archivedByName: freezed == archivedByName
                ? _value.archivedByName
                : archivedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
    _$RoomImpl value,
    $Res Function(_$RoomImpl) then,
  ) = __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @JsonKey(name: 'room_number') String? roomNumber,
    @RoomTypeConverter() RoomType type,
    @JsonKey(name: 'floor') int? floor,
    @JsonKey(name: 'building_id') String? buildingId,
    @JsonKey(name: 'building_name') String? buildingName,
    @JsonKey(name: 'max_capacity') int maxCapacity,
    double? area,
    @TimeOfDayConverter() @JsonKey(name: 'open_time') TimeOfDay? openTime,
    @TimeOfDayConverter() @JsonKey(name: 'close_time') TimeOfDay? closeTime,
    @JsonKey(name: 'working_days') List<int> workingDays,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'deactivate_reason') String? deactivateReason,
    @JsonKey(name: 'deactivate_at') DateTime? deactivateAt,
    @JsonKey(name: 'deactivate_by') String? deactivateBy,
    @JsonKey(name: 'photo_urls') List<String> photoUrls,
    @JsonKey(name: 'floor_plan_url') String? floorPlanUrl,
    String? note,
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
    @JsonKey(name: 'archived_reason') String? archivedReason,
    @JsonKey(name: 'archived_by') String? archivedBy,
    @JsonKey(name: 'archived_by_name') String? archivedByName,
  });
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
    : super(_value, _then);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? roomNumber = freezed,
    Object? type = null,
    Object? floor = freezed,
    Object? buildingId = freezed,
    Object? buildingName = freezed,
    Object? maxCapacity = null,
    Object? area = freezed,
    Object? openTime = freezed,
    Object? closeTime = freezed,
    Object? workingDays = null,
    Object? isActive = null,
    Object? deactivateReason = freezed,
    Object? deactivateAt = freezed,
    Object? deactivateBy = freezed,
    Object? photoUrls = null,
    Object? floorPlanUrl = freezed,
    Object? note = freezed,
    Object? archivedAt = freezed,
    Object? archivedReason = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
  }) {
    return _then(
      _$RoomImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        roomNumber: freezed == roomNumber
            ? _value.roomNumber
            : roomNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as RoomType,
        floor: freezed == floor
            ? _value.floor
            : floor // ignore: cast_nullable_to_non_nullable
                  as int?,
        buildingId: freezed == buildingId
            ? _value.buildingId
            : buildingId // ignore: cast_nullable_to_non_nullable
                  as String?,
        buildingName: freezed == buildingName
            ? _value.buildingName
            : buildingName // ignore: cast_nullable_to_non_nullable
                  as String?,
        maxCapacity: null == maxCapacity
            ? _value.maxCapacity
            : maxCapacity // ignore: cast_nullable_to_non_nullable
                  as int,
        area: freezed == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as double?,
        openTime: freezed == openTime
            ? _value.openTime
            : openTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDay?,
        closeTime: freezed == closeTime
            ? _value.closeTime
            : closeTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDay?,
        workingDays: null == workingDays
            ? _value._workingDays
            : workingDays // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        deactivateReason: freezed == deactivateReason
            ? _value.deactivateReason
            : deactivateReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        deactivateAt: freezed == deactivateAt
            ? _value.deactivateAt
            : deactivateAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deactivateBy: freezed == deactivateBy
            ? _value.deactivateBy
            : deactivateBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrls: null == photoUrls
            ? _value._photoUrls
            : photoUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        floorPlanUrl: freezed == floorPlanUrl
            ? _value.floorPlanUrl
            : floorPlanUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        archivedAt: freezed == archivedAt
            ? _value.archivedAt
            : archivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        archivedReason: freezed == archivedReason
            ? _value.archivedReason
            : archivedReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        archivedBy: freezed == archivedBy
            ? _value.archivedBy
            : archivedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        archivedByName: freezed == archivedByName
            ? _value.archivedByName
            : archivedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomImpl implements _Room {
  const _$RoomImpl({
    required this.id,
    required this.name,
    this.description,
    @JsonKey(name: 'room_number') this.roomNumber,
    @RoomTypeConverter() required this.type,
    @JsonKey(name: 'floor') this.floor,
    @JsonKey(name: 'building_id') this.buildingId,
    @JsonKey(name: 'building_name') this.buildingName,
    @JsonKey(name: 'max_capacity') this.maxCapacity = 30,
    this.area,
    @TimeOfDayConverter() @JsonKey(name: 'open_time') this.openTime,
    @TimeOfDayConverter() @JsonKey(name: 'close_time') this.closeTime,
    @JsonKey(name: 'working_days') final List<int> workingDays = const [],
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'deactivate_reason') this.deactivateReason,
    @JsonKey(name: 'deactivate_at') this.deactivateAt,
    @JsonKey(name: 'deactivate_by') this.deactivateBy,
    @JsonKey(name: 'photo_urls') final List<String> photoUrls = const [],
    @JsonKey(name: 'floor_plan_url') this.floorPlanUrl,
    this.note,
    @JsonKey(name: 'archived_at') this.archivedAt,
    @JsonKey(name: 'archived_reason') this.archivedReason,
    @JsonKey(name: 'archived_by') this.archivedBy,
    @JsonKey(name: 'archived_by_name') this.archivedByName,
  }) : _workingDays = workingDays,
       _photoUrls = photoUrls;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'room_number')
  final String? roomNumber;
  @override
  @RoomTypeConverter()
  final RoomType type;
  @override
  @JsonKey(name: 'floor')
  final int? floor;
  // Changed to int?
  @override
  @JsonKey(name: 'building_id')
  final String? buildingId;
  @override
  @JsonKey(name: 'building_name')
  final String? buildingName;
  @override
  @JsonKey(name: 'max_capacity')
  final int maxCapacity;
  @override
  final double? area;
  @override
  @TimeOfDayConverter()
  @JsonKey(name: 'open_time')
  final TimeOfDay? openTime;
  @override
  @TimeOfDayConverter()
  @JsonKey(name: 'close_time')
  final TimeOfDay? closeTime;
  final List<int> _workingDays;
  @override
  @JsonKey(name: 'working_days')
  List<int> get workingDays {
    if (_workingDays is EqualUnmodifiableListView) return _workingDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workingDays);
  }

  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'deactivate_reason')
  final String? deactivateReason;
  @override
  @JsonKey(name: 'deactivate_at')
  final DateTime? deactivateAt;
  @override
  @JsonKey(name: 'deactivate_by')
  final String? deactivateBy;
  final List<String> _photoUrls;
  @override
  @JsonKey(name: 'photo_urls')
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  @override
  @JsonKey(name: 'floor_plan_url')
  final String? floorPlanUrl;
  @override
  final String? note;
  @override
  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;
  @override
  @JsonKey(name: 'archived_reason')
  final String? archivedReason;
  @override
  @JsonKey(name: 'archived_by')
  final String? archivedBy;
  @override
  @JsonKey(name: 'archived_by_name')
  final String? archivedByName;

  @override
  String toString() {
    return 'Room(id: $id, name: $name, description: $description, roomNumber: $roomNumber, type: $type, floor: $floor, buildingId: $buildingId, buildingName: $buildingName, maxCapacity: $maxCapacity, area: $area, openTime: $openTime, closeTime: $closeTime, workingDays: $workingDays, isActive: $isActive, deactivateReason: $deactivateReason, deactivateAt: $deactivateAt, deactivateBy: $deactivateBy, photoUrls: $photoUrls, floorPlanUrl: $floorPlanUrl, note: $note, archivedAt: $archivedAt, archivedReason: $archivedReason, archivedBy: $archivedBy, archivedByName: $archivedByName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.roomNumber, roomNumber) ||
                other.roomNumber == roomNumber) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.buildingId, buildingId) ||
                other.buildingId == buildingId) &&
            (identical(other.buildingName, buildingName) ||
                other.buildingName == buildingName) &&
            (identical(other.maxCapacity, maxCapacity) ||
                other.maxCapacity == maxCapacity) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.openTime, openTime) ||
                other.openTime == openTime) &&
            (identical(other.closeTime, closeTime) ||
                other.closeTime == closeTime) &&
            const DeepCollectionEquality().equals(
              other._workingDays,
              _workingDays,
            ) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.deactivateReason, deactivateReason) ||
                other.deactivateReason == deactivateReason) &&
            (identical(other.deactivateAt, deactivateAt) ||
                other.deactivateAt == deactivateAt) &&
            (identical(other.deactivateBy, deactivateBy) ||
                other.deactivateBy == deactivateBy) &&
            const DeepCollectionEquality().equals(
              other._photoUrls,
              _photoUrls,
            ) &&
            (identical(other.floorPlanUrl, floorPlanUrl) ||
                other.floorPlanUrl == floorPlanUrl) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason) &&
            (identical(other.archivedBy, archivedBy) ||
                other.archivedBy == archivedBy) &&
            (identical(other.archivedByName, archivedByName) ||
                other.archivedByName == archivedByName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    roomNumber,
    type,
    floor,
    buildingId,
    buildingName,
    maxCapacity,
    area,
    openTime,
    closeTime,
    const DeepCollectionEquality().hash(_workingDays),
    isActive,
    deactivateReason,
    deactivateAt,
    deactivateBy,
    const DeepCollectionEquality().hash(_photoUrls),
    floorPlanUrl,
    note,
    archivedAt,
    archivedReason,
    archivedBy,
    archivedByName,
  ]);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(this);
  }
}

abstract class _Room implements Room {
  const factory _Room({
    required final String id,
    required final String name,
    final String? description,
    @JsonKey(name: 'room_number') final String? roomNumber,
    @RoomTypeConverter() required final RoomType type,
    @JsonKey(name: 'floor') final int? floor,
    @JsonKey(name: 'building_id') final String? buildingId,
    @JsonKey(name: 'building_name') final String? buildingName,
    @JsonKey(name: 'max_capacity') final int maxCapacity,
    final double? area,
    @TimeOfDayConverter() @JsonKey(name: 'open_time') final TimeOfDay? openTime,
    @TimeOfDayConverter()
    @JsonKey(name: 'close_time')
    final TimeOfDay? closeTime,
    @JsonKey(name: 'working_days') final List<int> workingDays,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'deactivate_reason') final String? deactivateReason,
    @JsonKey(name: 'deactivate_at') final DateTime? deactivateAt,
    @JsonKey(name: 'deactivate_by') final String? deactivateBy,
    @JsonKey(name: 'photo_urls') final List<String> photoUrls,
    @JsonKey(name: 'floor_plan_url') final String? floorPlanUrl,
    final String? note,
    @JsonKey(name: 'archived_at') final DateTime? archivedAt,
    @JsonKey(name: 'archived_reason') final String? archivedReason,
    @JsonKey(name: 'archived_by') final String? archivedBy,
    @JsonKey(name: 'archived_by_name') final String? archivedByName,
  }) = _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'room_number')
  String? get roomNumber;
  @override
  @RoomTypeConverter()
  RoomType get type;
  @override
  @JsonKey(name: 'floor')
  int? get floor; // Changed to int?
  @override
  @JsonKey(name: 'building_id')
  String? get buildingId;
  @override
  @JsonKey(name: 'building_name')
  String? get buildingName;
  @override
  @JsonKey(name: 'max_capacity')
  int get maxCapacity;
  @override
  double? get area;
  @override
  @TimeOfDayConverter()
  @JsonKey(name: 'open_time')
  TimeOfDay? get openTime;
  @override
  @TimeOfDayConverter()
  @JsonKey(name: 'close_time')
  TimeOfDay? get closeTime;
  @override
  @JsonKey(name: 'working_days')
  List<int> get workingDays;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'deactivate_reason')
  String? get deactivateReason;
  @override
  @JsonKey(name: 'deactivate_at')
  DateTime? get deactivateAt;
  @override
  @JsonKey(name: 'deactivate_by')
  String? get deactivateBy;
  @override
  @JsonKey(name: 'photo_urls')
  List<String> get photoUrls;
  @override
  @JsonKey(name: 'floor_plan_url')
  String? get floorPlanUrl;
  @override
  String? get note;
  @override
  @JsonKey(name: 'archived_at')
  DateTime? get archivedAt;
  @override
  @JsonKey(name: 'archived_reason')
  String? get archivedReason;
  @override
  @JsonKey(name: 'archived_by')
  String? get archivedBy;
  @override
  @JsonKey(name: 'archived_by_name')
  String? get archivedByName;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
