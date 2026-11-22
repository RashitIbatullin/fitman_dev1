# Функциональные требования / Интеграция с системами бухгалтерского учета

*Часть 2 | источник: Требования ТЗ фитнес-тренинг часть 2.docx | [индекс](../INDEX.md)*

Данный раздел описывает архитектуру, механизмы и требования к интеграции системы «Фитнес-менеджер» с внешними бухгалтерскими и финансовыми системами на примере типовой интеграции с «1С:Предприятие».
Интеграция обеспечивает двусторонний обмен ключевыми бизнес-данными для автоматизации учёта клиентов, платежей, абонементов и посещений.

#### Общие положения

Цель интеграции:
Автоматизация передачи финансово-учётных данных между FitMan и бухгалтерской системой для исключения ручного ввода, минимизации ошибок и обеспечения актуальности данных в обеих системах.

Основные принципы:

Двусторонняя синхронизация: Данные могут передаваться как из FitMan в 1С, так и в обратном направлении (например, обновление реквизитов клиента).

Поддержка различных конфигураций 1С: Интеграция должна быть гибкой и настраиваемой под типовые конфигурации («1С:Бухгалтерия», «1С:Зарплата и управление персоналом», «1С:Управление торговлей»).

Надёжность и отказоустойчивость: Использование очереди сообщений, повторные попытки отправки, логирование всех операций.

Безопасность: Все данные передаются по защищённым каналам (HTTPS), используются ключи API, чувствительные данные шифруются.

#### Синхронизируемые сущности и сценарии

##### Клиенты (физические лица)

Направление: В основном FitMan → 1С (при создании/обновлении клиента).

Данные: ФИО, пол, дата рождения, контакты (телефон, email), дата регистрации.

Сценарий: Новый клиент регистрируется в FitMan → его карточка автоматически создаётся в 1С как контрагент (физическое лицо).

##### Платежи и финансовые операции

Направление: FitMan → 1С.

Данные: Сумма, дата и время оплаты, тип платежа (абонемент, разовое занятие, товар), способ оплаты (наличные, карта, перевод), привязка к клиенту и договору.

Сценарий: Клиент оплачивает абонемент через кассу FitMan → платёж фиксируется в 1С как приходный кассовый ордер (ПКО) или поступление на расчётный счёт.

##### Абонементы и договоры оказания услуг

Направление: Двусторонняя.

Данные: Тип абонемента (месячный, годовой, разовый), срок действия, стоимость, статус (активен, приостановлен, завершён), привязка к клиенту.

Сценарий: Менеджер оформляет в FitMan новый абонемент клиенту → в 1С создаётся документ «Договор оказания услуг» или регистрируется продажа услуги.

##### Посещения и оказанные услуги (для аналитики и расчёта зарплаты)

Направление: FitMan → 1С.

Данные: Факт посещения клиентом занятия (дата, время, тип услуги), привязка к тренеру (для расчёта вознаграждения).

Сценарий: После завершения занятия в FitMan фиксируется факт оказания услуги → данные передаются в 1С для учёта выручки и расчёта зарплаты тренера.

#### Архитектура и механизм обмена

##### Общая схема

Интеграция построена по принципу асинхронного обмена через очередь сообщений.
FitMan выступает инициатором событий, помещая задачи в очередь. Отдельный сервис (воркер) обрабатывает очередь и взаимодействует с веб-сервисом 1С через REST API.

FitMan → [Очередь задач] → Сервис синхронизации → [REST API] → 1С

##### Компоненты системы

Таблица конфигурации интеграции (integration_1c_config) – хранит настройки подключения к конкретному экземпляру 1С.

Очередь задач (integration_1c_queue) – хранит отложенные операции синхронизации.

Сервис-воркер – фоновый процесс, который:

Забирает задачи из очереди.

Формирует и отправляет запросы в 1С.

Обрабатывает ответы, обновляет статусы задач, выполняет повторные попытки при ошибках.

REST API в 1С – набор веб-сервисов (HTTP-ендпоинтов), разработанных в конфигурации 1С для приёма и отправки данных.

##### Модель данных для обмена (Dart-модели)

```dart
// Конфигурация подключения к 1С
class Integration1CConfig {
  String id;
  String baseUrl; // URL веб-сервиса 1С (например, https://1c.company.com/ws/fitman)
  String apiKey; // Ключ авторизации для доступа к API 1С
  SyncSettings syncSettings; // Настройки синхронизации
  List<EntityMapping> entityMappings; // Соответствие полей между системами
  bool isActive; // Включена ли интеграция
}

// Настройки синхронизации
class SyncSettings {
  bool autoSyncEnabled; // Автоматическая фоновая синхронизация
  Duration syncInterval; // Интервал (например, каждые 5 минут)
  List<String> syncEntities; // Какие сущности синхронизировать: ['client', 'payment', 'subscription']
  DateTime lastSuccessfulSync; // Время последней успешной синхронизации
}

// Соответствие полей сущности между FitMan и 1С
class EntityMapping {
  String fitmanEntity; // Название сущности в FitMan ('client')
  String externalCode; // Код соответствующей сущности в 1С
  Map<String, String> fieldMappings; // {'first_name': 'Имя', 'last_name': 'Фамилия'}
}
```

#### Техническая реализация

##### Структура таблиц в PostgreSQL

