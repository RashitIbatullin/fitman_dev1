import 'package:fitman_backend/modules/equipment/models/equipment/equipment_category.enum.dart';

class EquipmentType {
  EquipmentType({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.weightRange,
    this.dimensions,

    this.isMobile = true,



    this.schematicIcon,

    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
  });

  final String id;
  final String name;
  final String? description;

  // Классификация
  final EquipmentCategory category;

  // Базовые характеристики
  final String? weightRange;
  final String? dimensions;

  final bool isMobile;

  // Связи


  // Медиа


  final String? schematicIcon;

  // Статус


  // Архивация
  final DateTime? archivedAt;
  final String? archivedBy;
  final String? archivedReason;

  factory EquipmentType.fromMap(Map<String, dynamic> map) {
    final category = EquipmentCategory.values[map['category'] as int];

    return EquipmentType(
      id: map['id'].toString(),
      name: map['name'] as String,
      description: map['description'] as String?,
      category: category,
      weightRange: map['weight_range'] as String?,
      dimensions: map['dimensions'] as String?,

      isMobile: map['is_mobile'] as bool,



      schematicIcon: map['schematic_icon'] as String?,

      archivedAt: map['archived_at'] as DateTime?,
      archivedBy: map['archived_by']?.toString(),
      archivedReason: map['archived_reason'] as String?,
    );
  }

  factory EquipmentType.fromJson(Map<String, dynamic> json) =>
      EquipmentType.fromMap(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index,
      'weight_range': weightRange,
      'dimensions': dimensions,

      'is_mobile': isMobile,



      'schematic_icon': schematicIcon,

      'archived_at': archivedAt?.toIso8601String(),
      'archived_by': archivedBy,
      'archived_reason': archivedReason,
    };
  }
}
