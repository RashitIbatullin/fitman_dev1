// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_group.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingGroup _$TrainingGroupFromJson(Map<String, dynamic> json) =>
    TrainingGroup(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      trainingGroupTypeId: (json['training_group_type_id'] as num).toInt(),
      primaryTrainerId: (json['primary_trainer_id'] as num?)?.toInt(),
      primaryInstructorId: (json['primary_instructor_id'] as num?)?.toInt(),
      responsibleManagerId: (json['responsible_manager_id'] as num?)?.toInt(),
      clientIds:
          (json['client_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      programId: (json['program_id'] as num?)?.toInt(),
      goalId: (json['goal_id'] as num?)?.toInt(),
      levelId: (json['level_id'] as num?)?.toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      maxParticipants: (json['max_participants'] as num).toInt(),
      currentParticipants: (json['current_participants'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
      chatId: (json['chat_id'] as num?)?.toInt(),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
      archivedBy: (json['archived_by'] as num?)?.toInt(),
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
      'archived_at': instance.archivedAt?.toIso8601String(),
      'archived_by': instance.archivedBy,
    };
