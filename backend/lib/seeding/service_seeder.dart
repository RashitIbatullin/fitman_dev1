import 'package:postgres/postgres.dart';

import 'package:fitman_backend/logging/app_logger.dart';

import 'user_seeder.dart';

/// Сидирование домена услуг: студийные услуги, исполнители и их инфраструктура.
///
/// Каталог услуг переживает очистку пользовательских данных, поэтому услуги
/// вставляются через `ON CONFLICT (code) DO NOTHING`. Комнаты и зоны удаляются
/// каскадом вместе со зданиями и создаются заново.
class ServiceSeeder {
  ServiceSeeder(this._connection, this._userSeeder);

  final Connection _connection;
  final UserSeeder _userSeeder;

  /// Создаёт двух исполнителей (массажист, косметолог), кабинеты и зоны,
  /// а также студийные услуги под их специализации.
  Future<void> seedStudioDirection({
    required String buildingId,
    required String createdBy,
  }) async {
    final massageRoomId = await _createRoom(
      name: 'Кабинет массажа',
      buildingId: buildingId,
      floor: 2,
    );
    final beautyRoomId = await _createRoom(
      name: 'Кабинет косметологии',
      buildingId: buildingId,
      floor: 3,
    );
    await _createZone(name: 'СПА-зона', roomId: massageRoomId);
    await _createZone(name: 'Косметология', roomId: beautyRoomId);

    final roles = await _idsByKey('roles', keyColumn: 'name');
    final executorRoleId = roles['executor'];
    if (executorRoleId == null) {
      throw StateError(
        'Роль executor не найдена: примените миграцию 0003_services.sql',
      );
    }

    final massageId = await _ensureSpecialization('massage', 'Массаж');
    final spaId = await _ensureSpecialization('spa', 'СПА-процедуры');
    final cosmetologyId =
        await _ensureSpecialization('cosmetology', 'Косметология');

    final massageTherapistId = await _createExecutor(
      email: 'massage@fitman.ru',
      firstName: 'Анна',
      lastName: 'Массажистова',
      phone: '+70000000005',
      gender: 1,
      specializationTitle: 'Массаж',
      workExperience: 7,
      password: 'massage123',
      createdBy: createdBy,
      executorRoleId: executorRoleId,
      specializationLevels: {massageId: 3, spaId: 2},
    );
    appLog.info('   💆 Created massage therapist');

    final cosmetologistId = await _createExecutor(
      email: 'cosmetology@fitman.ru',
      firstName: 'Ольга',
      lastName: 'Косметологова',
      phone: '+70000000006',
      gender: 1,
      specializationTitle: 'Косметология',
      workExperience: 5,
      password: 'cosmetic123',
      createdBy: createdBy,
      executorRoleId: executorRoleId,
      specializationLevels: {cosmetologyId: 2, spaId: 1},
    );
    appLog.info('   💅 Created cosmetologist');

    await _upsertService(
      code: 'MS-030',
      name: 'Массаж 30 минут',
      description: 'Короткий сеанс массажа спины и шеи.',
      serviceTypeCode: 'studio_service',
      specializationId: massageId,
      basePrice: 1500,
      durationDays: 180,
      durationMinutes: 30,
      createdBy: createdBy,
    );
    await _upsertService(
      code: 'MS-060',
      name: 'Массаж 60 минут',
      description: 'Общий массаж тела, снимает мышечное напряжение.',
      serviceTypeCode: 'studio_service',
      specializationId: massageId,
      basePrice: 2500,
      durationDays: 180,
      durationMinutes: 60,
      createdBy: createdBy,
    );
    await _upsertService(
      code: 'SPA-090',
      name: 'СПА-программа',
      description: 'Скраб, обёртывание и массаж, 90 минут.',
      serviceTypeCode: 'studio_service',
      specializationId: spaId,
      basePrice: 4000,
      durationDays: 180,
      durationMinutes: 90,
      createdBy: createdBy,
    );
    await _upsertService(
      code: 'CS-060',
      name: 'Косметология: чистка лица',
      description: 'Ультразвуковая чистка и уход по типу кожи.',
      serviceTypeCode: 'studio_service',
      specializationId: cosmetologyId,
      basePrice: 3500,
      durationDays: 180,
      durationMinutes: 60,
      createdBy: createdBy,
    );
    await _upsertService(
      code: 'PT-010',
      name: 'Пакет тренировок 10',
      description: 'Десять персональных тренировок с тренером.',
      serviceTypeCode: 'training_package',
      basePrice: 20000,
      durationDays: 90,
      usageLimitMode: 1,
      maxUses: 10,
      grantsAccess: true,
      createdBy: createdBy,
    );
    appLog.info('   📋 Created 5 services');

    final clientId = await _demoClientId();
    final purchases = await _ensureDemoPurchases(
      clientId: clientId,
      soldBy: createdBy,
    );
    await _createDemoAppointments(
      clientId: clientId,
      massageTherapistId: massageTherapistId,
      cosmetologistId: cosmetologistId,
      createdBy: createdBy,
      purchases: purchases,
    );
  }

