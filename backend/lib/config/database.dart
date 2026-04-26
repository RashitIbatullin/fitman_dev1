import 'dart:async';
import 'package:postgres/postgres.dart';

import 'app_config.dart';

import '../modules/groups/repositories/group_repository.dart';
import '../modules/rooms/repositories/room_repository.dart';
import '../modules/equipment/repositories/equipment_item.repository.dart';
import '../modules/equipment/repositories/equipment_type.repository.dart';
import '../modules/users/repositories/user_repository.dart';
import '../modules/clients/repositories/client_repository.dart';
import '../modules/schedule/repositories/schedule_repository.dart';
import '../modules/recommendations/repositories/recommendation_repository.dart';
import '../modules/catalogs/repositories/catalog_repository.dart';

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
  late final ScheduleRepository schedules = ScheduleRepositoryImpl(_instance);
  late final RecommendationRepository recommendations = RecommendationRepositoryImpl(_instance);
  late final CatalogRepository catalogs = CatalogRepositoryImpl(_instance);

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
}
