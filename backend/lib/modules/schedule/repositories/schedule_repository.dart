import 'package:postgres/postgres.dart';

import '../../../config/database.dart';

abstract class ScheduleRepository {
  Future<List<Map<String, dynamic>>> getScheduleForUser(String userId, String role);
}

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this._db);

  final Database _db;

  Future<Connection> get _connection => _db.connection;

  @override
  Future<List<Map<String, dynamic>>> getScheduleForUser(String userId, String role) async {
    try {
      final conn = await _connection;
      String userColumn;
      switch (role) {
        case 'instructor':
          userColumn = 'l.instructor_id';
          break;
        case 'trainer':
          userColumn = 'l.trainer_id';
          break;
        case 'client':
          userColumn = 'l.client_id';
          break;
        default:
          return [];
      }

      final results = await conn.execute(
        Sql.named('''
          SELECT 
            l.id,
            tpt.name as training_plan_name,
            l.start_plan_at as start_time,
            l.finish_plan_at as end_time,
            l.complete as status,
            (SELECT u.first_name || ' ' || u.last_name FROM users u WHERE u.id = l.trainer_id) as trainer_name
          FROM lessons l
          LEFT JOIN client_training_plans ctp ON l.client_training_plan_id = ctp.id
          LEFT JOIN training_plan_templates tpt ON ctp.training_plan_template_id = tpt.id
          WHERE $userColumn = @userId
          ORDER BY l.start_plan_at ASC
        '''),
        parameters: {'userId': userId},
      );

      return results.map((row) {
        final rowMap = row.toColumnMap();
        return {
          'id': rowMap['id'],
          'training_plan_name': rowMap['training_plan_name'] ?? 'Без названия',
          'start_time': (rowMap['start_time'] as DateTime).toIso8601String(),
          'end_time': (rowMap['end_time'] as DateTime).toIso8601String(),
          'status': _statusToString(rowMap['status']),
          'trainer_name': rowMap['trainer_name'] ?? 'Не назначен',
        };
      }).toList();
    } catch (e) {
      print('❌ getScheduleForUser error: $e');
      rethrow;
    }
  }

  String _statusToString(dynamic status) {
    if (status is! int) return 'unknown';
    switch (status) {
      case 0:
        return 'scheduled';
      case 1:
        return 'completed';
      case 2:
        return 'canceled';
      default:
        return 'unknown';
    }
  }
}
