import 'package:postgres/postgres.dart';

class InfrastructureSeeder {
  InfrastructureSeeder(this._connection);
  final Connection _connection;

  Future<String> createBuilding({required String name, required String address}) async {
    final result = await _connection.execute(Sql.named('''
      INSERT INTO buildings (name, address) VALUES (@name, @address) RETURNING id;
    '''), parameters: {'name': name, 'address': address});
    return result.first[0].toString();
  }

  Future<String> createRoom({required String name, required String buildingId, required int type, required int floor}) async {
    final result = await _connection.execute(Sql.named('''
      INSERT INTO rooms (name, building_id, type, floor) VALUES (@name, @buildingId, @type, @floor) RETURNING id;
    '''), parameters: {'name': name, 'buildingId': buildingId, 'type': type, 'floor': floor});
    return result.first[0].toString();
  }

  Future<Map<String, String>> seedEquipmentTypes() async {
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
      {'name': 'Разгибание ног', 'category': 1, 'schematic_icon': 'leg_extension'},
      {'name': 'Сгибание ног', 'category': 1, 'schematic_icon': 'leg_curl'},
      {'name': 'Сведение/разведение ног', 'category': 1, 'schematic_icon': 'adductor_abductor'},
      {'name': 'Верхняя тяга (Lat Pulldown)', 'category': 1, 'schematic_icon': 'lat_pulldown'},
      {'name': 'Горизонтальная тяга', 'category': 1, 'schematic_icon': 'seated_row'},
      {'name': 'Жим от груди', 'category': 1, 'schematic_icon': 'chest_press'},
      {'name': 'Бабочка (Pec Deck)', 'category': 1, 'schematic_icon': 'pec_deck'},
      {'name': 'Жим на плечи', 'category': 1, 'schematic_icon': 'shoulder_press'},
      {'name': 'Хаммер для груди', 'category': 1, 'schematic_icon': 'hammer_chest'},
      {'name': 'Силовая рама', 'category': 1, 'schematic_icon': 'power_rack'},
      {'name': 'Машина Смита', 'category': 1, 'schematic_icon': 'smith_machine'},
      
      // Свободные веса (category 2)
      {'name': 'Гантели', 'category': 2, 'schematic_icon': 'dumbbell'},
      {'name': 'Штанга', 'category': 2, 'schematic_icon': 'barbell'},
      {'name': 'EZ-гриф', 'category': 2, 'schematic_icon': 'ez_bar'},
      {'name': 'Диски (блины)', 'category': 2, 'schematic_icon': 'plates'},
      {'name': 'Гири', 'category': 2, 'schematic_icon': 'kettlebell'},
      
      // Функциональное оборудование (category 3)
      {'name': 'Петли TRX', 'category': 3, 'schematic_icon': 'trx'},
      {'name': 'Медбол', 'category': 3, 'schematic_icon': 'med_ball'},
      {'name': 'Плиобокс', 'category': 3, 'schematic_icon': 'plyo_box'},
      {'name': 'Скакалка', 'category': 3, 'schematic_icon': 'jump_rope'},
      {'name': 'Боксерский мешок', 'category': 3, 'schematic_icon': 'punching_bag'},

      // Аксессуары (category 4)
      {'name': 'Коврик (мат)', 'category': 4, 'schematic_icon': 'mat'},
      {'name': 'Фитбол', 'category': 4, 'schematic_icon': 'fitball'},
      {'name': 'МФР-ролл', 'category': 4, 'schematic_icon': 'foam_roller'},
      {'name': 'Степ для аэробики', 'category': 4, 'schematic_icon': 'aerobic_step'},
      {'name': 'Скамья регулируемая', 'category': 4, 'schematic_icon': 'adjustable_bench'},
      {'name': 'Скамья для жима', 'category': 4, 'schematic_icon': 'flat_bench'},
    ];
    for (final type in types) {
      await _connection.execute(Sql.named('''
        INSERT INTO equipment_types (name, category, schematic_icon)
        VALUES (@name, @category, @schematic_icon)
        ON CONFLICT (name) DO UPDATE SET
          category = EXCLUDED.category,
          schematic_icon = EXCLUDED.schematic_icon;
      '''), parameters: type);
    }
    return await getIdsForTable('equipment_types', keyColumn: 'schematic_icon');
  }

  Future<String> createEquipmentItem({required String typeId, required String inventoryNumber, required String roomId, String? model, String? manufacturer}) async {
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

  Future<void> createBooking({required String equipmentItemId, required String bookedById, required Duration startOffset, required Duration endOffset, required String createdBy}) async {
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

  Future<void> seedRepairTimeStandards(Map<String, String> equipmentTypeIds, String adminId) async {
    print('   -> Seeding repair time standards...');
    final standards = [
      {'name': 'Замена бегового полотна', 'equipmentTypeId': equipmentTypeIds['treadmill'], 'duration': 4.0, 'complexity': 1, 'description': 'Полная замена изношенного бегового полотна на новое.'},
      {'name': 'Диагностика и смазка', 'equipmentTypeId': equipmentTypeIds['treadmill'], 'duration': 1.0, 'complexity': 0, 'description': 'Плановая проверка, чистка и смазка движущихся частей беговой дорожки.'},
      {'name': 'Замена педалей', 'equipmentTypeId': equipmentTypeIds['bike'], 'duration': 0.5, 'complexity': 0},
      {'name': 'Замена троса', 'equipmentTypeId': equipmentTypeIds['crossover'], 'duration': 2.5, 'complexity': 2, 'description': 'Полная замена одного из тросов силового тренажера. Требует частичной разборки.'},
      {'name': 'Перепрошивка консоли', 'equipmentTypeId': equipmentTypeIds['elliptical'], 'duration': 1.5, 'complexity': 1},
    ];

    for (final standard in standards) {
      await _connection.execute(
        Sql.named(r'''
        INSERT INTO repair_time_standards (name, equipment_type_id, standard_duration_hours, complexity, description, created_by, updated_by)
        VALUES (@name, @typeId, @duration, @complexity, @description, @createdBy, @updatedBy)
        ON CONFLICT (name, equipment_type_id) DO NOTHING;
      '''),
        parameters: {
          'name': standard['name'],
          'typeId': standard['equipmentTypeId'],
          'duration': standard['duration'],
          'complexity': standard['complexity'],
          'description': standard['description'],
          'createdBy': adminId,
          'updatedBy': adminId,
        },
      );
    }
    print('   ✅ Seeded ${standards.length} repair time standards.');
  }
  
  Future<Map<String, String>> getIdsForTable(String tableName, {String idColumn = 'id', required String keyColumn}) async {
    final results = await _connection.execute('SELECT $idColumn, $keyColumn FROM $tableName');
    return {for (var row in results) row[1] as String: row[0].toString()};
  }
}
