-- recommendations.sql
-- Таблицы для подсистемы рекомендаций
-- Скрипт является идемпотентным.

-- Удаление старых таблиц, если они существуют
DROP TABLE IF EXISTS 
    "anthropometry_fix",
    "anthropometry_start",
    "anthropometry_finish",
    "types_body_build", 
    "body_shape_recommendations", 
    "whtr_refinements", 
    "ai_recommendation_cache",
    "bioimpedance_start",
    "bioimpedance_finish"
CASCADE;


-- Таблицы антропометрии
CREATE TABLE anthropometry_fix (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ DEFAULT NOW(),
    height INT,
    wrist_circ INT,
    ankle_circ INT,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMP WITH TIME ZONE,
    archived_by BIGINT
);

CREATE TABLE anthropometry_start (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ DEFAULT NOW(),
    photo VARCHAR(255),
    photo_date_time TIMESTAMPTZ,
    profile_photo VARCHAR(255),
    profile_photo_date_time TIMESTAMPTZ,
    weight REAL,
    shoulders_circ INT,
    breast_circ INT,
    waist_circ INT,
    hips_circ INT,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMP WITH TIME ZONE,
    archived_by BIGINT
);

CREATE TABLE anthropometry_finish (
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ DEFAULT NOW(),
    photo VARCHAR(255),
    photo_date_time TIMESTAMPTZ,
    profile_photo VARCHAR(255),
    profile_photo_date_time TIMESTAMPTZ,
    weight REAL,
    shoulders_circ INT,
    breast_circ INT,
    waist_circ INT,
    hips_circ INT,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMP WITH TIME ZONE,
    archived_by BIGINT
);

-- Каталог "Типы телосложения" для алгоритма определения соматотипа
CREATE TABLE types_body_build (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL, -- 'Эктоморф', 'Мезоморф', 'Эндоморф'
    description VARCHAR(200),
    gender VARCHAR(20) NOT NULL, -- 'M', 'Ж', 'ALL'
    wrist_min REAL,
    wrist_max REAL,
    ankle_min REAL,
    ankle_max REAL,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);

-- Начальные данные для types_body_build (из ТЗ)
INSERT INTO types_body_build (name, gender, wrist_min, wrist_max, ankle_min, ankle_max) VALUES
('Эктоморф', 'M', NULL, 17, NULL, 21),
('Мезоморф', 'M', 17, 20, 21, 25),
('Эндоморф', 'M', 20, NULL, 25, NULL),
('Эктоморф', 'Ж', NULL, 15, NULL, 21),
('Мезоморф', 'Ж', 15, 17, 21, 25),
('Эндоморф', 'Ж', 17, NULL, 25, NULL);

-- 3. Таблица БАЗОВЫХ рекомендаций по ТИПУ ФИГУРЫ
CREATE TABLE body_shape_recommendations (
    id BIGSERIAL PRIMARY KEY,
    body_type VARCHAR(50) NOT NULL, -- 'Яблоко', 'Груша', 'Песочные часы', 'Прямоугольник', 'Перевернутый треугольник', 'Не определен'
    goal_training_id BIGINT REFERENCES goals_training(id),
    level_training_id BIGINT REFERENCES levels_training(id),
    recommendation_text_trainer TEXT NOT NULL, -- Для тренера (более детально)
    recommendation_text_client TEXT NOT NULL, -- Для клиента (простыми словами)
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);
COMMENT ON TABLE body_shape_recommendations IS 'Базовые рекомендации, основанные на типе фигуры';


-- ПОЛНОЕ ЗАПОЛНЕНИЕ ТАБЛИЦЫ РЕКОМЕНДАЦИЙ
TRUNCATE TABLE body_shape_recommendations RESTART IDENTITY;

