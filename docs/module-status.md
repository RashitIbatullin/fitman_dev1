# Матрица готовности модулей FitMan

Обновляется после каждой модульной сессии. Обозначения: ✅ — сделано,
⚠️ — частично, ⬜ — не начато.

## Сессия 2. Пользователи и доступ

**Дата:** 23.11.2026  
**Ветка:** `feature/logging-foundation`  
**Связанные документы:** [план логирования и аудита](logging-audit-plan.md),
[шаблон модуля](module-template.md)

| Модуль | Схема | API | UI | Тесты | Лог | Аудит | Статус |
| --- | --- | --- | --- | --- | --- | --- | --- |
| users | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | вертикальный срез |
| rooms | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | вертикальный срез (1b) |
| schedule | ✅ | ⚠️ | ⬜ | ⬜ | ⬜ | ⬜ | — |

### Что сделано по users/access

- миграция `0002_users_settings.sql`: строки `user_settings` для существующих
  пользователей, индексы `users(archived_at)`, `users(last_name, first_name)`,
  `user_roles(role_id)`;
- слои `UsersController → UserService → UserRepository`; сервис владеет
  транзакцией, репозиторий принимает `Session?`;
- аудит в транзакции: `users` (`INSERT/UPDATE/ARCHIVE/RESTORE`),
  `user_roles` (`INSERT/UPDATE`), `user_settings` (`INSERT/UPDATE`),
  `client_profiles`, `employee_profiles`;
- `AuditService` маскирует `password_hash`, `sms_code`, `jwt_refresh_token`
  и токены во вложенных снимках;
- ошибки — через `AppException` (`VALIDATION_ERROR`, `UNAUTHORIZED`,
  `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`), клиенту не уходят SQL и стек;
- чтение и запись `user_settings` (`send_notifications`, `hour_notification`)
  в payload пользователя; `GET/PUT /api/profile/settings` и админские
  `/api/users/<id>/settings`;
- `POST /api/users/<id>/reset-password` и legacy-сброс по email;
  `POST /api/users/<id>/restore`;
- поля фронтенда принимаются и в camelCase, и в snake_case
  (`first_name`, `send_notification`, `archived_at` и т. д.);
- аутентификация: вход только по телефону, архивная учётная запись
  блокируется; самостоятельная регистрация — только роль `client`;
- логи: создание/обновление/архивация/восстановление/смена ролей/сброс пароля/
  настройки/аватар пишут `entity`, `entity_id`, `actor_id`, `request_id`;
  телефоны, email и пароли не логируются.

### Тесты

- `backend/test/users/user_policy_test.dart` — политика паролей, ролей,
  архивации (всегда);
- `backend/test/users/user_service_integration_test.dart` — транзакционный
  сервис на фейковом репозитории: аудит, конфликт email, отказ по ролям;
- `backend/test/audit/audit_integration_test.dart` — маскирование снимков;
  DB-тесты требуют `RUN_DB_TESTS=true`.

### Осознанно не сделано в сессии 2

- RLS и контекст актора на уровне PostgreSQL — техдолг из плана (этап 7);
- пагинация списка пользователей;
- блокировка после 5 неудачных входов и словарная проверка паролей;
- вход по email (сейчас только телефон) и смена пароля при первом входе;
- `notification_email`/`notification_push` в API и UI;
- экран истории аудита и frontend-контракт `ApiException` — сессии 5 и 14;
- аудит связей менеджер–клиент/инструктор/тренер — до сессии групп.

### Следующая сессия

Сессия 3 — справочники: цели, уровни, виды активности, типы тела,
типы упражнений, BMR-формулы; API справочников и экраны-заглушки.
