import 'dart:io';
import 'dart:math';

import 'package:faker_dart/faker_dart.dart';
import 'package:postgres/postgres.dart';
import 'package:fitman_backend/config/app_config.dart';

import 'group_seeder.dart';
import 'infrastructure_seeder.dart';
import 'recommendation_seeder.dart';
import 'russian_names_provider.dart';
import 'static_data_seeder.dart';
import 'user_seeder.dart';

class DatabaseSeeder {
  late final Connection _connection;
  final Faker _faker = Faker.instance;
  final _random = Random();

  // Seeder helpers
  late final StaticDataSeeder _staticDataSeeder;
  late final UserSeeder _userSeeder;
  late final InfrastructureSeeder _infrastructureSeeder;
  late final RecommendationSeeder _recommendationSeeder;
  late final GroupSeeder _groupSeeder;

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
    
    _faker.setLocale(FakerLocaleType.ru);

    _staticDataSeeder = StaticDataSeeder(_connection);
    _userSeeder = UserSeeder(_connection, _faker);
    _infrastructureSeeder = InfrastructureSeeder(_connection);
    _recommendationSeeder = RecommendationSeeder(_connection);
    _groupSeeder = GroupSeeder(_connection);

    print('📦 Connected to database: ${dbConfig.dbName}');
  }

  Future<void> close() async {
    await _connection.close();
    print('✋ Connection to database closed.');
  }

  Future<void> runDemo() async {
    await _clearDynamicData();
    await _staticDataSeeder.seed();

    print('🏢 Seeding infrastructure (buildings, rooms)...');
    final building1Id = await _infrastructureSeeder.createBuilding(name: 'Главный корпус', address: 'ул. Спортивная, д. 1');
    final building2Id = await _infrastructureSeeder.createBuilding(name: 'Водный комплекс', address: 'ул. Спортивная, д. 1, стр. 2');

    final rooms = {
      'reception': await _infrastructureSeeder.createRoom(name: 'Ресепшен', buildingId: building1Id, type: 9, floor: 1),
      'cardio': await _infrastructureSeeder.createRoom(name: 'Кардио-зона', buildingId: building1Id, type: 1, floor: 2),
      'strength': await _infrastructureSeeder.createRoom(name: 'Силовая зона', buildingId: building1Id, type: 2, floor: 2),
      'group': await _infrastructureSeeder.createRoom(name: 'Зал групповых программ', buildingId: building1Id, type: 0, floor: 3),
      'yoga': await _infrastructureSeeder.createRoom(name: 'Студия йоги', buildingId: building1Id, type: 4, floor: 3),
      'pool': await _infrastructureSeeder.createRoom(name: 'Бассейн 25м', buildingId: building2Id, type: 6, floor: 1),
    };
    print('🏡 Created ${rooms.length} rooms in 2 buildings.');

    print('👥 Seeding users and profiles...');
    final roles = await getIdsForTable('roles', keyColumn: 'name');
    final levels = await getIdsForTable('levels_training', keyColumn: 'name');
    final goals = await getIdsForTable('goals_training', keyColumn: 'name');

    final adminId = await _userSeeder.createUser(login: 'admin@fitman.ru', firstName: 'Админ', lastName: 'Администраторов', phone: '+70000000000', password: 'admin123');
    await _userSeeder.assignRole(adminId, roles['admin']!);
    await _connection.execute(Sql.named('INSERT INTO admin_profiles (user_id) VALUES (@user_id)'), parameters: {'user_id': adminId});
    print('   👤 Created Admin');

    final managerId = await _userSeeder.createUser(login: 'manager@fitman.ru', firstName: 'Менеджер', lastName: 'Менеджеров', phone: '+70000000003', password: 'manager123');
    await _userSeeder.assignRole(managerId, roles['manager']!);
    await _userSeeder.createEmployeeProfile(managerId, specialization: 'Управление', workExperience: 3, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO manager_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': managerId, 'created_by': adminId});
    print('   👤 Created Manager');

    final trainerId = await _userSeeder.createUser(login: 'trainer@fitman.ru', firstName: 'Тренер', lastName: 'Тренеров', phone: '+70000000002', password: 'trainer123');
    await _userSeeder.assignRole(trainerId, roles['trainer']!);
    await _userSeeder.createEmployeeProfile(trainerId, specialization: 'Силовой тренинг', workExperience: 5, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO trainer_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': trainerId, 'created_by': adminId});
    print('   👤 Created Trainer');

    final instructorId = await _userSeeder.createUser(login: 'instructor@fitman.ru', firstName: 'Инструктор', lastName: 'Инструкторова', phone: '+70000000001', gender: 1, password: 'instructor123');
    await _userSeeder.assignRole(instructorId, roles['instructor']!);
    await _userSeeder.createEmployeeProfile(instructorId, specialization: 'Групповые занятия', workExperience: 2, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO instructor_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': instructorId, 'created_by': adminId});
    print('   👤 Created Instructor');

    final clientId = await _userSeeder.createUser(login: 'client@fitman.ru', firstName: 'Клиент', lastName: 'Клиентов', phone: '+70000000004', gender: 0, password: 'client123');
    await _userSeeder.assignRole(clientId, roles['client']!);
    await _connection.execute(Sql.named('''
      INSERT INTO client_profiles (user_id, goal_training_id, level_training_id, created_by)
      VALUES (@user_id, @goal, @level, @created_by)
      '''), parameters: {'user_id': clientId, 'goal': goals['Набор мышечной массы и силы'], 'level': levels['Новичок'], 'created_by': adminId});
    print('   👤 Created Client');

    await _userSeeder.assign(managerId, 'manager_trainers', 'trainer_id', trainerId);
    await _userSeeder.assign(managerId, 'manager_instructors', 'instructor_id', instructorId);
    await _userSeeder.assign(managerId, 'manager_clients', 'client_id', clientId);
    await _userSeeder.assign(instructorId, 'instructor_clients', 'client_id', clientId);
    print('🔗 Created relationships between users');

    print('📖 Seeding recommendation data...');
    await _recommendationSeeder.seedBodyShapeRecommendations(goals, levels);
    await _recommendationSeeder.seedWhtrRefinements(goals);
    print('   📖 Created recommendation data.');
  }

  Future<void> runMediumCenter() async {
    await _clearDynamicData();
    await _staticDataSeeder.seed();

    print('🏢 Seeding infrastructure (buildings, rooms)...');
    final building1Id = await _infrastructureSeeder.createBuilding(name: 'Главный корпус', address: 'ул. Спортивная, д. 1');
    final building2Id = await _infrastructureSeeder.createBuilding(name: 'Водный комплекс', address: 'ул. Спортивная, д. 1, стр. 2');

    final rooms = {
      'reception': await _infrastructureSeeder.createRoom(name: 'Ресепшен', buildingId: building1Id, type: 9, floor: 1),
      'cardio': await _infrastructureSeeder.createRoom(name: 'Кардио-зона', buildingId: building1Id, type: 1, floor: 2),
      'strength': await _infrastructureSeeder.createRoom(name: 'Силовая зона', buildingId: building1Id, type: 2, floor: 2),
      'group': await _infrastructureSeeder.createRoom(name: 'Зал групповых программ', buildingId: building1Id, type: 0, floor: 3),
      'yoga': await _infrastructureSeeder.createRoom(name: 'Студия йоги', buildingId: building1Id, type: 4, floor: 3),
      'pool': await _infrastructureSeeder.createRoom(name: 'Бассейн 25м', buildingId: building2Id, type: 6, floor: 1),
    };
    print('🏡 Created ${rooms.length} rooms in 2 buildings.');
    
    print('🔩 Seeding equipment...');
    final equipmentTypes = await _infrastructureSeeder.seedEquipmentTypes();
    
    // Cardio
    for (var i = 1; i <= 5; i++) { await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['treadmill']!, inventoryNumber: 'ТРЕД-00$i', roomId: rooms['cardio']!); }
    for (var i = 1; i <= 3; i++) { await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['elliptical']!, inventoryNumber: 'ЭЛЛ-00$i', roomId: rooms['cardio']!); }
    for (var i = 1; i <= 2; i++) { await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['bike']!, inventoryNumber: 'ВЕЛО-00$i', roomId: rooms['cardio']!); }
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['rower']!, inventoryNumber: 'ГРЕБ-001', roomId: rooms['cardio']!);
    
    // Strength Machines
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['leg_press']!, inventoryNumber: 'ЖИМ-НОГ-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['leg_extension']!, inventoryNumber: 'РАЗГ-НОГ-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['leg_curl']!, inventoryNumber: 'СГИБ-НОГ-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['lat_pulldown']!, inventoryNumber: 'В-ТЯГА-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['seated_row']!, inventoryNumber: 'Г-ТЯГА-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['chest_press']!, inventoryNumber: 'ЖИМ-ГР-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['shoulder_press']!, inventoryNumber: 'ЖИМ-ПЛ-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['crossover']!, inventoryNumber: 'КРОСС-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['smith_machine']!, inventoryNumber: 'СМИТ-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['power_rack']!, inventoryNumber: 'РАМА-001', roomId: rooms['strength']!);
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['power_rack']!, inventoryNumber: 'РАМА-002', roomId: rooms['strength']!);

    // Benches & Barbells
    for (var i = 1; i <= 4; i++) { await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['adjustable_bench']!, inventoryNumber: 'СКАМ-РЕГ-00$i', roomId: rooms['strength']!); }
    await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['flat_bench']!, inventoryNumber: 'СКАМ-ГОР-001', roomId: rooms['strength']!);
    for (var i = 1; i <= 4; i++) { await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['barbell']!, inventoryNumber: 'ШТАНГА-00$i', roomId: rooms['strength']!); }

    // Free Weights - Dumbbells & Kettlebells
    for (var i = 4; i <= 30; i += 2) {
      final weight = i.toString().padLeft(2, '0');
      await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['dumbbell']!, inventoryNumber: 'ГАН-$weight-01', roomId: rooms['strength']!);
      await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['dumbbell']!, inventoryNumber: 'ГАН-$weight-02', roomId: rooms['strength']!);
    }
    final kettlebellWeights = [8, 12, 16, 20, 24, 32];
    for (final weight in kettlebellWeights) {
      await _infrastructureSeeder.createEquipmentItem(typeId: equipmentTypes['kettlebell']!, inventoryNumber: 'ГИРЯ-$weight', roomId: rooms['strength']!);
    }

    print('🔧 Created a full set of equipment items.');

    print('👥 Seeding users and profiles for a medium center...');
    final roles = await getIdsForTable('roles', keyColumn: 'name');
    final levels = await getIdsForTable('levels_training', keyColumn: 'name');
    final goals = await getIdsForTable('goals_training', keyColumn: 'name');
    final groupTypes = await getIdsForTable('training_group_types', keyColumn: 'name');

    // 1. Create Staff
    final adminId = await _userSeeder.createUser(login: 'admin@fitman.ru', firstName: 'Админ', lastName: 'Администраторов', phone: '+70000000000', password: 'admin123');
    await _userSeeder.assignRole(adminId, roles['admin']!);
    await _connection.execute(Sql.named('INSERT INTO admin_profiles (user_id) VALUES (@user_id)'), parameters: {'user_id': adminId});
    print('   👤 Created Admin');

    // --- Static test users from login screen ---
    final managerId_static = await _userSeeder.createUser(login: 'manager@fitman.ru', firstName: 'Менеджер', lastName: 'Менеджеров', phone: '+70000000003', password: 'manager123');
    await _userSeeder.assignRole(managerId_static, roles['manager']!);
    await _userSeeder.createEmployeeProfile(managerId_static, specialization: 'Управление', workExperience: 3, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO manager_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': managerId_static, 'created_by': adminId});
    print('   👤 Created Manager (static)');

    final trainerId_static = await _userSeeder.createUser(login: 'trainer@fitman.ru', firstName: 'Тренер', lastName: 'Тренеров', phone: '+70000000002', password: 'trainer123');
    await _userSeeder.assignRole(trainerId_static, roles['trainer']!);
    await _userSeeder.createEmployeeProfile(trainerId_static, specialization: 'Силовой тренинг', workExperience: 5, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO trainer_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': trainerId_static, 'created_by': adminId});
    print('   👤 Created Trainer (static)');

    final instructorId_static = await _userSeeder.createUser(login: 'instructor@fitman.ru', firstName: 'Инструктор', lastName: 'Инструкторова', phone: '+70000000001', gender: 1, password: 'instructor123');
    await _userSeeder.assignRole(instructorId_static, roles['instructor']!);
    await _userSeeder.createEmployeeProfile(instructorId_static, specialization: 'Групповые занятия', workExperience: 2, createdBy: adminId);
    await _connection.execute(Sql.named('INSERT INTO instructor_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': instructorId_static, 'created_by': adminId});
    print('   👤 Created Instructor (static)');

    final clientId_static = await _userSeeder.createUser(login: 'client@fitman.ru', firstName: 'Клиент', lastName: 'Клиентов', phone: '+70000000004', gender: 0, password: 'client123');
    await _userSeeder.assignRole(clientId_static, roles['client']!);
    await _connection.execute(Sql.named('''
      INSERT INTO client_profiles (user_id, goal_training_id, level_training_id, created_by)
      VALUES (@user_id, @goal, @level, @created_by)
      '''), parameters: {'user_id': clientId_static, 'goal': goals['Набор мышечной массы и силы'], 'level': levels['Новичок'], 'created_by': adminId});
    print('   👤 Created Client (static)');
    // --- End of static test users ---

    final managerIds = [managerId_static]; // Use the static manager ID for assignments

    final trainerIds = <String>[];
    for (int i = 1; i <= 5; i++) {
      final trainerId = await _userSeeder.createUser(login: 'trainer$i@fitman.ru', firstName: 'Тренер-$i', lastName: 'Наставников', phone: '+700000001${10 + i}', password: 'trainer123');
      await _userSeeder.assignRole(trainerId, roles['trainer']!);
      await _userSeeder.createEmployeeProfile(trainerId, specialization: 'Силовой тренинг', workExperience: i, createdBy: adminId);
      await _connection.execute(Sql.named('INSERT INTO trainer_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': trainerId, 'created_by': adminId});
      trainerIds.add(trainerId);
      print('   👤 Created Trainer $i');
    }

    final instructorIds = <String>[];
    for (int i = 1; i <= 4; i++) {
      final instructorId = await _userSeeder.createUser(login: 'instructor$i@fitman.ru', firstName: 'Инструктор-$i', lastName: 'Проводникова', gender: 1, phone: '+700000002${10 + i}', password: 'instructor123');
      await _userSeeder.assignRole(instructorId, roles['instructor']!);
      await _userSeeder.createEmployeeProfile(instructorId, specialization: 'Групповые программы', workExperience: i, createdBy: adminId);
      await _connection.execute(Sql.named('INSERT INTO instructor_profiles (user_id, created_by) VALUES (@user_id, @created_by)'), parameters: {'user_id': instructorId, 'created_by': adminId});
      instructorIds.add(instructorId);
      print('   👤 Created Instructor $i');
    }

    // 2. Create Clients
    final clientIds = <String>[];
    print('   Creating 100 clients...');
    for (int i = 1; i <= 100; i++) {
            final gender = _random.nextInt(2);
      final isMale = gender == 0;
      final clientId = await _userSeeder.createUser(
        login: 'client$i@fitman.ru',
        firstName: _faker.name.russianFirstName(isMale: isMale),
        lastName: _faker.name.russianLastName(isMale: isMale),
        gender: gender,
        password: 'client123',
        phone: '+7${9000000000 + i}',
      );
      await _userSeeder.assignRole(clientId, roles['client']!);
      await _connection.execute(Sql.named('''
        INSERT INTO client_profiles (user_id, goal_training_id, level_training_id, created_by)
        VALUES (@user_id, @goal, @level, @created_by)
      '''), parameters: {
        'user_id': clientId,
        'goal': goals.values.elementAt(_faker.datatype.number(min: 0, max:goals.length)),
        'level': levels.values.elementAt(_faker.datatype.number(min: 0, max:levels.length)),
        'created_by': adminId,
      });
      clientIds.add(clientId);
      if (i % 20 == 0) stdout.write('.');
    }
    print('');
    print('   Created 100 clients.');
    
    // 3. Seeding support staff and competencies
    print('🛠️ Seeding support staff and competencies...');
    final supportStaffId1 = await _userSeeder.createSupportStaff(firstName: 'Петр', lastName: 'Сергеев', phone: '+79991112233', email: 'p.sergeev@techservice.com', employmentType: 2, category: 0, canMaintainEquipment: true, companyName: 'ООО "ТехСервис"', createdBy: adminId);
    await _userSeeder.createCompetency(competentId: supportStaffId1, executorType: 1, name: 'Обслуживание кардио-тренажеров Matrix', level: 3, verifiedBy: adminId, createdBy: adminId);
    
    final supportStaffId2 = await _userSeeder.createSupportStaff(firstName: 'Иван', lastName: 'Золотов', phone: '+79992223344', email: 'i.zolotov@clean.com', employmentType: 1, category: 1, canMaintainEquipment: false, createdBy: adminId);
    await _userSeeder.createCompetency(competentId: supportStaffId2, executorType: 1, name: 'Уборка помещений', level: 2, verifiedBy: adminId, createdBy: adminId);

    await _userSeeder.createCompetency(competentId: trainerIds[0], executorType: 0, name: 'Базовое обслуживание силовых тренажеров', level: 2, verifiedBy: adminId, createdBy: adminId);
    await _userSeeder.createCompetency(competentId: trainerIds[1], executorType: 0, name: 'TRX-тренировки', level: 3, verifiedBy: adminId, createdBy: adminId);
    await _userSeeder.createCompetency(competentId: instructorIds[0], executorType: 0, name: 'Проведение занятий по Йоге', level: 3, verifiedBy: adminId, createdBy: adminId);
    print('   🛠️ Created support staff and competencies.');

    // 4. Create Training Groups
    print('🤸 Seeding training groups...');
    final yogaGroup = await _groupSeeder.createTrainingGroup(name: 'Утренняя Йога', description: 'Группа для тех, кто хочет начать день с бодрости и гибкости.', trainingGroupTypeId: groupTypes['group']!, primaryTrainerId: trainerIds[0], primaryInstructorId: instructorIds[0], responsibleManagerId: managerIds[0], createdBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: yogaGroup, dayOfWeek: 2, startTime: '08:00', endTime: '09:00');
    await _groupSeeder.createGroupSchedule(groupId: yogaGroup, dayOfWeek: 4, startTime: '08:00', endTime: '09:00');
    print('   🧘 Created Yoga group');

    final strengthGroup = await _groupSeeder.createTrainingGroup(name: 'Силовой Пауэрлифтинг', description: 'Для тех, кто хочет стать сильнее. Работа с большими весами.', trainingGroupTypeId: groupTypes['group']!, primaryTrainerId: trainerIds[1], responsibleManagerId: managerIds[0], createdBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: strengthGroup, dayOfWeek: 1, startTime: '19:00', endTime: '20:30');
    await _groupSeeder.createGroupSchedule(groupId: strengthGroup, dayOfWeek: 3, startTime: '19:00', endTime: '20:30');
    await _groupSeeder.createGroupSchedule(groupId: strengthGroup, dayOfWeek: 5, startTime: '19:00', endTime: '20:30');
    print('   🏋️ Created Powerlifting group');
    
    final crossfitGroup = await _groupSeeder.createTrainingGroup(name: 'CrossFit для всех', description: 'Интенсивные функциональные тренировки.', trainingGroupTypeId: groupTypes['group']!, primaryTrainerId: trainerIds[2], primaryInstructorId: instructorIds[1], responsibleManagerId: managerIds[0], createdBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: crossfitGroup, dayOfWeek: 2, startTime: '18:00', endTime: '19:00');
    await _groupSeeder.createGroupSchedule(groupId: crossfitGroup, dayOfWeek: 4, startTime: '18:00', endTime: '19:00');
    print('   🤸 Created CrossFit group');

    final boxingGroup = await _groupSeeder.createTrainingGroup(name: 'Бокс для начинающих', description: 'Основы бокса, постановка удара и защита.', trainingGroupTypeId: groupTypes['group']!, primaryTrainerId: trainerIds[3], primaryInstructorId: instructorIds[2], responsibleManagerId: managerIds[0], createdBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: boxingGroup, dayOfWeek: 1, startTime: '20:00', endTime: '21:30');
    await _groupSeeder.createGroupSchedule(groupId: boxingGroup, dayOfWeek: 5, startTime: '20:00', endTime: '21:30');
    print('   🥊 Created Boxing group');
    
    final pilatesGroup = await _groupSeeder.createTrainingGroup(name: 'Пилатес', description: 'Укрепление мышечного корсета и улучшение осанки.', trainingGroupTypeId: groupTypes['group']!, primaryTrainerId: trainerIds[4], primaryInstructorId: instructorIds[3], responsibleManagerId: managerIds[0], createdBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: pilatesGroup, dayOfWeek: 3, startTime: '18:00', endTime: '19:00');
    print('   🧘‍♀️ Created Pilates group');

    // 5. Assign members to groups
    print('   Assigning members to groups...');
    // Distribute 80 clients among 5 groups
    for (var i = 0; i < 15; i++) {
      await _groupSeeder.addMemberToTrainingGroup(groupId: yogaGroup, userId: clientIds[i], addedBy: adminId);
    }
    for (var i = 15; i < 30; i++) {
      await _groupSeeder.addMemberToTrainingGroup(groupId: strengthGroup, userId: clientIds[i], addedBy: adminId);
    }
    for (var i = 30; i < 50; i++) {
      await _groupSeeder.addMemberToTrainingGroup(groupId: crossfitGroup, userId: clientIds[i], addedBy: adminId);
    }
    for (var i = 50; i < 65; i++) {
      await _groupSeeder.addMemberToTrainingGroup(groupId: boxingGroup, userId: clientIds[i], addedBy: adminId);
    }
    for (var i = 65; i < 80; i++) {
      await _groupSeeder.addMemberToTrainingGroup(groupId: pilatesGroup, userId: clientIds[i], addedBy: adminId);
    }

    // Create semi-personal groups
    final semiPersonal1 = await _groupSeeder.createTrainingGroup(name: 'Полуперсональная 1', description: 'Тренировка для двоих', trainingGroupTypeId: groupTypes['semi_personal']!, primaryTrainerId: trainerIds[0], createdBy: adminId, maxParticipants: 2);
    await _groupSeeder.addMemberToTrainingGroup(groupId: semiPersonal1, userId: clientIds[80], addedBy: adminId);
    await _groupSeeder.addMemberToTrainingGroup(groupId: semiPersonal1, userId: clientIds[81], addedBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: semiPersonal1, dayOfWeek: 1, startTime: '10:00', endTime: '11:00');

    final semiPersonal2 = await _groupSeeder.createTrainingGroup(name: 'Полуперсональная 2', description: 'Тренировка для двоих', trainingGroupTypeId: groupTypes['semi_personal']!, primaryTrainerId: trainerIds[1], createdBy: adminId, maxParticipants: 2);
    await _groupSeeder.addMemberToTrainingGroup(groupId: semiPersonal2, userId: clientIds[82], addedBy: adminId);
    await _groupSeeder.addMemberToTrainingGroup(groupId: semiPersonal2, userId: clientIds[83], addedBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: semiPersonal2, dayOfWeek: 2, startTime: '11:00', endTime: '12:00');

    // Create individual groups
    final individual1 = await _groupSeeder.createTrainingGroup(name: 'Индивидуальная 1', description: 'Персональная тренировка', trainingGroupTypeId: groupTypes['individual']!, primaryTrainerId: trainerIds[2], createdBy: adminId, maxParticipants: 1);
    await _groupSeeder.addMemberToTrainingGroup(groupId: individual1, userId: clientIds[84], addedBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: individual1, dayOfWeek: 3, startTime: '14:00', endTime: '15:00');

    final individual2 = await _groupSeeder.createTrainingGroup(name: 'Индивидуальная 2', description: 'Персональная тренировка', trainingGroupTypeId: groupTypes['individual']!, primaryTrainerId: trainerIds[3], createdBy: adminId, maxParticipants: 1);
    await _groupSeeder.addMemberToTrainingGroup(groupId: individual2, userId: clientIds[85], addedBy: adminId);
    await _groupSeeder.createGroupSchedule(groupId: individual2, dayOfWeek: 4, startTime: '15:00', endTime: '16:00');

    print('   ✅ Members assigned.');
  }

  Future<void> runLoadTest({int userCount = 100}) async {
    await _clearDynamicData();
    await _staticDataSeeder.seed();
    print('Generating $userCount users...');
    for (int i = 0; i < userCount; i++) {
      final gender = _random.nextInt(2);
      final isMale = gender == 0;
      await _userSeeder.createUser(
        login: _faker.internet.email(),
        firstName: _faker.name.russianFirstName(isMale: isMale),
        lastName: _faker.name.russianLastName(isMale: isMale),
        gender: gender,
        password: 'password',
      );
      stdout.write('.');
    }
    print('');
    print('$userCount users created.');
  }

  Future<void> _clearDynamicData() async {
    print('🧹 Clearing all data from cascading tables...');
    await _connection.execute('TRUNCATE buildings, equipment_items, support_staff, equipment_bookings, body_shape_recommendations, whtr_refinements, users CASCADE');
  }

  Future<Map<String, String>> getIdsForTable(String tableName, {String idColumn = 'id', required String keyColumn}) async {
    final results = await _connection.execute('SELECT $idColumn, $keyColumn FROM $tableName');
    return {for (var row in results) row[1] as String: row[0].toString()};
  }
}
