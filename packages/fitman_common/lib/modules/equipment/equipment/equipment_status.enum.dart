
enum EquipmentStatus {
  available, // Доступно
  inUse, // Используется (во время занятия)
  reserved, // Забронировано
  maintenance, // На обслуживании/ремонте
  outOfOrder, // Неисправно
  storage, // На складе
}

extension EquipmentStatusExtension on EquipmentStatus {
  String get displayName {
    switch (this) {
      case EquipmentStatus.available:
        return 'Доступно';
      case EquipmentStatus.inUse:
        return 'В использовании';
      case EquipmentStatus.reserved:
        return 'Забронировано';
      case EquipmentStatus.maintenance:
        return 'На ТО';
      case EquipmentStatus.outOfOrder:
        return 'Неисправно';
      case EquipmentStatus.storage:
        return 'На складе';
    }
  }
}
