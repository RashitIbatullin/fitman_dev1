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
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      maxParticipants: (json['max_participants'] as num).toInt(),
      currentParticipants: (json['current_participants'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
      chatId: json['chat_id'] as String?,
      companyId: json['company_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
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
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'max_participants': instance.maxParticipants,
      'current_participants': instance.currentParticipants,
      'is_active': instance.isActive,
      'chat_id': instance.chatId,
      'company_id': instance.companyId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_by': instance.archivedBy,
    };
