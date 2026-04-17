# Модуль "Антропометрия"

Учет и анализ антропометрических данных клиентов, включая постоянные (рост, обхваты для соматотипа) и периодические (вес, обхваты тела) замеры.

## 1. Модель данных

### 1.1. `AnthropometryFixed` (Постоянные замеры)
Хранит базовые, редко изменяемые антропометрические данные клиента, используемые для определения соматотипа и других расчетов.

```dart
class AnthropometryFixed {
  String userId;
  DateTime? dateTime;
  int? height;
  int? wristCirc;
  int? ankleCirc;
  // ... служебные поля
}
```

### 1.2. `AnthropometryMeasurement` (Периодические замеры)
Хранит данные регулярных замеров для отслеживания динамики и прогресса клиента.

```dart
class AnthropometryMeasurement {
  String id;
  String userId;
  DateTime dateTime;
  double? weight;
  int? shouldersCirc;
  int? breastCirc;
  int? waistCirc;
  int? hipsCirc;
  DateTime? archivedAt;
  String? archivedBy;
  String? archivedReason;
  // ... служебные поля
}
```

## 2. Таблицы базы данных

### 2.1. `anthropometry_fix`
```sql
CREATE TABLE anthropometry_fix (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ DEFAULT NOW(),
    height INT,
    wrist_circ INT,
    ankle_circ INT,
    -- ... служебные поля
);
```

### 2.2. `anthropometry_measurements`
```sql
CREATE TABLE anthropometry_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ NOT NULL,
    weight REAL,
    shoulders_circ INT,
    breast_circ INT,
    waist_circ INT,
    hips_circ INT,
    archived_at TIMESTAMPTZ,
    archived_by UUID REFERENCES users(id),
	  archived_reason TEXT,
    -- ... служебные поля
    UNIQUE(user_id, date_time)
);
```

## 3. API endpoints
Управление антропометрией осуществляется через эндпоинты, разделенные по ролям (клиентские и административные).

### 3.1. Клиентские эндпоинты
`GET    /api/client/anthropometry` # Получение списка своих периодических замеров (только активные).
`GET    /api/client/anthropometry/fixed` # Получение своих постоянных замеров.

### 3.2. Административные эндпоинты (для сотрудников)
`GET    /api/admin/clients/:id/anthropometry` # Получение списка замеров клиента. Принимает query-параметр `?includeArchived=true`.
`POST   /api/admin/clients/:id/anthropometry` # Создание или обновление периодического замера для клиента.

`GET    /api/admin/clients/:id/anthropometry/fixed` # Получение постоянных замеров клиента.
`POST   /api/admin/clients/:id/anthropometry/fixed` # Создание или обновление постоянных замеров для клиента.

`POST   /api/admin/clients/:id/anthropometry/:measurementId/archive` # Архивирование замера с указанием причины в теле запроса.
`PUT    /api/admin/clients/:id/anthropometry/:measurementId/unarchive` # Восстановление замера из архива.


## 4. Пользовательские интерфейсы
Функционал доступен из карточки клиента.

### 4.1. `anthropometry_screen.dart`
Главный экран модуля, разделенный на 2 вкладки:
*   **Вкладка "Постоянные данные"**: Отображает виджет `FixedValuesView`.
*   **Вкладка "Периодические замеры"**: Отображает виджет `AnthropometryListScreen`.
*   **Кнопка "Создать замер" (+)**: Видна только сотрудникам на вкладке "Периодические замеры", открывает `anthropometry_edit_screen.dart` для создания новой записи.

### 4.2. `fixed_values_view.dart`
*   **Для сотрудников**: Форма с редактируемыми полями для роста и обхватов запястья/лодыжки. Кнопка "Сохранить" активна только при наличии изменений.
*   **Для клиентов**: Поля отображаются в режиме "только для чтения", кнопка "Сохранить" скрыта.

### 4.3. `anthropometry_list_screen.dart`
Отображает список периодических замеров.
*   **Для сотрудников**:
    *   В `AppBar`'е есть переключатель "Показать архив" для просмотра/скрытия архивных записей.
    *   Каждая строка содержит чекбокс для выбора, название и кебаб-меню (три точки) с действиями.
    *   Кебаб-меню для активной записи: "Редактировать", "Архивировать".
    *   Кебаб-меню для архивной записи: "Деархивировать".
    *   Внизу экрана кнопка "Посмотреть рекомендации", активная при выборе двух замеров.
*   **Для клиентов**:
    *   Нет переключателя архива.
    *   Каждая строка содержит чекбокс и название. Нажатие на строку открывает экран `anthropometry_detail_screen.dart` для просмотра деталей.
    *   Внизу экрана кнопка "Посмотреть рекомендации", активная при выборе двух замеров.

### 4.4. `anthropometry_edit_screen.dart`
Форма создания/редактирования периодического замера. Доступна только сотрудникам. Содержит поля для веса, обхватов и выбора даты.

### 4.5. `anthropometry_detail_screen.dart`
Экран просмотра деталей одного периодического замера в режиме "только для чтения". Доступен клиентам.

## 5. Архитектура и расположение кода
Функционал является частью модуля "Клиенты" (`clients`).

### Бэкенд (`/backend/lib/modules/clients/`)
```
/clients/
├── controllers/
│   └── anthropometry_controller.dart # API для антропометрии
├── repositories/
│   └── client_repository.dart      # Репозиторий с SQL-запросами для антропометрии
```

### Фронтенд (`/frontend/lib/modules/clients/`)
```
/clients/
├── providers/
│   └── ... (провайдеры используются из других файлов, например, auth_provider)
├── screens/
│   ├── anthropometry_screen.dart
│   ├── anthropometry_list_screen.dart
│   ├── anthropometry_edit_screen.dart
│   └── anthropometry_detail_screen.dart
├── widgets/
│   └── fixed_values_view.dart
└── services/
    ├── api/
    │   ├── client_api.dart   # Клиентские API-методы
    │   └── admin_api.dart    # Административные API-методы
```
