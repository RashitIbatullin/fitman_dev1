-- Технический аудит изменений.
-- Хранится 36 месяцев по ТЗ; очистка/партиционирование — отдельной сессией.

CREATE TABLE IF NOT EXISTS audit_log (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name   text NOT NULL,
  row_pk       uuid NOT NULL,
  action       text NOT NULL,
  changed_at   timestamptz NOT NULL DEFAULT now(),
  changed_by   uuid REFERENCES users(id),
  actor_role   text,
  request_id   uuid,
  source       text NOT NULL DEFAULT 'api',
  reason       text,
  old_values   jsonb,
  new_values   jsonb
);

CREATE INDEX IF NOT EXISTS idx_audit_log_table_row_changed
  ON audit_log (table_name, row_pk, changed_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_log_changed_at
  ON audit_log (changed_at);

-- audit_log — append-only: запрещаем UPDATE/DELETE/TRUNCATE на уровне БД.
CREATE OR REPLACE FUNCTION forbid_audit_log_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'audit_log is append-only';
END;
$$;

DROP TRIGGER IF EXISTS audit_log_no_update_delete ON audit_log;
CREATE TRIGGER audit_log_no_update_delete
  BEFORE UPDATE OR DELETE ON audit_log
  FOR EACH ROW
  EXECUTE FUNCTION forbid_audit_log_mutation();

DROP TRIGGER IF EXISTS audit_log_no_truncate ON audit_log;
CREATE TRIGGER audit_log_no_truncate
  BEFORE TRUNCATE ON audit_log
  FOR EACH STATEMENT
  EXECUTE FUNCTION forbid_audit_log_mutation();

COMMENT ON TABLE audit_log IS
  'Неизменяемый журнал действий; запись только INSERT в транзакции изменения.';