-- Goal 1: Снижение веса и оздоровление
INSERT INTO body_shape_recommendations (body_type, goal_training_id, level_training_id, recommendation_text_trainer, recommendation_text_client) VALUES
-- Apple
('Яблоко', 1, 1, 'Акцент на снижение висцерального жира. Кардио 3-4 р/нед, 30-40 мин (ЧСС 60-70%). Силовые 2-3 р/нед, Full-body. Избегать скручиваний с весом.','Ваша цель - похудение. Сосредоточьтесь на кардио (ходьба, эллипс) и силовых на все тело. Ешьте меньше сладкого и жирного.'),
('Яблоко', 1, 2, 'Увеличение интенсивности. Добавить 1-2 HIIT сессии в неделю. Силовые 3 р/нед (сплит верх/низ) с акцентом на ноги и спину для улучшения пропорций.','Добавляем интенсивности! Пробуйте интервальные тренировки и разделите силовые на "верх" и "низ".'),
('Яблоко', 1, 3, 'Максимальное жиросжигание. 2-3 HIIT сессии (Табата). Силовые 3-4 р/нед, тяжелые базовые упражнения. Строгий контроль КБЖУ.','Продвинутые интервальные тренировки и тяжелые базовые упражнения. Строго следите за питанием.'),
-- Pear
('Груша', 1, 1, 'Балансировка пропорций. Силовые 3 р/нед: 60% на верх (плечи, спина). Ноги - многоповторка (15-20) с легким весом. Кардио 3-4 р/нед (гребной тренажер).','Больше внимания верху тела (плечи, спина), чтобы уравновесить фигуру. Ноги тренируйте на много повторений с легким весом.'),
('Груша', 1, 2, 'Интенсификация верха. Сплит "верх/низ". На верх - прогрессия весов. На низ - круговые сеты. Добавить HIIT 2 раза в неделю.','В день верха увеличивайте вес, в день низа работайте интенсивно. Добавьте интервальные кардио.'),
('Груша', 1, 3, 'Построение атлетичного верха. Приоритет на тяжелые веса для верха. Ноги - плиометрика, интервальные сеты. Комбинация HIIT и LISS кардио.','Стройте сильный верх. На ноги используйте прыжковые и интервальные упражнения. Строгий контроль диеты.'),
-- Hourglass
('Песочные часы', 1, 1, 'Сохранение пропорций. Full-body 3 р/нед, сбалансированно на все группы мышц. Кардио 3-4 р/нед по 30 мин.','Тренируйте все тело равномерно, чтобы сохранить ваши пропорции. Ешьте немного меньше обычной порции.'),
('Песочные часы', 1, 2, 'Добавление интенсивности при сохранении баланса. Сплит "верх/низ" или PPL 3-4 р/нед. Включение HIIT 1-2 раза в неделю.','Можно переходить на раздельные тренировки, но сохраняйте равную нагрузку на все группы мышц.'),
('Песочные часы', 1, 3, 'Шлифовка фигуры. 4-5 р/нед, добавление изолирующих упражнений. Варьирование HIIT и LISS кардио.','Добавьте изолирующие упражнения для детальной проработки мышц. Тщательно контролируйте питание.'),
-- Rectangle
('Прямоугольник', 1, 1, 'Создание изгибов. Силовые 3 р/нед с акцентом на плечи (боковые дельты) и ягодицы/бедра. Кардио 2-3 р/нед по 30 мин.','Фокус на упражнениях для плеч и ягодиц, чтобы визуально создать талию. Питайтесь с небольшим дефицитом.'),
('Прямоугольник', 1, 2, 'Прогрессия в целевых группах. 3-4 р/нед, увеличение объемов на плечи и ноги. Упражнения на широчайшие.','Увеличивайте нагрузку на плечи и ноги. Это ключ к созданию женственного силуэта.'),
('Прямоугольник', 1, 3, 'Максимальное развитие формы. 4-5 р/нед, специализация на дельты и ягодицы. Кардио по необходимости.','Продвинутые программы с акцентом на плечи и ягодицы. Контролируйте питание для рельефа.'),
-- Inverted Triangle
('Перевернутый треугольник', 1, 1, 'Акцент на развитие низа. Силовые 3 р/нед, 60% нагрузки на ноги и ягодицы. Кардио 3-4 р/нед (велотренажер, степпер).','Основное внимание — ногам и ягодицам. Это визуально уравновесит ваши широкие плечи.'),
('Перевернутый треугольник', 1, 2, 'Прогрессия нагрузки на низ. Сплит с акцентом на ноги (3-4 р/нед). Тяжелые приседания, выпады, тяги.','Увеличивайте веса в упражнениях на ноги. Это ваш главный инструмент.'),
('Перевернутый треугольник', 1, 3, 'Максимальное развитие ног. 4-5 р/нед, специализация на ноги (2-3 тренировки в неделю).','Продвинутые программы для ног для максимального результата. Контролируйте диету.'),
-- Not Defined
('Не определен', 1, 1, 'Сбалансированный подход. Кардио 3 р/нед по 30 мин. Силовые 2-3 р/нед, Full-body. Начать с уменьшения порций и исключения вредных продуктов.','Сочетайте кардио и силовые тренировки. Ешьте чуть меньше и откажитесь от фастфуда и газировки.'),
('Не определен', 1, 2, 'Умеренный подход. Кардио 3 р/нед, можно добавить интервалы. Силовые 3 р/нед, сплит "верх/низ".','Продолжайте сочетать кардио и силовые, постепенно увеличивая их сложность и интенсивность.'),
('Не определен', 1, 3, 'Интенсивный подход. 2-3 HIIT-сессии в неделю. Силовые 3-4 р/нед. Строгий контроль КБЖУ.','Используйте интенсивные тренировки и тщательно следите за питанием для наилучшего результата.');

