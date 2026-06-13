import 'package:fitman_common/custom/custom_date_time_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'training_group.model.g.dart';

@JsonSerializable()
class TrainingGroup extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final String trainingGroupTypeId;

  // ПЕРСОНАЛ (обязательные для тренировочного процесса)
  final String? primaryTrainerId; // Основной тренер группы (обязательно)
  final String? primaryInstructorId; // Основной инструктор группы
  final String? responsibleManagerId; // Ответственный менеджер

  // СОСТАВ ГРУППЫ (фиксированный)
  final List<String> clientIds; // Фиксированный состав участников

  // РАСПИСАНИЕ ЗАНЯТИЙ - This will be fetched separately or populated by a service
  // List<GroupScheduleSlot> scheduleSlots;

  // ПАРАМЕТРЫ ТРЕНИРОВКИ
  final String? programId; // Ссылка на программу тренировок
  final String? goalId; // Цель тренировок (похудение, набор массы и т.д.)
  final String? levelId; // Уровень подготовки группы

  // ЛИМИТЫ И ОГРАНИЧЕНИЯ
  @CustomDateTimeConverter()
  final DateTime startDate; // Дата начала работы группы
  
  @NullableCustomDateTimeConverter()
  final DateTime? endDate; // Дата окончания (если предусмотрена)
  
  final int maxParticipants; // Максимальное количество участников
  final int? currentParticipants; // Текущее количество участников

  // СТАТУС И СВЯЗИ
  final bool? isActive; // Активна ли группа
  final String? chatId; // Ссылка на групповой чат (создается автоматически)
  final String? companyId;

  @NullableCustomDateTimeConverter()
  final DateTime? createdAt;
  
  @NullableCustomDateTimeConverter()
  final DateTime? updatedAt;
  
  final String? createdBy;
  final String? updatedBy;
  
  @NullableCustomDateTimeConverter()
  final DateTime? archivedAt;
  
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
