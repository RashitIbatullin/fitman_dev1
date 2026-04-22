# Модуль "Антропометрия"

Учет и анализ антропометрических данных клиентов, включая постоянные (рост, обхваты для соматотипа) и периодические (вес, обхваты тела) замеры.

## 1. Модели данных

### 1.1. `AnthropometryFixed` (Постоянные замеры)
Хранит базовые, редко изменяемые антропометрические данные клиента.

```dart
class AnthropometryFixed {
  String userId;
  double? height;
  int? wristCirc;
  int? ankleCirc;
}
```

### 1.2. `AnthropometryMeasurement` (Периодические замеры)
Хранит данные регулярных замеров для отслеживания динамики. Включает поля для архивации.

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
}
```

### 1.3. `WhtrProfile`
Модель для хранения данных о коэффициенте "талия-рост" (WHtR).

```dart
class WhtrProfile {
  double ratio;
  String gradation;
}
```

## 2. Таблицы базы данных

### 2.1. `anthropometry_fix`
```sql
CREATE TABLE anthropometry_fix (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    height REAL,
    wrist_circ INT,
    ankle_circ INT
);
```

### 2.2. `anthropometry_measurements`
```sql
CREATE TABLE anthropometry_measurements (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date_time TIMESTAMPTZ NOT NULL,
    weight REAL,
    shoulders_circ INT,
    breast_circ INT,
    waist_circ INT,
    hips_circ INT,
    archived_at TIMESTAMPTZ,
    archived_by UUID,
    archived_reason TEXT
);
```

## 3. API эндпоинты
Управление антропометрией осуществляется через эндпоинты, разделенные по ролям.

### 3.1. Клиентские эндпоинты
`GET    /api/client/anthropometry`
`GET    /api/client/anthropometry/fixed`
`POST   /api/client/anthropometry`
`GET    /api/client/anthropometry/measurements/<id>/whtr`

### 3.2. Административные эндпоинты (для сотрудников)
`GET    /api/admin/clients/:id/anthropometry`
`POST   /api/admin/clients/:id/anthropometry`
`GET    /api/admin/clients/:id/anthropometry/fixed`
`POST   /api/admin/clients/:id/anthropometry/fixed`
`POST   /api/admin/clients/:id/anthropometry/<measurementId>/archive`
`PUT    /api/admin/clients/:id/anthropometry/<measurementId>/unarchive`
`GET    /api/admin/clients/:id/measurements/<measurementId>/whtr`


## 4. Пользовательские интерфейсы
Функционал доступен из карточки клиента.

### 4.1. `anthropometry_list_screen.dart`
Отображает список периодических замеров.
*   Каждая строка содержит чекбокс для выбора. Можно выбрать 1 или 2 замера.
*   При выборе замеров внизу экрана становятся активными кнопки:
    *   **"Сравнение"**: Активна при выборе 2 замеров. Открывает `comparison_screen.dart`.
    *   **"Анализ"**: Активна при выборе 1 или 2 замеров.
        *   При выборе 1 замера открывает `analysis_screen.dart`.
        *   При выборе 2 замеров открывает `analysis_comparison_screen.dart`.
    *   **"Рекомендации"**: Активна при выборе 1 замера. Открывает `system_recommendation_screen.dart`.

### 4.2. `comparison_screen.dart`
Экран для визуального сравнения двух замеров.
*   Отображает два силуэта, наложенных друг на друга, со слайдером для сравнения.
*   Силуэты окрашены в разные цвета.
*   Под слайдером находится легенда с датами и временем замеров.
*   Ниже отображается таблица со сравнением числовых показателей (вес, обхваты) и их динамикой.

### 4.3. `analysis_screen.dart` (Анализ одного замера)
Экран для отображения аналитических данных для **одного конкретного** замера.
*   **Карточка "Соматотип"**: Статичный параметр, рассчитывается на основе постоянных замеров.
*   **Карточка "Тип фигуры"**: Динамический параметр, рассчитывается на основе обхватов из выбранного замера.
*   **Карточка "Индекс WHtR"**: Динамический параметр, рассчитывается для выбранного замера.

### 4.4. `analysis_comparison_screen.dart` (Сравнение двух замеров)
Экран для сравнения аналитических данных двух замеров.
*   **Статичные данные**: Вверху отображается общая для обоих замеров информация (Соматотип), т.к. она не меняется.
*   **Динамичные данные**: Для каждого изменяемого параметра (Тип фигуры, Индекс WHtR) создается отдельная карточка, где построчно сравниваются значения для первого и второго замера.

### 4.5. `system_recommendation_screen.dart`
Экран для отображения персональных рекомендаций и генерации промпта для ИИ.
*   На основе **конкретного выбранного замера** запрашивает у бэкенда рекомендацию.
*   Генерирует промпт для ИИ, используя данные клиента (возраст, пол, рост, цель, уровень), соматотип и данные замера.

## 5. Архитектура и Провайдеры
Логика получения и расчета данных вынесена в гранулярные провайдеры.

### 5.1. Провайдеры данных
Находятся в `frontend/lib/modules/clients/providers/analysis_provider.dart`.

*   `somatotypeStringProvider(userId)`: Асинхронно получает данные пользователя и постоянные замеры, вызывает **локальный калькулятор** и возвращает строку с соматотипом.
*   `bodyShapeProvider(measurement)`: Синхронно вызывает **локальный калькулятор** и возвращает строку с типом фигуры для конкретного замера.
*   `whtrProfileProvider(measurement)`: Асинхронно обращается к (`.../whtr`), чтобы получить `WhtrProfile` для конкретного замера. Это обеспечивает единство данных с модулем рекомендаций.

### 5.2. Расположение кода

#### Бэкенд
*Логика для расчета WHtR и соответствующие эндпоинты.*
```
/backend/lib/
├── modules/
│   └── clients/
│       ├── controllers/
│       │   └── anthropometry_controller.dart  # Контроллер для обработки запросов по антропометрии.
│       └── repositories/
│           └── client_repository.dart         # Репозиторий для получения данных клиента, включая замеры.
└── services/
    └── recommendations/
        └── recommendation_service.dart      # Сервис, содержащий бизнес-логику для расчета WHtR.
```

#### Фронтенд
*Основные файлы модуля антропометрии и анализа.*
```
/frontend/lib/
└── modules/
    └── clients/
        ├── providers/
        │   └── analysis_provider.dart          # Провайдеры для аналитических расчетов (соматотип, тип фигуры, WHtR).
        ├── screens/
        │   ├── analysis_comparison_screen.dart # Экран для сравнения аналитики ДВУХ замеров.
        │   ├── analysis_screen.dart            # Экран для анализа ОДНОГО замера.
        │   └── system_recommendation_screen.dart # Экран для рекомендаций и генерации промпта для ИИ.
        └── utils/
            ├── body_shape_calculator.dart      # Локальный калькулятор для определения типа фигуры.
            └── somatotype_calculator.dart      # Локальный калькулятор для определения соматотипа.
```

