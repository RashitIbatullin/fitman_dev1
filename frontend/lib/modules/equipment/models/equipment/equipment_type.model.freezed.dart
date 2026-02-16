// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_type.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EquipmentType _$EquipmentTypeFromJson(Map<String, dynamic> json) {
  return _EquipmentType.fromJson(json);
}

/// @nodoc
mixin _$EquipmentType {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @EquipmentCategoryConverter()
  EquipmentCategory get category => throw _privateConstructorUsedError;
  String? get weightRange => throw _privateConstructorUsedError;
  String? get dimensions => throw _privateConstructorUsedError;
  bool get isMobile => throw _privateConstructorUsedError;
  String? get schematicIcon => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedReason => throw _privateConstructorUsedError;

  /// Serializes this EquipmentType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentTypeCopyWith<EquipmentType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentTypeCopyWith<$Res> {
  factory $EquipmentTypeCopyWith(
    EquipmentType value,
    $Res Function(EquipmentType) then,
  ) = _$EquipmentTypeCopyWithImpl<$Res, EquipmentType>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @EquipmentCategoryConverter() EquipmentCategory category,
    String? weightRange,
    String? dimensions,
    bool isMobile,
    String? schematicIcon,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  });
}

/// @nodoc
class _$EquipmentTypeCopyWithImpl<$Res, $Val extends EquipmentType>
    implements $EquipmentTypeCopyWith<$Res> {
  _$EquipmentTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? weightRange = freezed,
    Object? dimensions = freezed,
    Object? isMobile = null,
    Object? schematicIcon = freezed,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as EquipmentCategory,
            weightRange: freezed == weightRange
                ? _value.weightRange
                : weightRange // ignore: cast_nullable_to_non_nullable
                      as String?,
            dimensions: freezed == dimensions
                ? _value.dimensions
                : dimensions // ignore: cast_nullable_to_non_nullable
                      as String?,
            isMobile: null == isMobile
                ? _value.isMobile
                : isMobile // ignore: cast_nullable_to_non_nullable
                      as bool,
            schematicIcon: freezed == schematicIcon
                ? _value.schematicIcon
                : schematicIcon // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EquipmentTypeImplCopyWith<$Res>
    implements $EquipmentTypeCopyWith<$Res> {
  factory _$$EquipmentTypeImplCopyWith(
    _$EquipmentTypeImpl value,
    $Res Function(_$EquipmentTypeImpl) then,
  ) = __$$EquipmentTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @EquipmentCategoryConverter() EquipmentCategory category,
    String? weightRange,
    String? dimensions,
    bool isMobile,
    String? schematicIcon,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  });
}

/// @nodoc
class __$$EquipmentTypeImplCopyWithImpl<$Res>
    extends _$EquipmentTypeCopyWithImpl<$Res, _$EquipmentTypeImpl>
    implements _$$EquipmentTypeImplCopyWith<$Res> {
  __$$EquipmentTypeImplCopyWithImpl(
    _$EquipmentTypeImpl _value,
    $Res Function(_$EquipmentTypeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquipmentType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? weightRange = freezed,
    Object? dimensions = freezed,
    Object? isMobile = null,
    Object? schematicIcon = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
  }) {
    return _then(
      _$EquipmentTypeImpl(
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
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as EquipmentCategory,
        weightRange: freezed == weightRange
            ? _value.weightRange
            : weightRange // ignore: cast_nullable_to_non_nullable
                  as String?,
        dimensions: freezed == dimensions
            ? _value.dimensions
            : dimensions // ignore: cast_nullable_to_non_nullable
                  as String?,
        isMobile: null == isMobile
            ? _value.isMobile
            : isMobile // ignore: cast_nullable_to_non_nullable
                  as bool,
        schematicIcon: freezed == schematicIcon
            ? _value.schematicIcon
            : schematicIcon // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquipmentTypeImpl implements _EquipmentType {
  const _$EquipmentTypeImpl({
    required this.id,
    required this.name,
    this.description,
    @EquipmentCategoryConverter() required this.category,
    this.weightRange,
    this.dimensions,
    this.isMobile = true,
    this.schematicIcon,
    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
  });

  factory _$EquipmentTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentTypeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @EquipmentCategoryConverter()
  final EquipmentCategory category;
  @override
  final String? weightRange;
  @override
  final String? dimensions;
  @override
  @JsonKey()
  final bool isMobile;
  @override
  final String? schematicIcon;
  @override
  final DateTime? archivedAt;
  @override
  final String? archivedBy;
  @override
  final String? archivedReason;

  @override
  String toString() {
    return 'EquipmentType(id: $id, name: $name, description: $description, category: $category, weightRange: $weightRange, dimensions: $dimensions, isMobile: $isMobile, schematicIcon: $schematicIcon, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedReason: $archivedReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.weightRange, weightRange) ||
                other.weightRange == weightRange) &&
            (identical(other.dimensions, dimensions) ||
                other.dimensions == dimensions) &&
            (identical(other.isMobile, isMobile) ||
                other.isMobile == isMobile) &&
            (identical(other.schematicIcon, schematicIcon) ||
                other.schematicIcon == schematicIcon) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedBy, archivedBy) ||
                other.archivedBy == archivedBy) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    category,
    weightRange,
    dimensions,
    isMobile,
    schematicIcon,
    archivedAt,
    archivedBy,
    archivedReason,
  );

  /// Create a copy of EquipmentType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentTypeImplCopyWith<_$EquipmentTypeImpl> get copyWith =>
      __$$EquipmentTypeImplCopyWithImpl<_$EquipmentTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EquipmentTypeImplToJson(this);
  }
}

abstract class _EquipmentType implements EquipmentType {
  const factory _EquipmentType({
    required final String id,
    required final String name,
    final String? description,
    @EquipmentCategoryConverter() required final EquipmentCategory category,
    final String? weightRange,
    final String? dimensions,
    final bool isMobile,
    final String? schematicIcon,
    final DateTime? archivedAt,
    final String? archivedBy,
    final String? archivedReason,
  }) = _$EquipmentTypeImpl;

  factory _EquipmentType.fromJson(Map<String, dynamic> json) =
      _$EquipmentTypeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @EquipmentCategoryConverter()
  EquipmentCategory get category;
  @override
  String? get weightRange;
  @override
  String? get dimensions;
  @override
  bool get isMobile;
  @override
  String? get schematicIcon;
  @override
  DateTime? get archivedAt;
  @override
  String? get archivedBy;
  @override
  String? get archivedReason;

  /// Create a copy of EquipmentType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentTypeImplCopyWith<_$EquipmentTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
