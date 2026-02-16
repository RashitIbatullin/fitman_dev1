import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'training_group.model.g.dart';

@JsonSerializable()
class TrainingGroup extends Equatable {
  final int? id;
  final String name;
  final String? description;
  @JsonKey(name: 'training_group_type_id')
  final int trainingGroupTypeId;
  
  // ПЕРСОНАЛ (обязательные для тренировочного процесса)
  @JsonKey(name: 'primary_trainer_id')
  final int? primaryTrainerId;     // Основной тренер группы (обязательно)
  @JsonKey(name: 'primary_instructor_id')
  final int? primaryInstructorId; // Основной инструктор группы
  @JsonKey(name: 'responsible_manager_id')
  final int? responsibleManagerId; // Ответственный менеджер
  
  // СОСТАВ ГРУППЫ (фиксированный)
  @JsonKey(name: 'client_ids', defaultValue: [])
  final List<int> clientIds;      // Фиксированный состав участников
  
  // РАСПИСАНИЕ ЗАНЯТИЙ - This will be fetched separately or populated by a service
  // List<GroupScheduleSlot> scheduleSlots; 
  
  // ПАРАМЕТРЫ ТРЕНИРОВКИ
  @JsonKey(name: 'program_id')
  final int? programId;           // Ссылка на программу тренировок
  @JsonKey(name: 'goal_id')
  final int? goalId;              // Цель тренировок (похудение, набор массы и т.д.)
  @JsonKey(name: 'level_id')
  final int? levelId;             // Уровень подготовки группы
  
  // ЛИМИТЫ И ОГРАНИЧЕНИЯ
  @JsonKey(name: 'start_date')
  final DateTime startDate;          // Дата начала работы группы
  @JsonKey(name: 'end_date')
  final DateTime? endDate;           // Дата окончания (если предусмотрена)
  @JsonKey(name: 'max_participants')
  final int maxParticipants;         // Максимальное количество участников
  @JsonKey(name: 'current_participants')
  final int? currentParticipants;     // Текущее количество участников
  
  // СТАТУС И СВЯЗИ
  @JsonKey(name: 'is_active')
  final bool? isActive;               // Активна ли группа
  @JsonKey(name: 'chat_id')
  final int? chatId;              // Ссылка на групповой чат (создается автоматически)
  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;
  @JsonKey(name: 'archived_by')
  final int? archivedBy;

  const TrainingGroup({
    this.id,
    required this.name,
    this.description,
    required this.trainingGroupTypeId,
    this.primaryTrainerId,
    this.primaryInstructorId,
    this.responsibleManagerId,
    this.clientIds = const [],
    this.programId,
    this.goalId,
    this.levelId,
    required this.startDate,
    this.endDate,
    required this.maxParticipants,
    this.currentParticipants,
    this.isActive,
    this.chatId,
    this.archivedAt,
    this.archivedBy,
  });

  factory TrainingGroup.fromJson(Map<String, dynamic> json) => _$TrainingGroupFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingGroupToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        trainingGroupTypeId,
        primaryTrainerId,
        primaryInstructorId,
        responsibleManagerId,
        clientIds,
        programId,
        goalId,
        levelId,
        startDate,
        endDate,
        maxParticipants,
        currentParticipants,
        isActive,
        chatId,
        archivedAt,
        archivedBy,
      ];
}