-- Goal 2: Набор мышечной массы и силы
INSERT INTO body_shape_recommendations (body_type, goal_training_id, level_training_id, recommendation_text_trainer, recommendation_text_client) VALUES
-- Apple
('Яблоко', 2, 1, 'Осторожный набор с минимальным увеличением талии. 3-4 р/нед, акцент на плечи, спину и ноги. Небольшой профицит калорий (+200-300).','3-4 силовые в неделю, упор на плечи, спину и ноги. Ешьте немного больше, налегая на каши и белок.'),
('Яблоко', 2, 2, 'Прогрессия нагрузки в базовых упражнениях. Увеличение объема на целевые группы (плечи, ноги). Профицит +300-400 ккал.','Увеличивайте рабочий вес в упражнениях на плечи, спину и ноги. Питайтесь с небольшим избытком калорий.'),
('Яблоко', 2, 3, 'Периодизация нагрузок. Тяжелые базовые упражнения. Строгий контроль профицита калорий, чтобы минимизировать рост жира.','Используйте циклы тяжелых и легких тренировок. Питайтесь с чистым профицитом, избегая "мусорной" еды.'),
-- Pear
('Груша', 2, 1, 'Агрессивный набор на верхнюю часть тела. 3-4 р/нед, приоритет на плечи, спину, грудь. Умеренный профицит (+300-400 ккал).','Основной фокус на верх тела, чтобы сделать фигуру пропорциональнее. Ешьте больше, чтобы мышцы росли.'),
('Груша', 2, 2, 'Специализация на верх. Увеличение объема и интенсивности на плечи и спину. На ноги - поддерживающий объем.','Сосредоточьтесь на тренировках верха тела, постепенно увеличивая нагрузку.'),
('Груша', 2, 3, 'Продвинутые техники (дроп-сеты, суперсеты) для верха тела. Тяжелые жимы и тяги.','Используйте продвинутые тренировочные методы для плеч, спины и груди для максимального роста.'),
-- Hourglass
('Песочные часы', 2, 1, 'Сбалансированный набор. 3 р/нед, Full-body, прогрессия в базовых упражнениях. Умеренный профицит (+300 ккал).','Равномерно нагружайте все тело, постепенно увеличивая веса. Ешьте немного больше для роста мышц.'),
('Песочные часы', 2, 2, 'Сбалансированный сплит "верх/низ" или PPL 3-4 р/нед. Прогрессия нагрузки во всех упражнениях.','Разделите тренировки по дням, но продолжайте уделять равное внимание всем мышечным группам.'),
('Песочные часы', 2, 3, 'Пропорциональное увеличение объемов и интенсивности. Тяжелая база + изолирующие упражнения.','Работайте тяжело над базовыми упражнениями и добавляйте изоляцию для "шлифовки" всех мышечных групп.'),
-- Rectangle
('Прямоугольник', 2, 1, 'Набор для создания форм. 3-4 р/нед, акцент на широчайшие, дельты и ягодицы. Умеренный профицит калорий.','Чтобы создать изгибы, сосредоточьтесь на тренировке спины, плеч и ягодиц. Ешьте с небольшим избытком калорий.'),
('Прямоугольник', 2, 2, 'Увеличение объема на целевые группы. Прогрессия весов в тягах, жимах на плечи, приседаниях и выпадах.','Увеличивайте вес в упражнениях на спину, плечи и ноги, чтобы построить атлетичную фигуру.'),
('Прямоугольник', 2, 3, 'Специализация на ширину спины и плеч, объем ягодиц. Продвинутые сплиты.','Сфокусируйтесь на программах, которые максимально развивают ширину спины, плеч и округлость ягодиц.'),
-- Inverted Triangle
('Перевернутый треугольник', 2, 1, 'Агрессивный набор на низ тела. 3-4 р/нед, приоритет на ноги и ягодицы. Верх - в поддерживающем режиме.','Основное внимание — ногам. Тренируйте их тяжело и объемно, чтобы сбалансировать фигуру.'),
('Перевернутый треугольник', 2, 2, 'Специализация на ноги. 2 тренировки в неделю на ноги с разным акцентом (сила/объем).','Посвятите две тренировки в неделю ногам, одна пусть будет тяжелой, другая — более объемной.'),
('Перевернутый треугольник', 2, 3, 'Продвинутые техники для ног (кластерные сеты, отдых-пауза). Максимальная прогрессия в приседе и тягах.','Используйте продвинутые методы для тренировки ног, чтобы добиться максимального роста.'),
-- Not Defined
('Не определен', 2, 1, 'Сбалансированный набор. 3 р/нед, Full-body, фокус на базовых упражнениях. Профицит +300-500 ккал. 1.5-1.8г белка/кг.','3 силовые тренировки в неделю на все тело. Ешьте больше, налегая на белок и сложные углеводы.'),
('Не определен', 2, 2, 'Прогрессия в базовых упражнениях. Можно перейти на сплит "верх/низ". Увеличение профицита при стагнации.','Увеличивайте рабочие веса в базовых упражнениях. Если вес не растет, ешьте еще немного больше.'),
('Не определен', 2, 3, 'Периодизация нагрузок, продвинутые сплиты (PPL). Чистый профицит, строгий контроль нутриентов.','Чередуйте тяжелые и легкие тренировки. Питайтесь с чистым избытком калорий.');

