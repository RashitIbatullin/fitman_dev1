-- ============================================
-- Файл создания таблиц оборудования, бронирования и ТО
-- для системы "Фитнес-менеджер" (FitMan)
-- ============================================

-- ============================================
-- УДАЛЕНИЕ СУЩЕСТВУЮЩИХ ТАБЛИЦ (если они созданы)
-- ============================================
DROP TABLE IF EXISTS equipment_bookings CASCADE;
DROP TABLE IF EXISTS maintenance_photos CASCADE;
DROP TABLE IF EXISTS equipment_maintenance_history CASCADE;
DROP TABLE IF EXISTS repair_time_standards CASCADE;
DROP TABLE IF EXISTS equipment_items CASCADE;



-- ============================================
-- 1. ТАБЛИЦЫ ОБОРУДОВАНИЯ И ТЕХНИЧЕСКОГО ОБСЛУЖИВАНИЯ
-- ============================================



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

-- Новая таблица для нормативов времени ремонта
CREATE TABLE repair_time_standards (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  equipment_type_id BIGINT REFERENCES equipment_types(id),
  description TEXT,
  standard_duration_hours DECIMAL(6,2) NOT NULL,
  complexity SMALLINT, -- 1-Низкая, 2-Средняя, 3-Высокая
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT
);

-- История обслуживания оборудования (модифицированная)
CREATE TABLE equipment_maintenance_history (
  id BIGSERIAL PRIMARY KEY,
  equipment_item_id BIGINT NOT NULL REFERENCES equipment_items(id),
  equipment_name VARCHAR(255),
  type SMALLINT NOT NULL, -- 0: preventive, 1: corrective
  status SMALLINT DEFAULT 0, -- 0:reported, 1:diagnosing, 2:in_progress, 3:completed, 4:cancelled
  repair_time_standard_id BIGINT REFERENCES repair_time_standards(id),
  diagnosis_notes TEXT,
  actual_duration_hours DECIMAL(6,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  equipment_available_from TIMESTAMPTZ,
  reported_problem TEXT NOT NULL,
  work_description TEXT,
  reported_by BIGINT NOT NULL REFERENCES users(id),
  executor_id BIGINT,
  executor_type SMALLINT, -- 0 for User, 1 for SupportStaff
  related_booking_id BIGINT, -- REFERENCES equipment_bookings(id), -- Ссылка будет добавлена позже
  caused_downtime BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT,
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id)
);

-- Фотографии ТО
CREATE TABLE maintenance_photos (
  id BIGSERIAL PRIMARY KEY,
  maintenance_id BIGINT NOT NULL REFERENCES equipment_maintenance_history(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  comment TEXT,
  timing SMALLINT NOT NULL, -- 0: before, 1: after
  taken_at TIMESTAMPTZ DEFAULT NOW(),
  taken_by BIGINT REFERENCES users(id)
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


-- ============================================
-- 2. СОЗДАНИЕ ИНДЕКСОВ
-- ============================================



-- Индексы для equipment_items
CREATE INDEX idx_equipment_items_type ON equipment_items(type_id);
CREATE INDEX idx_equipment_items_room ON equipment_items(room_id) WHERE room_id IS NOT NULL;
CREATE INDEX idx_equipment_items_status ON equipment_items(status) WHERE status = 0;
CREATE INDEX idx_equipment_items_inventory ON equipment_items(inventory_number);
CREATE INDEX idx_equipment_items_active ON equipment_items(company_id) WHERE archived_at IS NULL;

-- Индексы для нормативов ремонта
CREATE INDEX idx_rts_equipment_type ON repair_time_standards(equipment_type_id);

-- Индексы для equipment_maintenance_history
CREATE INDEX idx_maintenance_equipment ON equipment_maintenance_history(equipment_item_id);
CREATE INDEX idx_maintenance_status ON equipment_maintenance_history(status) WHERE archived_at IS NULL;
CREATE INDEX idx_maintenance_executor ON equipment_maintenance_history(executor_id, executor_type) WHERE executor_id IS NOT NULL;

-- Индексы для maintenance_photos
CREATE INDEX idx_maintenance_photos ON maintenance_photos(maintenance_id, timing);

-- Индексы для equipment_bookings
CREATE INDEX idx_equipment_bookings_item ON equipment_bookings(equipment_item_id);
CREATE INDEX idx_equipment_bookings_user ON equipment_bookings(booked_by);
CREATE INDEX idx_equipment_bookings_time ON equipment_bookings(equipment_item_id, start_time, end_time) WHERE status IN (0, 1);
CREATE INDEX idx_equipment_bookings_active ON equipment_bookings(company_id) WHERE archived_at IS NULL;
CREATE INDEX idx_equipment_bookings_time_status ON equipment_bookings(equipment_item_id, start_time, end_time, status);


-- ============================================
-- 3. ИНИЦИАЛИЗАЦИЯ НАЧАЛЬНЫМИ ДАННЫМИ
-- ============================================



-- Заполняем экземпляры оборудования
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

-- Создаем несколько бронирований оборудования (пример)
INSERT INTO equipment_bookings (equipment_item_id, booked_by, start_time, end_time, purpose, notes) VALUES
(1, 1, '2024-01-15 10:00:00+03', '2024-01-15 11:00:00+03', 'Индивидуальная тренировка', 'Клиент: Иванов И.И.'),
(2, 1, '2024-01-15 11:00:00+03', '2024-01-15 12:00:00+03', 'Групповое занятие', 'Группа "Кардио для начинающих"'),
(5, 2, '2024-01-15 14:00:00+03', '2024-01-15 15:00:00+03', 'Силовая тренировка', 'Клиент: Петров П.П.'),
(8, 2, '2024-01-15 16:00:00+03', '2024-01-15 17:00:00+03', 'Тренировка грудных', 'Собственный вес + гантели');
