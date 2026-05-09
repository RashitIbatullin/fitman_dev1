// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_group.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingGroup _$TrainingGroupFromJson(Map<String, dynamic> json) =>
    TrainingGroup(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      trainingGroupTypeId: json['training_group_type_id'] as String,
      primaryTrainerId: json['primary_trainer_id'] as String?,
      primaryInstructorId: json['primary_instructor_id'] as String?,
      responsibleManagerId: json['responsible_manager_id'] as String?,
      clientIds: (json['client_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      programId: json['program_id'] as String?,
      goalId: json['goal_id'] as String?,
      levelId: json['level_id'] as String?,
      startDate:
          const CustomDateTimeConverter().fromJson(json['start_date'] as Object),
      endDate: const NullableCustomDateTimeConverter()
          .fromJson(json['end_date'] as Object?),
      maxParticipants: (json['max_participants'] as num).toInt(),
      currentParticipants: (json['current_participants'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
      chatId: json['chat_id'] as String?,
      companyId: json['company_id'] as String?,
      createdAt: const NullableCustomDateTimeConverter()
          .fromJson(json['created_at'] as Object?),
      updatedAt: const NullableCustomDateTimeConverter()
          .fromJson(json['updated_at'] as Object?),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      archivedAt: const NullableCustomDateTimeConverter()
          .fromJson(json['archived_at'] as Object?),
      archivedBy: json['archived_by'] as String?,
    );

Map<String, dynamic> _$TrainingGroupToJson(TrainingGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'training_group_type_id': instance.trainingGroupTypeId,
      'primary_trainer_id': instance.primaryTrainerId,
      'primary_instructor_id': instance.primaryInstructorId,
      'responsible_manager_id': instance.responsibleManagerId,
      'client_ids': instance.clientIds,
      'program_id': instance.programId,
      'goal_id': instance.goalId,
      'level_id': instance.levelId,
      'start_date':
          const CustomDateTimeConverter().toJson(instance.startDate),
      'end_date':
          const NullableCustomDateTimeConverter().toJson(instance.endDate),
      'max_participants': instance.maxParticipants,
      'current_participants': instance.currentParticipants,
      'is_active': instance.isActive,
      'chat_id': instance.chatId,
      'company_id': instance.companyId,
      'created_at':
          const NullableCustomDateTimeConverter().toJson(instance.createdAt),
      'updated_at':
          const NullableCustomDateTimeConverter().toJson(instance.updatedAt),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'archived_at':
          const NullableCustomDateTimeConverter().toJson(instance.archivedAt),
      'archived_by': instance.archivedBy,
    };
