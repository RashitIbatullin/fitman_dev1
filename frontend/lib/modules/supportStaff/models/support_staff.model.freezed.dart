// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_staff.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SupportStaff _$SupportStaffFromJson(Map<String, dynamic> json) {
  return _SupportStaff.fromJson(json);
}

/// @nodoc
mixin _$SupportStaff {
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get middleName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  EmploymentType get employmentType => throw _privateConstructorUsedError;
  StaffCategory get category => throw _privateConstructorUsedError;
  List<Competency>? get competencies => throw _privateConstructorUsedError;
  List<String>? get accessibleEquipmentTypes =>
      throw _privateConstructorUsedError;
  bool get canMaintainEquipment => throw _privateConstructorUsedError;
  WorkSchedule? get schedule => throw _privateConstructorUsedError;
  String? get companyName => throw _privateConstructorUsedError;
  String? get contractNumber => throw _privateConstructorUsedError;
  DateTime? get contractExpiryDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedBy => throw _privateConstructorUsedError;
  String? get archivedReason => throw _privateConstructorUsedError;

  /// Serializes this SupportStaff to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportStaff
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportStaffCopyWith<SupportStaff> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportStaffCopyWith<$Res> {
  factory $SupportStaffCopyWith(
    SupportStaff value,
    $Res Function(SupportStaff) then,
  ) = _$SupportStaffCopyWithImpl<$Res, SupportStaff>;
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    String? middleName,
    String? phone,
    String? email,
    EmploymentType employmentType,
    StaffCategory category,
    List<Competency>? competencies,
    List<String>? accessibleEquipmentTypes,
    bool canMaintainEquipment,
    WorkSchedule? schedule,
    String? companyName,
    String? contractNumber,
    DateTime? contractExpiryDate,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  });

  $WorkScheduleCopyWith<$Res>? get schedule;
}

