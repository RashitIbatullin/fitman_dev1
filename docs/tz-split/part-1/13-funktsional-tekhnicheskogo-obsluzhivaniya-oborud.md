# Функциональные требования / Модуль управления оборудованием / Функционал технического обслуживания оборудования

*Часть 1 | источник: Требования ТЗ фитнес-тренинг часть 1.docx | [индекс](../INDEX.md)*

##### Модель истории ТО

class EquipmentMaintenanceHistory {

String id;

String? number; // Уникальный номер заявки, генерируемый системой (например, "2024-001")

String equipmentItemId;

MaintenanceType type; // Профилактическое/Ремонт

MaintenanceStatus status;

DateTime createdAt; // Дата создания заявки

DateTime? startedAt; // Начало работ

DateTime? completedAt; // Завершение работ

DateTime? cancelledAt; // Дата отмены

String reportedProblem; // Описание проблемы

String? workDescription; // Описание выполненных работ

String reportedBy; // Кто сообщил (FK к users)

String? executorId;       // FK к users или support_staff.

ExecutorType? executorType; // Тип исполнителя

List<MaintenancePhoto> photos; // Фото до/после

String? cancellationReason; // Причина отмены

}

##### Вспомогательные модели

- Тип исполнителя ТО
enum ExecutorType {

user,         // Внутренний сотрудник (из таблицы users)

supportStaff  // Внешний персонал (из таблицы support_staff)

}

- Тип ТО
enum MaintenanceType {

preventive,  // Плановое профилактическое

corrective   // Ремонт по факту неисправности

}

- Статус ТО
enum MaintenanceStatus {

reported,    // Проблема зафиксирована

inProgress,  // В работе

completed,   // Завершено

cancelled    // Отменено

}

- Фотография ТО
class MaintenancePhoto {

String id;

String url;

String comment; // Комментарий к фото

PhotoTiming timing; // before/after

DateTime takenAt;

String takenByUserId;

}

enum PhotoTiming { before, after }
