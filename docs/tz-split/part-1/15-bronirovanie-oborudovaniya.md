# Функциональные требования / Модуль управления оборудованием / Бронирование оборудования

*Часть 1 | источник: Требования ТЗ фитнес-тренинг часть 1.docx | [индекс](../INDEX.md)*

##### Модель бронирования (EquipmentBooking)

```dart
class EquipmentBooking {
  String id;
  String equipmentItemId;     // Конкретный экземпляр
  String bookedById;          // Кто забронировал (тренер/менеджер)

  // Время бронирования
  DateTime startTime;
  DateTime endTime;

  // Контекст
  String? lessonId;           // Для какого занятия
  String? trainingGroupId;    // Для какой группы
  String purpose;             // "Групповое занятие", "Индивидуальная тренировка"

  // Статус
  BookingStatus status;       // confirmed, active, completed, cancelled

  // Дополнительно
  String? notes;              // Особые пожелания
}
```
