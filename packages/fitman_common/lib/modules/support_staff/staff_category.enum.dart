
enum StaffCategory {
  technician,      // Техник/механик
  cleaner,         // Уборщик
  administrator,   // Администратор (вспомогательный)
  security,        // Охрана
  medical,         // Медицинский работник
  itService,       // Айтишник
  other            // Прочее
}

extension StaffCategoryExtension on StaffCategory {
  String get localizedName {
    switch (this) {
      case StaffCategory.technician:
        return 'Техник/Механик';
      case StaffCategory.cleaner:
        return 'Уборщик';
      case StaffCategory.administrator:
        return 'Администратор';
      case StaffCategory.security:
        return 'Охрана';
      case StaffCategory.medical:
        return 'Мед. работник';
      case StaffCategory.itService:
        return 'ИТ-Специалист';
      case StaffCategory.other:
        return 'Прочее';
    }
  }
}
