import 'package:fitman_common/modules/clients/anthropometry/anthropometry_fixed.dart';
import 'package:fitman_common/modules/clients/anthropometry/anthropometry_measurement.dart';
import 'package:postgres/postgres.dart';

import '../../../config/database.dart';

abstract class ClientRepository {
  Future<List<AnthropometryMeasurement>> getAnthropometryMeasurements(
    String clientId, {
    bool includeArchived,
  });
  Future<AnthropometryMeasurement> saveAnthropometryMeasurement(
    AnthropometryMeasurement measurement,
  );
  Future<AnthropometryFixed?> getFixedAnthropometry(String clientId);
  Future<AnthropometryFixed> saveFixedAnthropometry(
      AnthropometryFixed fixedData);
  Future<void> archiveAnthropometryMeasurement(
      String measurementId, String archivedBy, String archivedReason);
  Future<void> unarchiveAnthropometryMeasurement(String measurementId);

  Future<List<Map<String, dynamic>>> getCalorieTrackingData(String clientId);
  Future<Map<String, dynamic>> getProgressData(String clientId);
  Future<Map<String, dynamic>> getBioimpedanceData(String clientId);
}

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl(this._db);

  final Database _db;

  Future<Connection> get _connection => _db.connection;

  @override
  Future<void> archiveAnthropometryMeasurement(
      String measurementId, String archivedBy, String archivedReason) async {
    try {
      final conn = await _connection;
      await conn.execute(
        Sql.named('''
          UPDATE anthropometry_measurements
          SET archived_at = NOW(), archived_by = @archivedBy, archived_reason = @archivedReason
          WHERE id = @measurementId
        '''),
        parameters: {
          'measurementId': measurementId,
          'archivedBy': archivedBy,
          'archivedReason': archivedReason,
        },
      );
    } catch (e) {
      print('❌ archiveAnthropometryMeasurement error: $e');
      rethrow;
    }
  }

  @override
  Future<void> unarchiveAnthropometryMeasurement(String measurementId) async {
    try {
      final conn = await _connection;
      await conn.execute(
        Sql.named('''
          UPDATE anthropometry_measurements
          SET archived_at = NULL, archived_by = NULL, archived_reason = NULL
          WHERE id = @measurementId
        '''),
        parameters: {
          'measurementId': measurementId,
        },
      );
    } catch (e) {
      print('❌ unarchiveAnthropometryMeasurement error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AnthropometryMeasurement>> getAnthropometryMeasurements(
    String clientId, {
    bool includeArchived = false,
  }) async {
    try {
      final conn = await _connection;
      var query = '''
          SELECT id, user_id, date_time, photo, photo_date_time, profile_photo, profile_photo_date_time, 
                 weight, shoulders_circ, breast_circ, waist_circ, hips_circ, 
                 company_id, created_at, updated_at, created_by, updated_by, 
                 archived_at, archived_by, archived_reason
          FROM anthropometry_measurements 
          WHERE user_id = @clientId
        ''';

      if (!includeArchived) {
        query += ' AND archived_at IS NULL';
      }

      query += ' ORDER BY date_time DESC';

      final result = await conn.execute(
        Sql.named(query),
        parameters: {'clientId': clientId},
      );

      return result.map((row) {
        try {
          return AnthropometryMeasurement.fromJson(_convertDateTimeToString(row.toColumnMap()));
        } catch (e, s) {
          print('❌ Failed to parse anthropometry measurement row:');
          print('Row data: ${row.toColumnMap()}');
          print('Error: $e');
          print('Stacktrace: $s');
          return null;
        }
      }).whereType<AnthropometryMeasurement>().toList();
    } catch (e) {
      print('❌ getAnthropometryMeasurements error: $e');
      rethrow;
    }
  }

  @override
  Future<AnthropometryMeasurement> saveAnthropometryMeasurement(
    AnthropometryMeasurement measurement,
  ) async {
    try {
      final conn = await _connection;
      final params = measurement.toJson()
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('archived_at')
        ..remove('archived_by')
        ..remove('archived_reason');

      final result = await conn.execute(
        Sql.named('''
          INSERT INTO anthropometry_measurements (
            id, user_id, date_time, photo, photo_date_time, profile_photo, profile_photo_date_time, 
            weight, shoulders_circ, breast_circ, waist_circ, hips_circ, 
            company_id, updated_at, created_by, updated_by
          )
          VALUES (
            COALESCE(@id, gen_random_uuid()), @user_id, @date_time, @photo, @photo_date_time, 
            @profile_photo, @profile_photo_date_time, @weight, @shoulders_circ, 
            @breast_circ, @waist_circ, @hips_circ, @company_id, NOW(), 
            @created_by, @updated_by
          )
          ON CONFLICT (id) DO UPDATE SET
            date_time = EXCLUDED.date_time,
            photo = EXCLUDED.photo,
            photo_date_time = EXCLUDED.photo_date_time,
            profile_photo = EXCLUDED.profile_photo,
            profile_photo_date_time = EXCLUDED.profile_photo_date_time,
            weight = EXCLUDED.weight,
            shoulders_circ = EXCLUDED.shoulders_circ,
            breast_circ = EXCLUDED.breast_circ,
            waist_circ = EXCLUDED.waist_circ,
            hips_circ = EXCLUDED.hips_circ,
            updated_at = NOW(),
            updated_by = EXCLUDED.updated_by
          RETURNING *;
        '''),
        parameters: params,
      );

      if (result.isEmpty) {
        throw Exception('Failed to save anthropometry measurement.');
      }

      return AnthropometryMeasurement.fromJson(_convertDateTimeToString(result.first.toColumnMap()));
    } catch (e) {
      print('❌ saveAnthropometryMeasurement error: $e');
      rethrow;
    }
  }

  @override
  Future<AnthropometryFixed?> getFixedAnthropometry(String clientId) async {
    try {
      final conn = await _connection;
      final result = await conn.execute(
        Sql.named('SELECT * FROM anthropometry_fix WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );
      if (result.isEmpty) {
        return null;
      }
      return AnthropometryFixed.fromJson(_convertDateTimeToString(result.first.toColumnMap()));
    } catch (e) {
      print('❌ getFixedAnthropometry error: $e');
      rethrow;
    }
  }

  @override
  Future<AnthropometryFixed> saveFixedAnthropometry(
      AnthropometryFixed fixedData) async {
    try {
      final conn = await _connection;
      final params = fixedData.toJson()
        ..remove('created_at')
        ..remove('updated_at');

      final result = await conn.execute(
        Sql.named('''
        INSERT INTO anthropometry_fix (user_id, height, wrist_circ, ankle_circ, created_by, updated_by, company_id, updated_at)
        VALUES (@user_id, @height, @wrist_circ, @ankle_circ, @created_by, @updated_by, @company_id, NOW())
        ON CONFLICT (user_id) DO UPDATE
        SET 
          height = EXCLUDED.height,
          wrist_circ = EXCLUDED.wrist_circ,
          ankle_circ = EXCLUDED.ankle_circ,
          updated_at = NOW(),
          updated_by = EXCLUDED.updated_by
        RETURNING *;
      '''),
        parameters: params,
      );

      if (result.isEmpty) {
        throw Exception('Failed to save fixed anthropometry.');
      }
      return AnthropometryFixed.fromJson(_convertDateTimeToString(result.first.toColumnMap()));
    } catch (e) {
      print('❌ saveFixedAnthropometry error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCalorieTrackingData(
      String clientId) async {
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
    ];
  }

  @override
  Future<Map<String, dynamic>> getProgressData(String clientId) async {
    // TODO: Implement actual database query
    print('Fetching progress data for client $clientId');
    // Placeholder implementation
    return {
      'weight': [{'date': '2025-10-01', 'value': 85}],
      'calories': [],
      'balance': [],
      'kpi': {
        'avgWeight': 0,
        'weightChange': 0,
        'avgCalories': 0,
      },
      'recommendations': 'Нет данных для рекомендаций.',
    };
  }

  @override
  Future<Map<String, dynamic>> getBioimpedanceData(String clientId) async {
    try {
      final conn = await _connection;
      final startResult = await conn.execute(
        Sql.named('SELECT * FROM bioimpedance_start WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );
      final finishResult = await conn.execute(
        Sql.named('SELECT * FROM bioimpedance_finish WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );

      final startData = startResult.isNotEmpty
          ? _convertDateTimeToString(startResult.first.toColumnMap())
          : {};
      final finishData = finishResult.isNotEmpty
          ? _convertDateTimeToString(finishResult.first.toColumnMap())
          : {};

      return {
        'start': startData,
        'finish': finishData,
      };
    } catch (e) {
      print('❌ getBioimpedanceData error: $e');
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
}
