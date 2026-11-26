import 'package:postgres/postgres.dart';
import 'package:fitman_backend/logging/app_logger.dart';

class StaticDataSeeder {
  StaticDataSeeder(this._connection);
  final Connection _connection;

  Future<void> seed() async {
    appLog.info('🌱 Seeding static data (roles, levels, goals)...');
    await _seedRoles();
    await _seedTrainingLevels();
    await _seedTrainingGoals();
    await _seedTrainingGroupTypes();
    await _seedWorkSchedules();
    await _seedBodyBuildTypes();
    await _seedServiceTypes();
    await _seedSpecializations();
  }

  Future<void> _seedRoles() => _connection.execute('''
    INSERT INTO roles (name, title) VALUES
      ('client', 'Клиент'), ('instructor', 'Инструктор'), ('trainer', 'Тренер'),
      ('manager', 'Менеджер'), ('admin', 'Администратор'),
      ('executor', 'Исполнитель услуг')
    ON CONFLICT (name) DO NOTHING;
  ''');

  Future<void> _seedTrainingLevels() async {
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
  }

  Future<void> _seedTrainingGoals() => _connection.execute('''
    INSERT INTO goals_training (name) VALUES
      ('Снижение веса и оздоровление'), ('Набор мышечной массы и силы'),
      ('Поддержание формы и улучшение рельефа'), ('Развитие общей выносливости'),
      ('Увеличение гибкости и мобильности')
    ON CONFLICT (name) DO NOTHING;
  ''');

  Future<void> _seedTrainingGroupTypes() => _connection.execute('''
    INSERT INTO training_group_types (name, title, min_participants, max_participants) VALUES
      ('individual', 'Индивид.', 1, 1),
      ('semi_personal', 'Полуперсон.', 2, 2),
      ('group', 'Группа', 4, 50)
    ON CONFLICT (name) DO NOTHING;
  ''');

  Future<void> _seedWorkSchedules() => _connection.execute('''
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

  /// Справочник типов услуг. Дублирует сиды миграции 0003: очистка
  /// пользовательских данных каскадом сносит каталог (created_by → users),
  /// поэтому сидер обязан восстановить его самостоятельно.
  Future<void> _seedServiceTypes() => _connection.execute('''
    INSERT INTO service_types (code, title) VALUES
      ('club_membership',    'Клубная карта (полный доступ)'),
      ('zone_membership',    'Абонемент на зону'),
      ('limited_membership', 'Лимитированный абонемент'),
      ('group_membership',   'Абонемент на групповые занятия'),
      ('day_membership',     'Дневной / утренний абонемент'),
      ('single_visit',       'Разовое посещение'),
      ('guest_pass',         'Гостевой визит'),
      ('trial',              'Пробное посещение'),
      ('single_training',    'Персональная разовая тренировка'),
      ('training_package',   'Пакет персональных тренировок'),
      ('group_course',       'Курс групповых занятий'),
      ('studio_service',     'Студийная услуга с исполнителем'),
      ('studio_package',     'Пакет процедур'),
      ('program_design',     'Составление программы тренировок'),
      ('freeze_package',     'Пакет заморозки'),
      ('service_fee',        'Сервисный сбор'),
      ('gift_certificate',   'Подарочный сертификат'),
      ('gift_card',          'Подарочная карта'),
      ('medical_test',       'Взятие анализов, обследование')
    ON CONFLICT (code) DO NOTHING;
  ''');

  Future<void> _seedSpecializations() => _connection.execute('''
    INSERT INTO specializations (code, title, is_medical) VALUES
      ('massage',          'Массаж', false),
      ('spa',              'СПА-процедуры', false),
      ('cosmetology',      'Косметология', false),
      ('solarium',         'Солярий', false),
      ('lfk',              'ЛФК', true),
      ('nutrition',        'Консультация по питанию', false),
      ('group_instructor', 'Инструктор групповых программ', false),
      ('personal_trainer', 'Персональный тренер', false),
      ('physician',        'Врач', true),
      ('nurse',            'Медсестра', true)
    ON CONFLICT (code) DO NOTHING;
  ''');

  Future<void> _seedBodyBuildTypes() async {
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
}
