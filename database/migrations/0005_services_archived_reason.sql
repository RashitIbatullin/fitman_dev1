-- Причина архивации позиции каталога услуг.
-- Нужна для карточки архива и отчёта; удаление, как и везде, заменено архивом.

ALTER TABLE services
  ADD COLUMN IF NOT EXISTS archived_reason TEXT;

COMMENT ON COLUMN services.archived_reason IS
  'Причина архивации позиции каталога; NULL для действующих услуг.';
