-- ============================================
-- Файл создания таблиц упражнений, помещений и оборудования
-- для системы "Фитнес-менеджер" (FitMan)
-- ============================================

-- ============================================
-- УДАЛЕНИЕ СУЩЕСТВУЮЩИХ ТАБЛИЦ (если они созданы)
-- ============================================

-- Удаляем в обратном порядке (сначала дочерние таблицы, затем родительские)

-- Таблицы бронирования и оборудования
DROP TABLE IF EXISTS equipment_bookings CASCADE;
DROP TABLE IF EXISTS maintenance_photos CASCADE;
DROP TABLE IF EXISTS equipment_maintenance_history CASCADE;
DROP TABLE IF EXISTS equipment_items CASCADE;

-- Таблицы вспомогательного персонала
DROP TABLE IF EXISTS support_staff_schedules CASCADE;
DROP TABLE IF EXISTS support_staff_competencies CASCADE;
DROP TABLE IF EXISTS support_staff CASCADE;

DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS buildings CASCADE;

-- Таблицы индивидуальных назначений
DROP TABLE IF EXISTS client_exercises CASCADE;
DROP TABLE IF EXISTS client_set_exercises CASCADE;
DROP TABLE IF EXISTS client_training_plans CASCADE;

-- Таблицы формул и рекомендаций
DROP TABLE IF EXISTS bmr_formulas CASCADE;
DROP TABLE IF EXISTS training_recommendations CASCADE;

-- Таблицы связей между планами и наборами упражнений
DROP TABLE IF EXISTS training_plan__templates_set_exercises_templates CASCADE;
DROP TABLE IF EXISTS set_exercises_templates_exercis_templates CASCADE;

-- Основные таблицы планов тренировок
DROP TABLE IF EXISTS training_plan_templates CASCADE;
DROP TABLE IF EXISTS sets_exercises_templates CASCADE;
DROP TABLE IF EXISTS exercises_templates CASCADE;

-- Таблицы типов и видов
DROP TABLE IF EXISTS types_exercis CASCADE;
DROP TABLE IF EXISTS equipment_types CASCADE;
DROP TABLE IF EXISTS kinds_exercis CASCADE;
DROP TABLE IF EXISTS types_body_build CASCADE;
DROP TABLE IF EXISTS goals_training CASCADE;
DROP TABLE IF EXISTS levels_training CASCADE;
DROP TABLE IF EXISTS kinds_activity_client CASCADE;


-- Отключаем проверку внешних ключей для удобства
SET session_replication_role = 'replica';

-- ============================================
-- 1. ТАБЛИЦЫ ДЛЯ УПРАЖНЕНИЙ И ПЛАНОВ ТРЕНИРОВОК
-- ============================================

