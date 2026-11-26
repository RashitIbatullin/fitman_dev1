-- Настройки пользователей и индексы выборок модуля users.
-- Миграция идемпотентна: может применяться на существующей схеме.

-- Гарантируем строку настроек для каждого пользователя: код и UI читают
-- send_notifications/hour_notification из user_settings, а не из users.
INSERT INTO user_settings (
  user_id,
  send_notifications,
  hour_notification,
  notification_email,
  notification_push,
  created_by,
  updated_by
)
SELECT
  u.id,
  true,
  2,
  true,
  true,
  u.id,
  u.id
FROM users u
ON CONFLICT (user_id) DO NOTHING;

-- История и фильтры архива.
CREATE INDEX IF NOT EXISTS idx_users_archived_at
  ON users (archived_at);

-- Поиск пользователей по ФИО в списках.
CREATE INDEX IF NOT EXISTS idx_users_name
  ON users (last_name, first_name);

-- Фильтр списка по роли (обратная сторона составного PK user_roles).
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id
  ON user_roles (role_id);

COMMENT ON TABLE user_settings IS
  'Настройки уведомлений пользователя; строка создаётся вместе с users.';
