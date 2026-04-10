import 'dart:async';
import 'package:postgres/postgres.dart';

import 'app_config.dart';

import '../modules/groups/repositories/group_repository.dart';
import '../modules/rooms/repositories/room.repository.dart';
import '../modules/equipment/repositories/equipment_item.repository.dart';
import '../modules/equipment/repositories/equipment_type.repository.dart';
import '../modules/users/repositories/user_repository.dart';
import '../modules/clients/repositories/client_repository.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  Connection? _connection;
  bool _isConnecting = false;
  Completer<void>? _connectionCompleter;
  
  late final GroupRepository groups = GroupRepository(_instance);
  late final RoomRepository rooms = RoomRepositoryImpl(_instance);
  late final EquipmentItemRepository equipmentItems = EquipmentItemRepositoryImpl(_instance);
  late final EquipmentTypeRepository equipmentTypes = EquipmentTypeRepositoryImpl(_instance);
  late final UserRepository users = UserRepositoryImpl(_instance);
  late final ClientRepository clients = ClientRepositoryImpl(_instance);

  Future<Connection> get connection async {
    if (_connection != null) {
      return _connection!;
    }

    if (_isConnecting && _connectionCompleter != null) {
      await _connectionCompleter!.future;
      return _connection!;
    }

    await connect();
    return _connection!;
  }

  Future<void> connect() async {
    if (_connection != null) return;

    _isConnecting = true;
    _connectionCompleter = Completer<void>();

    try {
      final config = AppConfig.instance;
      final endpoint = Endpoint(
        host: config.dbHost,
        port: config.dbPort,
        database: config.dbName,
        username: config.dbUser,
        password: config.dbPass,
      );

      print('🔄 Connecting to PostgreSQL database...');
      _connection = await Connection.open(endpoint, settings: ConnectionSettings(sslMode: SslMode.disable));
      print('✅ Connected to PostgreSQL database');
      
      _connectionCompleter!.complete();
    } catch (e) {
      print('❌ Database connection error: $e');
      _connectionCompleter!.completeError(e);
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _connectionCompleter = null;
  }

  // Получить данные для каталога по имени таблицы
  Future<List<Map<String, dynamic>>> getCatalog(String tableName) async {
    try {
      final conn = await connection;
      final results = await conn.execute('SELECT id, name FROM $tableName WHERE archived_at IS NULL ORDER BY id');
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ getCatalog ($tableName) error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getScheduleForUser(String userId, String role) async {
    try {
      final conn = await connection;
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

  Future<Map<String, dynamic>> getBioimpedanceData(String clientId) async {
    try {
      final conn = await connection;
      final startResult = await conn.execute(
        Sql.named('SELECT * FROM bioimpedance_start WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );
      final finishResult = await conn.execute(
        Sql.named('SELECT * FROM bioimpedance_finish WHERE user_id = @clientId'),
        parameters: {'clientId': clientId},
      );

      final startData = startResult.isNotEmpty ? _convertDateTimeToString(startResult.first.toColumnMap()) : {};
      final finishData = finishResult.isNotEmpty ? _convertDateTimeToString(finishResult.first.toColumnMap()) : {};

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

  Future<List<Map<String, dynamic>>> getSomatotypeRules() async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT * FROM types_body_build WHERE archived_at IS NULL'),
      );
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ getSomatotypeRules error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBodyShapeRecommendations() async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT * FROM body_shape_recommendations WHERE archived_at IS NULL'),
      );
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ getBodyShapeRecommendations error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWhtrRefinements() async {
    try {
      final conn = await connection;
      final results = await conn.execute(
        Sql.named('SELECT * FROM whtr_refinements WHERE archived_at IS NULL'),
      );
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('❌ getWhtrRefinements error: $e');
      rethrow;
    }
  }
}
