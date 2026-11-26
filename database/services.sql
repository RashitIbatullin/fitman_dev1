-- Домен «Услуги»: каталог, оформление, списания, заморозки, возвраты,
-- записи на услуги, результаты, лицевые счета, карты и посещения.
--
-- Полный скрипт домена (пересоздание с нуля). Для существующей базы
-- применяйте инкрементальную миграцию database/migrations/0003_services.sql.
-- Порядок запуска: users.sql -> lessons.sql -> groups.sql -> infrastructure.sql
-- -> equipment.sql -> services.sql.

-- Удаление в обратном порядке зависимостей
DROP TABLE IF EXISTS
  medical_clearances,
  visits,
  card_scans,
  personal_cards,
  gift_documents,
  payments,
  account_transactions,
  accounts,
  service_results,
  appointments,
  visit_plans,
  service_refunds,
  service_freezes,
  service_usages,
  purchase_quota_periods,
  purchase_participants,
  service_purchases,
  service_access_rules,
  service_zones,
  access_points,
  access_zones,
  service_price_levels,
  services,
  service_types,
  employee_specializations,
  specializations
CASCADE;

-- 1. Специализации сотрудников: массаж, косметология, СПА, ЛФК…
CREATE TABLE specializations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  description TEXT,
  is_medical BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id)
);

CREATE TABLE employee_specializations (
  employee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  specialization_id UUID NOT NULL REFERENCES specializations(id) ON DELETE CASCADE,
  level SMALLINT NOT NULL DEFAULT 1,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  PRIMARY KEY (employee_id, specialization_id),
  CONSTRAINT chk_employee_specialization_level CHECK (level BETWEEN 1 AND 3)
);

-- 2. Типы услуг
CREATE TABLE service_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id)
);

-- 3. Каталог услуг
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  service_type_id UUID NOT NULL REFERENCES service_types(id),
  base_price NUMERIC(12,2),                 -- NULL: услуга без стоимости
  currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
  duration_days INTEGER,
  -- Ограничение доступа: 0 безлимит, 1 общий лимит, 2 квота на период
  usage_limit_mode SMALLINT NOT NULL DEFAULT 1,
  max_uses INTEGER,
  quota_period SMALLINT,                    -- 1 день, 2 неделя, 3 месяц
  quota_limit INTEGER,
  max_visits_per_day INTEGER NOT NULL DEFAULT 1,
  guest_visits_included INTEGER NOT NULL DEFAULT 0,
  allow_stacking BOOLEAN NOT NULL DEFAULT true,
  grants_access BOOLEAN NOT NULL DEFAULT true, -- false для сборов и пакетов заморозки
  executor_specialization_id UUID REFERENCES specializations(id),
  duration_minutes INTEGER,
  requires_room BOOLEAN NOT NULL DEFAULT false,
  participants_limit INTEGER NOT NULL DEFAULT 1,
  freeze_days_granted INTEGER,
  is_gift BOOLEAN NOT NULL DEFAULT false,
  min_term_days INTEGER,
  training_group_type_id UUID REFERENCES training_group_types(id),
  -- Заморозка
  freeze_allowed BOOLEAN NOT NULL DEFAULT true,
  freeze_max_count INTEGER NOT NULL DEFAULT 0,
  freeze_max_days INTEGER NOT NULL DEFAULT 0,
  freeze_min_days INTEGER NOT NULL DEFAULT 10,
  freeze_after_days INTEGER NOT NULL DEFAULT 0,
  -- Пропуски и сложность
  no_show_policy SMALLINT NOT NULL DEFAULT 0,  -- 0 списать, 1 простить
  late_cancel_hours INTEGER NOT NULL DEFAULT 24,
  complexity_coefficient NUMERIC(4,2) NOT NULL DEFAULT 1.00,
  -- Ограничения оформления
  activation_required BOOLEAN NOT NULL DEFAULT false,
  min_age INTEGER,
  max_age INTEGER,
  gender_restriction SMALLINT NOT NULL DEFAULT 0,
  requires_medical_check BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  CONSTRAINT chk_services_limit CHECK (
    usage_limit_mode NOT IN (0, 1, 2)
    OR (usage_limit_mode = 2 AND quota_period IS NOT NULL AND quota_limit > 0)
    OR (usage_limit_mode = 1 AND max_uses IS NOT NULL)
    OR usage_limit_mode = 0
  ),
  CONSTRAINT chk_services_participants CHECK (participants_limit >= 1),
  CONSTRAINT chk_services_complexity CHECK (complexity_coefficient > 0)
);

