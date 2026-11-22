# Функциональные требования / Модуль управления зданиями и помещениями

*Часть 1 | источник: Требования ТЗ фитнес-тренинг часть 1.docx | [индекс](../INDEX.md)*

Предусмотрено 2 уровня иерархии: Здания и Помещения. Эта структура позволяет гибко управлять как крупными объектами (корпусами), так и отдельными залами, кабинетами и зонами внутри них.

• Здания (Buildings). Верхнеуровневая сущность, представляющая собой отдельный корпус или строение.

• Помещения (Rooms). Сущность, описывающая конкретный зал, студию или зону, которая всегда принадлежит определенному зданию.

#### Модели

##### Модель здания

Хранит основную информацию о корпусах фитнес-центра.

Модель данных:

class Building {

String id;

String name;           // Название, e.g., "Главный корпус"

String address;        // Адрес

String? note;          // Примечание

DateTime? archivedAt;  // Дата архивации

…Служебные поля

}

Таблица buildings в БД:

CREATE TABLE buildings (

id UUID PRIMARY KEY,

name VARCHAR(255) NOT NULL,

address TEXT NOT NULL,

note TEXT,

…Служебные поля

);

##### Модель помещения

Описывает характеристики конкретного помещения и его принадлежность к зданию.

- Модель данных
class Room {

String id;

String name;              // "Зал групповых программ", "Кардио-зона"

String buildingId;        // Ссылка на здание (обязательно, не может быть null)

String? buildingName;     // Денормализованное имя здания для удобства отображения

RoomType type;            // Тип помещения (enum)

int? floor;               // Этаж (число, не строка)

int maxCapacity;          // Максимальная вместимость (чел.)

double? area;             // Площадь (м²)

bool isActive;            // Статус активности

DateTime? archivedAt;     // Дата архивации

String? archivedReason;   // Причина архивации

DateTime? deactivateAt;   // Дата деактивации

String? deactivateReason; // Причина деактивации

List<String> photoUrls;   // Фотографии (URL)

// Дополнительные поля для расширенной информации и аудита

String? description;      // Описание помещения

String? roomNumber;       // Номер помещения

String? floorPlanUrl;     // URL плана этажа

String? note;             // Примечание

String? deactivateBy;     // ID пользователя, деактивировавшего запись

…Служебные поля

}

- Таблица `rooms` в БД:
CREATE TABLE rooms (

id UUID PRIMARY KEY,

name VARCHAR(255) NOT NULL,

building_id UUID NOT NULL REFERENCES buildings(id), -- Связь со зданием (обязательно)

type SMALLINT NOT NULL,

floor INT,

max_capacity INT NOT NULL DEFAULT 30,

area DECIMAL(5,2),

is_active BOOLEAN DEFAULT true,

photo_urls JSONB,

description TEXT,

room_number VARCHAR(50),

floor_plan_url TEXT,

note TEXT,

…Служебные поля

);

##### Типы помещений

enum RoomType {

groupHall(0),      // Зал групповых занятий
cardioZone(1),     // Кардио-зона
strengthZone(2),   // Силовая зона
mixedZone(3),      // Смешанная зона
studio(4),         // Студия (йога, пилатес)
boxingRing(5),     // Бокс/единоборства
pool(6),           // Бассейн
sauna(7),          // Сауна
lockerRoom(8),     // Раздевалка
reception(9),      // Ресепшен
office(10),        // Офис
other(11);         // Прочее

}

##### Модель расписания помещения

Для гибкого управления графиком работы каждого помещения имеется отдельная сущность `RoomSchedule`.

Модель данных:

class RoomSchedule {

String id;

String roomId;

int dayOfWeek;

bool isWorkingDay;

TimeOfDayCustom? openTime;

TimeOfDayCustom? closeTime;

}

