// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_item.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EquipmentItem _$EquipmentItemFromJson(Map<String, dynamic> json) {
  return _EquipmentItem.fromJson(json);
}

/// @nodoc
mixin _$EquipmentItem {
  String get id => throw _privateConstructorUsedError;
  String get typeId => throw _privateConstructorUsedError;
  String get inventoryNumber => throw _privateConstructorUsedError;
  String? get serialNumber => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  String? get manufacturer => throw _privateConstructorUsedError;
  String? get roomId => throw _privateConstructorUsedError;
  String? get placementNote => throw _privateConstructorUsedError;
  @EquipmentStatusConverter()
  EquipmentStatus get status => throw _privateConstructorUsedError;
  int get conditionRating => throw _privateConstructorUsedError;
  String? get conditionNotes => throw _privateConstructorUsedError;
  DateTime? get lastMaintenanceDate => throw _privateConstructorUsedError;
  DateTime? get nextMaintenanceDate => throw _privateConstructorUsedError;
  String? get maintenanceNotes => throw _privateConstructorUsedError;
  DateTime? get purchaseDate => throw _privateConstructorUsedError;
  double? get purchasePrice => throw _privateConstructorUsedError;
  String? get supplier => throw _privateConstructorUsedError;
  int? get warrantyMonths => throw _privateConstructorUsedError;
  int get usageHours => throw _privateConstructorUsedError;
  DateTime? get lastUsedDate => throw _privateConstructorUsedError;
  List<String> get photoUrls => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedReason => throw _privateConstructorUsedError;

  /// Serializes this EquipmentItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentItemCopyWith<EquipmentItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentItemCopyWith<$Res> {
  factory $EquipmentItemCopyWith(
    EquipmentItem value,
    $Res Function(EquipmentItem) then,
  ) = _$EquipmentItemCopyWithImpl<$Res, EquipmentItem>;
  @useResult
  $Res call({
    String id,
    String typeId,
    String inventoryNumber,
    String? serialNumber,
    String? model,
    String? manufacturer,
    String? roomId,
    String? placementNote,
    @EquipmentStatusConverter() EquipmentStatus status,
    int conditionRating,
    String? conditionNotes,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? maintenanceNotes,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? supplier,
    int? warrantyMonths,
    int usageHours,
    DateTime? lastUsedDate,
    List<String> photoUrls,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  });
}

