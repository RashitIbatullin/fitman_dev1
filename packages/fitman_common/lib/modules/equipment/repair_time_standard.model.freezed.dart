// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repair_time_standard.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RepairTimeStandard _$RepairTimeStandardFromJson(Map<String, dynamic> json) {
  return _RepairTimeStandard.fromJson(json);
}

/// @nodoc
mixin _$RepairTimeStandard {
  String? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get equipmentTypeId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get standardDurationHours => throw _privateConstructorUsedError;
  RepairComplexity? get complexity =>
      throw _privateConstructorUsedError; // Системные поля
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedReason => throw _privateConstructorUsedError;

  /// Serializes this RepairTimeStandard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RepairTimeStandard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RepairTimeStandardCopyWith<RepairTimeStandard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepairTimeStandardCopyWith<$Res> {
  factory $RepairTimeStandardCopyWith(
          RepairTimeStandard value, $Res Function(RepairTimeStandard) then) =
      _$RepairTimeStandardCopyWithImpl<$Res, RepairTimeStandard>;
  @useResult
  $Res call(
      {String? id,
      String name,
      String equipmentTypeId,
      String? description,
      double standardDurationHours,
      RepairComplexity? complexity,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? createdBy,
      String? updatedBy,
      DateTime? archivedAt,
      String? archivedBy,
      String? archivedReason});
}

/// @nodoc
class _$RepairTimeStandardCopyWithImpl<$Res, $Val extends RepairTimeStandard>
    implements $RepairTimeStandardCopyWith<$Res> {
  _$RepairTimeStandardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RepairTimeStandard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? equipmentTypeId = null,
    Object? description = freezed,
    Object? standardDurationHours = null,
    Object? complexity = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      equipmentTypeId: null == equipmentTypeId
          ? _value.equipmentTypeId
          : equipmentTypeId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      standardDurationHours: null == standardDurationHours
          ? _value.standardDurationHours
          : standardDurationHours // ignore: cast_nullable_to_non_nullable
              as double,
      complexity: freezed == complexity
          ? _value.complexity
          : complexity // ignore: cast_nullable_to_non_nullable
              as RepairComplexity?,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RepairTimeStandardImplCopyWith<$Res>
    implements $RepairTimeStandardCopyWith<$Res> {
  factory _$$RepairTimeStandardImplCopyWith(_$RepairTimeStandardImpl value,
          $Res Function(_$RepairTimeStandardImpl) then) =
      __$$RepairTimeStandardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String name,
      String equipmentTypeId,
      String? description,
      double standardDurationHours,
      RepairComplexity? complexity,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? createdBy,
      String? updatedBy,
      DateTime? archivedAt,
      String? archivedBy,
      String? archivedReason});
}

/// @nodoc
class __$$RepairTimeStandardImplCopyWithImpl<$Res>
    extends _$RepairTimeStandardCopyWithImpl<$Res, _$RepairTimeStandardImpl>
    implements _$$RepairTimeStandardImplCopyWith<$Res> {
  __$$RepairTimeStandardImplCopyWithImpl(_$RepairTimeStandardImpl _value,
      $Res Function(_$RepairTimeStandardImpl) _then)
      : super(_value, _then);

  /// Create a copy of RepairTimeStandard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? equipmentTypeId = null,
    Object? description = freezed,
    Object? standardDurationHours = null,
    Object? complexity = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
  }) {
    return _then(_$RepairTimeStandardImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      equipmentTypeId: null == equipmentTypeId
          ? _value.equipmentTypeId
          : equipmentTypeId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      standardDurationHours: null == standardDurationHours
          ? _value.standardDurationHours
          : standardDurationHours // ignore: cast_nullable_to_non_nullable
              as double,
      complexity: freezed == complexity
          ? _value.complexity
          : complexity // ignore: cast_nullable_to_non_nullable
              as RepairComplexity?,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RepairTimeStandardImpl implements _RepairTimeStandard {
  const _$RepairTimeStandardImpl(
      {this.id,
      required this.name,
      required this.equipmentTypeId,
      this.description,
      required this.standardDurationHours,
      this.complexity,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.updatedBy,
      this.archivedAt,
      this.archivedBy,
      this.archivedReason});

  factory _$RepairTimeStandardImpl.fromJson(Map<String, dynamic> json) =>
      _$$RepairTimeStandardImplFromJson(json);

  @override
  final String? id;
  @override
  final String name;
  @override
  final String equipmentTypeId;
  @override
  final String? description;
  @override
  final double standardDurationHours;
  @override
  final RepairComplexity? complexity;
// Системные поля
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
  String toString() {
    return 'RepairTimeStandard(id: $id, name: $name, equipmentTypeId: $equipmentTypeId, description: $description, standardDurationHours: $standardDurationHours, complexity: $complexity, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedReason: $archivedReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepairTimeStandardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.equipmentTypeId, equipmentTypeId) ||
                other.equipmentTypeId == equipmentTypeId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.standardDurationHours, standardDurationHours) ||
                other.standardDurationHours == standardDurationHours) &&
            (identical(other.complexity, complexity) ||
                other.complexity == complexity) &&
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
                other.archivedReason == archivedReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      equipmentTypeId,
      description,
      standardDurationHours,
      complexity,
      createdAt,
      updatedAt,
      createdBy,
      updatedBy,
      archivedAt,
      archivedBy,
      archivedReason);

  /// Create a copy of RepairTimeStandard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RepairTimeStandardImplCopyWith<_$RepairTimeStandardImpl> get copyWith =>
      __$$RepairTimeStandardImplCopyWithImpl<_$RepairTimeStandardImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RepairTimeStandardImplToJson(
      this,
    );
  }
}

abstract class _RepairTimeStandard implements RepairTimeStandard {
  const factory _RepairTimeStandard(
      {final String? id,
      required final String name,
      required final String equipmentTypeId,
      final String? description,
      required final double standardDurationHours,
      final RepairComplexity? complexity,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String? createdBy,
      final String? updatedBy,
      final DateTime? archivedAt,
      final String? archivedBy,
      final String? archivedReason}) = _$RepairTimeStandardImpl;

  factory _RepairTimeStandard.fromJson(Map<String, dynamic> json) =
      _$RepairTimeStandardImpl.fromJson;

  @override
  String? get id;
  @override
  String get name;
  @override
  String get equipmentTypeId;
  @override
  String? get description;
  @override
  double get standardDurationHours;
  @override
  RepairComplexity? get complexity; // Системные поля
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

  /// Create a copy of RepairTimeStandard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RepairTimeStandardImplCopyWith<_$RepairTimeStandardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