CREATE INDEX idx_services_type ON services (service_type_id);
CREATE INDEX idx_services_active ON services (is_active) WHERE archived_at IS NULL;

-- 4. Цены по уровню исполнителя
CREATE TABLE service_price_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  executor_level SMALLINT NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (service_id, executor_level),
  CONSTRAINT chk_price_level CHECK (executor_level BETWEEN 1 AND 3),
  CONSTRAINT chk_price_positive CHECK (price >= 0)
);

-- 5. Зоны и точки доступа
CREATE TABLE access_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  room_id UUID REFERENCES rooms(id),
  open_from TIME,
  open_to TIME,
  is_active BOOLEAN NOT NULL DEFAULT true,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE access_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  access_zone_id UUID REFERENCES access_zones(id),
  equipment_item_id UUID REFERENCES equipment_items(id),
  is_active BOOLEAN NOT NULL DEFAULT true,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE service_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  access_zone_id UUID NOT NULL REFERENCES access_zones(id),
  UNIQUE (service_id, access_zone_id)
);

CREATE TABLE service_access_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  weekdays SMALLINT NOT NULL DEFAULT 127,   -- битовая маска Пн..Вс
  time_from TIME,
  time_to TIME,
  is_active BOOLEAN NOT NULL DEFAULT true
);

-- 6. Оформленные услуги
CREATE TABLE service_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES users(id),
  service_id UUID NOT NULL REFERENCES services(id),
  training_group_id UUID REFERENCES training_groups(id),
  trainer_id UUID REFERENCES users(id),
  sold_by UUID REFERENCES users(id),
  invoice_number VARCHAR(50) UNIQUE,
  purchase_price NUMERIC(12,2),
  discount_percent NUMERIC(5,2) NOT NULL DEFAULT 0,
  discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  final_price NUMERIC(12,2),
  payment_status SMALLINT NOT NULL DEFAULT 0,  -- 0 не требуется, 1 оплачено, 2 долг
  payment_source SMALLINT,                     -- 1 счёт, 2 касса, 3 терминал, 4 1С, 5 нет
  purchase_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  activation_date TIMESTAMPTZ,
  expiry_date TIMESTAMPTZ,
  actual_expiry_date TIMESTAMPTZ,
  total_uses INTEGER,                          -- NULL для безлимитных
  used_uses INTEGER NOT NULL DEFAULT 0,
  status SMALLINT NOT NULL DEFAULT 0,          -- 0 черновик, 1 активна, 2 заморожена,
                                               -- 3 исчерпана, 4 истекла, 5 отменена,
                                               -- 6 возвращена
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  CONSTRAINT chk_purchase_uses CHECK (used_uses >= 0),
  CONSTRAINT chk_purchase_uses_limit CHECK (total_uses IS NULL OR used_uses <= total_uses)
);

CREATE INDEX idx_service_purchases_client_status
  ON service_purchases (client_id, status, actual_expiry_date);
CREATE INDEX idx_service_purchases_service
  ON service_purchases (service_id);

-- Участники совместной покупки («для двоих», гостевой визит)
CREATE TABLE purchase_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id UUID NOT NULL REFERENCES service_purchases(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES users(id),
  role SMALLINT NOT NULL DEFAULT 1,   -- 1 владелец, 2 участник, 3 гость
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_by UUID REFERENCES users(id),
  UNIQUE (purchase_id, client_id)
);

-- Квоты по периодам («8 посещений в месяц»)
CREATE TABLE purchase_quota_periods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id UUID NOT NULL REFERENCES service_purchases(id) ON DELETE CASCADE,
  period_start TIMESTAMPTZ NOT NULL,
  period_end TIMESTAMPTZ NOT NULL,
  quota_limit INTEGER NOT NULL,
  quota_used INTEGER NOT NULL DEFAULT 0,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (purchase_id, period_start),
  CONSTRAINT chk_quota_used CHECK (quota_used >= 0 AND quota_used <= quota_limit),
  CONSTRAINT chk_quota_period CHECK (period_end > period_start)
);