/// @nodoc
class _$EquipmentItemCopyWithImpl<$Res, $Val extends EquipmentItem>
    implements $EquipmentItemCopyWith<$Res> {
  _$EquipmentItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? typeId = null,
    Object? inventoryNumber = null,
    Object? serialNumber = freezed,
    Object? model = freezed,
    Object? manufacturer = freezed,
    Object? roomId = freezed,
    Object? placementNote = freezed,
    Object? status = null,
    Object? conditionRating = null,
    Object? conditionNotes = freezed,
    Object? lastMaintenanceDate = freezed,
    Object? nextMaintenanceDate = freezed,
    Object? maintenanceNotes = freezed,
    Object? purchaseDate = freezed,
    Object? purchasePrice = freezed,
    Object? supplier = freezed,
    Object? warrantyMonths = freezed,
    Object? usageHours = null,
    Object? lastUsedDate = freezed,
    Object? photoUrls = null,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            typeId: null == typeId
                ? _value.typeId
                : typeId // ignore: cast_nullable_to_non_nullable
                      as String,
            inventoryNumber: null == inventoryNumber
                ? _value.inventoryNumber
                : inventoryNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            serialNumber: freezed == serialNumber
                ? _value.serialNumber
                : serialNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            model: freezed == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String?,
            manufacturer: freezed == manufacturer
                ? _value.manufacturer
                : manufacturer // ignore: cast_nullable_to_non_nullable
                      as String?,
            roomId: freezed == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String?,
            placementNote: freezed == placementNote
                ? _value.placementNote
                : placementNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EquipmentStatus,
            conditionRating: null == conditionRating
                ? _value.conditionRating
                : conditionRating // ignore: cast_nullable_to_non_nullable
                      as int,
            conditionNotes: freezed == conditionNotes
                ? _value.conditionNotes
                : conditionNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMaintenanceDate: freezed == lastMaintenanceDate
                ? _value.lastMaintenanceDate
                : lastMaintenanceDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            nextMaintenanceDate: freezed == nextMaintenanceDate
                ? _value.nextMaintenanceDate
                : nextMaintenanceDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            maintenanceNotes: freezed == maintenanceNotes
                ? _value.maintenanceNotes
                : maintenanceNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchaseDate: freezed == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            purchasePrice: freezed == purchasePrice
                ? _value.purchasePrice
                : purchasePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            supplier: freezed == supplier
                ? _value.supplier
                : supplier // ignore: cast_nullable_to_non_nullable
                      as String?,
            warrantyMonths: freezed == warrantyMonths
                ? _value.warrantyMonths
                : warrantyMonths // ignore: cast_nullable_to_non_nullable
                      as int?,
            usageHours: null == usageHours
                ? _value.usageHours
                : usageHours // ignore: cast_nullable_to_non_nullable
                      as int,
            lastUsedDate: freezed == lastUsedDate
                ? _value.lastUsedDate
                : lastUsedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            photoUrls: null == photoUrls
                ? _value.photoUrls
                : photoUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EquipmentItemImplCopyWith<$Res>
    implements $EquipmentItemCopyWith<$Res> {
  factory _$$EquipmentItemImplCopyWith(
    _$EquipmentItemImpl value,
    $Res Function(_$EquipmentItemImpl) then,
  ) = __$$EquipmentItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String typeId,
    String inventoryNumber,
    String? serialNumber,
    String? model,
    String? manufacturer,
    String? roomId,
    String? placementNote,
    @EquipmentStatusConverter() EquipmentStatus status,
    int conditionRating,
    String? conditionNotes,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? maintenanceNotes,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? supplier,
    int? warrantyMonths,
    int usageHours,
    DateTime? lastUsedDate,
    List<String> photoUrls,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  });
}

