// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'building.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Building _$BuildingFromJson(Map<String, dynamic> json) {
  return _Building.fromJson(json);
}

/// @nodoc
mixin _$Building {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  @NullableDateTimeConverter()
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedByName => throw _privateConstructorUsedError;
  String? get archivedReason => throw _privateConstructorUsedError;

  /// Serializes this Building to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuildingCopyWith<Building> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuildingCopyWith<$Res> {
  factory $BuildingCopyWith(Building value, $Res Function(Building) then) =
      _$BuildingCopyWithImpl<$Res, Building>;
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    String? note,
    @NullableDateTimeConverter() DateTime? createdAt,
    @NullableDateTimeConverter() DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    @NullableDateTimeConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archivedReason,
  });
}

/// @nodoc
class _$BuildingCopyWithImpl<$Res, $Val extends Building>
    implements $BuildingCopyWith<$Res> {
  _$BuildingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? note = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
    Object? archivedReason = freezed,
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
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            archivedByName: freezed == archivedByName
                ? _value.archivedByName
                : archivedByName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$BuildingImplCopyWith<$Res>
    implements $BuildingCopyWith<$Res> {
  factory _$$BuildingImplCopyWith(
    _$BuildingImpl value,
    $Res Function(_$BuildingImpl) then,
  ) = __$$BuildingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    String? note,
    @NullableDateTimeConverter() DateTime? createdAt,
    @NullableDateTimeConverter() DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    @NullableDateTimeConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archivedReason,
  });
}

/// @nodoc
class __$$BuildingImplCopyWithImpl<$Res>
    extends _$BuildingCopyWithImpl<$Res, _$BuildingImpl>
    implements _$$BuildingImplCopyWith<$Res> {
  __$$BuildingImplCopyWithImpl(
    _$BuildingImpl _value,
    $Res Function(_$BuildingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? note = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedByName = freezed,
    Object? archivedReason = freezed,
  }) {
    return _then(
      _$BuildingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        archivedByName: freezed == archivedByName
            ? _value.archivedByName
            : archivedByName // ignore: cast_nullable_to_non_nullable
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
class _$BuildingImpl implements _Building {
  const _$BuildingImpl({
    required this.id,
    required this.name,
    required this.address,
    this.note,
    @NullableDateTimeConverter() this.createdAt,
    @NullableDateTimeConverter() this.updatedAt,
    this.createdBy,
    this.updatedBy,
    @NullableDateTimeConverter() this.archivedAt,
    this.archivedBy,
    this.archivedByName,
    this.archivedReason,
  });

  factory _$BuildingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuildingImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final String? note;
  @override
  @NullableDateTimeConverter()
  final DateTime? createdAt;
  @override
  @NullableDateTimeConverter()
  final DateTime? updatedAt;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;
  @override
  @NullableDateTimeConverter()
  final DateTime? archivedAt;
  @override
  final String? archivedBy;
  @override
  final String? archivedByName;
  @override
  final String? archivedReason;

  @override
  String toString() {
    return 'Building(id: $id, name: $name, address: $address, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedByName: $archivedByName, archivedReason: $archivedReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuildingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.note, note) || other.note == note) &&
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
            (identical(other.archivedByName, archivedByName) ||
                other.archivedByName == archivedByName) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    address,
    note,
    createdAt,
    updatedAt,
    createdBy,
    updatedBy,
    archivedAt,
    archivedBy,
    archivedByName,
    archivedReason,
  );

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuildingImplCopyWith<_$BuildingImpl> get copyWith =>
      __$$BuildingImplCopyWithImpl<_$BuildingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuildingImplToJson(this);
  }
}

abstract class _Building implements Building {
  const factory _Building({
    required final String id,
    required final String name,
    required final String address,
    final String? note,
    @NullableDateTimeConverter() final DateTime? createdAt,
    @NullableDateTimeConverter() final DateTime? updatedAt,
    final String? createdBy,
    final String? updatedBy,
    @NullableDateTimeConverter() final DateTime? archivedAt,
    final String? archivedBy,
    final String? archivedByName,
    final String? archivedReason,
  }) = _$BuildingImpl;

  factory _Building.fromJson(Map<String, dynamic> json) =
      _$BuildingImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  String? get note;
  @override
  @NullableDateTimeConverter()
  DateTime? get createdAt;
  @override
  @NullableDateTimeConverter()
  DateTime? get updatedAt;
  @override
  String? get createdBy;
  @override
  String? get updatedBy;
  @override
  @NullableDateTimeConverter()
  DateTime? get archivedAt;
  @override
  String? get archivedBy;
  @override
  String? get archivedByName;
  @override
  String? get archivedReason;

  /// Create a copy of Building
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuildingImplCopyWith<_$BuildingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
