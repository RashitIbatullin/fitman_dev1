import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/modules/rooms/room_schedule.model.dart';
import 'package:postgres/postgres.dart';

abstract class RoomScheduleRepository {
  Future<List<RoomSchedule>> getSchedulesByRoomId(String roomId);
  Future<void> updateSchedules(String roomId, List<RoomSchedule> schedules);
  Future<void> createDefaultSchedules(String roomId, {String? createdBy});
}

class RoomScheduleRepositoryImpl implements RoomScheduleRepository {
  RoomScheduleRepositoryImpl(this._db);

  final Database _db;

  RoomSchedule _fromRow(Map<String, dynamic> row) {
    final sanitizedRow = Map<String, dynamic>.from(row);

    const timeFields = ['open_time', 'close_time'];
    for (final field in timeFields) {
      if (sanitizedRow[field] is Time) {
        final time = sanitizedRow[field] as Time;
        sanitizedRow[field] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
      }
    }

    const dateFields = ['created_at', 'updated_at'];
    for (final field in dateFields) {
      if (sanitizedRow[field] is DateTime) {
        sanitizedRow[field] = (sanitizedRow[field] as DateTime).toIso8601String();
      }
    }
    
    return RoomSchedule.fromJson(sanitizedRow);
  }

  @override
  Future<List<RoomSchedule>> getSchedulesByRoomId(String roomId) async {
    final conn = await _db.connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM room_schedules WHERE room_id = @roomId ORDER BY day_of_week'),
      parameters: {'roomId': roomId},
    );
    return result.map((row) => _fromRow(row.toColumnMap())).toList();
  }

  @override
  Future<void> createDefaultSchedules(String roomId, {String? createdBy}) async {
    final conn = await _db.connection;
    await conn.runTx((session) async {
      for (var day = 1; day <= 7; day++) {
        // By default, Saturday (6) and Sunday (7) are not working days
        final isWorking = day < 6;
        await session.execute(
          Sql.named('''
            INSERT INTO room_schedules (room_id, day_of_week, is_working_day, open_time, close_time, created_by, updated_by)
            VALUES (@roomId, @day, @isWorking, @openTime, @closeTime, @user, @user)
          '''),
          parameters: {
            'roomId': roomId,
            'day': day,
            'isWorking': isWorking,
            'openTime': isWorking ? '09:00:00' : null,
            'closeTime': isWorking ? '21:00:00' : null,
            'user': createdBy,
          },
        );
      }
    });
  }

  @override
  Future<void> updateSchedules(String roomId, List<RoomSchedule> schedules) async {
    final conn = await _db.connection;
    await conn.runTx((session) async {
      for (final schedule in schedules) {
        await session.execute(
          Sql.named('''
            INSERT INTO room_schedules (room_id, day_of_week, is_working_day, open_time, close_time, created_by, updated_by)
            VALUES (@roomId, @dayOfWeek, @isWorkingDay, @openTime, @closeTime, @updatedBy, @updatedBy)
            ON CONFLICT (room_id, day_of_week) DO UPDATE SET
              is_working_day = EXCLUDED.is_working_day,
              open_time = EXCLUDED.open_time,
              close_time = EXCLUDED.close_time,
              updated_at = NOW(),
              updated_by = EXCLUDED.updated_by;
          '''),
          parameters: {
            'roomId': roomId,
            'dayOfWeek': schedule.dayOfWeek,
            'isWorkingDay': schedule.isWorkingDay,
            'openTime': schedule.openTime?.toJson(),
            'closeTime': schedule.closeTime?.toJson(),
            'updatedBy': schedule.updatedBy,
          },
        );
      }
    });
  }
}