-- Goal 3: Поддержание формы и улучшение рельефа
INSERT INTO body_shape_recommendations (body_type, goal_training_id, level_training_id, recommendation_text_trainer, recommendation_text_client)
SELECT
    bt.body_type, 3, l.id,
    '**База (Поддержание формы):** Тренировки 3 р/нед. Комбинация силовых (Full-body или сплит) и кардио. Калорийность на уровне поддержки. Фокус на качестве еды.',
    '**Базовая стратегия для поддержания формы:** Тренируйтесь 3 раза в неделю, сочетая силовые и кардио. Питайтесь в пределах своей нормы калорий.'
FROM
    (VALUES ('Яблоко'), ('Груша'), ('Песочные часы'), ('Прямоугольник'), ('Перевернутый треугольник'), ('Не определен')) AS bt(body_type),
    levels_training AS l;

-- Goal 4: Развитие общей выносливости
INSERT INTO body_shape_recommendations (body_type, goal_training_id, level_training_id, recommendation_text_trainer, recommendation_text_client)
SELECT
    bt.body_type, 4, l.id,
    '**База (Выносливость):** 3-5 р/нед аэробные сессии (бег, плавание, вело). Длительность от 30 мин. 1-2 круговые силовые тренировки для поддержки мышц.',
    '**Базовая стратегия для выносливости:** 3-5 раз в неделю делайте кардио. Добавьте пару легких силовых тренировок для тонуса мышц.'
FROM
    (VALUES ('Яблоко'), ('Груша'), ('Песочные часы'), ('Прямоугольник'), ('Перевернутый треугольник'), ('Не определен')) AS bt(body_type),
    levels_training AS l;

