-- ============================================
-- Файл создания таблиц оборудования, бронирования и ТО
-- для системы "Фитнес-менеджер" (FitMan)
-- ============================================

DROP TABLE IF EXISTS equipment_bookings CASCADE;
DROP TABLE IF EXISTS maintenance_photos CASCADE;
DROP TABLE IF EXISTS equipment_maintenance_history CASCADE;
DROP TABLE IF EXISTS repair_time_standards CASCADE;
DROP TABLE IF EXISTS equipment_items CASCADE;

-- 1. ТАБЛИЦЫ ОБОРУДОВАНИЯ И ТЕХНИЧЕСКОГО ОБСЛУЖИВАНИЯ

CREATE TABLE equipment_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type_id UUID NOT NULL REFERENCES equipment_types(id),
  inventory_number VARCHAR(50) NOT NULL UNIQUE,
  serial_number VARCHAR(100),
  model VARCHAR(100),
  manufacturer VARCHAR(255),
  room_id UUID REFERENCES rooms(id),
  placement_note TEXT,
  status SMALLINT DEFAULT 0,
  condition_rating INT CHECK (condition_rating >= 1 AND condition_rating <= 5),
  condition_notes TEXT,
  last_maintenance_date DATE,
  next_maintenance_date DATE,
  maintenance_notes TEXT,
  purchase_date DATE,
  purchase_price DECIMAL(10,2),
  supplier VARCHAR(255),
  warranty_months INT,
  usage_hours INT DEFAULT 0,
  last_used_date DATE,
  photo_urls JSONB,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  archived_reason TEXT,
  note VARCHAR(100)
);

CREATE TABLE repair_time_standards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  equipment_type_id UUID REFERENCES equipment_types(id),
  description TEXT,
  standard_duration_hours DECIMAL(6,2) NOT NULL,
  complexity SMALLINT,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  archived_reason TEXT
);

CREATE TABLE equipment_maintenance_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  number SERIAL, -- Keep as a simple counter, not a primary key
  equipment_item_id UUID NOT NULL REFERENCES equipment_items(id),
  equipment_name VARCHAR(255),
  type SMALLINT NOT NULL,
  status SMALLINT DEFAULT 0,
  repair_time_standard_id UUID REFERENCES repair_time_standards(id),
  diagnosis_notes TEXT,
  actual_duration_hours DECIMAL(6,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  equipment_available_from TIMESTAMPTZ,
  reported_problem TEXT NOT NULL,
  work_description TEXT,
  notes TEXT,
  reported_by UUID NOT NULL REFERENCES users(id),
  in_progress_by UUID REFERENCES users(id),
  completed_by UUID REFERENCES users(id),
  cancelled_by UUID REFERENCES users(id),
  cancelled_at TIMESTAMPTZ,
  cancellation_reason TEXT,
  executor_id UUID,
  executor_type SMALLINT,
  related_booking_id UUID,
  caused_downtime BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  archived_reason TEXT,
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id)
);

CREATE TABLE maintenance_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  maintenance_id UUID NOT NULL REFERENCES equipment_maintenance_history(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  comment TEXT,
  timing SMALLINT NOT NULL,
  taken_at TIMESTAMPTZ DEFAULT NOW(),
  taken_by UUID REFERENCES users(id)
);

CREATE TABLE equipment_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equipment_item_id UUID NOT NULL REFERENCES equipment_items(id),
  booked_by UUID NOT NULL REFERENCES users(id),
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  lesson_id UUID,
  training_group_id UUID,
  purpose VARCHAR(255) NOT NULL,
  status SMALLINT DEFAULT 0,
  notes TEXT,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  archived_reason TEXT,
  CONSTRAINT valid_booking_time CHECK (end_time > start_time)
);

-- Add foreign key constraint after table creation to avoid circular dependency if needed
ALTER TABLE equipment_maintenance_history ADD CONSTRAINT fk_maintenance_booking FOREIGN KEY (related_booking_id) REFERENCES equipment_bookings(id);

-- 2. СОЗДАНИЕ ИНДЕКСОВ

CREATE INDEX idx_equipment_items_type ON equipment_items(type_id);
CREATE INDEX idx_equipment_items_room ON equipment_items(room_id) WHERE room_id IS NOT NULL;
CREATE INDEX idx_equipment_items_status ON equipment_items(status) WHERE status = 0;
CREATE INDEX idx_equipment_items_inventory ON equipment_items(inventory_number);

CREATE INDEX idx_rts_equipment_type ON repair_time_standards(equipment_type_id);

CREATE INDEX idx_maintenance_equipment ON equipment_maintenance_history(equipment_item_id);
CREATE INDEX idx_maintenance_status ON equipment_maintenance_history(status) WHERE archived_at IS NULL;
CREATE INDEX idx_maintenance_executor ON equipment_maintenance_history(executor_id, executor_type) WHERE executor_id IS NOT NULL;

CREATE INDEX idx_maintenance_photos ON maintenance_photos(maintenance_id, timing);

CREATE INDEX idx_equipment_bookings_item ON equipment_bookings(equipment_item_id);
CREATE INDEX idx_equipment_bookings_user ON equipment_bookings(booked_by);
CREATE INDEX idx_equipment_bookings_time ON equipment_bookings(equipment_item_id, start_time, end_time) WHERE status IN (0, 1);

-- 3. СООБЩЕНИЕ ОБ УСПЕШНОМ ВЫПОЛНЕНИИ

DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Создание таблиц оборудования, бронирования и ТО завершено!';
    RAISE NOTICE '============================================';
END $$;
