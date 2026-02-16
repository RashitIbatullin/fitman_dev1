// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_staff.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupportStaffImpl _$$SupportStaffImplFromJson(Map<String, dynamic> json) =>
    _$SupportStaffImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      employmentType: $enumDecode(
        _$EmploymentTypeEnumMap,
        json['employment_type'],
      ),
      category: $enumDecode(_$StaffCategoryEnumMap, json['category']),
      competencies: (json['competencies'] as List<dynamic>?)
          ?.map((e) => Competency.fromJson(e as Map<String, dynamic>))
          .toList(),
      accessibleEquipmentTypes:
          (json['accessible_equipment_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      canMaintainEquipment: json['can_maintain_equipment'] as bool,
      schedule: json['schedule'] == null
          ? null
          : WorkSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
      companyName: json['company_name'] as String?,
      contractNumber: json['contract_number'] as String?,
      contractExpiryDate: json['contract_expiry_date'] == null
          ? null
          : DateTime.parse(json['contract_expiry_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      archivedBy: json['archived_by'] as String?,
      archivedReason: json['archived_reason'] as String?,
    );

Map<String, dynamic> _$$SupportStaffImplToJson(_$SupportStaffImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'middle_name': instance.middleName,
      'phone': instance.phone,
      'email': instance.email,
      'employment_type': _$EmploymentTypeEnumMap[instance.employmentType]!,
      'category': _$StaffCategoryEnumMap[instance.category]!,
      'competencies': instance.competencies,
      'accessible_equipment_types': instance.accessibleEquipmentTypes,
      'can_maintain_equipment': instance.canMaintainEquipment,
      'schedule': instance.schedule,
      'company_name': instance.companyName,
      'contract_number': instance.contractNumber,
      'contract_expiry_date': instance.contractExpiryDate?.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_by': instance.archivedBy,
      'archived_reason': instance.archivedReason,
    };

const _$EmploymentTypeEnumMap = {
  EmploymentType.fullTime: 'fullTime',
  EmploymentType.partTime: 'partTime',
  EmploymentType.contractor: 'contractor',
  EmploymentType.freelance: 'freelance',
};

const _$StaffCategoryEnumMap = {
  StaffCategory.technician: 'technician',
  StaffCategory.cleaner: 'cleaner',
  StaffCategory.administrator: 'administrator',
  StaffCategory.security: 'security',
  StaffCategory.medical: 'medical',
  StaffCategory.itService: 'itService',
  StaffCategory.other: 'other',
};
