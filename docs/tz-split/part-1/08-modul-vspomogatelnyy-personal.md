# Функциональные требования / Модуль "Вспомогательный персонал"

*Часть 1 | источник: Требования ТЗ фитнес-тренинг часть 1.docx | [индекс](../INDEX.md)*

Учет внешних специалистов и подрядчиков, выполняющих ТО оборудования, экспорт-импорт в другие системы и прочие не функциональные услуги, но не являющихся пользователями системы.

#### Модель данных

```
class SupportStaff {
  String id;
  String firstName;
  String lastName;
  String? middleName;
  String? phone;
  String? email;
  EmploymentType employmentType; // Штатный/Внешний/Подрядчик
  StaffCategory category; // Техник/Уборщик/Медик и т.д.
  List<String> accessibleEquipmentTypes; // Типы оборудования для работы
  WorkSchedule? schedule; // График работы
  String? companyName; // Для подрядчиков
  String? contractNumber;
  DateTime? contractExpiryDate;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;}
```

#### Перечисления (Enums)

```
// Тип занятости
enum EmploymentType {
  fullTime,    // Штатный сотрудник
  partTime,    // Частичная занятость
  contractor,  // Внешний подрядчик
  freelance    // Разовые работы
}

// Категория персонала
enum StaffCategory {
  technician,      // Техник/механик
  cleaner,         // Уборщик
  administrator,   // Администратор (вспомогательный)
  security,        // Охрана
  medical,         // Медицинский работник
  itService,       // Айтишник
  other            // Прочее
}
```

#### Таблицы базы данных

```
-- Основная таблица вспомогательного персонала
CREATE TABLE support_staff (
  id UUID PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  middle_name VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(255),
  employment_type SMALLINT NOT NULL,
  category SMALLINT NOT NULL,
  can_maintain_equipment BOOLEAN DEFAULT false,
  company_name VARCHAR(255),
  contract_number VARCHAR(100),
  contract_expiry_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by UUID REFERENCES users(id)
);
```

#### API endpoints

GET    /api/support-staff                           # Список персонала

POST   /api/support-staff                           # Добавить персонал

GET    /api/support-staff/:id                       # Детали персонала

PUT    /api/support-staff/:id                       # Обновить персонал

DELETE /api/support-staff/:id                       # Архивировать персонал

GET    /api/support-staff/:id/competencies          # Компетенции персонала

POST   /api/support-staff/:id/competencies          # Добавить компетенцию

DELETE /api/support-staff/:id/competencies/:compId  # Удалить компетенцию

#### Пользовательские интерфейсы

  Список персонала: Фильтрация по типу, категории, активности.

  Карточка сотрудника: Основная информация, компетенции, график.

  Компетенции: Добавление/редактирование навыков с подтверждением.

#### Архитектура и расположение кода

```
• Бэкенд (`/backend/lib/modules/support_staff/`)
/support_staff/
├── controllers/
│   └── support_staff_controller.dart # API для вспомогательного персонала
├── models/
│   └── support_staff.model.dart      # Модель персонала
├── repositories/
│   └── support_staff_repository.dart # Репозиторий для персонала
└── services/
    └── support_staff_service.dart      # Бизнес-логика для персонала

• Фронтенд (`/frontend/lib/modules/support_staff/`)
/support_staff/
├── models/
│   └── support_staff.model.dart      # Модель персонала
├── providers/
│   └── support_staff_provider.dart   # Управляет состоянием UI
├── screens/
│   ├── support_staff_list_screen.dart # Экран списка персонала
│   └── support_staff_edit_screen.dart # Экран редактирования персонала
└── services/
    └── support_staff_api.dart        # Клиентский сервис для API
```
