import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/modules/rooms/room.model.dart';
import 'package:postgres/postgres.dart';
import 'room_schedule_repository.dart';

abstract class RoomRepository {
  Future<Room?> getById(String id);
  Future<List<Room>> getAll({bool? isArchived, bool? isActive});
  Future<Room> create(Room room, {String? createdBy});
  Future<Room> update(String id, Room room);
  Future<void> archive(String id, String userId);
}

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._db, this._scheduleRepository);

  final Database _db;
  final RoomScheduleRepository _scheduleRepository;

  Room _roomFromRow(Map<String, dynamic> row) {
    final sanitizedRow = Map<String, dynamic>.from(row);

    // Convert DateTime objects to ISO 8601 strings
    const dateFields = [
      'deactivate_at',
      'archived_at',
      'updated_at',
      'created_at'
    ];
    for (final field in dateFields) {
      if (sanitizedRow[field] is DateTime) {
        sanitizedRow[field] = (sanitizedRow[field] as DateTime).toIso8601String();
      }
    }

    // Convert numeric fields that might be returned as strings from the DB
    const numericFields = ['area', 'max_capacity', 'floor'];
    for (final field in numericFields) {
      if (sanitizedRow[field] is String) {
        if (field == 'area') {
          sanitizedRow[field] = double.tryParse(sanitizedRow[field] as String);
        } else {
          sanitizedRow[field] = int.tryParse(sanitizedRow[field] as String);
        }
      }
    }

    return Room.fromMap(sanitizedRow);
  }

  @override
  Future<Room> create(Room room, {String? createdBy}) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        WITH new_row AS (
          INSERT INTO rooms (name, description, room_number, type, floor, building_id, max_capacity, area, is_active, deactivate_reason, deactivate_at, deactivate_by, archived_at, archived_by, archived_reason, created_by, updated_by) 
          VALUES (@name, @description, @room_number, @type, @floor, @building_id, @max_capacity, @area, @is_active, @deactivate_reason, @deactivate_at, @deactivate_by, @archived_at, @archived_by, @archived_reason, @user, @user) 
          RETURNING *
        )
        SELECT nr.id, nr.name, nr.description, nr.room_number, nr.type, nr.floor, nr.building_id, b.name as building_name, nr.max_capacity, nr.area, nr.is_active, nr.deactivate_reason, nr.deactivate_at, nr.deactivate_by, nr.photo_urls, nr.floor_plan_url, nr.note, nr.created_at, nr.updated_at, nr.created_by, nr.updated_by, nr.archived_at, nr.archived_by, nr.archived_reason
        FROM new_row nr
        LEFT JOIN buildings b ON nr.building_id = b.id
      '''),
      parameters: {
        'name': room.name,
        'description': room.description,
        'room_number': room.roomNumber,
        'type': room.type.value,
        'floor': room.floor,
        'building_id': room.buildingId,
        'max_capacity': room.maxCapacity,
        'area': room.area,
        'is_active': room.isActive,
        'deactivate_reason': room.deactivateReason,
        'deactivate_at': room.deactivateAt,
        'deactivate_by': room.deactivateBy,
        'archived_at': room.archivedAt,
        'archived_by': room.archivedBy,
        'archived_reason': room.archivedReason,
        'user': createdBy,
      },
    );

    final newRoom = _roomFromRow(result.first.toColumnMap());

    await _scheduleRepository.createDefaultSchedules(newRoom.id, createdBy: createdBy);

    return newRoom;
  }

  @override
  Future<void> archive(String id, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE rooms SET archived_at = NOW(), archived_by = @userId, is_active = FALSE WHERE id = @id'),
      parameters: {'id': id, 'userId': userId},
    );
  }

  @override
  Future<List<Room>> getAll({bool? isArchived, bool? isActive}) async {
    try {
      final conn = await _db.connection;
      var query = '''
          SELECT 
                          r.id, r.name, r.description, r.room_number, r.type, r.floor, r.building_id, b.name as building_name, 
                          r.max_capacity, r.area, r.is_active, r.deactivate_reason, 
                          r.deactivate_at, r.deactivate_by, r.photo_urls, r.floor_plan_url, r.note, r.created_at, r.updated_at, 
                          r.created_by, r.updated_by, r.archived_at, r.archived_by, r.archived_reason,
                          (archiver.last_name || ' ' || archiver.first_name) AS archived_by_name
                        FROM rooms r
          LEFT JOIN buildings b ON r.building_id = b.id
          LEFT JOIN users archiver ON r.archived_by = archiver.id
      ''';
      final conditions = <String>[];
      final parameters = <String, dynamic>{};

      if (isArchived != null) {
        conditions.add(isArchived
            ? 'r.archived_at IS NOT NULL'
            : 'r.archived_at IS NULL');
      }
      if (isActive != null) {
        conditions.add('r.is_active = @isActive');
        parameters['isActive'] = isActive;
      }

      if (conditions.isNotEmpty) {
        query += ' WHERE ${conditions.join(' AND ')}';
      }

      final result = await conn.execute(
        Sql.named(query),
        parameters: parameters,
      );

      return result
          .map(
            (row) => _roomFromRow(row.toColumnMap()),
          )
          .toList();
    } catch (e) {
      print('Error fetching all rooms: $e');
      rethrow;
    }
  }

  @override
  Future<Room?> getById(String id) async {
    try {
      final conn = await _db.connection;
      final result = await conn.execute(
        Sql.named(
            '''
              SELECT 
                r.id, r.name, r.description, r.room_number, r.type, r.floor, r.building_id, b.name as building_name, 
                r.max_capacity, r.area, r.is_active, r.deactivate_reason, 
                r.deactivate_at, r.deactivate_by, r.photo_urls, r.floor_plan_url, r.note, r.created_at, r.updated_at, 
                r.created_by, r.updated_by, r.archived_at, r.archived_by, r.archived_reason,
                (archiver.last_name || ' ' || archiver.first_name) AS archived_by_name
              FROM rooms r              LEFT JOIN buildings b ON r.building_id = b.id
              LEFT JOIN users archiver ON r.archived_by = archiver.id
              WHERE r.id = @id
            '''),
        parameters: {'id': id},
      );

      if (result.isEmpty) {
        return null;
      }

      return _roomFromRow(result.first.toColumnMap());
    } catch (e) {
      print('Error fetching room by ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<Room> update(String id, Room room) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE rooms 
        SET 
          name = @name, 
          description = @description, 
          room_number = @room_number, 
          type = @type, 
          floor = @floor, 
          building_id = @building_id, 
          max_capacity = @max_capacity, 
          area = @area, 
          photo_urls = @photo_urls, 
          floor_plan_url = @floor_plan_url,
          note = @note,
          is_active = @is_active, 
          deactivate_reason = @deactivate_reason, 
          deactivate_at = @deactivate_at, 
          deactivate_by = @deactivate_by, 
          archived_at = @archived_at, 
          archived_reason = @archived_reason,
          updated_at = NOW(),
          updated_by = @updated_by,
          archived_by = @archived_by
        WHERE id = @id 
      '''),
      parameters: {
        'id': id,
        'name': room.name,
        'description': room.description,
        'room_number': room.roomNumber,
        'type': room.type.value,
        'floor': room.floor,
        'building_id': room.buildingId,
        'max_capacity': room.maxCapacity,
        'area': room.area,
        'photo_urls': jsonEncode(room.photoUrls),
        'floor_plan_url': room.floorPlanUrl,
        'note': room.note,
        'is_active': room.isActive,
        'deactivate_reason': room.deactivateReason,
        'deactivate_at': room.deactivateAt,
        'deactivate_by': room.deactivateBy,
        'archived_at': room.archivedAt,
        'updated_by': room.updatedBy,
        'archived_by': room.archivedBy,
        'archived_reason': room.archivedReason,
      },
    );
    
    final updatedRoom = await getById(id);
    if (updatedRoom == null) {
      throw Exception('Room not found after update');
    }
    return updatedRoom;
  }
}