  /// Демо-покупки клиента: массаж, пакет тренировок и косметология.
  ///
  /// Идемпотентно: создаёт покупки только если у клиента их ещё нет,
  /// затем возвращает карту «код услуги → id покупки» для привязки записей.
  Future<Map<String, String>> _ensureDemoPurchases({
    required String? clientId,
    required String soldBy,
  }) async {
    if (clientId == null) {
      return const {};
    }

    final existing = await _connection.execute(
      Sql.named(
        'SELECT COUNT(*) FROM service_purchases WHERE client_id = @client_id',
      ),
      parameters: {'client_id': clientId},
    );
    final count = existing.first[0] as int;

    if (count == 0) {
      await _insertDemoPurchase(
        clientId: clientId,
        serviceCode: 'MS-060',
        soldBy: soldBy,
        totalUses: 1,
        finalPrice: 2500,
      );
      await _insertDemoPurchase(
        clientId: clientId,
        serviceCode: 'PT-010',
        soldBy: soldBy,
        totalUses: 10,
        finalPrice: 20000,
      );
      await _insertDemoPurchase(
        clientId: clientId,
        serviceCode: 'CS-060',
        soldBy: soldBy,
        totalUses: 1,
        finalPrice: 3500,
      );
      appLog.info('   🎫 Created 3 demo service purchases');
    }

    final rows = await _connection.execute(
      Sql.named('''
        SELECT s.code, p.id
          FROM service_purchases p
          JOIN services s ON s.id = p.service_id
         WHERE p.client_id = @client_id
      '''),
      parameters: {'client_id': clientId},
    );
    return {
      for (final row in rows) row[0].toString(): row[1].toString(),
    };
  }

