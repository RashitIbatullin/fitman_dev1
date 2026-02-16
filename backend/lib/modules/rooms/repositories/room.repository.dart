import 'dart:convert';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/modules/rooms/models/room/room.model.dart';
import 'package:postgres/postgres.dart';

abstract class RoomRepository {
  Future<Room?> getById(String id);
  Future<List<Room>> getAll({bool? isArchived, bool? isActive});
  Future<Room> create(Room room);
  Future<Room> update(String id, Room room);
  Future<void> archive(String id, String userId);
}

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<Room> create(Room room) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        WITH new_row AS (
          INSERT INTO rooms (name, description, room_number, type, floor, building_id, max_capacity, area, open_time, close_time, working_days, is_active, deactivate_reason, deactivate_at, deactivate_by, archived_at, archived_by, archived_reason) 
          VALUES (@name, @description, @room_number, @type, @floor, @building_id, @max_capacity, @area, @open_time, @close_time, @working_days, @is_active, @deactivate_reason, @deactivate_at, @deactivate_by, @archived_at, @archived_by, @archived_reason) 
          RETURNING *
        )
        SELECT nr.id, nr.name, nr.description, nr.room_number, nr.type, nr.floor, nr.building_id, b.name as building_name, nr.max_capacity, nr.area, nr.open_time, nr.close_time, nr.working_days, nr.is_active, nr.deactivate_reason, nr.deactivate_at, nr.deactivate_by, nr.photo_urls, nr.floor_plan_url, nr.note, nr.created_at, nr.updated_at, nr.created_by, nr.updated_by, nr.archived_at, nr.archived_by, nr.archived_reason
        FROM new_row nr
        LEFT JOIN buildings b ON nr.building_id = b.id
      '''),
      parameters: {
        'name': room.name,
        'description': room.description,
        'room_number': room.roomNumber,
        'type': room.type.value,
        'floor': room.floor, // Now int?
        'building_id': room.buildingId != null ? int.parse(room.buildingId!) : null,
        'max_capacity': room.maxCapacity,
        'area': room.area,
        'open_time': room.openTime,
        'close_time': room.closeTime,
        'working_days': jsonEncode(room.workingDays),
        'is_active': room.isActive,
        'deactivate_reason': room.deactivateReason,
        'deactivate_at': room.deactivateAt,
        'deactivate_by': room.deactivateBy != null ? int.parse(room.deactivateBy!) : null,
        'archived_at': room.archivedAt,
        'archived_by': room.archivedBy != null ? int.parse(room.archivedBy!) : null,
        'archived_reason': room.archivedReason,
      },
    );
    return Room.fromMap(result.first.toColumnMap());
  }

  @override
  Future<void> archive(String id, String userId) async {
    final conn = await _db.connection;
    await conn.execute(
      Sql.named(
          'UPDATE rooms SET archived_at = NOW(), archived_by = @userId, is_active = FALSE WHERE id = @id'),
      parameters: {'id': int.parse(id), 'userId': int.parse(userId)},
    );
  }

  @override
  Future<List<Room>> getAll({bool? isArchived, bool? isActive}) async {
    try {
      final conn = await _db.connection;
      var query = '''
          SELECT 
            r.id, r.name, r.description, r.room_number, r.type, r.floor, r.building_id, b.name as building_name, 
            r.max_capacity, r.area, r.open_time, r.close_time, r.working_days, r.is_active, r.deactivate_reason, 
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
            (row) => Room.fromMap(row.toColumnMap()),
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
                r.max_capacity, r.area, r.open_time, r.close_time, r.working_days, r.is_active, r.deactivate_reason, 
                r.deactivate_at, r.deactivate_by, r.photo_urls, r.floor_plan_url, r.note, r.created_at, r.updated_at, 
                r.created_by, r.updated_by, r.archived_at, r.archived_by, r.archived_reason,
                (archiver.last_name || ' ' || archiver.first_name) AS archived_by_name
              FROM rooms r 
              LEFT JOIN buildings b ON r.building_id = b.id
              LEFT JOIN users archiver ON r.archived_by = archiver.id
              WHERE r.id = @id
            '''),
        parameters: {'id': int.parse(id)},
      );

      if (result.isEmpty) {
        return null;
      }

      return Room.fromMap(result.first.toColumnMap());
    } catch (e) {
      print('Error fetching room by ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<Room> update(String id, Room room) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        WITH updated AS (
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
            open_time = @open_time, 
            close_time = @close_time, 
            working_days = @working_days, 
            photo_urls = @photo_urls, 
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
          RETURNING *
        )
        SELECT u.id, u.name, u.description, u.room_number, u.type, u.floor, u.building_id, b.name as building_name, u.max_capacity, u.area, u.open_time, u.close_time, u.working_days, u.is_active, u.deactivate_reason, u.deactivate_at, u.deactivate_by, u.photo_urls, u.floor_plan_url, u.note, u.created_at, u.updated_at, u.created_by, u.updated_by, u.archived_at, u.archived_by, u.archived_reason 
        FROM updated u
        LEFT JOIN buildings b ON u.building_id = b.id
      '''),
      parameters: {
        'id': int.parse(id),
        'name': room.name,
        'description': room.description,
        'room_number': room.roomNumber,
        'type': room.type.value,
        'floor': room.floor, // Now int?
        'building_id': room.buildingId != null ? int.parse(room.buildingId!) : null,
        'max_capacity': room.maxCapacity,
        'area': room.area,
        'open_time': room.openTime,
        'close_time': room.closeTime,
        'working_days': jsonEncode(room.workingDays),
        'photo_urls': jsonEncode(room.photoUrls),
        'is_active': room.isActive,
        'deactivate_reason': room.deactivateReason,
        'deactivate_at': room.deactivateAt,
        'deactivate_by': room.deactivateBy != null ? int.parse(room.deactivateBy!) : null,
        'archived_at': room.archivedAt,
        'archived_by': room.archivedBy != null ? int.parse(room.archivedBy!) : null,
        'archived_reason': room.archivedReason,
        'updated_by': room.updatedBy != null ? int.parse(room.updatedBy!) : null,
      },
    );
    return Room.fromMap(result.first.toColumnMap());
  }


}