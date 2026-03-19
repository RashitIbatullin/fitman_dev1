-- ============================================
-- Файл создания таблиц упражнений, помещений и персонала
-- для системы "Фитнес-менеджер" (FitMan)
-- ============================================

-- ============================================
-- УДАЛЕНИЕ СУЩЕСТВУЮЩИХ ТАБЛИЦ (если они созданы)
-- ============================================

DROP TABLE IF EXISTS support_staff CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS buildings CASCADE;
DROP TABLE IF EXISTS client_exercises CASCADE;
DROP TABLE IF EXISTS client_set_exercises CASCADE;
DROP TABLE IF EXISTS client_training_plans CASCADE;
DROP TABLE IF EXISTS bmr_formulas CASCADE;
DROP TABLE IF EXISTS training_recommendations CASCADE;
DROP TABLE IF EXISTS training_plan__templates_set_exercises_templates CASCADE;
DROP TABLE IF EXISTS set_exercises_templates_exercis_templates CASCADE;
DROP TABLE IF EXISTS training_plan_templates CASCADE;
DROP TABLE IF EXISTS sets_exercises_templates CASCADE;
DROP TABLE IF EXISTS exercises_templates CASCADE;
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
-- 3. ТАБЛИЦЫ ПОМЕЩЕНИЙ И ПЕРСОНАЛА
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

-- ============================================
-- 4. СОЗДАНИЕ ИНДЕКСОВ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- ============================================

-- Индексы для kinds_activity_client, levels_training, и т.д.
CREATE INDEX idx_kinds_activity_client_name ON kinds_activity_client(name);
CREATE INDEX idx_levels_training_name ON levels_training(name);
CREATE INDEX idx_goals_training_name ON goals_training(name);

-- Индексы для equipment_types
CREATE INDEX idx_equipment_types_category ON equipment_types(category);
CREATE INDEX idx_equipment_types_active ON equipment_types(company_id) WHERE archived_at IS NULL;

-- ... и так далее для всех таблиц, кроме оборудования

-- Индексы для rooms, buildings
CREATE INDEX idx_rooms_type ON rooms(type) WHERE is_active = true;
CREATE INDEX idx_buildings_name ON buildings(name);


-- ============================================
-- 5. ИНИЦИАЛИЗАЦИЯ НАЧАЛЬНЫМИ ДАННЫМИ
-- ============================================

-- Включаем проверку внешних ключей
SET session_replication_role = 'origin';

-- Заполнение данными таблиц, не связанных с оборудованием...
-- (INSERT'ы для kinds_activity_client, levels_training, rooms, buildings, etc.)

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


-- ============================================
-- 8. СООБЩЕНИЕ ОБ УСПЕШНОМ ВЫПОЛНЕНИИ
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Создание таблиц инфраструктуры, упражнений и персонала завершено!';
    RAISE NOTICE '============================================';
END $$;
