import 'package:flutter/material.dart'; // Moved to top

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

  IconData get iconData {
    switch (this) {
      case EmploymentType.fullTime:
        return Icons.schedule;
      case EmploymentType.partTime:
        return Icons.event_note;
      case EmploymentType.contractor:
        return Icons.handshake;
      case EmploymentType.freelance:
        return Icons.person_outline;
    }
  }
}
