-- Удаление старых таблиц, если они существуют, для идемпотентности скрипта
DROP TABLE IF EXISTS 
"lessons",
"client_training_plans",
"training_plan_templates"
CASCADE;

-- Таблицы планов тренировок
CREATE TABLE training_plan_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    goal_training_id UUID REFERENCES goals_training(id),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);

CREATE TABLE client_training_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    training_plan_template_id UUID NOT NULL REFERENCES training_plan_templates(id),
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
    archived_by UUID REFERENCES users(id)
);

-- Таблица занятий (уроки)
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID, -- Can be null if it's an unscheduled lesson
    client_training_plan_id UUID REFERENCES client_training_plans(id),
    set_exercises_id UUID, -- This seems to be a denormalization, check usage
    client_id UUID NOT NULL REFERENCES users(id),
    instructor_id UUID REFERENCES users(id),
    trainer_id UUID REFERENCES users(id),
    start_plan_at TIMESTAMPTZ,
    finish_plan_at TIMESTAMPTZ,
    start_fact_at TIMESTAMPTZ,
    finish_fact_at TIMESTAMPTZ,
    complete SMALLINT DEFAULT 0, -- 0: scheduled, 1: completed, 2: canceled
    note VARCHAR(255),
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);
