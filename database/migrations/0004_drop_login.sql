-- Вход по телефону или email.
--
-- Поле users.login было техническим дублем email/телефона и только путало:
-- аутентификация давно идёт по телефону, email — второй идентификатор.
-- Теперь идентификатор один из двух: users.phone или users.email.
--
-- Идемпотентна: повторный запуск безопасен.

-- Email сравнивается без учёта регистра: Ivan@mail.ru и ivan@mail.ru — один
-- человек. Индекс создаётся до удаления login: если в базе найдутся дубли
-- по регистру, миграция остановится здесь, а не после потери колонки.
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email_lower
  ON users (lower(email))
  WHERE email IS NOT NULL;

ALTER TABLE users DROP COLUMN IF EXISTS login;

COMMENT ON COLUMN users.phone IS
  'Основной идентификатор входа и контакт; обязателен при создании.';
COMMENT ON COLUMN users.email IS
  'Второй идентификатор входа (без учёта регистра) и контакт; опционален.';
