import 'package:postgres/postgres.dart';

import '../../../config/database.dart';

abstract class ClientRepository {
  Future<Map<String, dynamic>> getAnthropometryData(String clientId);
  Future<void> updateAnthropometryPhoto(String clientId, String photoUrl, String type, DateTime? photoDateTime, String creatorId);
  Future<void> updateAnthropometryFixed(
    String clientId,
    int? height,
    int? wristCirc,
    int? ankleCirc,
    String creatorId,
  );
  Future<void> updateAnthropometryMeasurements(
    String clientId,
    String type, // 'start' or 'finish'
    double? weight,
    int? shouldersCirc,
    int? breastCirc,
    int? waistCirc,
    int? hipsCirc,
    String creatorId,
  );
  Future<List<Map<String, dynamic>>> getCalorieTrackingData(String clientId);
  Future<Map<String, dynamic>> getProgressData(String clientId);
}

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl(this._db);

  final Database _db;

  Future<Connection> get _connection => _db.connection;

  @override
  Future<Map<String, dynamic>> getAnthropometryData(String clientId) async {
    try {
      final conn = await _connection;
      final fixedResult = await conn.execute(
        Sql.named('SELECT * FROM anthropometry_fix WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );
      final startResult = await conn.execute(
        Sql.named('SELECT *, profile_photo, profile_photo_date_time FROM anthropometry_start WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );
      final finishResult = await conn.execute(
        Sql.named('SELECT *, profile_photo, profile_photo_date_time FROM anthropometry_finish WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );

      final fixedData = fixedResult.isNotEmpty ? _convertDateTimeToString(fixedResult.first.toColumnMap()) : {};
      final startData = startResult.isNotEmpty ? _convertDateTimeToString(startResult.first.toColumnMap()) : {};
      final finishData = finishResult.isNotEmpty ? _convertDateTimeToString(finishResult.first.toColumnMap()) : {};

      print('[getAnthropometryData] startData: $startData');
      print('[getAnthropometryData] finishData: $finishData');

      return {
        'fixed': fixedData,
        'start': startData,
        'finish': finishData,
      };
    } catch (e) {
      print('❌ getAnthropometryData error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _convertDateTimeToString(Map<String, dynamic> map) {
    final newMap = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is DateTime) {
        newMap[key] = value.toIso8601String();
      } else {
        newMap[key] = value;
      }
    });
    return newMap;
  }

  @override
  Future<void> updateAnthropometryPhoto(String clientId, String photoUrl, String type, DateTime? photoDateTime, String creatorId) async {
    try {
      final conn = await _connection;
      String tableName;
      String photoColumn;
      String photoDateTimeColumn;

      switch (type) {
        case 'start_front':
          tableName = 'anthropometry_start';
          photoColumn = 'photo';
          photoDateTimeColumn = 'photo_date_time';
          break;
        case 'finish_front':
          tableName = 'anthropometry_finish';
          photoColumn = 'photo';
          photoDateTimeColumn = 'photo_date_time';
          break;
        case 'start_profile':
          tableName = 'anthropometry_start';
          photoColumn = 'profile_photo';
          photoDateTimeColumn = 'profile_photo_date_time';
          break;
        case 'finish_profile':
          tableName = 'anthropometry_finish';
          photoColumn = 'profile_photo';
          photoDateTimeColumn = 'profile_photo_date_time';
          break;
        default:
          throw ArgumentError('Invalid photo type: $type');
      }

      await conn.execute(
        Sql.named('''
          INSERT INTO $tableName (user_id, $photoColumn, $photoDateTimeColumn, created_by, updated_by)
          VALUES (@clientId, @photoUrl, @photoDateTime, @creatorId, @creatorId)
          ON CONFLICT (user_id) DO UPDATE
          SET $photoColumn = @photoUrl, $photoDateTimeColumn = @photoDateTime, updated_at = NOW(), updated_by = @creatorId
        '''),
        parameters: {
          'photoUrl': photoUrl,
          'clientId': clientId,
          'photoDateTime': photoDateTime ?? DateTime.now(),
          'creatorId': creatorId,
        },
      );
    } catch (e) {
      print('❌ updateAnthropometryPhoto error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAnthropometryFixed(
    String clientId,
    int? height,
    int? wristCirc,
    int? ankleCirc,
    String creatorId,
  ) async {
    try {
      final conn = await _connection;
      await conn.execute(
        Sql.named('''
          INSERT INTO anthropometry_fix (user_id, height, wrist_circ, ankle_circ, created_by, updated_by)
          VALUES (@clientId, @height, @wristCirc, @ankleCirc, @creatorId, @creatorId)
          ON CONFLICT (user_id) DO UPDATE
          SET 
            height = @height,
            wrist_circ = @wristCirc,
            ankle_circ = @ankleCirc,
            updated_at = NOW(),
            updated_by = @creatorId
        '''),
        parameters: {
          'clientId': clientId,
          'height': height,
          'wristCirc': wristCirc,
          'ankleCirc': ankleCirc,
          'creatorId': creatorId,
        },
      );
    } catch (e) {
      print('❌ updateAnthropometryFixed error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAnthropometryMeasurements(
    String clientId,
    String type, // 'start' or 'finish'
    double? weight,
    int? shouldersCirc,
    int? breastCirc,
    int? waistCirc,
    int? hipsCirc,
    String creatorId,
  ) async {
    try {
      final conn = await _connection;
      final tableName = type == 'start' ? 'anthropometry_start' : 'anthropometry_finish';
      final now = DateTime.now();
      await conn.execute(
        Sql.named('''
          INSERT INTO $tableName (user_id, weight, shoulders_circ, breast_circ, waist_circ, hips_circ, date_time, created_by, updated_by)
          VALUES (@clientId, @weight, @shouldersCirc, @breastCirc, @waistCirc, @hipsCirc, @now, @creatorId, @creatorId)
          ON CONFLICT (user_id) DO UPDATE
          SET 
            weight = @weight,
            shoulders_circ = @shouldersCirc,
            breast_circ = @breastCirc,
            waist_circ = @waistCirc,
            hips_circ = @hipsCirc,
            date_time = @now,
            updated_at = NOW(),
            updated_by = @creatorId
        '''),
        parameters: {
          'clientId': clientId,
          'weight': weight,
          'shouldersCirc': shouldersCirc,
          'breastCirc': breastCirc,
          'waistCirc': waistCirc,
          'hipsCirc': hipsCirc,
          'now': now,
          'creatorId': creatorId,
        },
      );
    } catch (e) {
      print('❌ updateAnthropometryMeasurements error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCalorieTrackingData(String clientId) async {
    // TODO: Implement actual database query
    print('Fetching calorie tracking data for client $clientId');
    // Placeholder implementation
    return [
      {
        'date': '2025-10-27T18:00:00',
        'training': 'Тренировка 1',
        'consumed': 2200,
        'burned': 2500,
        'balance': -300,
      },
      {
        'date': '2025-10-29T18:00:00',
        'training': 'Тренировка 2',
        'consumed': 2400,
        'burned': 2100,
        'balance': 300,
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getProgressData(String clientId) async {
    // TODO: Implement actual database query
    print('Fetching progress data for client $clientId');
    // Placeholder implementation
    return {
      'weight': [
        {'date': '2025-10-01', 'value': 85},
        {'date': '2025-10-08', 'value': 84},
        {'date': '2025-10-15', 'value': 82},
        {'date': '2025-10-22', 'value': 83},
        {'date': '2025-10-29', 'value': 81},
      ],
      'calories': [
        {'date': '2025-10-01', 'value': 2200},
        {'date': '2025-10-08', 'value': 2100},
        {'date': '2025-10-15', 'value': 2000},
        {'date': '2025-10-22', 'value': 2300},
        {'date': '2025-10-29', 'value': 2050},
      ],
      'balance': [
        {'date': '2025-10-01', 'value': -300},
        {'date': '2025-10-08', 'value': 100},
        {'date': '2025-10-15', 'value': -500},
        {'date': '2025-10-22', 'value': 200},
        {'date': '2025-10-29', 'value': -150},
      ],
      'kpi': {
        'avgWeight': 82.2,
        'weightChange': -2.8,
        'avgCalories': 2130,
      },
      'recommendations': 'Ваш прогресс замедлился. Попробуйте добавить больше кардио-упражнений и следите за потреблением углеводов.',
    };
  }
}
