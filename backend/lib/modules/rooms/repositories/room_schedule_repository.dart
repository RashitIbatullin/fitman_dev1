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
    // Basic conversion, can be improved with json sanitizing like in RoomRepository
    return RoomSchedule.fromJson(row);
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
            UPDATE room_schedules 
            SET 
              is_working_day = @isWorkingDay,
              open_time = @openTime,
              close_time = @closeTime,
              updated_at = NOW(),
              updated_by = @updatedBy
            WHERE id = @id AND room_id = @roomId
          '''),
          parameters: {
            'id': schedule.id,
            'roomId': roomId,
            'isWorkingDay': schedule.isWorkingDay,
            'openTime': schedule.openTime?.toString(),
            'closeTime': schedule.closeTime?.toString(),
            'updatedBy': schedule.updatedBy,
          },
        );
      }
    });
  }
}