CREATE INDEX idx_quota_periods_purchase ON purchase_quota_periods (purchase_id, period_start DESC);

-- 7. Журнал списаний — источник истины по остатку
CREATE TABLE service_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id UUID NOT NULL REFERENCES service_purchases(id),
  client_id UUID NOT NULL REFERENCES users(id),
  lesson_id UUID REFERENCES lessons(id),
  visit_id UUID,
  status SMALLINT NOT NULL DEFAULT 0,   -- 0 резерв, 1 списано, 2 освобождено
  consumed_at TIMESTAMPTZ,
  consumed_by UUID REFERENCES users(id),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id)
);

CREATE UNIQUE INDEX ux_usage_lesson
  ON service_usages (lesson_id)
  WHERE lesson_id IS NOT NULL AND status IN (0, 1);
CREATE INDEX idx_service_usages_purchase ON service_usages (purchase_id, status);
CREATE INDEX idx_service_usages_client ON service_usages (client_id);

-- 8. Заморозки
CREATE TABLE service_freezes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id UUID NOT NULL REFERENCES service_purchases(id),
  client_id UUID NOT NULL REFERENCES users(id),
  freeze_start TIMESTAMPTZ NOT NULL,
  freeze_end TIMESTAMPTZ NOT NULL,
  freeze_days INTEGER NOT NULL,
  reason_code SMALLINT,                -- 1 болезнь, 2 отпуск, 3 командировка, 4 иное
  reason TEXT,
  document_url TEXT,
  status SMALLINT NOT NULL DEFAULT 0,  -- 0 заявка, 1 одобрена, 2 отклонена,
                                       -- 3 завершена, 4 отменена
  freeze_package_id UUID REFERENCES service_purchases(id),
  paid_days INTEGER NOT NULL DEFAULT 0,
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  CONSTRAINT chk_freeze_days CHECK (freeze_days > 0),
  CONSTRAINT chk_freeze_period CHECK (freeze_end > freeze_start)
);

CREATE INDEX idx_service_freezes_purchase ON service_freezes (purchase_id, status);

-- 9. Возвраты при расторжении
CREATE TABLE service_refunds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id UUID NOT NULL REFERENCES service_purchases(id),
  client_id UUID NOT NULL REFERENCES users(id),
  used_uses INTEGER NOT NULL,
  unit_price NUMERIC(12,2) NOT NULL,
  used_amount NUMERIC(12,2) NOT NULL,
  retention_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  refund_amount NUMERIC(12,2) NOT NULL,
  basis TEXT NOT NULL,
  method SMALLINT,                     -- 1 касса, 2 терминал, 3 1С, 4 счёт
  status SMALLINT NOT NULL DEFAULT 0,  -- 0 заявка, 1 утверждён, 2 выплачен, 3 отклонён
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  CONSTRAINT chk_refund_amount CHECK (refund_amount >= 0)
);

CREATE UNIQUE INDEX ux_refund_purchase ON service_refunds (purchase_id);

-- 10. Программы посещений
CREATE TABLE visit_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES users(id),
  service_id UUID NOT NULL REFERENCES services(id),
  executor_id UUID REFERENCES users(id),
  sessions_planned INTEGER NOT NULL,
  sessions_done INTEGER NOT NULL DEFAULT 0,
  periodicity_days INTEGER,
  valid_from DATE NOT NULL DEFAULT CURRENT_DATE,
  valid_to DATE,
  basis TEXT,
  status SMALLINT NOT NULL DEFAULT 0,  -- 0 активна, 1 завершена, 2 прервана
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  CONSTRAINT chk_plan_sessions CHECK (sessions_planned > 0 AND sessions_done >= 0),
  CONSTRAINT chk_plan_period CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

-- 11. Записи на услуги (не занятия)
CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES users(id),
  service_id UUID NOT NULL REFERENCES services(id),
  purchase_id UUID REFERENCES service_purchases(id),
  plan_id UUID REFERENCES visit_plans(id),
  executor_id UUID REFERENCES users(id),
  start_at TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER,
  service_description TEXT,
  note TEXT,
  status SMALLINT NOT NULL DEFAULT 0,  -- 0 назначено, 1 выполнено, 2 пропущено,
                                       -- 3 перенесено, 4 отменено, 5 отказ
  skip_party SMALLINT,                 -- 1 клиент, 2 сотрудник, 3 администрация
  skip_reason SMALLINT,
  rescheduled_to UUID REFERENCES appointments(id),
  visit_id UUID,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id),
  CONSTRAINT chk_appointment_skip CHECK (
    status <> 2 OR (skip_party IS NOT NULL AND skip_reason IS NOT NULL)
  )
);

