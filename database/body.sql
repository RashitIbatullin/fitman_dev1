-- recommendations.sql
-- Таблицы для подсистемы рекомендаций
-- Скрипт является идемпотентным.

-- Удаление старых таблиц, если они существуют
DROP TABLE IF EXISTS
	"anthropometry_fix", 
    "types_body_build", 
    "body_shape_recommendations", 
    "whtr_refinements", 
    "ai_recommendation_cache",
    "bioimpedance_start",
    "bioimpedance_finish"
CASCADE;


-- Таблицы антропометрии
CREATE TABLE anthropometry_fix (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ DEFAULT NOW(),
    height INT,
    wrist_circ INT,
    ankle_circ INT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMP WITH TIME ZONE,
    archived_by UUID
);

CREATE TABLE anthropometry_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ NOT NULL,
    weight REAL,
    shoulders_circ INT,
    breast_circ INT,
    waist_circ INT,
    hips_circ INT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id),
	archived_reason TEXT,
    UNIQUE(user_id, date_time)
);
CREATE INDEX IF NOT EXISTS idx_anthropometry_measurements_user_id ON anthropometry_measurements(user_id);


-- Каталог "Типы телосложения" для алгоритма определения соматотипа
-- This table is also defined in infrastructure.sql. Keeping it consistent.
CREATE TABLE types_body_build (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(20) NOT NULL,
    description VARCHAR(200),
    gender VARCHAR(20) NOT NULL,
    wrist_min REAL,
    wrist_max REAL,
    ankle_min REAL,
    ankle_max REAL,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id),
    UNIQUE(name, gender)
);

-- 3. Таблица БАЗОВЫХ рекомендаций по ТИПУ ФИГУРЫ
CREATE TABLE body_shape_recommendations (
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
    UNIQUE(body_type, goal_training_id, level_training_id)
);

-- 4. Новая таблица для УТОЧНЕНИЙ по WHtR
CREATE TABLE whtr_refinements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    whtr_gradation VARCHAR(50) NOT NULL,
    goal_training_id UUID REFERENCES goals_training(id),
    refinement_text_client TEXT,
    refinement_text_trainer TEXT,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id),
    UNIQUE(whtr_gradation, goal_training_id)
);

-- 5. Таблица для хранения сгенерированных AI рекомендаций
CREATE TABLE ai_recommendation_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    profile_snapshot JSONB NOT NULL,
    recommendation_text TEXT NOT NULL,
    ai_model VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, created_at)
);

-- 6. Таблица биоимпеданса
CREATE TABLE bioimpedance_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    date_time TIMESTAMPTZ NOT NULL,
    fat_percentage REAL,
    muscle_mass REAL,
    water_percentage REAL,
    visceral_fat INTEGER,
    bmc REAL,
    bmi REAL,
    metabolism INTEGER,
    company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id)
);


CREATE INDEX IF NOT EXISTS idx_bioimpedance_measurements_user_id ON bioimpedance_measurements(user_id);
