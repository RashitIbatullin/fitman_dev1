
enum EmploymentType {
  fullTime,    // Штатный сотрудник
  partTime,    // Частичная занятость
  contractor,  // Внешний подрядчик
  freelance    // Разовые работы
}

extension EmploymentTypeExtension on EmploymentType {
  String get localizedName {
    switch (this) {
      case EmploymentType.fullTime:
        return 'Штатный сотрудник';
      case EmploymentType.partTime:
        return 'Частичная занятость';
      case EmploymentType.contractor:
        return 'Внешний подрядчик';
      case EmploymentType.freelance:
        return 'Разовые работы';
    }
  }
}
