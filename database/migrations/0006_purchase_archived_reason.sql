-- Причина ручной архивации оформленной услуги.
-- Архивация — всегда действие сотрудника, а не автоматический статус.

ALTER TABLE service_purchases
  ADD COLUMN IF NOT EXISTS archived_reason TEXT;

COMMENT ON COLUMN service_purchases.archived_reason IS
  'Причина ручной архивации покупки; NULL для неархивных записей.';