-- Каталог "Виды активности клиента"
CREATE TABLE kinds_activity_client (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  coeff_activity REAL NOT NULL DEFAULT 1.2,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Каталог "Уровни фитнес-подготовки"
CREATE TABLE levels_training (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Каталог "Цели тренировок"
CREATE TABLE goals_training (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Каталог "Типы телосложения"
CREATE TABLE types_body_build (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  description VARCHAR(200),
  gender VARCHAR(20) NOT NULL, -- 'M', 'Ж', 'ALL'
  wrist_max REAL NOT NULL,
  wrist_min REAL NOT NULL,
  ankle_max REAL NOT NULL,
  ankle_min REAL NOT NULL,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Каталог "Виды Упражнений"
CREATE TABLE kinds_exercis (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Таблица типов оборудования (для связи с упражнениями)
CREATE TABLE equipment_types (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Классификация
  category SMALLINT NOT NULL,      -- EquipmentCategory enum (0:cardio, 1:strength, 2:freeWeights, 3:functional, 4:accessories, 5:measurement, 6:other)
  
  -- Характеристики
  weight_range VARCHAR(50),
  dimensions VARCHAR(100),

  is_mobile BOOLEAN DEFAULT true,
  
    -- Медиа
  

  schematic_icon VARCHAR(50),
    -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT,
  note VARCHAR(100)
);

-- Каталог "Типы Упражнений"
CREATE TABLE types_exercis (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  kind_exercis_id BIGINT REFERENCES kinds_exercis(id),
  equipment_type_id BIGINT REFERENCES equipment_types(id),
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Каталог "Упражнения" (шаблоны)
CREATE TABLE exercises_templates (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  repeat_qty INT,
  duration_exec REAL,  -- Длительность проведения в минутах
  duration_rest REAL,  -- Длительность отдыха после упражнения в минутах
  calories_out REAL,   -- Расход калорий в калориях
  is_group BOOLEAN DEFAULT false,
  type_exercis_id BIGINT REFERENCES types_exercis(id),
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Каталог "Набор упражнений" (шаблоны)
CREATE TABLE sets_exercises_templates (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  level_training_id BIGINT REFERENCES levels_training(id),
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Таблица связи "Набор упражнений - Упражнения"
CREATE TABLE set_exercises_templates_exercis_templates (
  id BIGSERIAL PRIMARY KEY,
  set_exercises_template_id BIGINT NOT NULL REFERENCES sets_exercises_templates(id) ON DELETE CASCADE,
  exercis_template_id BIGINT NOT NULL REFERENCES exercises_templates(id) ON DELETE CASCADE,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  
  UNIQUE(set_exercises_template_id, exercis_template_id)
);

-- Каталог "Планы тренировок" (шаблоны)
CREATE TABLE training_plan_templates (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  goal_training_id BIGINT REFERENCES goals_training(id),
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Таблица связи "Планы тренировок – Наборы упражнений"
CREATE TABLE training_plan__templates_set_exercises_templates (
  id BIGSERIAL PRIMARY KEY,
  training_plan_template_id BIGINT NOT NULL REFERENCES training_plan_templates(id) ON DELETE CASCADE,
  set_exercises_template_id BIGINT NOT NULL REFERENCES sets_exercises_templates(id) ON DELETE CASCADE,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  
  UNIQUE(training_plan_template_id, set_exercises_template_id)
);

-- Таблица рекомендаций по тренировкам
CREATE TABLE training_recommendations (
  id BIGSERIAL PRIMARY KEY,
  body_type VARCHAR(50) NOT NULL,  -- тип фигуры
  goal_training_id BIGINT REFERENCES goals_training(id),
  level_trainig_id BIGINT REFERENCES levels_training(id),
  recommendation_text_trainer TEXT NOT NULL,
  recommendation_text_client TEXT NOT NULL,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Таблица формул расчета BMR
CREATE TABLE bmr_formulas (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  formula TEXT NOT NULL,
  for_men BOOLEAN DEFAULT true,
  for_women BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- ============================================
-- 2. ТАБЛИЦЫ ИНДИВИДУАЛЬНЫХ НАЗНАЧЕНИЙ (клиентские планы)
-- ============================================

-- Индивидуальные планы тренировок клиентов
CREATE TABLE client_training_plans (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  training_plan_template_id BIGINT REFERENCES training_plan_templates(id),
  assigned_by BIGINT REFERENCES users(id),
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  goal VARCHAR(255),
  notes TEXT,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Индивидуальные наборы упражнений клиентов
CREATE TABLE client_set_exercises (
  id BIGSERIAL PRIMARY KEY,
  client_training_plan_id BIGINT NOT NULL REFERENCES client_training_plans(id) ON DELETE CASCADE,
  set_exercise_template_id BIGINT REFERENCES sets_exercises_templates(id),
  order_num INT NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  repeats INT,
  rest_after_set REAL,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Индивидуальные упражнения клиентов
CREATE TABLE client_exercises (
  id BIGSERIAL PRIMARY KEY,
  client_set_exercise_id BIGINT NOT NULL REFERENCES client_set_exercises(id) ON DELETE CASCADE,
  exercise_template_id BIGINT REFERENCES exercises_templates(id),
  order_num INT NOT NULL DEFAULT 0,
  custom_repeat_qty INT,
  custom_duration_exec REAL,
  custom_duration_rest REAL,
  custom_notes TEXT,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- ============================================
-- 4. ТАБЛИЦЫ ВСПОМОГАТЕЛЬНОГО ПЕРСОНАЛА
-- ============================================

-- Основная таблица вспомогательного персонала
CREATE TABLE support_staff (
  id BIGSERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  middle_name VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(255),
  employment_type SMALLINT NOT NULL,
  category SMALLINT NOT NULL,
  can_maintain_equipment BOOLEAN DEFAULT false,
  accessible_equipment_types JSONB,
  company_name VARCHAR(255),
  contract_number VARCHAR(100),
  contract_expiry_date DATE,
  notes TEXT,
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT
);

-- Компетенции вспомогательного персонала
CREATE TABLE support_staff_competencies (
  id BIGSERIAL PRIMARY KEY,
  staff_id BIGINT NOT NULL REFERENCES support_staff(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  level SMALLINT NOT NULL,
  certificate_url TEXT,
  verified_at DATE,
  verified_by BIGINT REFERENCES users(id),
  UNIQUE(staff_id, name)
);

-- Расписание работы
CREATE TABLE support_staff_schedules (
  id BIGSERIAL PRIMARY KEY,
  staff_id BIGINT NOT NULL REFERENCES support_staff(id) ON DELETE CASCADE,
  day_of_week SMALLINT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL
);

-- ============================================
-- 3. ТАБЛИЦЫ ПОМЕЩЕНИЙ И ОБОРУДОВАНИЯ
-- ============================================

-- Здания
CREATE TABLE buildings (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  address TEXT,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT,
  note VARCHAR(100)
);

-- Помещения (залы)
CREATE TABLE rooms (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  room_number VARCHAR(50), -- New field for room/cabinet number
  type SMALLINT NOT NULL,  -- RoomType enum (0:groupHall, 1:cardioZone, 2:strengthZone, 3:mixedZone, 4:studio, 5:boxingRing, 6:pool, 7:lockerRoom, 8:reception, 9:office, 10:other)
  
  -- Локация
  floor INT,
  building_id BIGINT REFERENCES buildings(id),
  
  -- Характеристики
  max_capacity INT NOT NULL DEFAULT 30,
  area DECIMAL(5,2),
  
  -- Расписание доступности
  open_time TIME,
  close_time TIME,
  working_days JSONB,  -- Массив дней недели [1,2,3,4,5,6,7]
  
  -- Статус
  is_active BOOLEAN DEFAULT true,
  deactivate_reason TEXT,
  deactivate_at TIMESTAMPTZ,
  deactivate_by BIGINT REFERENCES users(id),
  
  -- Файлы
  photo_urls JSONB,
  floor_plan_url TEXT,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT,
  note VARCHAR(100)
);
-- Экземпляры оборудования
CREATE TABLE equipment_items (
  id BIGSERIAL PRIMARY KEY,
  
  -- Тип оборудования
  type_id BIGINT NOT NULL REFERENCES equipment_types(id),
  
  -- Идентификация
  inventory_number VARCHAR(50) NOT NULL UNIQUE,
  serial_number VARCHAR(100),
  model VARCHAR(100),
  manufacturer VARCHAR(255),
  
  -- Локация
  room_id BIGINT REFERENCES rooms(id),
  placement_note TEXT,
  
  -- Состояние
  status SMALLINT DEFAULT 0,  -- EquipmentStatus enum (0:available, 1:inUse, 2:reserved, 3:maintenance, 4:outOfOrder, 5:storage)
  condition_rating INT CHECK (condition_rating >= 1 AND condition_rating <= 5),
  condition_notes TEXT,
  
  -- Обслуживание
  last_maintenance_date DATE,
  next_maintenance_date DATE,
  maintenance_notes TEXT,
  
  -- Учёт
  purchase_date DATE,
  purchase_price DECIMAL(10,2),
  supplier VARCHAR(255),
  warranty_months INT,
  
  -- Использование
  usage_hours INT DEFAULT 0,
  last_used_date DATE,
  
  -- Фотографии
  photo_urls JSONB,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT,
  note VARCHAR(100)
);

-- Бронирование оборудования
CREATE TABLE equipment_bookings (
  id BIGSERIAL PRIMARY KEY,
  
  -- Что бронируем
  equipment_item_id BIGINT NOT NULL REFERENCES equipment_items(id),
  
  -- Кто бронирует
  booked_by BIGINT NOT NULL REFERENCES users(id),
  
  -- Время
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  
  -- Контекст
  lesson_id BIGINT,  -- Ссылка будет добавлена позже
  training_group_id BIGINT,  -- Ссылка будет добавлена позже
  purpose VARCHAR(255) NOT NULL,
  
  -- Статус
  status SMALLINT DEFAULT 0,  -- BookingStatus enum
  
  -- Дополнительно
  notes TEXT,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT,
 
  -- Ограничения
  CONSTRAINT valid_booking_time CHECK (end_time > start_time)
);

-- История обслуживания оборудования
CREATE TABLE equipment_maintenance_history (
  id BIGSERIAL PRIMARY KEY,
  equipment_item_id BIGINT NOT NULL REFERENCES equipment_items(id),
  equipment_name VARCHAR(255),
  type SMALLINT NOT NULL,
  status SMALLINT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  equipment_available_from TIMESTAMPTZ,
  reported_problem TEXT NOT NULL,
  work_description TEXT,
  reported_by BIGINT NOT NULL REFERENCES users(id),
  assigned_to_user_id BIGINT REFERENCES users(id),
  assigned_to_staff_id BIGINT REFERENCES support_staff(id),
  related_booking_id BIGINT REFERENCES equipment_bookings(id),
  caused_downtime BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT,
  
  -- Ограничения
  CONSTRAINT assigned_to_check CHECK (
    (assigned_to_user_id IS NULL AND assigned_to_staff_id IS NOT NULL) OR
    (assigned_to_user_id IS NOT NULL AND assigned_to_staff_id IS NULL) OR
    (assigned_to_user_id IS NULL AND assigned_to_staff_id IS NULL)
  )
);

-- Фотографии ТО
CREATE TABLE maintenance_photos (
  id BIGSERIAL PRIMARY KEY,
  maintenance_id BIGINT NOT NULL REFERENCES equipment_maintenance_history(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  comment TEXT,
  timing SMALLINT NOT NULL,
  taken_at TIMESTAMPTZ DEFAULT NOW(),
  taken_by BIGINT REFERENCES users(id)
);


-- ============================================
-- 4. СОЗДАНИЕ ИНДЕКСОВ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- ============================================

-- Индексы для kinds_activity_client
CREATE INDEX idx_kinds_activity_client_name ON kinds_activity_client(name);
CREATE INDEX idx_kinds_activity_client_active ON kinds_activity_client(company_id) WHERE archived_at IS NULL;

-- Индексы для levels_training
CREATE INDEX idx_levels_training_name ON levels_training(name);
CREATE INDEX idx_levels_training_active ON levels_training(company_id) WHERE archived_at IS NULL;

-- Индексы для goals_training
CREATE INDEX idx_goals_training_name ON goals_training(name);
CREATE INDEX idx_goals_training_active ON goals_training(company_id) WHERE archived_at IS NULL;

-- Индексы для types_body_build
CREATE INDEX idx_types_body_build_gender ON types_body_build(gender);
CREATE INDEX idx_types_body_build_active ON types_body_build(company_id) WHERE archived_at IS NULL;

-- Индексы для kinds_exercis
CREATE INDEX idx_kinds_exercis_name ON kinds_exercis(name);
CREATE INDEX idx_kinds_exercis_active ON kinds_exercis(company_id) WHERE archived_at IS NULL;

-- Индексы для equipment_types
CREATE INDEX idx_equipment_types_category ON equipment_types(category);
CREATE INDEX idx_equipment_types_active ON equipment_types(company_id) WHERE archived_at IS NULL;

-- Индексы для types_exercis
CREATE INDEX idx_types_exercis_kind ON types_exercis(kind_exercis_id);
CREATE INDEX idx_types_exercis_equipment ON types_exercis(equipment_type_id);
CREATE INDEX idx_types_exercis_active ON types_exercis(company_id) WHERE archived_at IS NULL;

-- Индексы для exercises_templates
CREATE INDEX idx_exercises_templates_type ON exercises_templates(type_exercis_id);
CREATE INDEX idx_exercises_templates_active ON exercises_templates(company_id) WHERE archived_at IS NULL;

-- Индексы для sets_exercises_templates
CREATE INDEX idx_sets_exercises_templates_level ON sets_exercises_templates(level_training_id);
CREATE INDEX idx_sets_exercises_templates_active ON sets_exercises_templates(company_id) WHERE archived_at IS NULL;

-- Индексы для training_plan_templates
CREATE INDEX idx_training_plan_templates_goal ON training_plan_templates(goal_training_id);
CREATE INDEX idx_training_plan_templates_active ON training_plan_templates(company_id) WHERE archived_at IS NULL;

-- Индексы для training_recommendations
CREATE INDEX idx_training_recommendations_goal ON training_recommendations(goal_training_id);
CREATE INDEX idx_training_recommendations_level ON training_recommendations(level_trainig_id);
CREATE INDEX idx_training_recommendations_body_type ON training_recommendations(body_type);
CREATE INDEX idx_training_recommendations_active ON training_recommendations(company_id) WHERE archived_at IS NULL;

-- Индексы для client_training_plans
CREATE INDEX idx_client_training_plans_user ON client_training_plans(user_id);
CREATE INDEX idx_client_training_plans_template ON client_training_plans(training_plan_template_id);
CREATE INDEX idx_client_training_plans_active ON client_training_plans(company_id) WHERE archived_at IS NULL AND is_active = true;

-- Индексы для client_set_exercises
CREATE INDEX idx_client_set_exercises_plan ON client_set_exercises(client_training_plan_id);
CREATE INDEX idx_client_set_exercises_template ON client_set_exercises(set_exercise_template_id);
CREATE INDEX idx_client_set_exercises_active ON client_set_exercises(company_id) WHERE archived_at IS NULL AND is_active = true;

-- Индексы для client_exercises
CREATE INDEX idx_client_exercises_set ON client_exercises(client_set_exercise_id);
CREATE INDEX idx_client_exercises_template ON client_exercises(exercise_template_id);
CREATE INDEX idx_client_exercises_active ON client_exercises(company_id) WHERE archived_at IS NULL;

-- Индексы для rooms
CREATE INDEX idx_rooms_type ON rooms(type) WHERE is_active = true;
CREATE INDEX idx_rooms_building ON rooms(building_id) WHERE building_id IS NOT NULL;
CREATE INDEX idx_rooms_active ON rooms(company_id) WHERE archived_at IS NULL AND is_active = true;

-- Индексы для buildings
CREATE INDEX idx_buildings_name ON buildings(name);
CREATE INDEX idx_buildings_active ON buildings(company_id) WHERE archived_at IS NULL;


-- Индексы для equipment_items
CREATE INDEX idx_equipment_items_type ON equipment_items(type_id);
CREATE INDEX idx_equipment_items_room ON equipment_items(room_id) WHERE room_id IS NOT NULL;
CREATE INDEX idx_equipment_items_status ON equipment_items(status) WHERE status = 0;
CREATE INDEX idx_equipment_items_inventory ON equipment_items(inventory_number);
CREATE INDEX idx_equipment_items_active ON equipment_items(company_id) WHERE archived_at IS NULL;

-- Индексы для equipment_bookings
CREATE INDEX idx_equipment_bookings_item ON equipment_bookings(equipment_item_id);
CREATE INDEX idx_equipment_bookings_user ON equipment_bookings(booked_by);
CREATE INDEX idx_equipment_bookings_time ON equipment_bookings(equipment_item_id, start_time, end_time) WHERE status IN (0, 1);
CREATE INDEX idx_equipment_bookings_active ON equipment_bookings(company_id) WHERE archived_at IS NULL;
CREATE INDEX idx_equipment_bookings_time_status ON equipment_bookings(equipment_item_id, start_time, end_time, status);

-- Индексы для equipment_maintenance_history
CREATE INDEX idx_maintenance_equipment ON equipment_maintenance_history(equipment_item_id);
CREATE INDEX idx_maintenance_status ON equipment_maintenance_history(status) WHERE archived_at IS NULL;
CREATE INDEX idx_maintenance_assigned_user ON equipment_maintenance_history(assigned_to_user_id) WHERE assigned_to_user_id IS NOT NULL;
CREATE INDEX idx_maintenance_assigned_staff ON equipment_maintenance_history(assigned_to_staff_id) WHERE assigned_to_staff_id IS NOT NULL;

-- Индексы для maintenance_photos
CREATE INDEX idx_maintenance_photos ON maintenance_photos(maintenance_id, timing);

-- Индексы для таблиц связей
CREATE INDEX idx_set_exercises_link_set ON set_exercises_templates_exercis_templates(set_exercises_template_id);
CREATE INDEX idx_set_exercises_link_exercis ON set_exercises_templates_exercis_templates(exercis_template_id);
CREATE INDEX idx_training_plan_link_plan ON training_plan__templates_set_exercises_templates(training_plan_template_id);
CREATE INDEX idx_training_plan_link_set ON training_plan__templates_set_exercises_templates(set_exercises_template_id);

-- ============================================
-- 5. ИНИЦИАЛИЗАЦИЯ НАЧАЛЬНЫМИ ДАННЫМИ
-- ============================================

-- Включаем проверку внешних ключей
SET session_replication_role = 'origin';

-- 5.1. Заполняем виды активности клиента
INSERT INTO kinds_activity_client (name, coeff_activity, note) VALUES
('Сидячий образ жизни (мало или нет физических нагрузок)', 1.2, 'Основной обмен × 1.2'),
('Легкая активность (1-3 тренировки в неделю)', 1.375, 'Основной обмен × 1.375'),
('Средняя активность (3-5 тренировок в неделю)', 1.55, 'Основной обмен × 1.55'),
('Высокая активность (6-7 тренировок в неделю)', 1.725, 'Основной обмен × 1.725'),
('Экстремальная активность (тяжелые тренировки 2 раза в день)', 1.9, 'Основной обмен × 1.9');

-- 5.2. Заполняем уровни фитнес-подготовки
INSERT INTO levels_training (name, note) VALUES
('Начальный', 'Новичок, менее 6 месяцев тренировок'),
('Средний', 'Опытный, 6 месяцев - 2 года тренировок'),
('Продвинутый', 'Опыт более 2 лет'),
('Профессионал', 'Спортсмены, выступающие на соревнованиях');

-- 5.3. Заполняем цели тренировок
INSERT INTO goals_training (name, note) VALUES
('Похудение', 'Снижение веса, уменьшение жировой массы'),
('Набор мышечной массы', 'Увеличение мышечной массы, силовых показателей'),
('Поддержание формы', 'Сохранение текущей формы, тонус мышц'),
('Рельеф', 'Сушка, прорисовка мышц'),
('Выносливость', 'Улучшение кардио-выносливости'),
('Сила', 'Увеличение максимальной силы'),
('Реабилитация', 'Восстановление после травм');

-- 5.4. Заполняем типы телосложения
INSERT INTO types_body_build (name, description, gender, wrist_min, wrist_max, ankle_min, ankle_max, note) VALUES
('Эктоморф', 'Худощавое телосложение, быстрый метаболизм, сложно набирать массу', 'M', 15.0, 17.5, 20.0, 22.5, 'Для мужчин'),
('Мезоморф', 'Атлетическое телосложение, легко набирает мышцы и теряет жир', 'M', 17.6, 20.0, 22.6, 25.0, 'Для мужчин'),
('Эндоморф', 'Крупное телосложение, медленный метаболизм, легко набирает жир', 'M', 20.1, 23.0, 25.1, 28.0, 'Для мужчин'),
('Эктоморф', 'Худощавое телосложение, быстрый метаболизм', 'Ж', 13.0, 15.0, 17.0, 19.0, 'Для женщин'),
('Мезоморф', 'Атлетическое телосложение, хороший мышечный тонус', 'Ж', 15.1, 16.5, 19.1, 21.0, 'Для женщин'),
('Эндоморф', 'Пышное телосложение, склонность к накоплению жира', 'Ж', 16.6, 18.5, 21.1, 23.5, 'Для женщин');

-- 5.5. Заполняем виды упражнений
INSERT INTO kinds_exercis (name, note) VALUES
('Кардио', 'Упражнения для сердечно-сосудистой системы'),
('Силовые', 'Упражнения с отягощениями для развития силы'),
('Функциональные', 'Упражнения, имитирующие повседневные движения'),
('Растяжка', 'Упражнения для повышения гибкости'),
('Плиометрика', 'Взрывные упражнения для развития мощности'),
('Изометрика', 'Статические упражнения без движения в суставах');

-- 5.6. Заполняем типы оборудования
INSERT INTO equipment_types (name, description, category, weight_range, dimensions, is_mobile, schematic_icon, note) VALUES
('Беговая дорожка', 'Кардио тренажер для бега и ходьбы', 0, NULL, '180x80x140 см', false, 'treadmill', 'Электрическая, с наклоном'),
('Эллиптический тренажер', 'Кардио тренажер для низкоударной тренировки', 0, NULL, '160x70x170 см', true, 'elliptical', 'Орбитрек'),
('Велотренажер', 'Кардио тренажер для тренировки ног', 0, NULL, '120x60x140 см', true, 'bike', 'С вертикальной посадкой'),
('Гантели', 'Свободные веса для силовых упражнений', 2, '1-30 кг', NULL, true, 'dumbbell', 'Резиновое покрытие'),
('Штанга', 'Свободный вес для базовых упражнений', 2, '20 кг (гриф)', '220 см', false, 'barbell', 'Олимпийский гриф'),
('Скамья для жима', 'Силовой тренажер для жима лежа', 1, NULL, '120x30x45 см', true, 'bench', 'Регулируемый наклон'),
('Тренажер для жима ногами', 'Силовой тренажер для ног', 1, NULL, '200x120x150 см', false, 'leg_press', 'Под углом 45°'),
('Фитбол', 'Мяч для функциональных упражнений', 3, NULL, 'Диаметр 65 см', true, 'fitball', 'Антиразрывный'),
('Коврик для йоги', 'Аксессуар для растяжки и йоги', 4, NULL, '180x60x0.5 см', true, 'yoga_mat', 'ПВХ, 5 мм'),
('Весы напольные', 'Измерительное оборудование', 5, NULL, '30x30x3 см', true, 'scales', 'Электронные, до 200 кг');

-- 5.7. Заполняем типы упражнений
INSERT INTO types_exercis (name, kind_exercis_id, equipment_type_id, note) VALUES
('Бег на дорожке', 1, 1, 'Кардио упражнение'),
('Ходьба на эллипсе', 1, 2, 'Низкоударное кардио'),
('Езда на велотренажере', 1, 3, 'Кардио для ног'),
('Жим гантелей лежа', 2, 4, 'Упражнение на грудные мышцы'),
('Приседания со штангой', 2, 5, 'Базовое упражнение на ноги'),
('Жим ногами в тренажере', 2, 7, 'Упражнение на квадрицепсы'),
('Отжимания на брусьях', 2, NULL, 'Упражнение на трицепсы и грудные'),
('Подтягивания', 2, NULL, 'Упражнение на спину и бицепсы'),
('Планка', 6, NULL, 'Статическое упражнение на пресс'),
('Растяжка мышц ног', 4, 9, 'Упражнение на гибкость'),
('Упражнения с фитболом', 3, 8, 'Функциональная тренировка');

-- 5.8. Заполняем шаблоны упражнений
INSERT INTO exercises_templates (name, repeat_qty, duration_exec, duration_rest, calories_out, is_group, type_exercis_id, note) VALUES
('Бег на дорожке', NULL, 30.0, 1.0, 300.0, false, 1, 'Умеренный темп, 10 км/ч'),
('Ходьба на эллипсе', NULL, 45.0, 1.0, 250.0, false, 2, 'Среднее сопротивление'),
('Езда на велотренажере', NULL, 40.0, 1.0, 280.0, false, 3, 'Интервальная тренировка'),
('Жим гантелей лежа', 12, NULL, 60.0, 80.0, false, 4, '3 подхода, средний вес'),
('Приседания со штангой', 10, NULL, 90.0, 120.0, false, 5, '4 подхода, рабочий вес'),
('Жим ногами', 15, NULL, 60.0, 100.0, false, 6, '3 подхода, умеренный вес'),
('Отжимания на брусьях', 15, NULL, 60.0, 70.0, false, 7, '3 подхода, с весом или без'),
('Подтягивания', 10, NULL, 90.0, 90.0, false, 8, '4 подхода, широкий хват'),
('Планка', NULL, 60.0, 30.0, 40.0, false, 9, '3 подхода по 60 секунд'),
('Растяжка ног', NULL, 15.0, 0.0, 50.0, false, 10, 'Статическая растяжка'),
('Упражнения с фитболом', 20, NULL, 30.0, 60.0, true, 11, 'Групповое занятие');

-- 5.9. Заполняем шаблоны наборов упражнений
INSERT INTO sets_exercises_templates (name, level_training_id, note) VALUES
('Кардио для начинающих', 1, 'Базовый кардио-комплекс для новичков'),
('Силовая тренировка на все тело', 2, 'Базовая силовая для среднего уровня'),
('Интенсивное кардио', 3, 'Интервальная тренировка для продвинутых'),
('Силовая на ноги', 2, 'Акцент на нижнюю часть тела'),
('Верх тела', 2, 'Тренировка груди, спины и рук'),
('Функциональная тренировка', 1, 'Упражнения с собственным весом'),
('Растяжка и мобильность', 1, 'Комплекс на гибкость');

-- 5.10. Заполняем связи наборов и упражнений
INSERT INTO set_exercises_templates_exercis_templates (set_exercises_template_id, exercis_template_id) VALUES
(1, 1), (1, 2),  -- Кардио для начинающих
(2, 4), (2, 5), (2, 8),  -- Силовая на все тело
(3, 1), (3, 3),  -- Интенсивное кардио
(4, 5), (4, 6),  -- Силовая на ноги
(5, 4), (5, 7), (5, 8),  -- Верх тела
(6, 9), (6, 11),  -- Функциональная тренировка
(7, 10);  -- Растяжка

-- 5.11. Заполняем шаблоны планов тренировок
INSERT INTO training_plan_templates (name, goal_training_id, note) VALUES
('Похудение для начинающих', 1, 'План для снижения веса, новички'),
('Набор массы для среднего уровня', 2, 'План для роста мышц, средний уровень'),
('Поддержание формы', 3, 'План для сохранения результатов'),
('Рельеф для продвинутых', 4, 'Сушка для опытных тренирующихся'),
('Силовая программа', 6, 'Развитие максимальной силы');

-- 5.12. Заполняем связи планов и наборов упражнений
INSERT INTO training_plan__templates_set_exercises_templates (training_plan_template_id, set_exercises_template_id) VALUES
(1, 1), (1, 6), (1, 7),  -- Похудение: кардио, функциональная, растяжка
(2, 2), (2, 4), (2, 5),  -- Набор массы: силовая все тело, ноги, верх
(3, 1), (3, 2), (3, 7),  -- Поддержание: кардио, силовая, растяжка
(4, 3), (4, 2), (4, 7),  -- Рельеф: интенсивное кардио, силовая, растяжка
(5, 2), (5, 4), (5, 5);  -- Силовая: все тело, ноги, верх

-- 5.13. Заполняем рекомендации по тренировкам
INSERT INTO training_recommendations (body_type, goal_training_id, level_trainig_id, recommendation_text_trainer, recommendation_text_client, note) VALUES
('Яблоко', 1, 1, 'Акцент на кардио тренировки для снижения жира в области талии. Силовые тренировки на все группы мышц с умеренными весами. Избегать упражнений, создающих осевую нагрузку на позвоночник при наличии большого живота.', 'Рекомендуется больше кардио тренировок (бег, ходьба, велосипед) и упражнения на все группы мышц. Обратите внимание на питание - снизьте простые углеводы.', 'Для похудения при типе "Яблоко"'),
('Груша', 1, 1, 'Кардио тренировки для общего жиросжигания. Силовые тренировки с акцентом на верхнюю часть тела для балансировки фигуры. Умеренная нагрузка на ноги без увеличения объемов.', 'Делайте упор на тренировку верхней части тела (руки, плечи, спина) и кардио. Упражнения на ноги выполняйте с умеренной интенсивностью.', 'Для похудения при типе "Груша"'),
('Песочные часы', 2, 2, 'Сбалансированные силовые тренировки на все группы мышц для гармоничного развития. Кардио для поддержания формы. Можно использовать средние и тяжелые веса.', 'Идеальное телосложение для силовых тренировок! Тренируйте все группы мышц равномерно, используйте разнообразные упражнения.', 'Для набора массы при типе "Песочные часы"'),
('Прямоугольник', 2, 2, 'Создание иллюзии изгибов через развитие плеч и ягодиц. Тренировки с акцентом на дельтовидные мышцы и ягодицы. Кардио умеренное.', 'Сосредоточьтесь на упражнениях для плеч и ягодиц, чтобы создать более выраженную талию. Используйте различные углы нагрузки.', 'Для набора массы при типе "Прямоугольник"');

-- 5.14. Заполняем формулы расчета BMR
INSERT INTO bmr_formulas (name, formula, for_men, for_women, is_active, note) VALUES
('Миффлина-Сан Жеора', '10 × вес(кг) + 6.25 × рост(см) - 5 × возраст(лет) + 5', true, false, true, 'Стандартная формула для мужчин'),
('Миффлина-Сан Жеора', '10 × вес(кг) + 6.25 × рост(см) - 5 × возраст(лет) - 161', false, true, true, 'Стандартная формула для женщин'),
('Харриса-Бенедикта', '88.362 + (13.397 × вес[кг]) + (4.799 × рост[см]) - (5.677 × возраст[лет])', true, false, true, 'Классическая формула для мужчин'),
('Харриса-Бенедикта', '447.593 + (9.247 × вес[кг]) + (3.098 × рост[см]) - (4.330 × возраст[лет])', false, true, true, 'Классическая формула для женщин'),
('Кетча-МакАрдла', '370 + (21.6 × LBM)', true, true, true, 'LBM = масса тела × (100 - %жира) / 100');

-- 5.20. Заполняем вспомогательный персонал
INSERT INTO support_staff (first_name, last_name, middle_name, phone, email, employment_type, category, can_maintain_equipment, accessible_equipment_types, company_name, contract_number, contract_expiry_date, notes, created_by, updated_by) VALUES
('Александр', 'Иванов', 'Петрович', '+79001234567', 'a.ivanov@fitman.com', 0, 0, TRUE, '["1","2"]', 'ООО "ФитнесСервис"', 'FS-2023-001', '2024-12-31', 'Отвечает за обслуживание кардио-оборудования', 1, 1),
('Мария', 'Смирнова', 'Александровна', '+79007654321', 'm.smirnova@fitman.com', 1, 1, FALSE, NULL, NULL, NULL, NULL, 'Администратор зала, встречает клиентов', 1, 1),
('Дмитрий', 'Кузнецов', 'Сергеевич', '+79001112233', 'd.kuznetsov@fitman.com', 0, 2, TRUE, '["4","5","6","7"]', 'ИП "ТехСервис"', 'TS-2023-005', '2025-06-30', 'Обслуживание силовых тренажеров и гантелей', 1, 1),
('Елена', 'Петрова', 'Игоревна', '+79004445566', 'e.petrova@fitman.com', 1, 3, FALSE, NULL, NULL, NULL, NULL, 'Уборка помещений, дезинфекция оборудования', 1, 1);

-- 5.21. Заполняем компетенции вспомогательного персонала
INSERT INTO support_staff_competencies (staff_id, name, level, certificate_url, verified_at, verified_by) VALUES
(1, 'Ремонт беговых дорожек', 2, 'http://cert.com/alex-treadmill', '2023-03-10', 1),
(1, 'Диагностика эллипсов', 1, NULL, NULL, NULL),
(3, 'Ремонт силовых тренажеров', 3, 'http://cert.com/dmitry-strength', '2023-05-20', 1),
(3, 'Сварка металлоконструкций', 2, NULL, NULL, NULL);

-- 5.22. Заполняем расписание работы вспомогательного персонала
INSERT INTO support_staff_schedules (staff_id, day_of_week, start_time, end_time) VALUES
(1, 1, '09:00:00', '18:00:00'), -- Пн
(1, 3, '09:00:00', '18:00:00'), -- Ср
(1, 5, '09:00:00', '18:00:00'), -- Пт
(2, 2, '08:00:00', '16:00:00'), -- Вт
(2, 4, '08:00:00', '16:00:00'), -- Чт
(2, 6, '10:00:00', '14:00:00'), -- Сб
(3, 1, '10:00:00', '19:00:00'), -- Пн
(3, 2, '10:00:00', '19:00:00'), -- Вт
(3, 3, '10:00:00', '19:00:00'), -- Ср
(4, 1, '07:00:00', '15:00:00'), -- Пн
(4, 2, '07:00:00', '15:00:00'), -- Вт
(4, 3, '07:00:00', '15:00:00'), -- Ср
(4, 4, '07:00:00', '15:00:00'), -- Чт
(4, 5, '07:00:00', '15:00:00'); -- Пт
-- 5.15. Заполняем Здания
INSERT INTO buildings (name, address, note) VALUES
('Основной корпус', 'г. Москва, ул. Центральная, 1', 'Главное здание фитнес-центра'),
('Водный комплекс', 'г. Москва, ул. Центральная, 2', 'Здание с бассейном и спа');

-- 5.16. Заполняем помещения (залы)
INSERT INTO rooms (name, description, type, floor, building_id, max_capacity, area, open_time, close_time, working_days, note) VALUES
('Зал групповых занятий', 'Основной зал для групповых тренировок, йоги, аэробики', 0, '1', 1, 25, 120.0, '08:00', '22:00', '[1,2,3,4,5,6]', 'Основной зал, паркетное покрытие'),
('Кардио-зона', 'Зона с кардио оборудованием', 1, '1', 1, 15, 80.0, '06:00', '23:00', '[1,2,3,4,5,6,7]', '24/7 для членов клуба'),
('Силовая зона', 'Зона со свободными весами и силовыми тренажерами', 2, '1', 1, 20, 100.0, '06:00', '23:00', '[1,2,3,4,5,6,7]', 'Олимпийские платформы'),
('Йога-студия', 'Зал для йоги и пилатеса', 4, '2', 1, 12, 60.0, '07:00', '21:00', '[1,2,3,4,5,6]', 'Бамбуковое покрытие, оборудование для йоги'),
('Боксерский зал', 'Зал для единоборств и функционального тренинга', 5, '2', 1, 10, 70.0, '09:00', '20:00', '[1,2,3,4,5]', 'Боксерские груши, татами'),
('Бассейн', 'Плавание', 6, '1', 2, 30, 250.0, '07:00', '22:00', '[1,2,3,4,5,6,7]', '25-метровый бассейн, 4 дорожки'),
('Сауна', 'Зона отдыха с сауной', 7, '1', 2, 8, 20.0, '10:00', '21:00', '[1,2,3,4,5,6,7]', 'Финская сауна'),
('Сауна 2', 'Дополнительная зона отдыха с сауной', 7, '1', 2, 8, 20.0, '10:00', '21:00', '[1,2,3,4,5,6,7]', 'Вторая финская сауна');

-- 5.17. Заполняем экземпляры оборудования
INSERT INTO equipment_items (type_id, inventory_number, serial_number, model, manufacturer, room_id, placement_note, status, condition_rating, purchase_date, purchase_price, note) VALUES
(1, 'ТРЕД-001', 'SN123456', 'T8.5', 'Matrix', 2, 'У окна, левая сторона', 0, 5, '2023-01-15', 250000.00, 'Основная беговая дорожка'),
(1, 'ТРЕД-002', 'SN123457', 'T8.5', 'Matrix', 2, 'У окна, правая сторона', 0, 5, '2023-01-15', 250000.00, 'Запасная беговая дорожка'),
(2, 'ЭЛЛ-001', 'SN123458', 'E7Xi', 'Matrix', 2, 'Центр зала', 0, 4, '2023-02-20', 180000.00, 'Эллиптический тренажер'),
(3, 'ВЕЛ-001', 'SN123459', 'R7xe', 'Matrix', 2, 'У стены', 0, 5, '2023-02-20', 150000.00, 'Велотренажер вертикальный'),
(4, 'ГАН-001', NULL, 'Резиновые', 'Kettler', 3, 'Стеллаж №1', 0, 4, '2022-11-10', 5000.00, 'Гантели 5 кг, пара'),
(4, 'ГАН-002', NULL, 'Резиновые', 'Kettler', 3, 'Стеллаж №1', 0, 4, '2022-11-10', 7000.00, 'Гантели 10 кг, пара'),
(5, 'ШТАН-001', 'SN123460', 'Олимпийская', 'Rogue', 3, 'Стойка для штанги', 0, 5, '2023-03-05', 30000.00, 'Олимпийский гриф 20 кг'),
(6, 'СКАМ-001', 'SN123461', 'Adjustable', 'Body Solid', 3, 'Возле зеркала', 0, 4, '2022-12-15', 45000.00, 'Скамья регулируемая'),
(7, 'НОГИ-001', 'SN123462', 'Leg Press', 'Hammer Strength', 3, 'Угол зала', 0, 5, '2023-01-10', 320000.00, 'Тренажер для жима ногами'),
(8, 'ФИТ-001', NULL, 'Anti-Burst', 'Ledraplastik', 4, 'Корзина с мячами', 0, 5, '2023-04-01', 3000.00, 'Фитбол 65 см'),
(9, 'КОВ-001', NULL, 'Professional', 'Manduka', 4, 'Стеллаж для ковриков', 0, 5, '2023-04-01', 2500.00, 'Коврик для йоги 5мм'),
(10, 'ВЕС-001', 'SN123463', 'BF-350', 'Beurer', 5, 'У входа', 0, 5, '2023-05-10', 8000.00, 'Электронные весы');

-- 5.19. Создаем несколько бронирований оборудования (пример)
INSERT INTO equipment_bookings (equipment_item_id, booked_by, start_time, end_time, purpose, notes) VALUES
(1, 1, '2024-01-15 10:00:00+03', '2024-01-15 11:00:00+03', 'Индивидуальная тренировка', 'Клиент: Иванов И.И.'),
(2, 1, '2024-01-15 11:00:00+03', '2024-01-15 12:00:00+03', 'Групповое занятие', 'Группа "Кардио для начинающих"'),
(5, 2, '2024-01-15 14:00:00+03', '2024-01-15 15:00:00+03', 'Силовая тренировка', 'Клиент: Петров П.П.'),
(8, 2, '2024-01-15 16:00:00+03', '2024-01-15 17:00:00+03', 'Тренировка грудных', 'Собственный вес + гантели');



-- ============================================
-- 8. СООБЩЕНИЕ ОБ УСПЕШНОМ ВЫПОЛНЕНИИ
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Создание таблиц упражнений, помещений и оборудования завершено!';
    RAISE NOTICE 'Создано таблиц: 20';
    RAISE NOTICE 'Создано индексов: 40+';
    RAISE NOTICE 'Загружено начальных данных: ~80 записей';
    RAISE NOTICE '============================================';
END $$;
