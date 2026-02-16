import 'dart:convert';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_status.enum.dart';

class EquipmentItem {
  EquipmentItem({
    required this.id,
    required this.typeId,
    required this.inventoryNumber,
    this.serialNumber,
    this.model,
    this.manufacturer,
    this.roomId,
    this.placementNote,
    required this.status,
    required this.conditionRating,
    this.conditionNotes,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintenanceNotes,
    this.purchaseDate,
    this.purchasePrice,
    this.supplier,
    this.warrantyMonths,
    this.usageHours = 0,
    this.lastUsedDate,
    this.photoUrls = const [],
    this.archivedAt,
    this.archivedBy,
    this.archivedReason,
  });

  final String id;
  final String typeId;
  final String inventoryNumber;
  final String? serialNumber;
  final String? model;
  final String? manufacturer;

  // Локация
  final String? roomId;
  final String? placementNote;

  // Состояние
  final EquipmentStatus status;
  final int conditionRating;
  final String? conditionNotes;

  // Техническое обслуживание
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String? maintenanceNotes;

  // Покупка/учёт
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? supplier;
  final int? warrantyMonths;

  // Использование
  final int usageHours;
  final DateTime? lastUsedDate;

  // Фотографии
  final List<String> photoUrls;

  // Архивация
  final DateTime? archivedAt;
  final String? archivedBy;
  final String? archivedReason;

  factory EquipmentItem.fromMap(Map<String, dynamic> map) {
    final purchasePriceValue = map['purchase_price'];
    return EquipmentItem(
      id: map['id'].toString(),
      typeId: map['type_id'].toString(),
      inventoryNumber: map['inventory_number'] as String,
      serialNumber: map['serial_number'] as String?,
      model: map['model'] as String?,
      manufacturer: map['manufacturer'] as String?,
      roomId: map['room_id']?.toString(), // room_id can be null
      placementNote: map['placement_note'] as String?,
      status: EquipmentStatus.values[map['status'] as int],
      conditionRating: map['condition_rating'] as int,
      conditionNotes: map['condition_notes'] as String?,
      lastMaintenanceDate: _parseDateTime(map['last_maintenance_date']),
      nextMaintenanceDate: _parseDateTime(map['next_maintenance_date']),
      maintenanceNotes: map['maintenance_notes'] as String?,
      purchaseDate: _parseDateTime(map['purchase_date']),
      purchasePrice: purchasePriceValue is String
          ? double.tryParse(purchasePriceValue)
          : (purchasePriceValue as num?)?.toDouble(),
      supplier: map['supplier'] as String?,
      warrantyMonths: map['warranty_months'] as int?,
      usageHours: map['usage_hours'] as int,
      lastUsedDate: _parseDateTime(map['last_used_date']),
      photoUrls: (map['photo_urls'] is String
              ? (jsonDecode(map['photo_urls']) as List<dynamic>)
              : (map['photo_urls'] as List<dynamic>?))
          ?.map((e) => e.toString())
          .toList() ??
          const [],
      archivedAt: _parseDateTime(map['archived_at']),
      archivedBy: map['archived_by']?.toString(),
      archivedReason: map['archived_reason'] as String?,
    );
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) =>
      EquipmentItem.fromMap(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_id': typeId,
      'inventory_number': inventoryNumber,
      'serial_number': serialNumber,
      'model': model,
      'manufacturer': manufacturer,
      'room_id': roomId,
      'placement_note': placementNote,
      'status': status.index,
      'condition_rating': conditionRating,
      'condition_notes': conditionNotes,
      'last_maintenance_date': lastMaintenanceDate?.toIso8601String(),
      'next_maintenance_date': nextMaintenanceDate?.toIso8601String(),
      'maintenance_notes': maintenanceNotes,
      'purchase_date': purchaseDate?.toIso8601String(),
      'purchase_price': purchasePrice,
      'supplier': supplier,
      'warranty_months': warrantyMonths,
      'usage_hours': usageHours,
      'last_used_date': lastUsedDate?.toIso8601String(),
      'photo_urls': photoUrls,
      'archived_at': archivedAt?.toIso8601String(),
      'archived_by': archivedBy,
      'archived_reason': archivedReason,
    };
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  return null; // Or throw an error for unexpected types
}

