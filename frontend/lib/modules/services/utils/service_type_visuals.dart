import 'package:flutter/material.dart';

import 'service_category.dart';

/// Иконка конкретного типа услуги.
IconData serviceTypeIcon(String? typeCode, ServiceCategory category) {  switch (typeCode) {
    case 'club_membership':
      return Icons.card_membership;
    case 'zone_membership':
      return Icons.pool;
    case 'limited_membership':
      return Icons.confirmation_number_outlined;
    case 'group_membership':
      return Icons.groups;
    case 'day_membership':
      return Icons.wb_sunny_outlined;
    case 'single_visit':
      return Icons.login;
    case 'guest_pass':
      return Icons.person_add_alt_1;
    case 'trial':
      return Icons.emoji_people;
    case 'single_training':
      return Icons.fitness_center;
    case 'training_package':
      return Icons.inventory_2_outlined;
    case 'group_course':
      return Icons.school_outlined;
    case 'studio_service':
      return Icons.spa_outlined;
    case 'studio_package':
      return Icons.spa;
    case 'program_design':
      return Icons.assignment_outlined;
    case 'freeze_package':
      return Icons.ac_unit;
    case 'service_fee':
      return Icons.receipt_long;
    case 'gift_certificate':
      return Icons.card_giftcard;
    case 'gift_card':
      return Icons.credit_card;
    case 'medical_test':
      return Icons.medical_services_outlined;
    default:
      return _categoryIcon(category);
  }
}

/// Иконка типа услуги по коду — для справочников и фильтров.
IconData serviceTypeIconByCode(String? typeCode) {
  return serviceTypeIcon(
    typeCode,
    classifyServiceTypeCode(typeCode),
  );
}

/// Цвет иконки типа услуги по коду.
Color serviceTypeColorByCode(String? typeCode) {
  return serviceCategoryColor(classifyServiceTypeCode(typeCode));
}

/// Цвет фона цветной плашки типа услуги.
Color serviceCategoryColor(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.training:
      return const Color(0xFF2E7D32); // зелёный
    case ServiceCategory.medical:
      return const Color(0xFFC62828); // красный
    case ServiceCategory.cosmetology:
      return const Color(0xFFAD1457); // розово-малиновый
    case ServiceCategory.other:
      return const Color(0xFF455A64); // сине-серый
  }
}

IconData _categoryIcon(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.training:
      return Icons.fitness_center;
    case ServiceCategory.medical:
      return Icons.medical_services_outlined;
    case ServiceCategory.cosmetology:
      return Icons.spa_outlined;
    case ServiceCategory.other:
      return Icons.miscellaneous_services_outlined;
  }
}