-- Goal 5: Увеличение гибкости и мобильности
INSERT INTO body_shape_recommendations (body_type, goal_training_id, level_training_id, recommendation_text_trainer, recommendation_text_client)
SELECT
    bt.body_type, 5, l.id,
    '**База (Гибкость):** 3-5 р/нед. Йога, стретчинг, пилатес. Фокус на правильной технике и регулярности. Не допускать острой боли.',
    '**Базовая стратегия для гибкости:** 3-5 раз в неделю занимайтесь йогой или растяжкой. Главное — делать это регулярно и без боли.'
FROM
    (VALUES ('Яблоко'), ('Груша'), ('Песочные часы'), ('Прямоугольник'), ('Перевернутый треугольник'), ('Не определен')) AS bt(body_type),
    levels_training AS l;


-- 4. Новая таблица для УТОЧНЕНИЙ по WHtR
CREATE TABLE whtr_refinements (
    id BIGSERIAL PRIMARY KEY,
    whtr_gradation VARCHAR(50) NOT NULL, -- 'Высокий риск ожирения', 'Норма' и т.д.
    goal_training_id BIGINT REFERENCES goals_training(id),
    refinement_text_client TEXT, -- Уточнение для клиента
    refinement_text_trainer TEXT, -- Уточнение для тренера
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);
COMMENT ON TABLE whtr_refinements IS 'Уточнения к рекомендациям на основе индекса WHtR';

