import 'package:fitman_common/modules/support_staff/employment_type.enum.dart';
import 'package:fitman_common/modules/support_staff/staff_category.enum.dart';
import 'package:flutter/material.dart';

extension EmploymentTypeUI on EmploymentType {
  IconData get iconData {
    switch (this) {
      case EmploymentType.fullTime:
        return Icons.work;
      case EmploymentType.partTime:
        return Icons.hourglass_bottom;
      case EmploymentType.contractor:
        return Icons.handshake;
      case EmploymentType.freelance:
        return Icons.person_add;
    }
  }
}

extension StaffCategoryUI on StaffCategory {
  IconData get iconData {
    switch (this) {
      case StaffCategory.technician:
        return Icons.build;
      case StaffCategory.cleaner:
        return Icons.cleaning_services;
      case StaffCategory.administrator:
        return Icons.admin_panel_settings;
      case StaffCategory.security:
        return Icons.security;
      case StaffCategory.medical:
        return Icons.medical_services;
      case StaffCategory.itService:
        return Icons.computer;
      case StaffCategory.other:
        return Icons.more_horiz;
    }
  }
}