  Future<void> _insertDemoPurchase({
    required String clientId,
    required String serviceCode,
    required String soldBy,
    required int totalUses,
    required int finalPrice,
  }) async {
    final service = await _serviceSnapshot(serviceCode);
    final now = DateTime.now().toUtc();
    final expiry = service.durationDays == null
        ? null
        : now.add(Duration(days: service.durationDays!));

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO service_purchases (
          client_id, service_id, sold_by,
          purchase_price, discount_percent, discount_amount, final_price,
          payment_status, payment_source, purchase_date,
          activation_date, expiry_date, actual_expiry_date,
          total_uses, used_uses, status, created_by, updated_by
        ) VALUES (
          @client_id, @service_id, @sold_by,
          @price, 0, 0, @price,
          1, 2, @now,
          @now, @expiry, @expiry,
          @total_uses, 0, 1, @sold_by, @sold_by
        )
        RETURNING id
      '''),
      parameters: {
        'client_id': clientId,
        'service_id': service.id,
        'sold_by': soldBy,
        'price': finalPrice,
        'now': now,
        'expiry': expiry,
        'total_uses': totalUses,
      },
    );
    final purchaseId = result.first[0].toString();

    await _connection.execute(
      Sql.named('''
        INSERT INTO purchase_participants (
          purchase_id, client_id, role, created_by
        ) VALUES (@purchase_id, @client_id, 1, @sold_by)
        ON CONFLICT (purchase_id, client_id) DO NOTHING
      '''),
      parameters: {
        'purchase_id': purchaseId,
        'client_id': clientId,
        'sold_by': soldBy,
      },
    );
  }

  /// Две демонстрационные записи: массаж и косметология.
  Future<void> _createDemoAppointments({
    required String? clientId,
    required String massageTherapistId,
    required String cosmetologistId,
    required String createdBy,
    required Map<String, String> purchases,
  }) async {
    if (clientId == null) {
      return;
    }

    final existing = await _connection.execute(
      Sql.named('SELECT COUNT(*) FROM appointments WHERE client_id = @client_id'),
      parameters: {'client_id': clientId},
    );
    if ((existing.first[0] as int) > 0) {
      return;
    }

    final massageService = await _serviceSnapshot('MS-060');
    final cosmetologyService = await _serviceSnapshot('CS-060');

    await _insertAppointment(
      clientId: clientId,
      serviceId: massageService.id,
      executorId: massageTherapistId,
      daysAhead: 1,
      hour: 12,
      description: massageService.description,
      note: 'Просил не звонить, писать в чат',
      purchaseId: purchases['MS-060'],
      createdBy: createdBy,
    );
    await _insertAppointment(
      clientId: clientId,
      serviceId: cosmetologyService.id,
      executorId: cosmetologistId,
      daysAhead: 2,
      hour: 15,
      description: cosmetologyService.description,
      note: 'Аллергия на аромамасла',
      purchaseId: purchases['CS-060'],
      createdBy: createdBy,
    );
    appLog.info('   📅 Created 2 demo appointments');
  }

  Future<void> _insertAppointment({
    required String clientId,
    required String serviceId,
    required String executorId,
    required int daysAhead,
    required int hour,
    required String description,
    required String note,
    String? purchaseId,
    required String createdBy,
  }) async {
    final startAt = DateTime.now().add(Duration(days: daysAhead));
    final slot = DateTime(startAt.year, startAt.month, startAt.day, hour);

    await _connection.execute(
      Sql.named('''
        INSERT INTO appointments (
          client_id, service_id, purchase_id, executor_id, start_at,
          service_description, note, status, created_by, updated_by
        ) VALUES (
          @client_id, @service_id, @purchase_id, @executor_id, @start_at,
          @description, @note, 0, @created_by, @created_by
        )
      '''),
      parameters: {
        'client_id': clientId,
        'service_id': serviceId,
        'purchase_id': purchaseId,
        'executor_id': executorId,
        'start_at': slot,
        'description': description,
        'note': note,
        'created_by': createdBy,
      },
    );
  }

  Future<String> _createExecutor({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required int gender,
    required String specializationTitle,
    required String password,
    required int workExperience,
    required String createdBy,
    required String executorRoleId,
    required Map<String, int> specializationLevels,
  }) async {
    final userId = await _userSeeder.createUser(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      gender: gender,
      password: password,
    );

    await _userSeeder.assignRole(userId, executorRoleId);
    await _userSeeder.createEmployeeProfile(
      userId,
      specialization: specializationTitle,
      workExperience: workExperience,
      createdBy: createdBy,
    );

    for (final entry in specializationLevels.entries) {
      await _connection.execute(
        Sql.named('''
          INSERT INTO employee_specializations (
            employee_id, specialization_id, level, created_by
          ) VALUES (@employee_id, @specialization_id, @level, @created_by)
          ON CONFLICT (employee_id, specialization_id) DO NOTHING
        '''),
        parameters: {
          'employee_id': userId,
          'specialization_id': entry.key,
          'level': entry.value,
          'created_by': createdBy,
        },
      );
    }

    return userId;
  }

  Future<void> _upsertService({
    required String code,
    required String name,
    required String description,
    required String serviceTypeCode,
    String? specializationId,
    required int basePrice,
    required int durationDays,
    int? durationMinutes,
    int usageLimitMode = 1,
    int? maxUses = 1,
    int? quotaPeriod,
    int? quotaLimit,
    bool grantsAccess = false,
    required String createdBy,
  }) async {
    final typeId = await _serviceTypeId(serviceTypeCode);

    await _connection.execute(
      Sql.named('''
        INSERT INTO services (
          code, name, description, service_type_id, base_price,
          duration_days, usage_limit_mode, max_uses,
          quota_period, quota_limit, grants_access,
          executor_specialization_id, duration_minutes, freeze_allowed,
          created_by, updated_by
        ) VALUES (
          @code, @name, @description, @type_id, @base_price,
          @duration_days, @usage_limit_mode, @max_uses,
          @quota_period, @quota_limit, @grants_access,
          @specialization_id, @duration_minutes, false,
          @created_by, @created_by
        )
        ON CONFLICT (code) DO NOTHING
      '''),
      parameters: {
        'code': code,
        'name': name,
        'description': description,
        'type_id': typeId,
        'base_price': basePrice,
        'duration_days': durationDays,
        'usage_limit_mode': usageLimitMode,
        'max_uses': maxUses,
        'quota_period': quotaPeriod,
        'quota_limit': quotaLimit,
        'grants_access': grantsAccess,
        'specialization_id': specializationId,
        'duration_minutes': durationMinutes,
        'created_by': createdBy,
      },
    );
  }

  Future<String> _serviceTypeId(String code) async {
    final id = await _singleId(
      'SELECT id FROM service_types WHERE code = @code',
      {'code': code},
    );
    if (id == null) {
      throw StateError(
        'Тип услуги "$code" не найден: примените миграцию 0003_services.sql',
      );
    }
    return id;
  }

  Future<String> _ensureSpecialization(String code, String title) async {
    final existing = await _singleId(
      'SELECT id FROM specializations WHERE code = @code',
      {'code': code},
    );
    if (existing != null) {
      return existing;
    }

    await _connection.execute(
      Sql.named('''
        INSERT INTO specializations (code, title) VALUES (@code, @title)
        ON CONFLICT (code) DO NOTHING
      '''),
      parameters: {'code': code, 'title': title},
    );

    final created = await _singleId(
      'SELECT id FROM specializations WHERE code = @code',
      {'code': code},
    );
    if (created == null) {
      throw StateError('Не удалось создать специализацию "$code"');
    }
    return created;
  }

  Future<String> _createRoom({
    required String name,
    required String buildingId,
    required int floor,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO rooms (name, building_id, type, floor)
        VALUES (@name, @building_id, 4, @floor)
        RETURNING id
      '''),
      parameters: {'name': name, 'building_id': buildingId, 'floor': floor},
    );
    return result.first[0].toString();
  }

  Future<void> _createZone({required String name, required String roomId}) async {
    final existing = await _singleId(
      'SELECT id FROM access_zones WHERE name = @name',
      {'name': name},
    );
    if (existing != null) {
      return;
    }

    await _connection.execute(
      Sql.named('''
        INSERT INTO access_zones (name, room_id, open_from, open_to)
        VALUES (@name, @room_id, '09:00', '21:00')
      '''),
      parameters: {'name': name, 'room_id': roomId},
    );
  }

  Future<_ServiceSnapshot> _serviceSnapshot(String code) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT id, description, duration_days
          FROM services
         WHERE code = @code
      '''),
      parameters: {'code': code},
    );
    if (result.isEmpty) {
      throw StateError('Услуга "$code" не найдена для демо-записи');
    }
    return _ServiceSnapshot(
      id: result.first[0].toString(),
      description: (result.first[1] as String?) ?? '',
      durationDays: result.first[2] as int?,
    );
  }

  // Логин технический: email, если задан, иначе телефон.
  Future<String?> _demoClientId() => _singleId(
        "SELECT id FROM users WHERE email = 'client@fitman.ru'",
        const {},
      );

  Future<Map<String, String>> _idsByKey(
    String table, {
    required String keyColumn,
  }) async {
    final rows = await _connection.execute('SELECT id, $keyColumn FROM $table');
    return {
      for (final row in rows) row[1] as String: row[0].toString(),
    };
  }

  Future<String?> _singleId(String sql, Map<String, dynamic> parameters) async {
    final result = await _connection.execute(
      Sql.named(sql),
      parameters: parameters,
    );
    if (result.isEmpty) {
      return null;
    }
    return result.first[0].toString();
  }
}

class _ServiceSnapshot {
  const _ServiceSnapshot({
    required this.id,
    required this.description,
    required this.durationDays,
  });

  final String id;
  final String description;
  final int? durationDays;
}