CREATE INDEX idx_appointments_executor_time ON appointments (executor_id, start_at);
CREATE INDEX idx_appointments_client_time ON appointments (client_id, start_at DESC);

-- 12. Результаты услуг
CREATE TABLE service_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID REFERENCES appointments(id),
  visit_id UUID,
  client_id UUID NOT NULL REFERENCES users(id),
  result_type SMALLINT NOT NULL DEFAULT 1, -- 1 файл, 2 показатели, 3 заключение
  ready_at TIMESTAMPTZ,
  file_url VARCHAR(255),
  summary TEXT,
  issued_by UUID REFERENCES users(id),
  status SMALLINT NOT NULL DEFAULT 0,     -- 0 ожидается, 1 готов, 2 выдан клиенту
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id)
);

CREATE INDEX idx_service_results_client ON service_results (client_id, status);

-- 13. Лицевые счета
CREATE TABLE accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE REFERENCES users(id),
  account_number VARCHAR(50) NOT NULL UNIQUE,
  balance NUMERIC(12,2) NOT NULL DEFAULT 0,
  credit_limit NUMERIC(12,2) NOT NULL DEFAULT 0,
  currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
  status SMALLINT NOT NULL DEFAULT 0,   -- 0 активен, 1 заблокирован, 2 закрыт
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id)
);

-- 14. Проводки (append-only)
CREATE TABLE account_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID NOT NULL REFERENCES accounts(id),
  operation_key VARCHAR(100) NOT NULL UNIQUE,
  transaction_type SMALLINT NOT NULL,   -- 1 пополнение, 2 покупка, 3 возврат,
                                        -- 4 списание, 5 корректировка
  fund_type SMALLINT NOT NULL DEFAULT 1, -- 1 основные, 2 бонусные, 3 залоговые
  amount NUMERIC(12,2) NOT NULL,
  balance_before NUMERIC(12,2) NOT NULL,
  balance_after NUMERIC(12,2) NOT NULL,
  purchase_id UUID REFERENCES service_purchases(id),
  payment_id UUID,
  description TEXT NOT NULL,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  CONSTRAINT chk_transaction_amount CHECK (amount > 0)
);

CREATE INDEX idx_account_transactions_account
  ON account_transactions (account_id, created_at DESC);

-- 15. Записи об оплате (деньги приняты вне FitMan)
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES users(id),
  purchase_id UUID REFERENCES service_purchases(id),
  amount NUMERIC(12,2) NOT NULL,
  currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
  method SMALLINT NOT NULL,                   -- 1 наличные, 2 карта, 3 СБП, 4 перевод
  source_system SMALLINT NOT NULL DEFAULT 5,  -- 1 касса клуба, 2 терминал, 3 эквайринг,
                                              -- 4 1С, 5 ручной ввод
  document_number VARCHAR(100),
  status SMALLINT NOT NULL DEFAULT 0,         -- 0 ожидание, 1 успех, 2 отказ, 3 возврат
  external_id VARCHAR(100) UNIQUE,
  purpose TEXT,
  registered_by UUID REFERENCES users(id),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  CONSTRAINT chk_payment_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_client ON payments (client_id, created_at DESC);

-- 16. Подарочные сертификаты и карты
CREATE TABLE gift_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  gift_type SMALLINT NOT NULL,          -- 1 сертификат на услугу, 2 номинал/карта
  service_id UUID REFERENCES services(id),
  nominal_amount NUMERIC(12,2),
  remaining_amount NUMERIC(12,2),
  status SMALLINT NOT NULL DEFAULT 0,   -- 0 выпущен, 1 активирован, 2 погашен,
                                        -- 3 истёк, 4 заблокирован
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  issued_by UUID REFERENCES users(id),
  activated_client_id UUID REFERENCES users(id),
  activated_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  payment_id UUID REFERENCES payments(id),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  CONSTRAINT chk_gift_activation CHECK (status <> 1 OR activated_at IS NOT NULL)
);