-- Заполнение таблицы уточнений (whtr_refinements)
INSERT INTO whtr_refinements (whtr_gradation, goal_training_id, refinement_text_client, refinement_text_trainer) VALUES
-- Gradation: Высокий риск ожирения
('Высокий риск ожирения', 1, '
**Уточнение по здоровью:** Ваш приоритет — здоровье. Начните с ходьбы и простых упражнений, чтобы сердце и суставы привыкли к нагрузке. Каждый шаг важен!', '
**Уточнение по WHtR (Высокий риск):** Задача - безопасно ввести клиента в процесс. Строгий контроль ЧСС (не выше 60-70% от макс.). Избегать ударных и осевых нагрузок.'),
-- Gradation: Повышенный риск ожирения
('Повышенный риск ожирения', 1, '
**Уточнение по здоровью:** Вы на верном пути! Ваша задача — ускорить метаболизм. Сочетайте кардио и силовые тренировки.', '
**Уточнение по WHtR (Повышенный риск):** Можно вводить интервальное кардио. Силовой тренинг - ключ к изменению композиции тела. Строгий контроль питания.'),
-- Gradation: Норма
('Норма', 3, '
**Уточнение по здоровью:** Отличная форма! Ваша цель — отточить детали. Можете работать над "проблемными" зонами или просто поддерживать результат.', '
**Уточнение по WHtR (Норма):** Клиент готов к любым видам нагрузок. Можно применять продвинутые методики: суперсеты, дроп-сеты, круговые.'),
-- Gradation: Повышенный риск истощения
('Повышенный риск истощения', 2, '
**Уточнение по здоровью:** Вам нужно больше энергии и силы. Основа — силовые упражнения. Не бойтесь углеводов — это топливо для мышц.', '
**Уточнение по WHtR (Повышенный риск истощения):** Обеспечить профицит калорий. Кардио - минимум. Упор на базовые многосуставные упражнения.'),
-- Gradation: Высокий риск истощения
('Высокий риск истощения', 2, '
**Уточнение по здоровью:** Ваш организм нуждается в заботе. Тренировки должны быть регулярными, но не чрезмерными. Главное — питание и восстановление.', '
**Уточнение по WHtR (Высокий риск истощения):** Консервативная программа: 2-3 силовые в неделю. Избегать перетренированности. Контроль сна и стресса.');

-- Добавим записи для других целей для полноты картины
INSERT INTO whtr_refinements (whtr_gradation, goal_training_id, refinement_text_client, refinement_text_trainer)
SELECT 
    w.gradation, 
    g.id, 
    '
**Общее уточнение:** Следуйте базовым рекомендациям, соответствующим вашей цели.',
    '
**Общее уточнение:** Адаптируйте базовую программу под клиента, учитывая его текущее состояние и цель.'
FROM 
    (VALUES ('Высокий риск ожирения'), ('Повышенный риск ожирения'), ('Норма'), ('Повышенный риск истощения'), ('Высокий риск истощения')) AS w(gradation),
    goals_training AS g
WHERE 
    -- Исключаем комбинации, которые мы уже вставили вручную
    NOT (w.gradation = 'Высокий риск ожирения' AND g.id = 1) AND
    NOT (w.gradation = 'Повышенный риск ожирения' AND g.id = 1) AND
    NOT (w.gradation = 'Норма' AND g.id = 3) AND
    NOT (w.gradation = 'Повышенный риск истощения' AND g.id = 2) AND
    NOT (w.gradation = 'Высокий риск истощения' AND g.id = 2);


-- 5. Таблица для хранения сгенерированных AI рекомендаций (опционально, на будущее)
CREATE TABLE ai_recommendation_cache (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    profile_snapshot JSONB NOT NULL, -- "Портрет" клиента на момент запроса
    recommendation_text TEXT NOT NULL, -- Ответ от AI
    ai_model VARCHAR(50), -- 'deepseek', 'yandexgpt' и т.д.
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, created_at) -- Можно хранить историю, убрав UNIQUE
);

-- 6. Таблицы биоимпеданса
CREATE TABLE bioimpedance_start (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    date_time TIMESTAMPTZ NOT NULL,
    fat_percentage REAL,
    muscle_mass REAL,
    water_percentage REAL,
    visceral_fat INTEGER,
    bmc REAL,
    bmi REAL,
    metabolism INTEGER,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);

CREATE TABLE bioimpedance_finish (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    date_time TIMESTAMPTZ NOT NULL,
    fat_percentage REAL,
    muscle_mass REAL,
    water_percentage REAL,
    visceral_fat INTEGER,
    bmc REAL,
    bmi REAL,
    metabolism INTEGER,
    company_id BIGINT DEFAULT -1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id),
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_bioimpedance_start_user_id ON bioimpedance_start(user_id);
CREATE INDEX IF NOT EXISTS idx_bioimpedance_finish_user_id ON bioimpedance_finish(user_id);

-- Добавление начальных антропометрических данных для тестового клиента
DO $$
DECLARE
    client_user_id BIGINT;
    admin_user_id BIGINT;
BEGIN
    -- Находим ID тестового клиента и админа
    SELECT id INTO client_user_id FROM users WHERE email = 'client@fitman.ru';
    SELECT id INTO admin_user_id FROM users WHERE email = 'admin@fitman.ru';

    -- Если клиент найден, вставляем данные
    IF client_user_id IS NOT NULL THEN
        -- Вставляем или обновляем фиксированные данные
        INSERT INTO anthropometry_fix (user_id, height, wrist_circ, ankle_circ, created_by, updated_by)
        VALUES (client_user_id, 170, 16, 22, admin_user_id, admin_user_id)
        ON CONFLICT (user_id) DO UPDATE SET
            height = EXCLUDED.height,
            wrist_circ = EXCLUDED.wrist_circ,
            ankle_circ = EXCLUDED.ankle_circ,
            updated_by = EXCLUDED.updated_by,
            updated_at = NOW();

        -- Вставляем или обновляем начальные замеры
        INSERT INTO anthropometry_start (user_id, weight, shoulders_circ, breast_circ, waist_circ, hips_circ, created_by, updated_by)
        VALUES (client_user_id, 65, 100, 90, 70, 95, admin_user_id, admin_user_id)
        ON CONFLICT (user_id) DO UPDATE SET
            weight = EXCLUDED.weight,
            shoulders_circ = EXCLUDED.shoulders_circ,
            breast_circ = EXCLUDED.breast_circ,
            waist_circ = EXCLUDED.waist_circ,
            hips_circ = EXCLUDED.hips_circ,
            updated_by = EXCLUDED.updated_by,
            updated_at = NOW();
    END IF;
END;
$$;
