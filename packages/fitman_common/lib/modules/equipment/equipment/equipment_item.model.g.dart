// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_item.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquipmentItemImpl _$$EquipmentItemImplFromJson(Map<String, dynamic> json) =>
    _$EquipmentItemImpl(
      id: json['id'] as String,
      typeId: json['type_id'] as String,
      inventoryNumber: json['inventory_number'] as String,
      serialNumber: json['serial_number'] as String?,
      model: json['model'] as String?,
      manufacturer: json['manufacturer'] as String?,
      roomId: json['room_id'] as String?,
      placementNote: json['placement_note'] as String?,
      status: const EquipmentStatusConverter()
          .fromJson((json['status'] as num).toInt()),
      conditionRating: (json['condition_rating'] as num?)?.toInt() ?? 3,
      conditionNotes: json['condition_notes'] as String?,
      lastMaintenanceDate: const NullableDateTimeConverter()
          .fromJson(json['last_maintenance_date']),
      nextMaintenanceDate: const NullableDateTimeConverter()
          .fromJson(json['next_maintenance_date']),
      maintenanceNotes: json['maintenance_notes'] as String?,
      purchaseDate:
          const NullableDateTimeConverter().fromJson(json['purchase_date']),
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      supplier: json['supplier'] as String?,
      warrantyMonths: (json['warranty_months'] as num?)?.toInt(),
      usageHours: (json['usage_hours'] as num?)?.toInt() ?? 0,
      lastUsedDate:
          const NullableDateTimeConverter().fromJson(json['last_used_date']),
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      archivedAt:
          const NullableDateTimeConverter().fromJson(json['archived_at']),
      archivedBy: json['archived_by'] as String?,
      archivedReason: json['archived_reason'] as String?,
    );

Map<String, dynamic> _$$EquipmentItemImplToJson(_$EquipmentItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type_id': instance.typeId,
      'inventory_number': instance.inventoryNumber,
      'serial_number': instance.serialNumber,
      'model': instance.model,
      'manufacturer': instance.manufacturer,
      'room_id': instance.roomId,
      'placement_note': instance.placementNote,
      'status': const EquipmentStatusConverter().toJson(instance.status),
      'condition_rating': instance.conditionRating,
      'condition_notes': instance.conditionNotes,
      'last_maintenance_date': const NullableDateTimeConverter()
          .toJson(instance.lastMaintenanceDate),
      'next_maintenance_date': const NullableDateTimeConverter()
          .toJson(instance.nextMaintenanceDate),
      'maintenance_notes': instance.maintenanceNotes,
      'purchase_date':
          const NullableDateTimeConverter().toJson(instance.purchaseDate),
      'purchase_price': instance.purchasePrice,
      'supplier': instance.supplier,
      'warranty_months': instance.warrantyMonths,
      'usage_hours': instance.usageHours,
      'last_used_date':
          const NullableDateTimeConverter().toJson(instance.lastUsedDate),
      'photo_urls': instance.photoUrls,
      'archived_at':
          const NullableDateTimeConverter().toJson(instance.archivedAt),
      'archived_by': instance.archivedBy,
      'archived_reason': instance.archivedReason,
    };
