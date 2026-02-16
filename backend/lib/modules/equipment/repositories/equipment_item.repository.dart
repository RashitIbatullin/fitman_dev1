import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:postgres/postgres.dart';
import 'dart:convert';

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
          -1, NOW(), NOW(), @createdBy, @updatedBy
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
        'status': equipmentItem.status.index, // Enum to int
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
        'photoUrls': jsonEncode(equipmentItem.photoUrls), // List to JSON string
        'createdBy': userId,
        'updatedBy': userId,
      },
    );

    final newId = result.first.first as int;
    return await getById(newId.toString());
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<EquipmentItem>> getAll({bool includeArchived = false}) async {
    try {
      final conn = await _db.connection;
      final whereClause = includeArchived ? 'ei.archived_at IS NOT NULL' : 'ei.archived_at IS NULL';
      final result = await conn.execute(Sql.named('''
        SELECT ei.* FROM equipment_items ei
        JOIN equipment_types et ON ei.type_id = et.id
        WHERE $whereClause
        ORDER BY et.name ASC, ei.inventory_number ASC
      '''));

      return result
          .map(
            (row) => EquipmentItem.fromMap(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching all equipment items: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipmentItem>> getByRoomId(String roomId, {bool includeArchived = false}) async {
    try {
      final conn = await _db.connection;
      
      String whereClause;
      if (includeArchived) {
        whereClause = 'WHERE room_id = @roomId AND archived_at IS NOT NULL';
      } else {
        whereClause = 'WHERE room_id = @roomId AND archived_at IS NULL';
      }

      final result = await conn.execute(
        Sql.named('SELECT * FROM equipment_items $whereClause'),
        parameters: {
          'roomId': roomId,
        },
      );

      return result
          .map(
            (row) => EquipmentItem.fromMap(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching equipment items by room ID: $e');
      rethrow;
    }
  }

  @override
  Future<EquipmentItem> getById(String id) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM equipment_items WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw Exception('EquipmentItem with id $id not found');
    }

    return EquipmentItem.fromMap(result.first.toColumnMap());
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
        'status': equipmentItem.status.index, // Enum to int
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
        'photoUrls': jsonEncode(equipmentItem.photoUrls), // List to JSON string
        'updatedBy': userId,
        'archivedAt': equipmentItem.archivedAt,
        'archivedBy': equipmentItem.archivedBy,
        'archivedReason': equipmentItem.archivedReason,
      },
    );
    return await getById(id);
  }
}
