import 'package:flutter/material.dart';

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

  IconData get iconData { // Changed from iconName to iconData, and return type
    switch (this) {
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
}
