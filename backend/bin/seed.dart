import 'dart:io';

import 'package:args/args.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:faker/faker.dart';
import 'package:postgres/postgres.dart';
import 'package:fitman_backend/config/app_config.dart';

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

    print('👥 Seeding users and profiles...');
    final roles = await _getIdsForTable('roles', keyColumn: 'name');
    final levels = await _getIdsForTable('levels_training', keyColumn: 'name');
    final goals = await _getIdsForTable('goals_training', keyColumn: 'name');

    // Create users with correct passwords from login_screen.dart
    final adminId = await _createUser(login: 'admin@fitman.ru', firstName: 'Админ', lastName: 'Администраторов', phone: '+70000000000', password: 'admin123');

    await _assignRole(adminId, roles['admin']!);
    await _connection.execute(Sql.named('INSERT INTO admin_profiles (user_id) VALUES (@user_id)'), parameters: {'user_id': adminId});
    print('   👤 Created Admin');

    final managerId = await _createUser(login: 'manager@fitman.ru', firstName: 'Менеджер', lastName: 'Менеджеров', phone: '+70000000003', password: 'manager123');
    await _assignRole(managerId, roles['manager']!);
    await _createEmployeeProfile(managerId, specialization: 'Управление', workExperience: 3, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO manager_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': managerId, 'created_by': adminId});
    print('   👤 Created Manager');

    final trainerId = await _createUser(login: 'trainer@fitman.ru', firstName: 'Тренер', lastName: 'Тренеров', phone: '+70000000002', password: 'trainer123');
    await _assignRole(trainerId, roles['trainer']!);
    await _createEmployeeProfile(trainerId, specialization: 'Силовой тренинг', workExperience: 5, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO trainer_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': trainerId, 'created_by': adminId});
    print('   👤 Created Trainer');

    final instructorId = await _createUser(login: 'instructor@fitman.ru', firstName: 'Инструктор', lastName: 'Инструкторова', phone: '+70000000001', gender: 1, password: 'instructor123');
    await _assignRole(instructorId, roles['instructor']!);
    await _createEmployeeProfile(instructorId, specialization: 'Групповые занятия', workExperience: 2, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO instructor_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': instructorId, 'created_by': adminId});
    print('   👤 Created Instructor');

    final clientId = await _createUser(login: 'client@fitman.ru', firstName: 'Клиент', lastName: 'Клиентов', phone: '+70000000004', gender: 0, password: 'client123');
    await _assignRole(clientId, roles['client']!);
    await _connection.execute(Sql.named('''
      INSERT INTO client_profiles (user_id, goal_training_id, level_training_id, created_by)
      VALUES (@user_id, @goal, @level, @created_by)
      '''), parameters: {'user_id': clientId, 'goal': goals['Набор мышечной массы и силы'], 'level': levels['Новичок'], 'created_by': adminId});
    print('   👤 Created Client');

    print('📅 Fetching center work schedules...');
    final workSchedulesResult = await _connection.execute('SELECT day_of_week, start_time, end_time, is_day_off FROM work_schedules ORDER BY day_of_week');
    final List<Map<String, dynamic>> workSchedules = workSchedulesResult.map((row) {
      final openTime = row[1];
      final closeTime = row[2];
      return {
        'day_of_week': row[0] as int,
        'open_time': openTime is Time ? '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}:${openTime.second.toString().padLeft(2, '0')}' : null,
        'close_time': closeTime is Time ? '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}:${closeTime.second.toString().padLeft(2, '0')}' : null,
        'is_day_off': row[3] as bool,
      };
    }).toList();
    print('   Fetched ${workSchedules.length} work schedules.');

    print('🛌 Populating room schedules...');
    final allRoomIdsResult = await _connection.execute('SELECT id FROM rooms');
    final List<String> allRoomIds = allRoomIdsResult.map((row) => row[0].toString()).toList();

    for (final roomId in allRoomIds) {
      for (final ws in workSchedules) {
        await _connection.execute(Sql.named('''
          INSERT INTO room_schedules (room_id, day_of_week, is_working_day, open_time, close_time, created_by)
          VALUES (@roomId, @dayOfWeek, @isWorkingDay, @openTime, @closeTime, @createdBy)
        '''), parameters: {
          'roomId': roomId,
          'dayOfWeek': ws['day_of_week'],
          'isWorkingDay': !ws['is_day_off'],
          'openTime': ws['open_time'],
          'closeTime': ws['close_time'],
          'createdBy': adminId, // Assuming adminId is available and valid
        });
      }
    }
    print('   ✅ Room schedules populated for ${allRoomIds.length} rooms.');

    print('🔩 Seeding equipment...');
    final equipmentTypes = await _seedEquipmentTypes();
    final item1Id = await _createEquipmentItem(typeId: equipmentTypes['treadmill']!, inventoryNumber: 'ТРЕД-001', roomId: rooms['cardio']!, model: 'Matrix T7xi', manufacturer: 'Johnson Health Tech');
    final item2Id = await _createEquipmentItem(typeId: equipmentTypes['treadmill']!, inventoryNumber: 'ТРЕД-002', roomId: rooms['cardio']!, model: 'Precor TRM 885', manufacturer: 'Precor');
    await _createEquipmentItem(typeId: equipmentTypes['elliptical']!, inventoryNumber: 'ЭЛЛ-001', roomId: rooms['cardio']!, model: 'Life Fitness Platinum Club', manufacturer: 'Life Fitness');
    await _createEquipmentItem(typeId: equipmentTypes['dumbbell']!, inventoryNumber: 'ГАН-001', roomId: rooms['strength']!, model: 'Ziva ZVO', manufacturer: 'Ziva');
    await _createEquipmentItem(typeId: equipmentTypes['barbell']!, inventoryNumber: 'ШТАН-001', roomId: rooms['strength']!, model: 'Eleiko IWF', manufacturer: 'Eleiko');
    print('🔧 Created equipment items.');

    print('   📏 Seeding measurements for demo client...');
    // Fixed measurement
    await _connection.execute(Sql.named(r'''
        INSERT INTO anthropometry_fix (user_id, height, wrist_circ, ankle_circ)
        VALUES (@user_id, 175, 18, 22)
        ON CONFLICT (user_id) DO UPDATE SET height = EXCLUDED.height, wrist_circ = EXCLUDED.wrist_circ, ankle_circ = EXCLUDED.ankle_circ;
      '''), parameters: {'user_id': clientId});

    // Periodic measurement 1 (past)
    await _connection.execute(Sql.named(r'''
        INSERT INTO anthropometry_measurements (user_id, date_time, weight, shoulders_circ, breast_circ, waist_circ, hips_circ)
        VALUES (@user_id, @date, 85.0, 110, 100, 90, 105);
      '''), parameters: {'user_id': clientId, 'date': DateTime.now().subtract(const Duration(days: 30))});

    // Periodic measurement 2 (present)
    await _connection.execute(Sql.named(r'''
        INSERT INTO anthropometry_measurements (user_id, date_time, weight, shoulders_circ, breast_circ, waist_circ, hips_circ)
        VALUES (@user_id, @date, 83.5, 112, 101, 88, 104);
      '''), parameters: {'user_id': clientId, 'date': DateTime.now()});
    print('   📏 measurements for demo client seeded.');

    await _assign(managerId, 'manager_trainers', 'trainer_id', trainerId);
    await _assign(managerId, 'manager_instructors', 'instructor_id', instructorId);
    await _assign(managerId, 'manager_clients', 'client_id', clientId);
    await _assign(instructorId, 'instructor_clients', 'client_id', clientId);
    print('🔗 Created relationships between users');

    print('📖 Seeding bookings...');
    await _createBooking(equipmentItemId: item1Id, bookedById: clientId, startOffset: const Duration(hours: 2), endOffset: const Duration(hours: 3), createdBy: adminId);
    await _createBooking(equipmentItemId: item2Id, bookedById: trainerId, startOffset: const Duration(hours: 4), endOffset: const Duration(hours: 5), createdBy: adminId);
    print('   📖 Created bookings.');

    print('🛠️ Seeding support staff and competencies...');
    final supportStaffId = await _createSupportStaff(
      firstName: 'Петр',
      lastName: 'Сергеев',
      phone: '+79991112233',
      email: 'p.sergeev@techservice.com',
      employmentType: 2, // outsourced
      category: 0, // technician
      canMaintainEquipment: true,
      companyName: 'ООО "ТехСервис"',
      createdBy: adminId,
    );
    await _createCompetency(
      competentId: supportStaffId,
      executorType: 1, // supportStaff
      name: 'Обслуживание кардио-тренажеров Matrix',
      level: 3, // master
      verifiedBy: adminId,
      createdBy: adminId,
    );
     await _createCompetency(
      competentId: trainerId,
      executorType: 0, // user
      name: 'Базовое обслуживание силовых тренажеров',
      level: 2, // advanced
      verifiedBy: adminId,
      createdBy: adminId,
    );
    print('   🛠️ Created support staff and competencies.');
    
    print('📖 Seeding recommendation data...');
    await _seedBodyShapeRecommendations(goals, levels);
    await _seedWhtrRefinements(goals);
    print('   📖 Created recommendation data.');
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
        password: 'password', // Default password for load test users
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
    final levels = [
      {'name': 'Новичок', 'description': 'Человек, который никогда не занимался или имел длительный перерыв.'},
      {'name': 'Опытный', 'description': 'Человек, который занимается регулярно от 6 месяцев до 2 лет.'},
      {'name': 'Продвинутый', 'description': 'Человек, который занимается более 2 лет и имеет хорошие силовые показатели.'},
    ];
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

    await _connection.execute('''
      INSERT INTO work_schedules (day_of_week, start_time, end_time, is_day_off) VALUES
      (1, '09:00', '21:00', false),
      (2, '09:00', '21:00', false),
      (3, '09:00', '21:00', false),
      (4, '09:00', '21:00', false),
      (5, '09:00', '21:00', false),
      (6, '10:00', '20:00', false),
      (7, '10:00', '20:00', true)
      ON CONFLICT (day_of_week) DO NOTHING;
    ''');

    final bodyTypes = [
      {'name': 'Эктоморф', 'gender': 'M', 'wrist_max': 17, 'ankle_max': 21},
      {'name': 'Мезоморф', 'gender': 'M', 'wrist_min': 17, 'wrist_max': 20, 'ankle_min': 21, 'ankle_max': 25},
      {'name': 'Эндоморф', 'gender': 'M', 'wrist_min': 20, 'ankle_min': 25},
      {'name': 'Эктоморф', 'gender': 'Ж', 'wrist_max': 15, 'ankle_max': 21},
      {'name': 'Мезоморф', 'gender': 'Ж', 'wrist_min': 15, 'wrist_max': 17, 'ankle_min': 21, 'ankle_max': 25},
      {'name': 'Эндоморф', 'gender': 'Ж', 'wrist_min': 17, 'ankle_min': 25},
    ];
    for (final type in bodyTypes) {
       await _connection.execute(Sql.named('''
        INSERT INTO types_body_build (name, gender, wrist_min, wrist_max, ankle_min, ankle_max)
        VALUES (@name, @gender, @wrist_min, @wrist_max, @ankle_min, @ankle_max)
        ON CONFLICT (name, gender) DO NOTHING;
      '''), parameters: {
        'name': type['name'],
        'gender': type['gender'],
        'wrist_min': type['wrist_min'],
        'wrist_max': type['wrist_max'],
        'ankle_min': type['ankle_min'],
        'ankle_max': type['ankle_max'],
      });
    }
  }

  Future<void> _clearDynamicData() async {
    print('🧹 Clearing all data from cascading tables...');
    // Truncating users will cascade to most related tables.
    // We also truncate the new top-level tables.
    await _connection.execute('TRUNCATE buildings, equipment_items, support_staff, equipment_bookings, body_shape_recommendations, whtr_refinements, users CASCADE');
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
      // Кардиотренажеры (category 0)
      {'name': 'Беговая дорожка', 'category': 0, 'schematic_icon': 'treadmill'},
      {'name': 'Эллиптический тренажер', 'category': 0, 'schematic_icon': 'elliptical'},
      {'name': 'Велотренажер', 'category': 0, 'schematic_icon': 'bike'},
      {'name': 'Степпер', 'category': 0, 'schematic_icon': 'stepper'},
      {'name': 'Гребной тренажер', 'category': 0, 'schematic_icon': 'rower'},
      
      // Силовые тренажеры (category 1)
      {'name': 'Кроссовер', 'category': 1, 'schematic_icon': 'crossover'},
      {'name': 'Тренажер для жима ногами', 'category': 1, 'schematic_icon': 'leg_press'},
      {'name': 'Блок для тяги', 'category': 1, 'schematic_icon': 'pull_block'},
      {'name': 'Хаммер для груди', 'category': 1, 'schematic_icon': 'hammer_chest'},
      {'name': 'Силовая рама', 'category': 1, 'schematic_icon': 'power_rack'},
      {'name': 'Машина Смита', 'category': 1, 'schematic_icon': 'smith_machine'},
      
      // Свободные веса (category 2)
      {'name': 'Гантели', 'category': 2, 'schematic_icon': 'dumbbell'},
      {'name': 'Штанга', 'category': 2, 'schematic_icon': 'barbell'},
      {'name': 'Диски (блины)', 'category': 2, 'schematic_icon': 'plates'},
      {'name': 'Гири', 'category': 2, 'schematic_icon': 'kettlebell'},
      
      // Функциональное оборудование (category 3)
      {'name': 'Петли TRX', 'category': 3, 'schematic_icon': 'trx'},
      {'name': 'Медбол', 'category': 3, 'schematic_icon': 'med_ball'},
      {'name': 'Плиобокс', 'category': 3, 'schematic_icon': 'plyo_box'},
      {'name': 'Скакалка', 'category': 3, 'schematic_icon': 'jump_rope'},
      {'name': 'Боксерский мешок', 'category': 3, 'schematic_icon': 'punching_bag'},

      // Инвентарь для фитнеса и растяжки (category 4)
      {'name': 'Коврик (мат)', 'category': 4, 'schematic_icon': 'mat'},
      {'name': 'Фитбол', 'category': 4, 'schematic_icon': 'fitball'},
      {'name': 'МФР-ролл', 'category': 4, 'schematic_icon': 'foam_roller'},
      {'name': 'Степ для аэробики', 'category': 4, 'schematic_icon': 'aerobic_step'},
    ];
    for (final type in types) {
      await _connection.execute(Sql.named('''
        INSERT INTO equipment_types (name, category, schematic_icon)
        VALUES (@name, @category, @schematic_icon) ON CONFLICT DO NOTHING;
      '''), parameters: type);
    }
    return await _getIdsForTable('equipment_types', keyColumn: 'schematic_icon');
  }

  Future<String> _createEquipmentItem({required String typeId, required String inventoryNumber, required String roomId, String? model, String? manufacturer}) async {
     final result = await _connection.execute(Sql.named('''
      INSERT INTO equipment_items (type_id, inventory_number, room_id, status, model, manufacturer, condition_rating)
      VALUES (@type_id, @inventory_number, @room_id, 0, @model, @manufacturer, 5) RETURNING id;
    '''), parameters: {
      'type_id': typeId, 
      'inventory_number': inventoryNumber, 
      'room_id': roomId,
      'model': model,
      'manufacturer': manufacturer,
      });
    return result.first[0].toString();
  }

  Future<void> _createBooking({required String equipmentItemId, required String bookedById, required Duration startOffset, required Duration endOffset, required String createdBy}) async {
    final now = DateTime.now();
    await _connection.execute(Sql.named('''
      INSERT INTO equipment_bookings (equipment_item_id, booked_by, start_time, end_time, purpose, created_by, updated_by)
      VALUES (@item_id, @user_id, @start, @end, 'Демо-бронирование', @created_by, @created_by)
    '''), parameters: {
      'item_id': equipmentItemId,
      'user_id': bookedById,
      'start': now.add(startOffset),
      'end': now.add(endOffset),
      'created_by': createdBy,
    });
  }

  Future<String> _createSupportStaff({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    required int employmentType,
    required int category,
    required bool canMaintainEquipment,
    String? companyName,
    required String createdBy,
  }) async {
    final result = await _connection.execute(Sql.named('''
      INSERT INTO support_staff (first_name, last_name, phone, email, employment_type, category, can_maintain_equipment, company_name, created_by, updated_by)
      VALUES (@first_name, @last_name, @phone, @email, @employment_type, @category, @can_maintain, @company_name, @created_by, @created_by)
      RETURNING id;
    '''), parameters: {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'employment_type': employmentType,
      'category': category,
      'can_maintain': canMaintainEquipment,
      'company_name': companyName,
      'created_by': createdBy,
    });
    return result.first[0].toString();
  }

  Future<void> _createCompetency({
    required String competentId,
    required int executorType,
    required String name,
    required int level,
    required String createdBy,
    String? verifiedBy,
  }) async {
    await _connection.execute(Sql.named('''
      INSERT INTO competencies (competent_id, executor_type, name, level, verified_at, verified_by, created_by, updated_by)
      VALUES (@competent_id, @executor_type, @name, @level, @verified_at, @verified_by, @created_by, @created_by)
      ON CONFLICT (competent_id, executor_type, name) DO NOTHING;
    '''), parameters: {
      'competent_id': competentId,
      'executor_type': executorType,
      'name': name,
      'level': level,
      'verified_at': DateTime.now(),
      'verified_by': verifiedBy ?? createdBy,
      'created_by': createdBy,
    });
  }

  // Existing methods
  Future<String> _createUser({required String login, required String firstName, required String lastName, String? phone, int gender = 0, required String password}) async {
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    final result = await _connection.execute(Sql.named('''
      INSERT INTO users (login, password_hash, email, first_name, last_name, gender, date_of_birth, phone)
      VALUES (@login, @hash, @email, @first, @last, @gender, @dob, @phone)
      RETURNING id
      '''), parameters: {'login': phone ?? login, 'hash': passwordHash, 'email': login, 'first': firstName, 'last': lastName, 'gender': gender, 'dob': _faker.date.dateTime(minYear: 1970, maxYear: 2004), 'phone': phone});
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
    final managerIdColumn = '${tableName.split('_').first}_id';
    await _connection.execute(Sql.named('INSERT INTO $tableName ($managerIdColumn, $roleIdColumn) VALUES (@manager_id, @subordinate_id)'), parameters: {'manager_id': managerId, 'subordinate_id': subordinateId});
  }

  Future<Map<String, String>> _getIdsForTable(String tableName, {String idColumn = 'id', required String keyColumn}) async {
    final results = await _connection.execute('SELECT $idColumn, $keyColumn FROM $tableName');
    return {for (var row in results) row[1] as String: row[0].toString()};
  }
  
  Future<void> _seedBodyShapeRecommendations(Map<String, String> goals, Map<String, String> levels) async {
    print('   -> Seeding body shape recommendations...');
    final recommendations = [
      // --- Яблоко ---
      {'body_type': 'Яблоко', 'goal': 'Снижение веса и оздоровление', 'level': 'Новичок', 'trainer': 'Акцент на снижение висцерального жира. Кардио 3-4 р/нед, 30-40 мин (ЧСС 60-70%). Силовые 2-3 р/нед, Full-body. Избегать скручиваний с весом.', 'client': 'Ваша цель - похудение. Сосредоточьтесь на кардио (ходьба, эллипс) и силовых на все тело. Ешьте меньше сладкого и жирного.'},
      {'body_type': 'Яблоко', 'goal': 'Снижение веса и оздоровление', 'level': 'Опытный', 'trainer': 'Увеличение интенсивности. Добавить 1-2 HIIT сессии в неделю. Силовые 3 р/нед (сплит верх/низ) с акцентом на ноги и спину для улучшения пропорций.', 'client': 'Добавляем интенсивности! Пробуйте интервальные тренировки и разделите силовые на "верх" и "низ".'},
      {'body_type': 'Яблоко', 'goal': 'Набор мышечной массы и силы', 'level': 'Новичок', 'trainer': 'Создание мышечного корсета. Full-body 3 р/нед. Фокус на тяжелые базовые упр-я (присед, тяга, жим) с идеальной техникой. Укрепление мышц кора без прямой гипертрофии (планки, вакуум).', 'client': 'Начинаем строить мышцы! Фокус на базовых упражнениях (приседания, тяги, жимы). Сильный корсет — ваша основа.'},

      // --- Груша ---
      {'body_type': 'Груша', 'goal': 'Поддержание формы и улучшение рельефа', 'level': 'Опытный', 'trainer': 'Акцент на верхнюю часть тела (плечи, спина) для балансировки пропорций. Многоповторный тренинг на ноги для тонуса без излишнего объема. Умеренное кардио.', 'client': 'Сделаем акцент на плечи и спину, чтобы визуально сбалансировать фигуру. На ноги — больше повторений с меньшим весом.'},
      {'body_type': 'Груша', 'goal': 'Набор мышечной массы и силы', 'level': 'Продвинутый', 'trainer': 'Построение атлетичного верха. Приоритет на тяжелые веса для верха. Ноги - плиометрика, интервальные сеты. Комбинация HIIT и LISS кардио.', 'client': 'Стройте сильный верх. На ноги используйте прыжковые и интервальные упражнения. Строгий контроль диеты.'},
      {'body_type': 'Груша', 'goal': 'Снижение веса и оздоровление', 'level': 'Новичок', 'trainer': 'Сжигание жира с акцентом на ноги. Круговые тренировки 3 р/нед. Включить кардио после силовой. Профицит калорий минимальный.', 'client': 'Худеем и строим тело! Круговые тренировки помогут сжечь максимум калорий. Акцент на упражнения для ног.'},

      // --- Прямоугольник ---
      {'body_type': 'Прямоугольник', 'goal': 'Набор мышечной массы и силы', 'level': 'Новичок', 'trainer': 'Задача - создать изгибы. Акцент на широчайшие, дельты, ягодицы и бедра. Избегать прямой нагрузки на косые мышцы живота. Базовые упражнения: приседания, тяги, жимы.', 'client': 'Будем работать над созданием талии! Основное внимание — на развитие плеч, спины и ног, чтобы визуально сузить талию.'},
      {'body_type': 'Прямоугольник', 'goal': 'Поддержание формы и улучшение рельефа', 'level': 'Продвинутый', 'trainer': 'Детализация. Изолирующие упражнения на средние дельты, верх широчайших. Упражнения на кор с контролем вовлечения косых. Дроп-сеты, суперсеты.', 'client': 'Время отточить детали! Будем "лепить" фигуру с помощью изолирующих упражнений на плечи и спину.'},
       {'body_type': 'Прямоугольник', 'goal': 'Снижение веса и оздоровление', 'level': 'Опытный', 'trainer': 'Интенсивные full-body или круговые тренировки 3-4 р/нед. Добавить метаболические кондиционные сессии (сани, берпи). Контроль калорий.', 'client': 'Для похудения вам отлично подойдут интенсивные тренировки на все тело. Будет тяжело, но эффективно!'},
      
      // --- Песочные часы ---
      {'body_type': 'Песочные часы', 'goal': 'Поддержание формы и улучшение рельефа', 'level': 'Опытный', 'trainer': 'Пропорциональная проработка всех мышечных групп. Full-body тренировки 3 раза в неделю или сбалансированный сплит. Важно не нарушить пропорции.', 'client': 'У вас сбалансированная фигура, наша задача - поддерживать ее в тонусе. Тренируем все тело равномерно.'},
      {'body_type': 'Песочные часы', 'goal': 'Развитие общей выносливости', 'level': 'Новичок', 'trainer': 'Фокус на кардио-респираторную систему. Круговые тренировки с чередованием кардио и силовых станций. 2-3 раза в неделю. Контроль ЧСС.', 'client': 'Начинаем развивать выносливость. Вас ждут круговые тренировки, которые сочетают в себе и кардио, и силовые упражнения.'},
      {'body_type': 'Песочные часы', 'goal': 'Набор мышечной массы и силы', 'level': 'Новичок', 'trainer': 'Пропорциональное увеличение силы. Программа на основе базовых упражнений (присед, жим, тяга) с правильной техникой. 3 р/нед, full-body. Прогрессивная нагрузка.', 'client': 'Ваша фигура идеальна для силовых видов спорта. Начнем с основ: учим технику приседаний, жимов и тяг и плавно увеличиваем вес.'},

      // --- Перевернутый треугольник ---
      {'body_type': 'Перевернутый треугольник', 'goal': 'Набор мышечной массы и силы', 'level': 'Новичок', 'trainer': 'Начинаем с базы. Акцент на ноги: приседания с собственным весом/легким весом, выпады, гиперэкстензия. Верх тела - базовые тяги и жимы для общего тонуса, без акцента на ширину.', 'client': 'Ваша главная задача - научиться правильно приседать и делать выпады. Это основа для развития ног и создания гармоничной фигуры.'},
      {'body_type': 'Перевернутый треугольник', 'goal': 'Набор мышечной массы и силы', 'level': 'Опытный', 'trainer': 'Акцент на развитие ног и ягодиц для гармонизации пропорций. Тяжелые приседания, выпады, ягодичный мост. Верх тела - поддерживающий, многоповторный режим.', 'client': 'Ваш фокус — ноги и ягодицы, чтобы сбалансировать широкие плечи. Готовьтесь к приседаниям и выпадам!'},
      {'body_type': 'Перевернутый треугольник', 'goal': 'Поддержание формы и улучшение рельефа', 'level': 'Опытный', 'trainer': 'Максимум внимания ногам, минимум - верху. Силовые на ноги 2 р/нед, 1 поддерживающая на верх. Добавить беговое кардио для "сушки" ног.', 'client': 'Продолжаем работать над балансом фигуры. Две тяжелые тренировки на ноги в неделю, и одна легкая на верх тела для тонуса.'},
    ];

     for (final rec in recommendations) {
      await _connection.execute(Sql.named(r'''
        INSERT INTO body_shape_recommendations (body_type, goal_training_id, level_training_id, recommendation_text_trainer, recommendation_text_client)
        VALUES (@body_type, @goal_id, @level_id, @trainer_text, @client_text)
        ON CONFLICT (body_type, goal_training_id, level_training_id) DO NOTHING;
      '''), parameters: {
        'body_type': rec['body_type'],
        'goal_id': goals[rec['goal']],
        'level_id': levels[rec['level']],
        'trainer_text': rec['trainer'],
        'client_text': rec['client'],
      });
    }
  }

  Future<void> _seedWhtrRefinements(Map<String, String> goals) async {
    print('   -> Seeding WHtR refinements...');
    final refinements = [
      {'gradation': 'Высокий риск ожирения', 'goal': 'Снижение веса и оздоровление', 'client': 'Уточнение по здоровью: Ваш приоритет — здоровье. Начните с ходьбы и простых упражнений, чтобы сердце и суставы привыкли к нагрузке. Каждый шаг важен!', 'trainer': 'Уточнение по WHtR (Высокий риск): Задача - безопасно ввести клиента в процесс. Строгий контроль ЧСС (не выше 60-70% от макс.). Избегать ударных и осевых нагрузок.'},
      {'gradation': 'Норма', 'goal': 'Поддержание формы и улучшение рельефа', 'client': 'Уточнение по здоровью: Отличная форма! Ваша цель — отточить детали. Можете работать над "проблемными" зонами или просто поддерживать результат.', 'trainer': 'Уточнение по WHtR (Норма): Клиент готов к любым видам нагрузок. Можно применять продвинутые методики: суперсеты, дроп-сеты, круговые.'},
    ];

    for (final ref in refinements) {
       await _connection.execute(Sql.named(r'''
        INSERT INTO whtr_refinements (whtr_gradation, goal_training_id, refinement_text_client, refinement_text_trainer)
        VALUES (@gradation, @goal_id, @client_text, @trainer_text)
        ON CONFLICT (whtr_gradation, goal_training_id) DO NOTHING;
      '''), parameters: {
        'gradation': ref['gradation'],
        'goal_id': goals[ref['goal']],
        'client_text': ref['client'],
        'trainer_text': ref['trainer'],
      });
    }
  }
}
