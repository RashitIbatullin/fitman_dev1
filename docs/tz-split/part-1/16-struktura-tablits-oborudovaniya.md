# Функциональные требования / Модуль управления оборудованием / Структура таблиц оборудования

*Часть 1 | источник: Требования ТЗ фитнес-тренинг часть 1.docx | [индекс](../INDEX.md)*

##### Типы оборудования (equipment_types)

```sql
CREATE TABLE equipment_types (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,      -- "Гантели", "Беговая дорожка"
  description TEXT,

  -- Классификация
  category SMALLINT NOT NULL,      -- EquipmentCategory enum

  -- Характеристики
  weight_range VARCHAR(50),        -- "1-30 кг"
  dimensions VARCHAR(100),         -- "80x150x200 см"
  is_mobile BOOLEAN DEFAULT true,

   schematic_icon VARCHAR(50),
  -- Системные поля
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

-- Индексы для equipment_types
CREATE INDEX idx_eq_types_category ON equipment_types(category) WHERE is_active = true;
```

##### Экземпляры оборудования (equipment_items)

```sql
-- Конкретные экземпляры оборудования
CREATE TABLE equipment_items (
  id UUID PRIMARY KEY,

  -- Тип оборудования
  type_id UUID NOT NULL REFERENCES equipment_types(id),

  -- Идентификация
  inventory_number VARCHAR(50) NOT NULL UNIQUE,  -- "ГАН-001"
  serial_number VARCHAR(100),                    -- Заводской номер
  model VARCHAR(100),                            -- "Matrix T7xe"
  manufacturer VARCHAR(255),                     -- "Johnson Health Tech"

  -- Локация
  room_id UUID REFERENCES rooms(id),
  placement_note TEXT,

  -- Состояние
  status SMALLINT DEFAULT 0,                     -- EquipmentStatus enum
  condition_rating INT CHECK (condition_rating >= 1 AND condition_rating <= 5),
  condition_notes TEXT,

  -- Обслуживание (упрощённое)
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
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

-- Индексы для equipment_items
CREATE INDEX idx_eq_items_type ON equipment_items(type_id);
CREATE INDEX idx_eq_items_room ON equipment_items(room_id) WHERE room_id IS NOT NULL;
CREATE INDEX idx_eq_items_status ON equipment_items(status) WHERE status = 0; -- available
CREATE INDEX idx_eq_items_inventory ON equipment_items(inventory_number);
```

##### Бронирование оборудования (equipment_bookings)

```sql
-- Бронирование конкретного оборудования
CREATE TABLE equipment_bookings (
  id UUID PRIMARY KEY,

  -- Что бронируем
  equipment_item_id UUID NOT NULL REFERENCES equipment_items(id),

  -- Кто бронирует
  booked_by UUID NOT NULL REFERENCES users(id),

  -- Время
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,

  -- Контекст
  lesson_id UUID REFERENCES lessons(id),
  training_group_id UUID REFERENCES training_groups(id),
  purpose VARCHAR(255) NOT NULL,

  -- Статус
  status SMALLINT DEFAULT 0,  -- BookingStatus enum

  -- Дополнительно
  notes TEXT,

  -- Системные поля
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),

  -- Ограничения
  CONSTRAINT valid_booking_time CHECK (end_time > start_time)
);

-- Индекс для проверки пересечений бронирований
CREATE INDEX idx_eq_bookings_time
ON equipment_bookings(equipment_item_id, start_time, end_time)
WHERE status IN (0, 1); -- confirmed, active
```

##### История обслуживания оборудования (equipment_maintenance_history)

CREATE TABLE equipment_maintenance_history (

id UUID PRIMARY KEY,

equipment_item_id UUID NOT NULL REFERENCES equipment_items(id),

equipment_name VARCHAR(255),

type SMALLINT NOT NULL,

status SMALLINT DEFAULT 0,

created_at TIMESTAMPTZ DEFAULT NOW(),

started_at TIMESTAMPTZ,

completed_at TIMESTAMPTZ,

equipment_available_from TIMESTAMPTZ,

reported_problem TEXT NOT NULL,

work_description TEXT,

reported_by UUID NOT NULL REFERENCES users(id),

executor_id UUID,     -- ID исполнителя (из users или support_staff)

executor_type SMALLINT, -- Тип исполнителя (0 для User, 1 для SupportStaff). Выбор исполнителя осуществляется на основе его компетенций (см. п. 6.6.3.2).

related_booking_id UUID REFERENCES equipment_bookings(id),

caused_downtime BOOLEAN DEFAULT false,

updated_at TIMESTAMPTZ DEFAULT NOW(),

archived_at TIMESTAMPTZ,

archived_by UUID REFERENCES users(id),

archived_reason TEXT,

created_by UUID REFERENCES users(id),

updated_by UUID REFERENCES users(id)

);

##### Фотографии ТО (maintenance_photos)

-- Фотографии ТО

CREATE TABLE maintenance_photos (

id UUID PRIMARY KEY,

maintenance_id UUID NOT NULL REFERENCES equipment_maintenance_history(id) ON DELETE CASCADE,

url TEXT NOT NULL,

comment TEXT,

timing SMALLINT NOT NULL,

taken_at TIMESTAMPTZ DEFAULT NOW(),

taken_by UUID REFERENCES users(id),

INDEX idx_maintenance_photos (maintenance_id, timing)

);
