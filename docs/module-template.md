# Шаблон backend-модуля FitMan

**Назначение:** единый порядок для модулей после foundation 1a/1b.
Основа — `controller → service → repository`, ошибки через `AppException`,
аудит в транзакции изменения, актор и `request_id` передаются явно.

---

## 1. Слои

| Слой | Ответственность | Не делает |
| --- | --- | --- |
| Controller | HTTP, разбор тела, `AuditContext`, вызов сервиса, ответ | SQL, бизнес-правила |
| Service | бизнес-правила, транзакция, аудит | HTTP-статусы, JSON |
| Repository | SQL, маппинг строк | аудит, бизнес-правила |

Правило: **один write-path — одна транзакция**. Изменение и
`AuditService.record(...)` коммитятся или откатываются вместе.

---

## 2. Контроллер

```dart
Future<Response> update(Request request, String id) async {
  try {
    final user = request.context['user'] as User?;
    if (user == null) {
      throw const UnauthorizedException('Требуется авторизация');
    }

    final body = await request.readAsString();
    final model = Model.fromJson(jsonDecode(body) as Map<String, dynamic>);

    final updated = await _service.update(
      id,
      model,
      audit: AuditContext.fromRequest(request, user: user),
    );

    return Response.ok(jsonEncode(updated.toJson()));
  } on AppException {
    rethrow;
  } catch (error, stackTrace) {
    throw InternalException(cause: error, stackTrace: stackTrace);
  }
}
```

Не логировать тело запроса, телефон, email, пароли и токены.

---

## 3. Сервис

```dart
Future<Model> update(String id, Model model, {required AuditContext audit}) {
  return _database.runTx((session) async {
    final oldModel = await _repository.getById(id, session: session);
    if (oldModel == null) {
      throw const NotFoundException('Запись не найдена');
    }

    final updated = await _repository.update(id, model, session: session);

    await _auditService.record(
      session: session,
      tableName: 'models',
      rowPk: id,
      action: 'UPDATE',
      context: audit,
      oldValues: oldModel.toJson(),
      newValues: updated.toJson(),
    );

    return updated;
  });
}
```

Действия аудита: `INSERT`, `UPDATE`, `DELETE`, `ARCHIVE`, `RESTORE`.
`source`: `api`, `system`, `offline`, `job`.

Проверки, которые должны откатывать транзакцию, бросают
`ConflictException` / `ValidationException` / `NotFoundException`.

---

## 4. Репозиторий

```dart
Future<Model> update(String id, Model model, {Session? session}) async {
  final conn = session ?? await _db.connection;
  await conn.execute(Sql.named('UPDATE models SET ... WHERE id = @id'), parameters: {...});
  return (await getById(id, session: session))!;
}
```

- `Session?` обязателен для методов, участвующих в транзакции.
- Без `session` метод работает через обычное соединение, чтобы не ломать чтение.
- Вложенные `runTx` внутри репозитория не открывать: транзакцией владеет сервис.

---

## 5. Аудит

`AuditService.record(...)` пишет в `audit_log`:

- `changed_by` — `actorId`, может быть `null` для системных операций;
- `actor_role` — роль актора;
- `request_id` — из `RequestContext`;
- `old_values` / `new_values` — снимки только для диагностики, без ПДн;
- `reason` — для архивации/удаления, если есть.

`audit_log` append-only: `UPDATE`, `DELETE` и `TRUNCATE` запрещены
guard-триггером. Не пытаться чистить журнал из приложения.

---

## 6. Ошибки

- клиенту — `{"error":{"code","message","requestId"}}`;
- внутренние детали — только в лог через `errorHandler`;
- не возвращать `e.toString()` и SQL-текст;
- 5xx логируются с `request_id` и стеком автоматически.

---

## 7. Чек-лист модуля

- [ ] миграция таблицы/индексов добавлена в `database/migrations`;
- [ ] controller извлекает `AuditContext` из запроса;
- [ ] сервис открывает транзакцию и пишет аудит в неё;
- [ ] repository принимает `Session?`;
- [ ] нет `print()` и `e.toString()` в ответах;
- [ ] есть тест happy path и один отказ;
- [ ] интеграционный тест аудита: commit → запись, rollback → нет записи;
- [ ] `dart analyze` и `dart test` проходят.