```sql
-- Таблица конфигурации интеграции
CREATE TABLE integration_1c_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    base_url VARCHAR(500) NOT NULL,
    api_key VARCHAR(500) NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    sync_interval_minutes INTEGER DEFAULT 60,
    auto_sync_enabled BOOLEAN DEFAULT FALSE,
    last_successful_sync TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    company_id BIGINT DEFAULT -1
);

-- Очередь синхронизации
CREATE TABLE integration_1c_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- 'client', 'payment', 'subscription', 'visit'
    entity_id UUID NOT NULL, -- ID сущности в FitMan
    operation VARCHAR(20) NOT NULL, -- 'create', 'update', 'delete'
    payload JSONB NOT NULL, -- Данные сущности в формате JSON
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'processing', 'sent', 'error'
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    company_id BIGINT DEFAULT -1
);

-- Логи синхронизации (для аудита и отладки)
CREATE TABLE integration_1c_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    log_level VARCHAR(20) NOT NULL, -- 'info', 'warning', 'error'
    message TEXT NOT NULL,
    details JSONB, -- Дополнительные данные (например, тело запроса/ответа)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    company_id BIGINT DEFAULT -1
);
```

##### Сервис синхронизации (Dart)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Integration1CService {
  final HttpClient httpClient;
  final Integration1CConfig config;

  // Основной метод синхронизации (вызывается по расписанию или вручную)
  Future<SyncResult> syncData() async {
    try {
      // 1. Получаем pending-задачи из очереди
      final pendingItems = await _getPendingQueueItems();

      // 2. Группируем по типам сущностей для batch-отправки
      final groupedItems = _groupByEntityType(pendingItems);

      // 3. Отправляем пачки данных в 1С
      for (final entityType in groupedItems.keys) {
        await _sendBatchTo1C(entityType, groupedItems[entityType]!);
      }

      // 4. Опционально: запрашиваем обновления из 1С (если настроена двусторонняя синхронизация)
      if (config.syncSettings.syncDirection == 'bidirectional') {
        await _fetchUpdatesFrom1C();
      }

      await _logSyncSuccess();
      return SyncResult.success();
    } catch (e) {
      await _logSyncError(e);
      return SyncResult.error(e.toString());
    }
  }

  // Отправка пачки данных одного типа
  Future<void> _sendBatchTo1C(String entityType, List<QueueItem> items) async {
    final payload = {
      'entity_type': entityType,
      'items': items.map((item) => item.payload).toList(),
      'sync_timestamp': DateTime.now().toIso8601String(),
    };

    final response = await httpClient.post(
      Uri.parse('${config.baseUrl}/api/sync'),
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      // Помечаем задачи как успешно отправленные
      await _markItemsAsSent(items);
    } else {
      // Обрабатываем ошибку (логируем, увеличиваем счётчик повторов)
      await _handleSyncError(items, response);
    }
  }
}
```

#### Интерфейс управления интеграцией

Интерфейс для администратора должен находиться в разделе «Администрирование» → «Интеграции» и включать:

Панель статуса:

Статус подключения (✅/❌).

Время последней успешной синхронизации.

Количество неотправленных сообщений в очереди.

Настройки подключения:

Поля для ввода URL веб-сервиса 1С, API-ключа.

Переключатель «Интеграция активна».

Выбор сущностей для синхронизации (чекбоксы: Клиенты, Платежи, Абонементы).

Управление синхронизацией:

Кнопка «Синхронизировать сейчас» (ручной запуск).

Переключатель «Автоматическая синхронизация» с настройкой интервала.

Мониторинг и логи:

Таблица с последними операциями (статус, сущность, ошибка).

Фильтры по дате, типу сущности, статусу.

Кнопка «Экспорт логов».

#### Обработка ошибок и повторные попытки

Для обеспечения надёжности реализована стратегия повторных попыток (retry policy):

```dart
class SyncErrorHandler {
  static const maxRetries = 3;
  static const retryDelays = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15)
  ];

  Future<void> handleSyncError(QueueItem item, dynamic error) async {
    if (item.retryCount < maxRetries) {
      // Повторная попытка с увеличением задержки
      final delay = retryDelays[item.retryCount];
      await _rescheduleItem(item, delay);
      await _logWarning('Повторная попытка отправки ${item.entityType}#${item.entityId} через ${delay.inMinutes} мин.');
    } else {
      // Превышено максимальное число попыток - требуется вмешательство администратора
      await _notifyAdmin(
        'Критическая ошибка синхронизации',
        'Сущность: ${item.entityType}, ID: ${item.entityId}. Ошибка: ${error.toString()}'
      );
      await _markItemAsFailed(item, 'Превышено максимальное число попыток: $error');
    }
  }
}
```

#### Требования к API 1С

Со стороны 1С должен быть реализован REST API, поддерживающий как минимум следующие методы:

POST /api/sync – приём пачки данных от FitMan.

GET /api/sync/status – проверка доступности и статуса.

GET /api/clients/updates?since=... – получение обновлённых данных клиентов из 1С (для двусторонней синхронизации).

Формат запроса/ответа – JSON.
Обязательна авторизация по API-ключу в заголовке Authorization: Bearer <key>.

#### Рекомендации по внедрению

Этапность: Начать с синхронизации Клиентов и Платежей, затем добавить Абонементы и Посещения.

Тестирование: Перед включением в production выполнить тестовую синхронизацию с тестовой базой 1С.

Мониторинг: Настроить оповещения администратора при накоплении ошибок в очереди (>10 ошибок подряд).

Документация: Составить документ «Инструкция по настройке интеграции с 1С» для администраторов заказчика.