/// @nodoc
class __$$EquipmentItemImplCopyWithImpl<$Res>
    extends _$EquipmentItemCopyWithImpl<$Res, _$EquipmentItemImpl>
    implements _$$EquipmentItemImplCopyWith<$Res> {
  __$$EquipmentItemImplCopyWithImpl(
    _$EquipmentItemImpl _value,
    $Res Function(_$EquipmentItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? typeId = null,
    Object? inventoryNumber = null,
    Object? serialNumber = freezed,
    Object? model = freezed,
    Object? manufacturer = freezed,
    Object? roomId = freezed,
    Object? placementNote = freezed,
    Object? status = null,
    Object? conditionRating = null,
    Object? conditionNotes = freezed,
    Object? lastMaintenanceDate = freezed,
    Object? nextMaintenanceDate = freezed,
    Object? maintenanceNotes = freezed,
    Object? purchaseDate = freezed,
    Object? purchasePrice = freezed,
    Object? supplier = freezed,
    Object? warrantyMonths = freezed,
    Object? usageHours = null,
    Object? lastUsedDate = freezed,
    Object? photoUrls = null,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
  }) {
    return _then(
      _$EquipmentItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        typeId: null == typeId
            ? _value.typeId
            : typeId // ignore: cast_nullable_to_non_nullable
                  as String,
        inventoryNumber: null == inventoryNumber
            ? _value.inventoryNumber
            : inventoryNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        serialNumber: freezed == serialNumber
            ? _value.serialNumber
            : serialNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        model: freezed == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String?,
        manufacturer: freezed == manufacturer
            ? _value.manufacturer
            : manufacturer // ignore: cast_nullable_to_non_nullable
                  as String?,
        roomId: freezed == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String?,
        placementNote: freezed == placementNote
            ? _value.placementNote
            : placementNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EquipmentStatus,
        conditionRating: null == conditionRating
            ? _value.conditionRating
            : conditionRating // ignore: cast_nullable_to_non_nullable
                  as int,
        conditionNotes: freezed == conditionNotes
            ? _value.conditionNotes
            : conditionNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMaintenanceDate: freezed == lastMaintenanceDate
            ? _value.lastMaintenanceDate
            : lastMaintenanceDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        nextMaintenanceDate: freezed == nextMaintenanceDate
            ? _value.nextMaintenanceDate
            : nextMaintenanceDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        maintenanceNotes: freezed == maintenanceNotes
            ? _value.maintenanceNotes
            : maintenanceNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchaseDate: freezed == purchaseDate
            ? _value.purchaseDate
            : purchaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        purchasePrice: freezed == purchasePrice
            ? _value.purchasePrice
            : purchasePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        supplier: freezed == supplier
            ? _value.supplier
            : supplier // ignore: cast_nullable_to_non_nullable
                  as String?,
        warrantyMonths: freezed == warrantyMonths
            ? _value.warrantyMonths
            : warrantyMonths // ignore: cast_nullable_to_non_nullable
                  as int?,
        usageHours: null == usageHours
            ? _value.usageHours
            : usageHours // ignore: cast_nullable_to_non_nullable
                  as int,
        lastUsedDate: freezed == lastUsedDate
            ? _value.lastUsedDate
            : lastUsedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        photoUrls: null == photoUrls
            ? _value._photoUrls
            : photoUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquipmentItemImpl implements _EquipmentItem {
  const _$EquipmentItemImpl({
    required this.id,
    required this.typeId,
    required this.inventoryNumber,
    this.serialNumber,
    this.model,
    this.manufacturer,
    this.roomId,
    this.placementNote,
    @EquipmentStatusConverter() required this.status,
    required this.conditionRating,
    this.conditionNotes,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintenanceNotes,
    this.purchaseDate,
    this.purchasePrice,
    this.supplier,
    this.warrantyMonths,
    this.usageHours = 0,
    this.lastUsedDate,
    final List<String> photoUrls = const [],
    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
  }) : _photoUrls = photoUrls;

  factory _$EquipmentItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentItemImplFromJson(json);

  @override
  final String id;
  @override
  final String typeId;
  @override
  final String inventoryNumber;
  @override
  final String? serialNumber;
  @override
  final String? model;
  @override
  final String? manufacturer;
  @override
  final String? roomId;
  @override
  final String? placementNote;
  @override
  @EquipmentStatusConverter()
  final EquipmentStatus status;
  @override
  final int conditionRating;
  @override
  final String? conditionNotes;
  @override
  final DateTime? lastMaintenanceDate;
  @override
  final DateTime? nextMaintenanceDate;
  @override
  final String? maintenanceNotes;
  @override
  final DateTime? purchaseDate;
  @override
  final double? purchasePrice;
  @override
  final String? supplier;
  @override
  final int? warrantyMonths;
  @override
  @JsonKey()
  final int usageHours;
  @override
  final DateTime? lastUsedDate;
  final List<String> _photoUrls;
  @override
  @JsonKey()
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  @override
  final DateTime? archivedAt;
  @override
  final String? archivedBy;
  @override
  final String? archivedReason;

  @override
  String toString() {
    return 'EquipmentItem(id: $id, typeId: $typeId, inventoryNumber: $inventoryNumber, serialNumber: $serialNumber, model: $model, manufacturer: $manufacturer, roomId: $roomId, placementNote: $placementNote, status: $status, conditionRating: $conditionRating, conditionNotes: $conditionNotes, lastMaintenanceDate: $lastMaintenanceDate, nextMaintenanceDate: $nextMaintenanceDate, maintenanceNotes: $maintenanceNotes, purchaseDate: $purchaseDate, purchasePrice: $purchasePrice, supplier: $supplier, warrantyMonths: $warrantyMonths, usageHours: $usageHours, lastUsedDate: $lastUsedDate, photoUrls: $photoUrls, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedReason: $archivedReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.typeId, typeId) || other.typeId == typeId) &&
            (identical(other.inventoryNumber, inventoryNumber) ||
                other.inventoryNumber == inventoryNumber) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.placementNote, placementNote) ||
                other.placementNote == placementNote) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.conditionRating, conditionRating) ||
                other.conditionRating == conditionRating) &&
            (identical(other.conditionNotes, conditionNotes) ||
                other.conditionNotes == conditionNotes) &&
            (identical(other.lastMaintenanceDate, lastMaintenanceDate) ||
                other.lastMaintenanceDate == lastMaintenanceDate) &&
            (identical(other.nextMaintenanceDate, nextMaintenanceDate) ||
                other.nextMaintenanceDate == nextMaintenanceDate) &&
            (identical(other.maintenanceNotes, maintenanceNotes) ||
                other.maintenanceNotes == maintenanceNotes) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.purchasePrice, purchasePrice) ||
                other.purchasePrice == purchasePrice) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.warrantyMonths, warrantyMonths) ||
                other.warrantyMonths == warrantyMonths) &&
            (identical(other.usageHours, usageHours) ||
                other.usageHours == usageHours) &&
            (identical(other.lastUsedDate, lastUsedDate) ||
                other.lastUsedDate == lastUsedDate) &&
            const DeepCollectionEquality().equals(
              other._photoUrls,
              _photoUrls,
            ) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedBy, archivedBy) ||
                other.archivedBy == archivedBy) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    typeId,
    inventoryNumber,
    serialNumber,
    model,
    manufacturer,
    roomId,
    placementNote,
    status,
    conditionRating,
    conditionNotes,
    lastMaintenanceDate,
    nextMaintenanceDate,
    maintenanceNotes,
    purchaseDate,
    purchasePrice,
    supplier,
    warrantyMonths,
    usageHours,
    lastUsedDate,
    const DeepCollectionEquality().hash(_photoUrls),
    archivedAt,
    archivedBy,
    archivedReason,
  ]);

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentItemImplCopyWith<_$EquipmentItemImpl> get copyWith =>
      __$$EquipmentItemImplCopyWithImpl<_$EquipmentItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentItemImplToJson(this);
  }
}

