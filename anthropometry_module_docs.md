# Модуль "Антропометрия"

Учет и анализ антропометрических данных клиентов, включая постоянные (рост, обхваты для соматотипа) и периодические (вес, обхваты тела) замеры.

## 1. Модель данных

### 1.1. `AnthropometryFixed` (Постоянные замеры)
Хранит базовые, редко изменяемые антропометрические данные клиента.

```dart
class AnthropometryFixed {
  String userId;
  int? height;
  int? wristCirc;
  int? ankleCirc;
}
```

### 1.2. `AnthropometryMeasurement` (Периодические замеры)
Хранит данные регулярных замеров для отслеживания динамики.

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
}
```

### 1.3. `WhtrProfile` и `WhtrProfiles`
Модели для хранения и передачи данных о коэффициенте "талия-рост" (WHtR).

```dart
class WhtrProfile {
  double ratio;
  String gradation;
}

class WhtrProfiles {
  WhtrProfile start;
  WhtrProfile finish;
}
```

## 2. Таблицы базы данных

### 2.1. `anthropometry_fix`
```sql
CREATE TABLE anthropometry_fix (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    height INT,
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
    hips_circ INT
);
```

## 3. API endpoints
Управление антропометрией осуществляется через эндпоинты, разделенные по ролям.

### 3.1. Клиентские эндпоинты
`GET    /api/client/anthropometry` # Получение списка своих замеров.
`GET    /api/client/anthropometry/fixed` # Получение своих постоянных замеров.
`GET    /api/client/anthropometry/somatotype` # Получение соматотипа и типа фигуры.
`GET    /api/client/anthropometry/whtr-profiles` # Получение WHtR профилей.

### 3.2. Административные эндпоинты (для сотрудников)
`GET    /api/admin/clients/:id/anthropometry` # Получение замеров клиента.
`POST   /api/admin/clients/:id/anthropometry` # Создание/обновление замера.
`GET    /api/admin/clients/:id/anthropometry/fixed` # Получение постоянных замеров клиента.
`POST   /api/admin/clients/:id/anthropometry/fixed` # Создание/обновление постоянных замеров.

## 4. Пользовательские интерфейсы
Функционал доступен из карточки клиента.

### 4.1. `anthropometry_list_screen.dart`
Отображает отсортированный по дате список периодических замеров.
*   Каждая строка содержит чекбокс для выбора.
*   При выборе замеров внизу экрана становятся активными кнопки:
    *   **"Сравнение"**: Активна при выборе 2 замеров. Открывает `comparison_screen.dart`.
    *   **"Анализ"**: Активна при выборе 1 или 2 замеров. Открывает `analysis_screen.dart`.
    *   **"Рекомендации"**: Активна при выборе 1 или 2 замеров. Открывает `system_recommendation_screen.dart`.

### 4.2. `comparison_screen.dart`
Экран для визуального сравнения двух замеров.
*   Отображает два силуэта, наложенных друг на друга, со слайдером для сравнения.
*   Силуэты окрашены в разные цвета.
*   Под слайдером находится легенда с датами и временем замеров.
*   Ниже отображается таблица со сравнением числовых показателей (вес, обхваты) и их динамикой.

### 4.3. `analysis_screen.dart`
Экран для отображения аналитических данных на основе последних замеров клиента.
*   Отображает карточку с определенным **типом фигуры** ('Яблоко', 'Груша' и т.д.) и кнопкой помощи, объясняющей его особенности.
*   Отображает карточку с **соматотипом по Шелдону** (Эктоморф, Мезоморф, Эндоморф в %).
*   Отображает карточку с **индексом WHtR** (соотношение талии к росту), показывая значения для начального и текущего замера.

### 4.4. `system_recommendation_screen.dart`
Экран для отображения персональных рекомендаций.
*   На основе последнего выбранного замера и аналитических данных (тип фигуры, WHtR, цель, уровень) показывает текстовые рекомендации для клиента.

### 4.5. `body_silhouette_painter.dart`
Кастомный `painter` для отрисовки 2D-силуэта человека.
*   Принимает на вход `AnthropometryMeasurement` и `height`.
*   Строит схематичную, но пропорциональную фигуру человека с головой, торсом, руками и ногами.
*   Позволяет задавать цвет для отрисовки.

## 5. Архитектура и расположение кода

### Бэкенд (`/backend/lib/`)
```
/lib/
├── controllers/
│   └── anthropometry_controller.dart 
├── modules/
│   └── clients/
│       └── repositories/
│           └── client_repository.dart 
└── services/
    └── recommendations/
        ├── recommendation_service.dart # Основная логика расчетов
        └── somatotype_helper.dart
```

### Фронтенд (`/frontend/lib/`)
```
/lib/
├── modules/
│   └── clients/
│       ├── screens/
│       │   ├── anthropometry_list_screen.dart
│       │   ├── comparison_screen.dart
│       │   ├── analysis_screen.dart
│       │   └── system_recommendation_screen.dart
│       └── widgets/
│           └── body_silhouette_painter.dart
├── providers/
│   └── auth_provider.dart
├── services/
│   ├── api_service.dart
│   └── api/
│       ├── client_api.dart
│       └── admin_api.dart
└── utils/
    └── body_shape_helper.dart
```
