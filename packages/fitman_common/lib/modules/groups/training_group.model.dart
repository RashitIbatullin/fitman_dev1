import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'training_group.model.g.dart';

@JsonSerializable()
class TrainingGroup extends Equatable {
  final String? id;
  final String name;
  final String? description;
  @JsonKey(name: 'training_group_type_id')
  final String trainingGroupTypeId;

  // ПЕРСОНАЛ (обязательные для тренировочного процесса)
  @JsonKey(name: 'primary_trainer_id')
  final String? primaryTrainerId; // Основной тренер группы (обязательно)
  @JsonKey(name: 'primary_instructor_id')
  final String? primaryInstructorId; // Основной инструктор группы
  @JsonKey(name: 'responsible_manager_id')
  final String? responsibleManagerId; // Ответственный менеджер

  // СОСТАВ ГРУППЫ (фиксированный)
  @JsonKey(name: 'client_ids', defaultValue: [])
  final List<String> clientIds; // Фиксированный состав участников

  // РАСПИСАНИЕ ЗАНЯТИЙ - This will be fetched separately or populated by a service
  // List<GroupScheduleSlot> scheduleSlots;

  // ПАРАМЕТРЫ ТРЕНИРОВКИ
  @JsonKey(name: 'program_id')
  final String? programId; // Ссылка на программу тренировок
  @JsonKey(name: 'goal_id')
  final String? goalId; // Цель тренировок (похудение, набор массы и т.д.)
  @JsonKey(name: 'level_id')
  final String? levelId; // Уровень подготовки группы

  // ЛИМИТЫ И ОГРАНИЧЕНИЯ
  @JsonKey(name: 'start_date')
  final DateTime startDate; // Дата начала работы группы
  @JsonKey(name: 'end_date')
  final DateTime? endDate; // Дата окончания (если предусмотрена)
  @JsonKey(name: 'max_participants')
  final int maxParticipants; // Максимальное количество участников
  @JsonKey(name: 'current_participants')
  final int? currentParticipants; // Текущее количество участников

  // СТАТУС И СВЯЗИ
  @JsonKey(name: 'is_active')
  final bool? isActive; // Активна ли группа
  @JsonKey(name: 'chat_id')
  final String? chatId; // Ссылка на групповой чат (создается автоматически)
  @JsonKey(name: 'company_id')
  final String? companyId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'updated_by')
  final String? updatedBy;
  @JsonKey(name: 'archived_at')
  final DateTime? archivedAt;
  @JsonKey(name: 'archived_by')
  final String? archivedBy;

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
    this.companyId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.archivedAt,
    this.archivedBy,
  });

  factory TrainingGroup.fromJson(Map<String, dynamic> json) =>
      _$TrainingGroupFromJson(json);
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
        companyId,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        archivedAt,
        archivedBy,
      ];

  TrainingGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? trainingGroupTypeId,
    String? primaryTrainerId,
    String? primaryInstructorId,
    String? responsibleManagerId,
    List<String>? clientIds,
    String? programId,
    String? goalId,
    String? levelId,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    int? currentParticipants,
    bool? isActive,
    String? chatId,
    String? companyId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? archivedAt,
    String? archivedBy,
  }) {
    return TrainingGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      trainingGroupTypeId: trainingGroupTypeId ?? this.trainingGroupTypeId,
      primaryTrainerId: primaryTrainerId ?? this.primaryTrainerId,
      primaryInstructorId: primaryInstructorId ?? this.primaryInstructorId,
      responsibleManagerId: responsibleManagerId ?? this.responsibleManagerId,
      clientIds: clientIds ?? this.clientIds,
      programId: programId ?? this.programId,
      goalId: goalId ?? this.goalId,
      levelId: levelId ?? this.levelId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isActive: isActive ?? this.isActive,
      chatId: chatId ?? this.chatId,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedBy: archivedBy ?? this.archivedBy,
    );
  }
}