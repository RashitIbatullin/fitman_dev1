-- ============================================
-- Файл создания таблиц упражнений, помещений и персонала
-- для системы "Фитнес-менеджер" (FitMan)
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
DROP TABLE IF EXISTS kinds_activity_client CASCADE;

-- 1. ТАБЛИЦЫ ДЛЯ УПРАЖНЕНИЙ И ПЛАНОВ ТРЕНИРОВОК

CREATE TABLE kinds_activity_client (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  coeff_activity REAL NOT NULL DEFAULT 1.2,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE types_body_build (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(20) NOT NULL,
  description VARCHAR(200),
  gender VARCHAR(20) NOT NULL,
  wrist_max REAL NOT NULL,
  wrist_min REAL NOT NULL,
  ankle_max REAL NOT NULL,
  ankle_min REAL NOT NULL,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE kinds_exercis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE equipment_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  category SMALLINT NOT NULL,
  weight_range VARCHAR(50),
  dimensions VARCHAR(100),
  is_mobile BOOLEAN DEFAULT true,
  schematic_icon VARCHAR(50),
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

CREATE TABLE types_exercis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  kind_exercis_id UUID REFERENCES kinds_exercis(id),
  equipment_type_id UUID REFERENCES equipment_types(id),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE exercises_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  repeat_qty INT,
  duration_exec REAL,
  duration_rest REAL,
  calories_out REAL,
  is_group BOOLEAN DEFAULT false,
  type_exercis_id UUID REFERENCES types_exercis(id),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE sets_exercises_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  level_training_id UUID REFERENCES levels_training(id),
  description TEXT,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE set_exercises_templates_exercis_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  set_exercises_template_id UUID NOT NULL REFERENCES sets_exercises_templates(id) ON DELETE CASCADE,
  exercis_template_id UUID NOT NULL REFERENCES exercises_templates(id) ON DELETE CASCADE,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  UNIQUE(set_exercises_template_id, exercis_template_id)
);

CREATE TABLE training_plan_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  goal_training_id UUID REFERENCES goals_training(id),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE training_plan__templates_set_exercises_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  training_plan_template_id UUID NOT NULL REFERENCES training_plan_templates(id) ON DELETE CASCADE,
  set_exercises_template_id UUID NOT NULL REFERENCES sets_exercises_templates(id) ON DELETE CASCADE,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  UNIQUE(training_plan_template_id, set_exercises_template_id)
);

CREATE TABLE training_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  body_type VARCHAR(50) NOT NULL,
  goal_training_id UUID REFERENCES goals_training(id),
  level_training_id UUID REFERENCES levels_training(id),
  recommendation_text_trainer TEXT NOT NULL,
  recommendation_text_client TEXT NOT NULL,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE bmr_formulas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  formula TEXT NOT NULL,
  for_men BOOLEAN DEFAULT true,
  for_women BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

-- 2. ТАБЛИЦЫ ИНДИВИДУАЛЬНЫХ НАЗНАЧЕНИЙ (клиентские планы)

CREATE TABLE client_training_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  training_plan_template_id UUID REFERENCES training_plan_templates(id),
  assigned_by UUID REFERENCES users(id),
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  goal VARCHAR(255),
  notes TEXT,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE client_set_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_training_plan_id UUID NOT NULL REFERENCES client_training_plans(id) ON DELETE CASCADE,
  set_exercise_template_id UUID REFERENCES sets_exercises_templates(id),
  order_num INT NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  repeats INT,
  rest_after_set REAL,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

CREATE TABLE client_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_set_exercise_id UUID NOT NULL REFERENCES client_set_exercises(id) ON DELETE CASCADE,
  exercise_template_id UUID REFERENCES exercises_templates(id),
  order_num INT NOT NULL DEFAULT 0,
  custom_repeat_qty INT,
  custom_duration_exec REAL,
  custom_duration_rest REAL,
  custom_notes TEXT,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  note VARCHAR(100)
);

-- 3. ТАБЛИЦЫ ПОМЕЩЕНИЙ И ПЕРСОНАЛА

CREATE TABLE support_staff (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  archived_reason TEXT
);

CREATE TABLE buildings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  address TEXT,
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

CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  room_number VARCHAR(50),
  type SMALLINT NOT NULL,
  floor INT,
  building_id UUID REFERENCES buildings(id),
  max_capacity INT NOT NULL DEFAULT 30,
  area DECIMAL(5,2),
  open_time TIME,
  close_time TIME,
  working_days JSONB,
  is_active BOOLEAN DEFAULT true,
  deactivate_reason TEXT,
  deactivate_at TIMESTAMPTZ,
  deactivate_by UUID REFERENCES users(id),
  photo_urls JSONB,
  floor_plan_url TEXT,
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

DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Создание таблиц инфраструктуры, упражнений и персонала завершено!';
    RAISE NOTICE '============================================';
END $$;
