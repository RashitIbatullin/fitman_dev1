import 'package:flutter/material.dart';
import 'package:fitman_common/modules/support_staff/employment_type.enum.dart';
import 'package:fitman_common/modules/support_staff/staff_category.enum.dart';

IconData getEmploymentTypeIcon(EmploymentType type) {
  switch (type) {
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

IconData getStaffCategoryIcon(StaffCategory category) {
  switch (category) {
    case StaffCategory.technician:
      return Icons.handyman;
    case StaffCategory.cleaner:
      return Icons.cleaning_services;
    case StaffCategory.administrator:
      return Icons.admin_panel_settings;
    case StaffCategory.security:
      return Icons.security;
    case StaffCategory.medical:
      return Icons.local_hospital;
    case StaffCategory.itService:
      return Icons.computer;
    case StaffCategory.other:
      return Icons.category;
  }
}