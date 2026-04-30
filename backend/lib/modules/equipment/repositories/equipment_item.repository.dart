import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_item.model.dart';
import 'package:postgres/postgres.dart';

abstract class EquipmentItemRepository {
  Future<EquipmentItem> getById(String id);
  Future<List<EquipmentItem>> getAll({bool includeArchived = false});
  Future<List<EquipmentItem>> getByRoomId(String roomId, {bool includeArchived = false});
  Future<EquipmentItem> create(EquipmentItem equipmentItem, String userId);
  Future<EquipmentItem> update(String id, EquipmentItem equipmentItem, String userId);
  Future<void> delete(String id);
  Future<void> archive(String id, String reason, String userId);
  Future<void> unarchive(String id);
}

class EquipmentItemRepositoryImpl implements EquipmentItemRepository {
  EquipmentItemRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<void> archive(String id, String reason, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_items SET archived_at = NOW(), archived_by = @userId, archived_reason = @reason WHERE id = @id'),
      parameters: {
        'id': id,
        'reason': reason,
        'userId': userId,
      },
    );
  }

  @override
  Future<void> unarchive(String id) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE equipment_items SET archived_at = NULL, archived_by = NULL, archived_reason = NULL WHERE id = @id'),
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<EquipmentItem> create(EquipmentItem equipmentItem, String userId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO equipment_items (
          type_id, inventory_number, serial_number, model, manufacturer, room_id, placement_note,
          status, condition_rating, condition_notes, last_maintenance_date, next_maintenance_date,
          maintenance_notes, purchase_date, purchase_price, supplier, warranty_months, usage_hours,
          last_used_date, photo_urls,
          company_id, created_at, updated_at, created_by, updated_by
        ) VALUES (
          @typeId, @inventoryNumber, @serialNumber, @model, @manufacturer, @roomId, @placementNote,
          @status, @conditionRating, @conditionNotes, @lastMaintenanceDate, @nextMaintenanceDate,
          @maintenanceNotes, @purchaseDate, @purchasePrice, @supplier, @warrantyMonths, @usageHours,
          @lastUsedDate, @photoUrls,
          '00000000-0000-0000-0000-000000000000', NOW(), NOW(), @createdBy, @updatedBy
        ) RETURNING id;
      '''),
      parameters: {
        'typeId': equipmentItem.typeId,
        'inventoryNumber': equipmentItem.inventoryNumber,
        'serialNumber': equipmentItem.serialNumber,
        'model': equipmentItem.model,
        'manufacturer': equipmentItem.manufacturer,
        'roomId': equipmentItem.roomId,
        'placementNote': equipmentItem.placementNote,
        'status': equipmentItem.status.index,
        'conditionRating': equipmentItem.conditionRating,
        'conditionNotes': equipmentItem.conditionNotes,
        'lastMaintenanceDate': equipmentItem.lastMaintenanceDate,
        'nextMaintenanceDate': equipmentItem.nextMaintenanceDate,
        'maintenanceNotes': equipmentItem.maintenanceNotes,
        'purchaseDate': equipmentItem.purchaseDate,
        'purchasePrice': equipmentItem.purchasePrice,
        'supplier': equipmentItem.supplier,
        'warrantyMonths': equipmentItem.warrantyMonths,
        'usageHours': equipmentItem.usageHours,
        'lastUsedDate': equipmentItem.lastUsedDate,
        'photoUrls': jsonEncode(equipmentItem.photoUrls),
        'createdBy': userId,
        'updatedBy': userId,
      },
    );

    final newId = result.first.first as String;
    return await getById(newId);
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  // Helper method to safely parse photo_urls
  void _handlePhotoUrls(Map<String, dynamic> itemMap) {
    final photoUrlsData = itemMap['photo_urls'];
    if (photoUrlsData is String) {
      itemMap['photo_urls'] = jsonDecode(photoUrlsData);
    } else if (photoUrlsData is Map) {
      itemMap['photo_urls'] = []; // Treat empty JSON object as empty list
    }
    else if (photoUrlsData == null) {
      itemMap['photo_urls'] = [];
    }
    // If it's already a List, do nothing.
  }

  @override
  Future<List<EquipmentItem>> getAll({bool includeArchived = false}) async {
    final conn = await _db.connection;
    try {
      final whereClause =
          includeArchived ? 'ei.archived_at IS NOT NULL' : 'ei.archived_at IS NULL';
      final result = await conn.execute(Sql.named('''
        SELECT 
          ei.*,
          r.name as room_name,
          et.name as type_name
        FROM equipment_items ei
        LEFT JOIN equipment_types et ON ei.type_id = et.id
        LEFT JOIN rooms r ON ei.room_id = r.id
        WHERE $whereClause
        ORDER BY et.name ASC, ei.inventory_number ASC
      '''));

      final items = <EquipmentItem>[];
      for (final row in result) {
        final itemMap = row.toColumnMap();
        try {
          _handlePhotoUrls(itemMap);

          // Ensure status is int
          if (itemMap['status'] is num) {
            itemMap['status'] = (itemMap['status'] as num).toInt();
          }

          items.add(EquipmentItem.fromJson(itemMap));
        } catch (e, s) {
          print('====== FAILED TO PARSE EQUIPMENT ITEM ======');
          print('ERROR: $e');
          print('STACK TRACE: $s');
          print('RAW DATA: $itemMap');
          print('============================================');
          rethrow;
        }
      }
      return items;
    } catch (e) {
      print('Error fetching all equipment items: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipmentItem>> getByRoomId(String roomId,
      {bool includeArchived = false}) async {
    final conn = await _db.connection;
    try {
      String whereClause;
      if (includeArchived) {
        whereClause = 'WHERE ei.room_id = @roomId AND ei.archived_at IS NOT NULL';
      } else {
        whereClause = 'WHERE ei.room_id = @roomId AND ei.archived_at IS NULL';
      }

      final result = await conn.execute(
        Sql.named('''
          SELECT 
            ei.*,
            r.name as room_name,
            et.name as type_name
          FROM equipment_items ei
          LEFT JOIN equipment_types et ON ei.type_id = et.id
          LEFT JOIN rooms r ON ei.room_id = r.id
          $whereClause
        '''),
        parameters: {
          'roomId': roomId,
        },
      );

      final items = <EquipmentItem>[];
      for (final row in result) {
        final itemMap = row.toColumnMap();
        try {
          _handlePhotoUrls(itemMap);

          // Ensure status is int
          if (itemMap['status'] is num) {
            itemMap['status'] = (itemMap['status'] as num).toInt();
          }

          items.add(EquipmentItem.fromJson(itemMap));
        } catch (e, s) {
          print('====== FAILED TO PARSE EQUIPMENT ITEM (by Room ID) ======');
          print('ERROR: $e');
          print('STACK TRACE: $s');
          print('RAW DATA: $itemMap');
          print('======================================================');
          rethrow;
        }
      }
      return items;
    } catch (e) {
      print('Error fetching equipment items by room ID: $e');
      rethrow;
    }
  }

  @override
  Future<EquipmentItem> getById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT 
          ei.*,
          r.name as room_name,
          et.name as type_name
        FROM equipment_items ei
        LEFT JOIN equipment_types et ON ei.type_id = et.id
        LEFT JOIN rooms r ON ei.room_id = r.id
        WHERE ei.id = @id
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('EquipmentItem with id $id not found');
    }

    final itemMap = result.first.toColumnMap();
    try {
      _handlePhotoUrls(itemMap);

      // Ensure status is int
      if (itemMap['status'] is num) {
        itemMap['status'] = (itemMap['status'] as num).toInt();
      }

      return EquipmentItem.fromJson(itemMap);
    } catch (e, s) {
      print('====== FAILED TO PARSE EQUIPMENT ITEM (by ID) ======');
      print('ERROR: $e');
      print('STACK TRACE: $s');
      print('RAW DATA: $itemMap');
      print('==================================================');
      rethrow;
    }
  }

  @override
  Future<EquipmentItem> update(String id, EquipmentItem equipmentItem, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE equipment_items SET
          type_id = @typeId,
          inventory_number = @inventoryNumber,
          serial_number = @serialNumber,
          model = @model,
          manufacturer = @manufacturer,
          room_id = @roomId,
          placement_note = @placementNote,
          status = @status,
          condition_rating = @conditionRating,
          condition_notes = @conditionNotes,
          last_maintenance_date = @lastMaintenanceDate,
          next_maintenance_date = @nextMaintenanceDate,
          maintenance_notes = @maintenanceNotes,
          purchase_date = @purchaseDate,
          purchase_price = @purchasePrice,
          supplier = @supplier,
          warranty_months = @warrantyMonths,
          usage_hours = @usageHours,
          last_used_date = @lastUsedDate,
          photo_urls = @photoUrls,
          updated_at = NOW(),
          updated_by = @updatedBy,
          archived_at = @archivedAt,
          archived_by = @archivedBy,
          archived_reason = @archivedReason
        WHERE id = @id;
      '''),
      parameters: {
        'id': id,
        'typeId': equipmentItem.typeId,
        'inventoryNumber': equipmentItem.inventoryNumber,
        'serialNumber': equipmentItem.serialNumber,
        'model': equipmentItem.model,
        'manufacturer': equipmentItem.manufacturer,
        'roomId': equipmentItem.roomId,
        'placementNote': equipmentItem.placementNote,
        'status': equipmentItem.status.index,
        'conditionRating': equipmentItem.conditionRating,
        'conditionNotes': equipmentItem.conditionNotes,
        'lastMaintenanceDate': equipmentItem.lastMaintenanceDate,
        'nextMaintenanceDate': equipmentItem.nextMaintenanceDate,
        'maintenance_notes': equipmentItem.maintenanceNotes,
        'purchaseDate': equipmentItem.purchaseDate,
        'purchasePrice': equipmentItem.purchasePrice,
        'supplier': equipmentItem.supplier,
        'warrantyMonths': equipmentItem.warrantyMonths,
        'usageHours': equipmentItem.usageHours,
        'lastUsedDate': equipmentItem.lastUsedDate,
        'photoUrls': jsonEncode(equipmentItem.photoUrls),
        'updatedBy': userId,
        'archivedAt': equipmentItem.archivedAt,
        'archivedBy': equipmentItem.archivedBy,
        'archivedReason': equipmentItem.archivedReason,
      },
    );
    return await getById(id);
  }
}
