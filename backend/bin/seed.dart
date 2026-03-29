import 'dart:io';

import 'package:args/args.dart';
import 'package:faker/faker.dart';
import 'package:postgres/postgres.dart';

import '../lib/config/app_config.dart';

// ignore_for_file: no_leading_underscores_for_local_identifiers

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('demo', help: 'Seed with a small set of demo data.', negatable: false)
    ..addFlag('load', help: 'Seed with a large set of data for load testing.', negatable: false)
    ..addOption('users', abbr: 'u', help: 'Number of users to create for load testing.', defaultsTo: '100')
    ..addFlag('help', abbr: 'h', help: 'Show this help message.', negatable: false);

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool) {
    print('Database Seeding Tool');
    print(parser.usage);
    return;
  }

  final seeder = DatabaseSeeder();
  await seeder.connect();

  if (argResults['demo'] as bool) {
    print('Starting to seed database with DEMO data...');
    await seeder.runDemo();
    print('✅ Demo data seeding complete!');
  } else if (argResults['load'] as bool) {
    final userCount = int.tryParse(argResults['users'] as String) ?? 100;
    print('Starting to seed database with LOAD TEST data ($userCount users)...');
    await seeder.runLoadTest(userCount: userCount);
    print('✅ Load test data seeding complete!');
  } else {
    print('Please specify a mode: --demo or --load');
    print(parser.usage);
  }

  await seeder.close();
}

class DatabaseSeeder {
  late final Connection _connection;
  final Faker _faker = Faker();

  Future<void> connect() async {
    final dbConfig = AppConfig.instance;
    final endpoint = Endpoint(
      host: dbConfig.dbHost,
      port: dbConfig.dbPort,
      database: dbConfig.dbName,
      username: dbConfig.dbUser,
      password: dbConfig.dbPass,
    );
    _connection = await Connection.open(endpoint,
        settings: ConnectionSettings(sslMode: SslMode.disable));
    print('📦 Connected to database: ${dbConfig.dbName}');
  }

  Future<void> close() async {
    await _connection.close();
    print('✋ Connection to database closed.');
  }