abstract class _EquipmentItem implements EquipmentItem {
  const factory _EquipmentItem({
    required final String id,
    required final String typeId,
    required final String inventoryNumber,
    final String? serialNumber,
    final String? model,
    final String? manufacturer,
    final String? roomId,
    final String? placementNote,
    @EquipmentStatusConverter() required final EquipmentStatus status,
    required final int conditionRating,
    final String? conditionNotes,
    final DateTime? lastMaintenanceDate,
    final DateTime? nextMaintenanceDate,
    final String? maintenanceNotes,
    final DateTime? purchaseDate,
    final double? purchasePrice,
    final String? supplier,
    final int? warrantyMonths,
    final int usageHours,
    final DateTime? lastUsedDate,
    final List<String> photoUrls,
    final DateTime? archivedAt,
    final String? archivedBy,
    final String? archivedReason,
  }) = _$EquipmentItemImpl;

  factory _EquipmentItem.fromJson(Map<String, dynamic> json) =
      _$EquipmentItemImpl.fromJson;

  @override
  String get id;
  @override
  String get typeId;
  @override
  String get inventoryNumber;
  @override
  String? get serialNumber;
  @override
  String? get model;
  @override
  String? get manufacturer;
  @override
  String? get roomId;
  @override
  String? get placementNote;
  @override
  @EquipmentStatusConverter()
  EquipmentStatus get status;
  @override
  int get conditionRating;
  @override
  String? get conditionNotes;
  @override
  DateTime? get lastMaintenanceDate;
  @override
  DateTime? get nextMaintenanceDate;
  @override
  String? get maintenanceNotes;
  @override
  DateTime? get purchaseDate;
  @override
  double? get purchasePrice;
  @override
  String? get supplier;
  @override
  int? get warrantyMonths;
  @override
  int get usageHours;
  @override
  DateTime? get lastUsedDate;
  @override
  List<String> get photoUrls;
  @override
  DateTime? get archivedAt;
  @override
  String? get archivedBy;
  @override
  String? get archivedReason;

  /// Create a copy of EquipmentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentItemImplCopyWith<_$EquipmentItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
