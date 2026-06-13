-- Удаление старых таблиц, если они существуют, для идемпотентности скрипта
DROP TABLE IF EXISTS 
"group_conditions",
"group_schedule_slots",
"training_group_members",
"client_group_members",
"client_groups",
"training_group_types",
"training_groups",
"analytic_groups"	
CASCADE;

-- Типы тренировочных групп
CREATE TABLE training_group_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  min_participants INT NOT NULL DEFAULT 1,
  max_participants INT NOT NULL DEFAULT 1,
  description TEXT,
  icon VARCHAR(50),
  color VARCHAR(7)
);
  
-- Таблица для хранения тренировочных групп
CREATE TABLE training_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  training_group_type_id UUID NOT NULL REFERENCES training_group_types(id),
  
  -- Персонал
  primary_trainer_id UUID REFERENCES users(id),
  primary_instructor_id UUID REFERENCES users(id),
  responsible_manager_id UUID REFERENCES users(id),
  
  -- Программа тренировок
  program_id UUID REFERENCES training_plan_templates(id),
  goal_id UUID REFERENCES goals_training(id),
  level_id UUID REFERENCES levels_training(id),
  
  -- Лимиты
  max_participants INT NOT NULL DEFAULT 15,
  
  -- Жизненный цикл
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  
  -- Связи
  chat_id UUID, -- REFERENCES chats(id) - chat table is in another file
  
  -- Системные поля
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id)
);

-- Таблица для хранения расписания тренировочных групп
CREATE TABLE group_schedule_slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES training_groups(id) ON DELETE CASCADE,
  day_of_week SMALLINT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT true
);

-- Таблица для связи клиентов с тренировочными группами
CREATE TABLE training_group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  training_group_id UUID NOT NULL REFERENCES training_groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  added_by UUID REFERENCES users(id),
  UNIQUE(training_group_id, user_id)
);

-- Таблица для хранения аналитических групп
CREATE TABLE analytic_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type SMALLINT NOT NULL,
  is_auto_update BOOLEAN DEFAULT false,
  conditions JSONB,
  metadata JSONB,
  client_ids_cache JSONB,
  last_updated_at TIMESTAMPTZ,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id)
);

-- Индексы для ускорения запросов
CREATE INDEX idx_training_groups_company_id ON training_groups(company_id);
CREATE INDEX idx_training_groups_primary_trainer_id ON training_groups(primary_trainer_id);
CREATE INDEX idx_group_schedule_slots_group_id ON group_schedule_slots(group_id);
CREATE INDEX idx_training_group_members_user_id ON training_group_members(user_id);
CREATE INDEX idx_analytic_groups_company_id ON analytic_groups(company_id);
CREATE INDEX idx_analytic_groups_is_auto_update ON analytic_groups(is_auto_update);

-- Таблица для хранения истории перемещений участников групп
CREATE TABLE group_member_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  user_role VARCHAR(50) NOT NULL, -- 'client', 'trainer', 'instructor', 'manager'
  
  from_group_id UUID REFERENCES training_groups(id), -- Может быть NULL, если это первое вступление
  to_group_id UUID REFERENCES training_groups(id),   -- Может быть NULL, если это выход из последней группы
  
  movement_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reason TEXT, -- Основание для перемещения (свободный текст не менее 5 символов)
  
  moved_by_user_id UUID NOT NULL REFERENCES users(id), -- Кто инициировал перемещение
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Добавляем индексы для ускорения поиска
CREATE INDEX idx_group_movements_user ON group_member_movements(user_id);
CREATE INDEX idx_group_movements_from_group ON group_member_movements(from_group_id);
CREATE INDEX idx_group_movements_to_group ON group_member_movements(to_group_id);

-- Убедимся, что одно из полей from/to не NULL
ALTER TABLE group_member_movements 
ADD CONSTRAINT chk_from_to_not_both_null
CHECK (from_group_id IS NOT NULL OR to_group_id IS NOT NULL);