  Future<void> runDemo() async {
    await _clearDynamicData();
    await _seedStaticData();

    print('🏢 Seeding infrastructure (buildings, rooms)...');
    final building1Id = await _createBuilding(name: 'Главный корпус', address: 'ул. Спортивная, д. 1');
    final building2Id = await _createBuilding(name: 'Водный комплекс', address: 'ул. Спортивная, д. 1, стр. 2');

    final rooms = {
      'reception': await _createRoom(name: 'Ресепшен', buildingId: building1Id, type: 9, floor: 1),
      'cardio': await _createRoom(name: 'Кардио-зона', buildingId: building1Id, type: 1, floor: 2),
      'strength': await _createRoom(name: 'Силовая зона', buildingId: building1Id, type: 2, floor: 2),
      'group': await _createRoom(name: 'Зал групповых программ', buildingId: building1Id, type: 0, floor: 3),
      'yoga': await _createRoom(name: 'Студия йоги', buildingId: building1Id, type: 4, floor: 3),
      'pool': await _createRoom(name: 'Бассейн 25м', buildingId: building2Id, type: 6, floor: 1),
    };
    print('🏡 Created ${rooms.length} rooms in 2 buildings.');

    print('🔩 Seeding equipment...');
    final equipmentTypes = await _seedEquipmentTypes();
    await _createEquipmentItem(typeId: equipmentTypes['treadmill']!, inventoryNumber: 'ТРЕД-001', roomId: rooms['cardio']!);
    await _createEquipmentItem(typeId: equipmentTypes['treadmill']!, inventoryNumber: 'ТРЕД-002', roomId: rooms['cardio']!);
    await _createEquipmentItem(typeId: equipmentTypes['elliptical']!, inventoryNumber: 'ЭЛЛ-001', roomId: rooms['cardio']!);
    await _createEquipmentItem(typeId: equipmentTypes['dumbbell']!, inventoryNumber: 'ГАН-001', roomId: rooms['strength']!);
    await _createEquipmentItem(typeId: equipmentTypes['barbell']!, inventoryNumber: 'ШТАН-001', roomId: rooms['strength']!);
    print('🔧 Created equipment items.');

    print('👥 Seeding users and profiles...');
    final roles = await _getIdsForTable('roles', keyColumn: 'name');
    final levels = await _getIdsForTable('levels_training', keyColumn: 'name');
    final goals = await _getIdsForTable('goals_training', keyColumn: 'name');

    final adminId = await _createUser(login: 'admin@fitman.ru', firstName: 'Админ', lastName: 'Администраторов');
    await _assignRole(adminId, roles['admin']!);
    await _connection.execute(Sql.named('INSERT INTO admin_profiles (user_id) VALUES (@user_id)'), parameters: {'user_id': adminId});
    print('   👤 Created Admin');

    final managerId = await _createUser(login: 'manager@fitman.ru', firstName: 'Менеджер', lastName: 'Менеджеров');
    await _assignRole(managerId, roles['manager']!);
    await _createEmployeeProfile(managerId, specialization: 'Управление', workExperience: 3, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO manager_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': managerId, 'created_by': adminId});
    print('   👤 Created Manager');

    final trainerId = await _createUser(login: 'trainer@fitman.ru', firstName: 'Тренер', lastName: 'Тренеров');
    await _assignRole(trainerId, roles['trainer']!);
    await _createEmployeeProfile(trainerId, specialization: 'Силовой тренинг', workExperience: 5, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO trainer_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': trainerId, 'created_by': adminId});
    print('   👤 Created Trainer');

    final instructorId = await _createUser(login: 'instructor@fitman.ru', firstName: 'Инструктор', lastName: 'Инструкторова', gender: 1);
    await _assignRole(instructorId, roles['instructor']!);
    await _createEmployeeProfile(instructorId, specialization: 'Групповые занятия', workExperience: 2, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO instructor_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': instructorId, 'created_by': adminId});
    print('   👤 Created Instructor');

    final clientId = await _createUser(login: 'client@fitman.ru', firstName: 'Клиент', lastName: 'Клиентов', gender: 0);
    await _assignRole(clientId, roles['client']!);
    await _connection.execute(Sql.named('''
      INSERT INTO client_profiles (user_id, goal_training_id, level_training_id, created_by) 
      VALUES (@user_id, @goal, @level, @created_by)
      '''), parameters: {'user_id': clientId, 'goal': goals['Набор мышечной массы и силы'], 'level': levels['Новичок'], 'created_by': adminId});
    print('   👤 Created Client');

    await _assign(managerId, 'manager_trainers', 'trainer_id', trainerId);
    await _assign(managerId, 'manager_instructors', 'instructor_id', instructorId);
    await _assign(managerId, 'manager_clients', 'client_id', clientId);
    await _assign(instructorId, 'instructor_clients', 'client_id', clientId);
    print('🔗 Created relationships between users');
  }

  Future<void> runLoadTest({int userCount = 100}) async {
    await _clearDynamicData();
    await _seedStaticData();
    // Extend this to create infrastructure for load testing if needed
    print('Generating $userCount users...');
    for (int i = 0; i < userCount; i++) {
      await _createUser(
        login: _faker.internet.email(),
        firstName: _faker.person.firstName(),
        lastName: _faker.person.lastName(),
      );
      stdout.write('.');
    }
    print('$userCount users created.');
  }

  Future<void> _seedStaticData() async {
    print('🌱 Seeding static data (roles, levels, goals)...');
    await _connection.execute('''
      INSERT INTO roles (name, title) VALUES
        ('client', 'Клиент'), ('instructor', 'Инструктор'), ('trainer', 'Тренер'),
        ('manager', 'Менеджер'), ('admin', 'Администратор')
      ON CONFLICT (name) DO NOTHING;
    ''');
    final levels = [{'name': 'Новичок', 'description': 'Человек, который никогда не занимался или имел длительный перерыв.'}, {'name': 'Опытный', 'description': 'Человек, который занимается регулярно от 6 месяцев до 2 лет.'}, {'name': 'Продвинутый', 'description': 'Человек, который занимается более 2 лет и имеет хорошие силовые показатели.'},];
    for (final level in levels) {
      await _connection.execute(Sql.named('''
          INSERT INTO levels_training (name, description) 
          VALUES (@name, @description)
          ON CONFLICT (name) DO NOTHING;
        '''), parameters: level);
    }
    await _connection.execute('''
      INSERT INTO goals_training (name) VALUES
        ('Снижение веса и оздоровление'), ('Набор мышечной массы и силы'),
        ('Поддержание формы и улучшение рельефа'), ('Развитие общей выносливости'),
        ('Увеличение гибкости и мобильности')
      ON CONFLICT (name) DO NOTHING;
    ''');
    
    await _connection.execute('''
      INSERT INTO training_group_types (name, title, min_participants, max_participants) VALUES
        ('individual', 'Индивид.', 1, 1),
        ('semi_personal', 'Полуперсон.', 2, 2),
        ('group', 'Группа', 4, 50)
      ON CONFLICT (name) DO NOTHING;
    ''');
  }

  Future<void> _clearDynamicData() async {
    print('🧹 Clearing all data from cascading tables...');
    // Truncating users will cascade to most related tables.
    // We also truncate the new top-level tables.
    await _connection.execute('TRUNCATE buildings, equipment_items, users CASCADE');
  }
  
  // New creator methods for infrastructure

  Future<String> _createBuilding({required String name, required String address}) async {
    final result = await _connection.execute(Sql.named('''
      INSERT INTO buildings (name, address) VALUES (@name, @address) RETURNING id;
    '''), parameters: {'name': name, 'address': address});
    return result.first[0].toString();
  }

  Future<String> _createRoom({required String name, required String buildingId, required int type, required int floor}) async {
    final result = await _connection.execute(Sql.named('''
      INSERT INTO rooms (name, building_id, type, floor) VALUES (@name, @buildingId, @type, @floor) RETURNING id;
    '''), parameters: {'name': name, 'buildingId': buildingId, 'type': type, 'floor': floor});
    return result.first[0].toString();
  }

  Future<Map<String, String>> _seedEquipmentTypes() async {
    final types = [
      {'name': 'Беговая дорожка', 'category': 0, 'schematic_icon': 'treadmill'},
      {'name': 'Эллиптический тренажер', 'category': 0, 'schematic_icon': 'elliptical'},
      {'name': 'Велотренажер', 'category': 0, 'schematic_icon': 'bike'},
      {'name': 'Гантели', 'category': 2, 'schematic_icon': 'dumbbell'},
      {'name': 'Штанга', 'category': 2, 'schematic_icon': 'barbell'},
    ];
    for (final type in types) {
      await _connection.execute(Sql.named('''
        INSERT INTO equipment_types (name, category, schematic_icon)
        VALUES (@name, @category, @schematic_icon) ON CONFLICT DO NOTHING;
      '''), parameters: type);
    }
    return await _getIdsForTable('equipment_types', keyColumn: 'schematic_icon');
  }

  Future<String> _createEquipmentItem({required String typeId, required String inventoryNumber, required String roomId}) async {
     final result = await _connection.execute(Sql.named('''
      INSERT INTO equipment_items (type_id, inventory_number, room_id, status)
      VALUES (@type_id, @inventory_number, @room_id, 0) RETURNING id;
    '''), parameters: {'type_id': typeId, 'inventory_number': inventoryNumber, 'room_id': roomId});
    return result.first[0].toString();
  }

  // Existing methods
  Future<String> _createUser({required String login, String password = 'password123', required String firstName, required String lastName, int gender = 0}) async {
    final passwordHash = r'$2a$10$RATHndPnw7mQZOOfAb3RHeaGhV8Aul2U4BXx2C94pDr4EqV58uEUW';
    final result = await _connection.execute(Sql.named('''
      INSERT INTO users (login, password_hash, email, first_name, last_name, gender, date_of_birth)
      VALUES (@login, @hash, @email, @first, @last, @gender, @dob)
      RETURNING id
      '''), parameters: {'login': login, 'hash': passwordHash, 'email': login, 'first': firstName, 'last': lastName, 'gender': gender, 'dob': _faker.date.dateTime(minYear: 1970, maxYear: 2004)});
    return result.first[0].toString();
  }

  Future<void> _assignRole(String userId, String roleId) async {
    await _connection.execute(Sql.named('INSERT INTO user_roles (user_id, role_id) VALUES (@user_id, @role_id)'), parameters: {'user_id': userId, 'role_id': roleId});
  }

  Future<void> _createEmployeeProfile(String userId, {required String specialization, required int workExperience, required String createdBy}) async {
    await _connection.execute(Sql.named('''
      INSERT INTO employee_profiles (user_id, specialization, work_experience, can_maintain_equipment, created_by)
      VALUES (@user_id, @spec, @exp, @can_maintain, @created_by)
      '''), parameters: {'user_id': userId, 'spec': specialization, 'exp': workExperience, 'can_maintain': _faker.randomGenerator.boolean(), 'created_by': createdBy});
  }

  Future<void> _assign(String managerId, String tableName, String roleIdColumn, String subordinateId) async {
    final managerIdColumn = tableName.split('_').first + '_id';
    await _connection.execute(Sql.named('INSERT INTO $tableName ($managerIdColumn, $roleIdColumn) VALUES (@manager_id, @subordinate_id)'), parameters: {'manager_id': managerId, 'subordinate_id': subordinateId});
  }

  Future<Map<String, String>> _getIdsForTable(String tableName, {String idColumn = 'id', required String keyColumn}) async {
    final results = await _connection.execute('SELECT $idColumn, $keyColumn FROM $tableName');
    return {for (var row in results) row[1] as String: row[0].toString()};
  }
}
