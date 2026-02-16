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
  id SMALLSERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,          -- 'group', 'semi_personal', 'individual'
  title VARCHAR(100) NOT NULL,        -- 'Групповое занятие', 'Полуперсональная тренировка', 'Индивидуальное занятие'
  min_participants INT NOT NULL DEFAULT 1,
  max_participants INT NOT NULL DEFAULT 1,
  description TEXT,
  icon VARCHAR(50),                   -- Иконка для UI
  color VARCHAR(7)                    -- Цвет для UI (#RRGGBB)
);

-- Заполняем стандартные значения
INSERT INTO training_group_types (name, title, min_participants, max_participants) VALUES
  ('individual', 'Индивид.', 1, 1),
  ('semi_personal', 'Полуперсон.', 2, 2),
  ('group', 'Группа', 4, 50);
  
  
-- Таблица для хранения тренировочных групп
CREATE TABLE training_groups (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  training_group_type_id SMALLINT NOT NULL DEFAULT 3 REFERENCES training_group_types(id),
  
  -- Персонал
  primary_trainer_id BIGINT REFERENCES users(id),
  primary_instructor_id BIGINT REFERENCES users(id),
  responsible_manager_id BIGINT REFERENCES users(id),
  
  -- Программа тренировок
  program_id BIGINT REFERENCES training_plan_templates(id),
  goal_id BIGINT REFERENCES goals_training(id),
  level_id BIGINT REFERENCES levels_training(id),
  
  -- Лимиты
  max_participants INT NOT NULL DEFAULT 15,
  
  -- Жизненный цикл
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  
  -- Связи
  chat_id BIGINT REFERENCES chats(id),
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id)
);

COMMENT ON TABLE training_groups IS 'Хранит информацию о тренировочных группах с фиксированным составом и расписанием';
COMMENT ON COLUMN training_groups.description IS 'Описание группы';
COMMENT ON COLUMN training_groups.training_group_type_id IS 'Ссылка на тип тренировочной группы';
COMMENT ON COLUMN training_groups.primary_trainer_id IS 'Ссылка на основного тренера группы';
COMMENT ON COLUMN training_groups.primary_instructor_id IS 'Ссылка на основного инструктора группы';
COMMENT ON COLUMN training_groups.responsible_manager_id IS 'Ссылка на ответственного менеджера группы';
COMMENT ON COLUMN training_groups.program_id IS 'Ссылка на программу тренировок, связанную с этой группой';
COMMENT ON COLUMN training_groups.goal_id IS 'Ссылка на цель тренировок группы';
COMMENT ON COLUMN training_groups.level_id IS 'Ссылка на уровень подготовки группы';
COMMENT ON COLUMN training_groups.max_participants IS 'Максимальное количество участников в группе';

COMMENT ON COLUMN training_groups.start_date IS 'Дата и время начала действия группы';
COMMENT ON COLUMN training_groups.end_date IS 'Дата и время окончания действия группы (если применимо)';
COMMENT ON COLUMN training_groups.is_active IS 'Признак активности группы';
COMMENT ON COLUMN training_groups.chat_id IS 'Ссылка на автоматически созданный групповой чат';

-- Таблица для хранения расписания тренировочных групп
CREATE TABLE group_schedule_slots (
  id BIGSERIAL PRIMARY KEY,
  group_id BIGINT NOT NULL REFERENCES training_groups(id) ON DELETE CASCADE,
  day_of_week SMALLINT NOT NULL, -- 1-7 (понедельник-воскресенье)
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT true
);

COMMENT ON TABLE group_schedule_slots IS 'Хранит слоты расписания для тренировочных групп';
COMMENT ON COLUMN group_schedule_slots.group_id IS 'Ссылка на тренировочную группу';
COMMENT ON COLUMN group_schedule_slots.day_of_week IS 'День недели (1=Понедельник, 7=Воскресенье)';
COMMENT ON COLUMN group_schedule_slots.start_time IS 'Время начала занятия';
COMMENT ON COLUMN group_schedule_slots.end_time IS 'Время окончания занятия';
COMMENT ON COLUMN group_schedule_slots.is_active IS 'Признак активности слота расписания';

-- Таблица для связи клиентов с тренировочными группами
CREATE TABLE training_group_members (
  id BIGSERIAL PRIMARY KEY,
  training_group_id BIGINT NOT NULL REFERENCES training_groups(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  added_by BIGINT REFERENCES users(id),
  UNIQUE(training_group_id, user_id)
);

COMMENT ON TABLE training_group_members IS 'Связывает клиентов с тренировочными группами, в которых они состоят';
COMMENT ON COLUMN training_group_members.training_group_id IS 'Ссылка на тренировочную группу';
COMMENT ON COLUMN training_group_members.user_id IS 'Ссылка на пользователя (клиента)';
COMMENT ON COLUMN training_group_members.joined_at IS 'Дата и время добавления клиента в группу';
COMMENT ON COLUMN training_group_members.added_by IS 'Ссылка на пользователя, добавившего клиента в группу';

-- Таблица для хранения аналитических групп
CREATE TABLE analytic_groups (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type SMALLINT NOT NULL, -- 0:corporate, 1:demographic, 2:financial, 3:behavioral, 4:custom
  
  -- Автоматическое обновление
  is_auto_update BOOLEAN DEFAULT false,
  conditions JSONB, -- Условия для автоматических групп
  
  -- Метаданные
  metadata JSONB, -- Дополнительные данные
  
  -- Кэшированный состав
  client_ids_cache JSONB,
  last_updated_at TIMESTAMPTZ,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id)
);

COMMENT ON TABLE analytic_groups IS 'Хранит информацию об аналитических группах для сегментации клиентов';
COMMENT ON COLUMN analytic_groups.type IS 'Тип аналитической группы: 0 - Корпоративные, 1 - Демографические, 2 - Финансовые, 3 - Поведенческие, 4 - Произвольные';
COMMENT ON COLUMN analytic_groups.is_auto_update IS 'Признак автоматического обновления состава группы';
COMMENT ON COLUMN analytic_groups.conditions IS 'JSONB поле для хранения условий автоматического обновления группы';
COMMENT ON COLUMN analytic_groups.metadata IS 'JSONB поле для хранения дополнительных метаданных группы';
COMMENT ON COLUMN analytic_groups.client_ids_cache IS 'JSONB поле для кэширования списка ID клиентов в группе';
COMMENT ON COLUMN analytic_groups.last_updated_at IS 'Дата и время последнего обновления кэша состава группы';

-- Индексы для ускорения запросов
CREATE INDEX idx_training_groups_company_id ON training_groups(company_id);
CREATE INDEX idx_training_groups_primary_trainer_id ON training_groups(primary_trainer_id);
CREATE INDEX idx_group_schedule_slots_group_id ON group_schedule_slots(group_id);
CREATE INDEX idx_training_group_members_user_id ON training_group_members(user_id);
CREATE INDEX idx_analytic_groups_company_id ON analytic_groups(company_id);
CREATE INDEX idx_analytic_groups_is_auto_update ON analytic_groups(is_auto_update);