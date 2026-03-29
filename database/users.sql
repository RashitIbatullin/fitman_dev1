-- Подключаем расширение для генерации UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Удаление старых таблиц, если они существуют, для идемпотентности скрипта
DROP TABLE IF EXISTS
"user_settings",
"manager_clients",
"manager_instructors",
"manager_trainers",
"exercises_templates",
"competencies",
"goals_training",
"levels_training",
"employee_profiles",
"client_profiles",
"instructor_profiles",
"instructor_clients",
"trainer_profiles",
"manager_profiles",
"admin_profiles",
"work_schedules",
"anthropometry_fix",
"anthropometry_start",
"anthropometry_finish",
"roles",
"users",
"user_roles",
"client_schedule_preferences",
"types_body_build",
"training_recommendations",
"bioimpedance_start",
"bioimpedance_finish",
"types_body_build",
"body_shape_recommendations",
"whtr_refinements",
"ai_recommendation_cache"
CASCADE;

-- 1. Таблица ролей
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    icon VARCHAR(255),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    archived_at TIMESTAMPTZ,
    archived_by UUID
);

-- 2. Основная таблица пользователей
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    login VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    last_name VARCHAR(255),
    first_name VARCHAR(255),
    middle_name VARCHAR(255),
    gender SMALLINT,
    date_of_birth DATE,
    photo_url VARCHAR(255),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    archived_at TIMESTAMPTZ,
    archived_by UUID,
    archived_reason VARCHAR(255)
);

-- Добавление FK для created_by и updated_by после создания таблицы users
ALTER TABLE roles ADD CONSTRAINT fk_roles_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE roles ADD CONSTRAINT fk_roles_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE roles ADD CONSTRAINT fk_roles_archived_by FOREIGN KEY (archived_by) REFERENCES users(id);

ALTER TABLE users ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_archived_by FOREIGN KEY (archived_by) REFERENCES users(id);

-- 3. Связующая таблица пользователи-роли
CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id),
    PRIMARY KEY (user_id, role_id)
);

-- 4. Таблица настроек пользователя
CREATE TABLE user_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    send_notifications BOOLEAN DEFAULT true,
    hour_notification INTEGER DEFAULT 2,
    notification_email BOOLEAN DEFAULT true,
    notification_push BOOLEAN DEFAULT true,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

-- 5. Вспомогательные каталоги для профилей
CREATE TABLE goals_training (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) UNIQUE NOT NULL,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE levels_training (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

-- 6. Таблицы профилей для ролей
CREATE TABLE client_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    goal_training_id UUID REFERENCES goals_training(id),
    level_training_id UUID REFERENCES levels_training(id),
    track_calories BOOLEAN DEFAULT true,
    coeff_activity DOUBLE PRECISION DEFAULT 1.2,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE employee_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    specialization VARCHAR(255),
    work_experience INTEGER,
    can_maintain_equipment BOOLEAN DEFAULT false,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE instructor_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    is_duty BOOLEAN DEFAULT false,
    can_replace_trainer BOOLEAN DEFAULT false,
    can_create_plan BOOLEAN DEFAULT false,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE trainer_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE manager_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    is_duty BOOLEAN DEFAULT false,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE admin_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE competencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  competent_id UUID NOT NULL,
  executor_type  SMALLINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  level SMALLINT NOT NULL,
  certificate_url TEXT,
  verified_at DATE,
  verified_by UUID REFERENCES users(id),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  UNIQUE(competent_id, executor_type, name)
);
CREATE INDEX idx_competencies_polymorphic ON competencies(competent_id, executor_type);


CREATE TABLE instructor_clients (
    instructor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (instructor_id, client_id),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE manager_clients (
    manager_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (manager_id, client_id),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE manager_trainers (
    manager_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trainer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (manager_id, trainer_id),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE manager_instructors (
    manager_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    instructor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (manager_id, instructor_id),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE work_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    day_of_week INT NOT NULL UNIQUE,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_day_off BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    archived_at TIMESTAMP WITH TIME ZONE,
    archived_by UUID,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'
);

CREATE TABLE client_schedule_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES users(id),
    day_of_week INT NOT NULL,
    preferred_start_time TIME NOT NULL,
    preferred_end_time TIME NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    archived_at TIMESTAMP WITH TIME ZONE,
    archived_by UUID,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    UNIQUE (client_id, day_of_week)
);