-- 17. Персональные карты
CREATE TABLE personal_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES users(id),
  card_number VARCHAR(50) NOT NULL UNIQUE,
  card_uid VARCHAR(100) UNIQUE,
  card_type SMALLINT NOT NULL DEFAULT 0,   -- 0 пластик, 1 брелок, 2 виртуальная
  is_primary BOOLEAN NOT NULL DEFAULT true,
  status SMALLINT NOT NULL DEFAULT 0,      -- 0 активна, 1 заблокирована,
                                           -- 2 утеряна, 3 истекла, 4 перевыпущена
  issue_date TIMESTAMPTZ DEFAULT NOW(),
  expiry_date TIMESTAMPTZ,
  last_used_at TIMESTAMPTZ,
  usage_count INTEGER NOT NULL DEFAULT 0,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id)
);

CREATE UNIQUE INDEX ux_primary_card_per_client
  ON personal_cards (client_id)
  WHERE is_primary AND status IN (0, 1);

CREATE TABLE card_scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  card_id UUID NOT NULL REFERENCES personal_cards(id),
  client_id UUID NOT NULL REFERENCES users(id),
  access_point_id UUID REFERENCES access_points(id),
  context SMALLINT NOT NULL DEFAULT 0,  -- 0 вход, 1 зона, 2 занятие, 3 оплата
  result SMALLINT NOT NULL,             -- 0 разрешено, 1 отказ, 2 нужна оплата
  denial_reason VARCHAR(255),
  visit_id UUID,
  scanned_at TIMESTAMPTZ DEFAULT NOW(),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_card_scans_card ON card_scans (card_id, scanned_at DESC);

-- 18. Посещения
CREATE TABLE visits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES users(id),
  access_zone_id UUID REFERENCES access_zones(id),
  access_point_id UUID REFERENCES access_points(id),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  service_name VARCHAR(255),
  service_description TEXT,
  note TEXT,
  plan_id UUID REFERENCES visit_plans(id),
  appointment_id UUID REFERENCES appointments(id),
  purchase_id UUID REFERENCES service_purchases(id),
  source SMALLINT NOT NULL DEFAULT 0,   -- 0 карта, 1 приложение, 2 вручную
  usage_id UUID REFERENCES service_usages(id),
  payment_status SMALLINT NOT NULL DEFAULT 0, -- 0 не требуется, 1 оплачено, 2 долг
  amount NUMERIC(12,2),
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  CONSTRAINT chk_visit_times CHECK (finished_at IS NULL OR finished_at >= started_at)
);

CREATE INDEX idx_visits_client ON visits (client_id, started_at DESC);

-- 19. Медицинские допуски
CREATE TABLE medical_clearances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES users(id),
  scope SMALLINT NOT NULL DEFAULT 0,   -- 0 общий, 1 бассейн, 2 ЛФК, 3 интенсивные
  status SMALLINT NOT NULL DEFAULT 0,  -- 0 действует, 1 истёк, 2 отозван
  valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  valid_to TIMESTAMPTZ,
  conclusion TEXT,
  restrictions TEXT,
  document_url VARCHAR(255),
  issued_by UUID REFERENCES users(id),
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  revoked_by UUID REFERENCES users(id),
  revoked_at TIMESTAMPTZ,
  revoke_reason TEXT,
  company_id UUID DEFAULT '00000000-0000-0000-0000-000000000000',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  CONSTRAINT chk_clearance_period CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE INDEX idx_medical_clearances_client ON medical_clearances (client_id, status);

-- ============================================================================
-- Триггеры
-- ============================================================================

-- Проводки неизменяемы: исправление только обратной проводкой.
CREATE OR REPLACE FUNCTION forbid_account_transaction_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'account_transactions is append-only';
END;
$$;

CREATE TRIGGER account_transactions_no_update_delete
  BEFORE UPDATE OR DELETE ON account_transactions
  FOR EACH ROW EXECUTE FUNCTION forbid_account_transaction_mutation();

-- Остаток покупки пересчитывается из журнала списаний.
CREATE OR REPLACE FUNCTION recount_purchase_used_uses()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_id UUID;
  old_id UUID;