/// @nodoc
class _$SupportStaffCopyWithImpl<$Res, $Val extends SupportStaff>
    implements $SupportStaffCopyWith<$Res> {
  _$SupportStaffCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportStaff
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? middleName = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? employmentType = null,
    Object? category = null,
    Object? competencies = freezed,
    Object? accessibleEquipmentTypes = freezed,
    Object? canMaintainEquipment = null,
    Object? schedule = freezed,
    Object? companyName = freezed,
    Object? contractNumber = freezed,
    Object? contractExpiryDate = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            middleName: freezed == middleName
                ? _value.middleName
                : middleName // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            employmentType: null == employmentType
                ? _value.employmentType
                : employmentType // ignore: cast_nullable_to_non_nullable
                      as EmploymentType,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as StaffCategory,
            competencies: freezed == competencies
                ? _value.competencies
                : competencies // ignore: cast_nullable_to_non_nullable
                      as List<Competency>?,
            accessibleEquipmentTypes: freezed == accessibleEquipmentTypes
                ? _value.accessibleEquipmentTypes
                : accessibleEquipmentTypes // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            canMaintainEquipment: null == canMaintainEquipment
                ? _value.canMaintainEquipment
                : canMaintainEquipment // ignore: cast_nullable_to_non_nullable
                      as bool,
            schedule: freezed == schedule
                ? _value.schedule
                : schedule // ignore: cast_nullable_to_non_nullable
                      as WorkSchedule?,
            companyName: freezed == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractNumber: freezed == contractNumber
                ? _value.contractNumber
                : contractNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractExpiryDate: freezed == contractExpiryDate
                ? _value.contractExpiryDate
                : contractExpiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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

  /// Create a copy of SupportStaff
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkScheduleCopyWith<$Res>? get schedule {
    if (_value.schedule == null) {
      return null;
    }

    return $WorkScheduleCopyWith<$Res>(_value.schedule!, (value) {
      return _then(_value.copyWith(schedule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SupportStaffImplCopyWith<$Res>
    implements $SupportStaffCopyWith<$Res> {
  factory _$$SupportStaffImplCopyWith(
    _$SupportStaffImpl value,
    $Res Function(_$SupportStaffImpl) then,
  ) = __$$SupportStaffImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    String? middleName,
    String? phone,
    String? email,
    EmploymentType employmentType,
    StaffCategory category,
    List<Competency>? competencies,
    List<String>? accessibleEquipmentTypes,
    bool canMaintainEquipment,
    WorkSchedule? schedule,
    String? companyName,
    String? contractNumber,
    DateTime? contractExpiryDate,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  });

  @override
  $WorkScheduleCopyWith<$Res>? get schedule;
}

/// @nodoc
class __$$SupportStaffImplCopyWithImpl<$Res>
    extends _$SupportStaffCopyWithImpl<$Res, _$SupportStaffImpl>
    implements _$$SupportStaffImplCopyWith<$Res> {
  __$$SupportStaffImplCopyWithImpl(
    _$SupportStaffImpl _value,
    $Res Function(_$SupportStaffImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupportStaff
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? middleName = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? employmentType = null,
    Object? category = null,
    Object? competencies = freezed,
    Object? accessibleEquipmentTypes = freezed,
    Object? canMaintainEquipment = null,
    Object? schedule = freezed,
    Object? companyName = freezed,
    Object? contractNumber = freezed,
    Object? contractExpiryDate = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? archivedAt = freezed,
    Object? archivedBy = freezed,
    Object? archivedReason = freezed,
  }) {
    return _then(
      _$SupportStaffImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        middleName: freezed == middleName
            ? _value.middleName
            : middleName // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        employmentType: null == employmentType
            ? _value.employmentType
            : employmentType // ignore: cast_nullable_to_non_nullable
                  as EmploymentType,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as StaffCategory,
        competencies: freezed == competencies
            ? _value._competencies
            : competencies // ignore: cast_nullable_to_non_nullable
                  as List<Competency>?,
        accessibleEquipmentTypes: freezed == accessibleEquipmentTypes
            ? _value._accessibleEquipmentTypes
            : accessibleEquipmentTypes // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        canMaintainEquipment: null == canMaintainEquipment
            ? _value.canMaintainEquipment
            : canMaintainEquipment // ignore: cast_nullable_to_non_nullable
                  as bool,
        schedule: freezed == schedule
            ? _value.schedule
            : schedule // ignore: cast_nullable_to_non_nullable
                  as WorkSchedule?,
        companyName: freezed == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractNumber: freezed == contractNumber
            ? _value.contractNumber
            : contractNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractExpiryDate: freezed == contractExpiryDate
            ? _value.contractExpiryDate
            : contractExpiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$SupportStaffImpl implements _SupportStaff {
  const _$SupportStaffImpl({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.phone,
    this.email,
    required this.employmentType,
    required this.category,
    final List<Competency>? competencies,
    final List<String>? accessibleEquipmentTypes,
    required this.canMaintainEquipment,
    this.schedule,
    this.companyName,
    this.contractNumber,
    this.contractExpiryDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
  }) : _competencies = competencies,
       _accessibleEquipmentTypes = accessibleEquipmentTypes;

  factory _$SupportStaffImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportStaffImplFromJson(json);

  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? middleName;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final EmploymentType employmentType;
  @override
  final StaffCategory category;
  final List<Competency>? _competencies;
  @override
  List<Competency>? get competencies {
    final value = _competencies;
    if (value == null) return null;
    if (_competencies is EqualUnmodifiableListView) return _competencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _accessibleEquipmentTypes;
  @override
  List<String>? get accessibleEquipmentTypes {
    final value = _accessibleEquipmentTypes;
    if (value == null) return null;
    if (_accessibleEquipmentTypes is EqualUnmodifiableListView)
      return _accessibleEquipmentTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool canMaintainEquipment;
  @override
  final WorkSchedule? schedule;
  @override
  final String? companyName;
  @override
  final String? contractNumber;
  @override
  final DateTime? contractExpiryDate;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? archivedAt;
  @override
  final String? archivedBy;
  @override
  final String? archivedReason;

  @override
  String toString() {
    return 'SupportStaff(id: $id, firstName: $firstName, lastName: $lastName, middleName: $middleName, phone: $phone, email: $email, employmentType: $employmentType, category: $category, competencies: $competencies, accessibleEquipmentTypes: $accessibleEquipmentTypes, canMaintainEquipment: $canMaintainEquipment, schedule: $schedule, companyName: $companyName, contractNumber: $contractNumber, contractExpiryDate: $contractExpiryDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, archivedAt: $archivedAt, archivedBy: $archivedBy, archivedReason: $archivedReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportStaffImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.middleName, middleName) ||
                other.middleName == middleName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.employmentType, employmentType) ||
                other.employmentType == employmentType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(
              other._competencies,
              _competencies,
            ) &&
            const DeepCollectionEquality().equals(
              other._accessibleEquipmentTypes,
              _accessibleEquipmentTypes,
            ) &&
            (identical(other.canMaintainEquipment, canMaintainEquipment) ||
                other.canMaintainEquipment == canMaintainEquipment) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.contractNumber, contractNumber) ||
                other.contractNumber == contractNumber) &&
            (identical(other.contractExpiryDate, contractExpiryDate) ||
                other.contractExpiryDate == contractExpiryDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
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
    firstName,
    lastName,
    middleName,
    phone,
    email,
    employmentType,
    category,
    const DeepCollectionEquality().hash(_competencies),
    const DeepCollectionEquality().hash(_accessibleEquipmentTypes),
    canMaintainEquipment,
    schedule,
    companyName,
    contractNumber,
    contractExpiryDate,
    notes,
    createdAt,
    updatedAt,
    archivedAt,
    archivedBy,
    archivedReason,
  ]);

  /// Create a copy of SupportStaff
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportStaffImplCopyWith<_$SupportStaffImpl> get copyWith =>
      __$$SupportStaffImplCopyWithImpl<_$SupportStaffImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportStaffImplToJson(this);
  }
}

abstract class _SupportStaff implements SupportStaff {
  const factory _SupportStaff({
    required final String id,
    required final String firstName,
    required final String lastName,
    final String? middleName,
    final String? phone,
    final String? email,
    required final EmploymentType employmentType,
    required final StaffCategory category,
    final List<Competency>? competencies,
    final List<String>? accessibleEquipmentTypes,
    required final bool canMaintainEquipment,
    final WorkSchedule? schedule,
    final String? companyName,
    final String? contractNumber,
    final DateTime? contractExpiryDate,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? archivedAt,
    final String? archivedBy,
    final String? archivedReason,
  }) = _$SupportStaffImpl;

  factory _SupportStaff.fromJson(Map<String, dynamic> json) =
      _$SupportStaffImpl.fromJson;

  @override
  String get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String? get middleName;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  EmploymentType get employmentType;
  @override
  StaffCategory get category;
  @override
  List<Competency>? get competencies;
  @override
  List<String>? get accessibleEquipmentTypes;
  @override
  bool get canMaintainEquipment;
  @override
  WorkSchedule? get schedule;
  @override
  String? get companyName;
  @override
  String? get contractNumber;
  @override
  DateTime? get contractExpiryDate;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get archivedAt;
  @override
  String? get archivedBy;
  @override
  String? get archivedReason;

  /// Create a copy of SupportStaff
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportStaffImplCopyWith<_$SupportStaffImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