```

Таблица `room_schedules` в БД

CREATE TABLE room_schedules (

id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,

day_of_week SMALLINT NOT NULL CHECK (day_of_week >= 1 AND day_of_week <= 7),

is_working_day BOOLEAN NOT NULL DEFAULT true,

open_time TIME,

close_time TIME,

created_at TIMESTAMPTZ DEFAULT NOW(),

updated_at TIMESTAMPTZ DEFAULT NOW(),

created_by UUID REFERENCES users(id),

updated_by UUID REFERENCES users(id),

UNIQUE(room_id, day_of_week)

);

#### Пользовательские интерфейсы

###### Меню и правила

- Меню вызова пользовательских интерфейсов находится в дашбордах сотрудников, в меню->Каталоги->Помещения. Действия по добавлению, редактированию, активированию, архивированию, доступны только админу.
###### Дашборд управления помещениями

(Rooms Dashboard)

1. Верхняя панель с KPI:

• Всего помещений: X

• Залы в работе: Y

• На ремонте: Z

• Оборудование доступно: N

• Требует ТО: M

2. Карта залов (визуальное представление):

• Иконки залов с цветовой индикацией:

- Зеленый: свободен

- Желтый: частично занят

- Красный: полностью занят

- Синий: неактивный

- Серый: в архиве

• При клике на иконку зала - всплывающая карточка с деталями

3. Быстрые действия:

• Забронировать зал

• Смотреть расписание

###### Список помещений

(Rooms ListView)

Заголовок: "Помещения"

Панель инструментов:

• Кнопка "Создать помещение"

• Поле поиска по названию

• Фильтры:

- Тип помещения: Все / Групповые залы / Кардио-зоны / и т.д.

- Этаж: Все / 1 этаж / 2 этаж

- Статус: Все / Активные / На ремонте

Отображаемые колонки:

1. Иконка помещения

2. Название (кликабельно - открывает карточку)

3. Тип (иконка + название типа)

4. Вместимость (max_capacity чел.)

5. Площадь (area м²)

6. Статус:

- Зеленый бейдж "Активно"

- Оранжевый бейдж "На ремонте"

7. Занятость (прогресс-бар с % занятости на текущий день)

8. Действия (иконки):

- 👁️ Просмотр

- ✏️ Редактировать

- 📋 Бронировать

- 🗑️ Архивировать

###### Карточка помещения

(Room Detail Card)

Открывается при клике на помещение в списке

1. Верхняя часть.

• Карусель фотографий (photo_urls)

• Кнопка "Добавить фото"

• Схема расстановки (floor_plan_url, если есть)

2. Основная информация (табы):

Таб "Основное".

• Название (редактируемое)

• Тип (выпадающий список)

• Описание (textarea)

• Этаж, Корпус (текстовые поля)

• Вместимость, Площадь (числовые поля)

• Чекбоксы: Зеркала, Аудиосистема

• Статус: Активно / На ремонте (переключатель)

• При ремонте: причина (textarea), дата окончания (date picker)

3. Таб "Фото".

-   Карусель для просмотра загруженных фотографий.

-   Кнопка "Добавить фото" для загрузки новых изображений.

-   **Добавлена функциональность удаления фото:** Каждая фотография в карусели имеет значок удаления. При нажатии на значок отображается диалоговое окно подтверждения. После подтверждения фото удаляется из базы данных и с сервера.

4. Таб "Расписание".

-   Отображает список из 7 дней недели.

-   Для каждого дня можно установить статус "Рабочий/Выходной" с помощью переключателя.

-   Для рабочих дней можно задать время открытия и закрытия.

5. Таб "Статистика":

• График загрузки зала по дням недели

• Количество проведенных занятий за месяц

• Средняя заполняемость (%)

6. Кнопки действий внизу:

• Сохранить

• Отменить

• Архивировать

#### Архитектура и расположение кода

Бэкенд (`/backend/lib/modules/rooms/`)

```

/rooms/

├── controllers/

│   ├── building_controller.dart  # API для зданий

│   ├── room_controller.dart      # API для помещений (добавлены методы загрузки/удаления фото)

│   └── room_schedule_controller.dart # API для расписаний помещений

├── models/                       # Модели удалены, используются общие из fitman_common

├── providers/

│   └── room_providers.dart       # Провайдеры зависимостей для модуля

├── repositories/

│   ├── building_repository.dart  # Репозиторий для зданий

│   ├── room_repository.dart      # Репозиторий для помещений (добавлены методы управления фото)

│   └── room_schedule_repository.dart # Репозиторий для расписаний

└── services/

├── building_service.dart     # Сервис для зданий

├── room_service.dart         # Сервис для помещений (добавлены методы управления фото, включая удаление физических файлов)

└── room_schedule_service.dart  # Сервис для расписаний

```

Фронтенд (`/frontend/lib/modules/rooms/`)

```

/rooms/

├── models/                       # Модели удалены, используются общие из fitman_common

├── providers/

│   ├── building_provider.dart    # Провайдеры для зданий

│   ├── room_provider.dart        # Провайдеры для помещений

│   └── room_schedule_provider.dart # Провайдер для расписаний

├── screens/

│   ├── building/                 # Экраны для управления зданиями

│   │   ├── buildings_list_screen.dart

│   │   ├── building_create_screen.dart

│   │   └── ...

│   └── room/                     # Экраны для управления помещениями (обновлен RoomDetailScreen для удаления фото)

│       ├── rooms_list_screen.dart

│       ├── room_create_screen.dart

│       └── room_detail_screen.dart # Обновлен UI для удаления фото

└── services/

└── room_schedule_api.dart      # Клиентский сервис для API расписаний

```

Общие сервисы фронтенда (`frontend/lib/services/`)

```

/services/

├── api_service.dart                # Фасад для API (добавлены методы uploadRoomPhoto/removeRoomPhoto)

└── api/

└── infrastructure_api.dart     # API для инфраструктуры (добавлены методы uploadRoomPhoto/removeRoomPhoto)

```

Хранение файлов

Загруженные фотографии помещений хранятся в директории \uploads\room_photos` на сервере бэкенда. Доступ к ним осуществляется по URL `http://<backend_host>:<backend_port>/uploads/room_photos/<filename>`. Фронтенд использует `ApiService.baseUrl` для корректного формирования полного URL.

#### API endpoints

GET    /api/rooms                    # Список помещений

GET    /api/rooms/:id               # Детали помещения

POST   /api/rooms                   # Создать помещение

PUT    /api/rooms/:id               # Обновить помещение

GET    /api/rooms/availability      # Проверить доступность

GET    /api/rooms/:id/equipment     # Оборудование в помещении

GET    /api/rooms/:id/schedules     # Получить расписание для помещения

PUT    /api/rooms/:id/schedules     # Обновить расписание для помещения

POST   /api/rooms/:id/photos      # Загрузить фотографию для помещения (MultipartForm, поле 'photo')

DELETE /api/rooms/:id/photos      # Удалить фотографию для помещения (Body: {"photoUrl": "url_фото"})

#### Интеграция с существующими модулями

###### С тренировочными группами (TrainingGroup)

class TrainingGroup {

// ... существующие поля

String? primaryRoomId;     // Основной зал для занятий группы

List<String> requiredEquipmentTypeIds; // Типы необходимого оборудования

}

###### С расписанием занятий

ALTER TABLE lessons ADD COLUMN room_id UUID REFERENCES rooms(id);