BEGIN
  IF TG_OP = 'DELETE' THEN
    target_id := OLD.purchase_id;
  ELSE
    target_id := NEW.purchase_id;
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.purchase_id <> NEW.purchase_id THEN
    old_id := OLD.purchase_id;
  ELSE
    old_id := NULL;
  END IF;

  UPDATE service_purchases p
     SET used_uses = (
           SELECT COUNT(*) FROM service_usages u
            WHERE u.purchase_id = p.id AND u.status = 1
         ),
         updated_at = NOW()
   WHERE p.id = target_id OR p.id = old_id;

  RETURN NULL;
END;
$$;

CREATE TRIGGER service_usages_recount
  AFTER INSERT OR UPDATE OR DELETE ON service_usages
  FOR EACH ROW EXECUTE FUNCTION recount_purchase_used_uses();

-- Баланс счёта = сумма проводок с учётом направления.
CREATE OR REPLACE FUNCTION recount_account_balance()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE accounts a
     SET balance = COALESCE((
           SELECT SUM(CASE
                        WHEN t.transaction_type IN (1, 3) THEN t.amount
                        WHEN t.transaction_type IN (2, 4) THEN -t.amount
                        ELSE t.amount
                      END)
             FROM account_transactions t
            WHERE t.account_id = a.id
         ), 0),
         updated_at = NOW()
   WHERE a.id = NEW.account_id;

  RETURN NULL;
END;
$$;

CREATE TRIGGER account_transactions_recount_balance
  AFTER INSERT ON account_transactions
  FOR EACH ROW EXECUTE FUNCTION recount_account_balance();

COMMENT ON TABLE services IS
  'Каталог услуг: абонементы, разовые, пакеты, курсы, сборы, подарочные документы.';
COMMENT ON TABLE service_purchases IS
  'Оформленные услуги клиента; остаток считается из service_usages.';
COMMENT ON TABLE service_usages IS
  'Журнал резерва и списания занятий/посещений — источник истины по остатку.';
COMMENT ON TABLE account_transactions IS
  'Проводки по лицевому счёту, append-only.';
COMMENT ON TABLE appointments IS
  'Записи на услуги с исполнителем; без сетки слотов и контроля пересечений.';
COMMENT ON TABLE visits IS
  'Факт посещения: начало, окончание, услуга, списание.';

-- ============================================================================
-- Базовые справочники
-- ============================================================================

INSERT INTO service_types (code, title) VALUES
  ('club_membership',    'Клубная карта (полный доступ)'),
  ('zone_membership',    'Абонемент на зону'),
  ('limited_membership', 'Лимитированный абонемент'),
  ('group_membership',   'Абонемент на групповые занятия'),
  ('day_membership',     'Дневной / утренний абонемент'),
  ('single_visit',       'Разовое посещение'),
  ('guest_pass',         'Гостевой визит'),
  ('trial',              'Пробное посещение'),
  ('single_training',    'Персональная разовая тренировка'),
  ('training_package',   'Пакет персональных тренировок'),
  ('group_course',       'Курс групповых занятий'),
  ('studio_service',     'Студийная услуга с исполнителем'),
  ('studio_package',     'Пакет процедур'),
  ('program_design',     'Составление программы тренировок'),
  ('freeze_package',     'Пакет заморозки'),
  ('service_fee',        'Сервисный сбор'),
  ('gift_certificate',   'Подарочный сертификат'),
  ('gift_card',          'Подарочная карта'),
  ('medical_test',       'Взятие анализов, обследование');

INSERT INTO specializations (code, title, is_medical) VALUES
  ('massage',            'Массаж', false),
  ('spa',                'СПА-процедуры', false),
  ('cosmetology',        'Косметология', false),
  ('solarium',           'Солярий', false),
  ('lfk',                'ЛФК', true),
  ('nutrition',          'Консультация по питанию', false),
  ('group_instructor',   'Инструктор групповых программ', false),
  ('personal_trainer',   'Персональный тренер', false),
  ('physician',          'Врач', true),
  ('nurse',              'Медсестра', true);

INSERT INTO roles (name, title) VALUES
  ('executor', 'Исполнитель услуг')
ON CONFLICT (name) DO NOTHING;

-- Отложенная ссылка на домен услуг из занятий (таблица создана выше).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
     WHERE table_name = 'lessons' AND column_name = 'service_purchase_id'
  ) THEN
    ALTER TABLE lessons
      ADD COLUMN service_purchase_id UUID REFERENCES service_purchases(id);
  END IF;
END;
$$;
