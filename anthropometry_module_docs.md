# Модуль "Антропометрия"

Учет и анализ антропометрических данных клиентов, включая постоянные (рост, обхваты для соматотипа) и периодические (вес, обхваты тела, данные биоимпеданса) замеры.

## 1. Модели данных

### 1.1. `AnthropometryFixed` (Постоянные замеры)
Хранит базовые, редко изменяемые антропометрические данные клиента. Все поля являются обязательными.

```dart
// packages/fitman_common/lib/modules/clients/anthropometry/anthropometry_fixed.dart
class AnthropometryFixed {
  required String userId;
  required DateTime createdAt;
  required int height;
  required int wristCirc;
  required int ankleCirc;
  // ...служебные поля
}
```

### 1.2. `AnthropometryMeasurement` (Периодические замеры)
Хранит данные регулярных замеров для отслеживания динамики.
- Основные поля (`weight`, обхваты) являются **обязательными**.
- Поля биоимпеданса (`fatPercentage`, `muscleMass`) являются **необязательными**, но должны заполняться парой.

```dart
// packages/fitman_common/lib/modules/clients/anthropometry/anthropometry_measurement.dart
class AnthropometryMeasurement {
  String? id;
  required String userId;
  required DateTime dateTime;
  required double weight;
  required int shouldersCirc;
  required int breastCirc;
  required int waistCirc;
  required int hipsCirc;
  double? fatPercentage;
  double? muscleMass;
  // ...служебные поля для архивации и аудита
}
```

### 1.3. Расчетные профили (Backend)
Эти модели не хранятся в БД, а создаются "на лету" на бэкенде в `recommendation_service.dart`.

- **`WhtrProfile`**: Профиль для индекса "талия-рост" (WHtR).
- **`MetabolicProfile`**: Профиль для базального метаболизма (BMR) и суточной потребности в калориях (TDEE).

```dart
class WhtrProfile {
  final double ratio;
  final String gradation;
}

class MetabolicProfile {
  final double bmr;
  final double tdee;
}
```


## 2. Таблицы базы данных (`database/body.sql`)

### 2.1. `anthropometry_fix`
Схема не изменилась, но теперь все поля (`height`, `wrist_circ`, `ankle_circ`) должны быть `NOT NULL`.

### 2.2. `anthropometry_measurements`
В таблицу добавлены два новых необязательных поля.
```sql
CREATE TABLE anthropometry_measurements (
    -- ...старые поля...
    weight REAL NOT NULL,
    shoulders_circ INT NOT NULL,
    breast_circ INT NOT NULL,
    waist_circ INT NOT NULL,
    hips_circ INT NOT NULL,
    fat_percentage REAL, -- Новое поле
    muscle_mass REAL,    -- Новое поле
    -- ...служебные поля...
);
```

## 3. Валидация в формах ввода
Для всех полей антропометрии (постоянной и периодической) на экранах `fixed_values_view.dart` и `anthropometry_edit_screen.dart` введена валидация:
1.  Все обязательные поля не могут быть пустыми.
2.  Все обязательные поля не могут содержать значение "0".
3.  Поля биоимпеданса (`fatPercentage`, `muscleMass`) должны быть заполнены **вместе**. Если заполнено одно, второе также становится обязательным. Проверка происходит при нажатии кнопки "Сохранить".

## 4. API эндпоинты
Добавлен новый эндпоинт для получения расчетных данных по метаболизму.

`GET /api/clients/<userId>/measurements/<measurementId>/metabolic-rate`
- **Описание**: Рассчитывает и возвращает BMR и TDEE для конкретного замера клиента.
- **Логика**: Использует формулу Кэтча-МакАрдла, которая требует наличия `fatPercentage` в данных замера.
- **Ответ**: `MetabolicProfile` в формате JSON.

## 5. Пользовательские интерфейсы
Функционал был расширен для отображения новых данных.

### 5.1. `analysis_screen.dart` (Анализ одного замера)
В дополнение к существующим карточкам добавлена новая:
- **Карточка "Базовый метаболизм"**: Асинхронно запрашивает данные с нового эндпоинта и отображает BMR (в покое) и TDEE (с учетом активности) в ккал.

### 5.2. `analysis_comparison_screen.dart` (Сравнение двух замеров)
В дополнение к существующим карточкам добавлена новая:
- **Карточка "Базовый метаболизм"**: Асинхронно запрашивает и отображает BMR/TDEE для каждого из двух замеров, позволяя сравнить их динамику.

### 5.3. `system_recommendation_screen.dart`
Промпт, генерируемый для ИИ, теперь включает данные биоимпеданса, если они есть в замере.
```
...
## Антропометрические данные
- **Рост (см):** $height
- **Соматотип:** $somatotype
- **Замер от ...:**
- Вес, кг: ...
...
- Процент жира, %: {fatPercentage} (если есть)
- Мышечная масса, кг: {muscleMass} (если есть)
```

## 6. Архитектура и Провайдеры
В `analysis_provider.dart` добавлен новый провайдер.

- **`metabolicRateProvider(params)`**: Асинхронно обращается к новому эндпоинту `/metabolic-rate` и возвращает `MetabolicProfile` с данными BMR и TDEE.

Логика расчета BMR/TDEE реализована на бэкенде в `recommendation_service.dart`.

## 7. Расположение кода

### 7.1. Бэкенд
*Логика для расчета аналитических профилей и соответствующие эндпоинты.*
```
/backend/lib/
├── controllers/
│   └── recommendations_controller.dart # Контроллер для нового эндпоинта BMR/TDEE.
├── modules/
│   └── clients/
│       └── repositories/
│           └── client_repository.dart    # SQL-запросы для сохранения и получения новых полей.
├── routes/
│   └── router.dart                     # Центральный роутер, где прописан новый маршрут.
└── services/
    └── recommendations/
        └── recommendation_service.dart # Сервис с бизнес-логикой для расчета WHtR и нового MetabolicProfile (BMR/TDEE).
```

### 7.2. Фронтенд
*Экраны и провайдеры для ввода, просмотра и анализа антропометрии.*
```
/frontend/lib/
└── modules/
    └── clients/
        ├── providers/
        │   └── analysis_provider.dart      # Провайдеры для всех аналитических данных, включая новый metabolicRateProvider.
        ├── screens/
        │   ├── anthropometry_edit_screen.dart # Форма для СОЗДАНИЯ/РЕДАКТИРОВАНИЯ периодических замеров. Здесь была добавлена валидация.
        │   ├── anthropometry_list_screen.dart # Список всех периодических замеров клиента.
        │   ├── analysis_screen.dart         # Экран анализа ОДНОГО замера. Сюда добавлена карточка BMR/TDEE.
        │   └── analysis_comparison_screen.dart# Экран сравнения ДВУХ анализов. Сюда добавлена карточка сравнения BMR/TDEE.
        └── widgets/
            └── fixed_values_view.dart      # Виджет-форма для постоянных замеров. Здесь была добавлена валидация.
```
