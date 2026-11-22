# Функциональные требования / Аудит и журнал событий (Audit Log)

*Часть 2 | источник: Требования ТЗ фитнес-тренинг часть 2.docx | [индекс](../INDEX.md)*

  - Цель
Обеспечить полную прослеживаемость изменений любых данных системы (клиенты, сотрудники, расписания, справочники, архивация/восстановление) без физического хранения версий строк.
  - Единая таблица аудита
Создаётся одна таблица на всю БД:
```sql
CREATE TABLE audit_log (
id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
table_name    text      NOT NULL,                       -- имя таблицы-источника
row_pk        uuid      NOT NULL,                       -- PK изменённой строки
action        text      NOT NULL CHECK (action IN (
 'INSERT','UPDATE','DELETE','ARCHIVE','RESTORE')),
changed_at    timestamptz DEFAULT now(),
changed_by    uuid      REFERENCES users(id),
old_values    jsonb,                                    -- предыдущие значения (NULL при INSERT)
new_values    jsonb                                     -- новые значения (NULL при DELETE)
);
Триггеры
Для каждой таблицы автоматически создаются триггеры AFTER INSERT, AFTER UPDATE, AFTER DELETE (через миграцию или генератор кода).
Триггер:
заполняет table_name = TG_TABLE_NAME,
row_pk = NEW.id / OLD.id,
action по типу операции,
changed_by = current_user_id() (из RLS-сессии),
old_values = to_jsonb(OLD), new_values = to_jsonb(NEW).
При архивации/восстановлении (команды ArchiveEntityCommand / RestoreEntityCommand) триггер фиксирует action = 'ARCHIVE' или 'RESTORE'.
Доступ к журналу
Просмотр аудита доступен только роли Администратор.
В карточке любой сущности кнопка «История» открывает список записей audit_log отфильтрованных по table_name + row_pk, отсортированных по changed_at DESC.
Для удобства чтения поля old_values/new_values отображаются в виде сворачиваемого JSON-дерева; значения дат/чисел форматируются по текущей локали.
Хранение и ротация
Строки хранятся 36 месяцев.
Ежедневным cron-Job (pg_cron или внешний планировщик) удаляются записи старше 36 мес:
sql
DELETE FROM audit_log WHERE changed_at < now() - interval '36 months';
Производительность
Индексы:
(table_name, row_pk, changed_at DESC) – быстрая выборка истории строки.
(changed_at) – быстрая чистка старых данных.
Триггеры объявляются FOR EACH ROW, но только при первичной записи (без каскадных UPDATE-ов) чтобы избежать рекурсии.
Интерфейс
Списочная форма «Аудит» (доступна только администратору): фильтры по периоду, таблице, пользователю, типу действия; экспорт в CSV/XLSX.
Виджет «Последние изменения» на дашборде администратора: 10 последних записей системы.
Безопасность
Таблица audit_log не подлежит архивации (archived_at не добавляется).
Прямое изменение/удаление строк audit_log запрещено триггером BEFORE DELETE / UPDATE (только SELECT и INSERT).
Маскировка чувствительных данных: перед записью в new_values/old_values поля password_hash, sms_code, jwt_refresh_token обнуляются ('::text = '***').
```
