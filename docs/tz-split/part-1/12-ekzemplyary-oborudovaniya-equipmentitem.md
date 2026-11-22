# Функциональные требования / Модуль управления оборудованием / Экземпляры оборудования (EquipmentItem)

*Часть 1 | источник: Требования ТЗ фитнес-тренинг часть 1.docx | [индекс](../INDEX.md)*

Учёт конкретных физических единиц оборудования. Каждый экземпляр имеет инвентарный номер и отслеживается индивидуально.

##### Модель экземпляра оборудования (EquipmentItem)

```dart
class EquipmentItem {
  String id;
  String typeId;              // Ссылка на EquipmentType
  String inventoryNumber;     // Внутренний инвентарный номер "ГАН-001"
  String? serialNumber;       // Заводской серийный номер (опционально)
  String? model;              // Модель "Matrix T7xe"
  String? manufacturer;       // Производитель

  // Локация
  String? roomId;             // Где находится (ссылка на Room)
  String? placementNote;      // "У окна, рядом с колонной"

  // Состояние
  EquipmentStatus status;     // available, inUse, maintenance
  int conditionRating;        // 1-5 (5 = отличное)
  String? conditionNotes;     // "Поцарапана панель, работает нормально"

  // Техническое обслуживание (упрощённое)
  DateTime? lastMaintenanceDate;
  DateTime? nextMaintenanceDate;
  String? maintenanceNotes;   // "Заменили ремень"

  // Покупка/учёт
  DateTime? purchaseDate;
  double? purchasePrice;
  String? supplier;
  int? warrantyMonths;        // Гарантия в месяцах

  // Использование
  int usageHours;             // Накопленные часы использования
  DateTime? lastUsedDate;

  // Фотографии конкретного экземпляра
  List<String> photoUrls;
}
```

##### Статусы оборудования (EquipmentStatus)

```dart
enum EquipmentStatus {
  available,     // Доступно
  inUse,         // Используется (во время занятия)
  reserved,      // Забронировано
  maintenance,   // На обслуживании/ремонте
  outOfOrder,    // Неисправно
  storage,       // На складе
}
```
