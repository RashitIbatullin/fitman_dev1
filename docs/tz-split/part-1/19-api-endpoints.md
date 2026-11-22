# Функциональные требования / Модуль управления оборудованием / API endpoints

*Часть 1 | источник: Требования ТЗ фитнес-тренинг часть 1.docx | [индекс](../INDEX.md)*

##### Оборудование

GET    /api/equipment/types         # Типы оборудования

GET    /api/equipment/items         # Экземпляры оборудования

GET    /api/equipment/items/:id     # Детали экземпляра

POST   /api/equipment/items         # Создать экземпляр

PUT    /api/equipment/items/:id     # Обновить экземпляр

GET    /api/equipment/availability  # Доступное оборудование

##### Бронирование

GET    /api/bookings/equipment      # Бронирования оборудования

POST   /api/bookings/equipment      # Создать бронирование

PUT    /api/bookings/equipment/:id/cancel # Отменить бронирование

GET    /api/bookings/conflicts      # Проверить конфликты

##### Техническое обслуживание

GET    /api/maintenance                    # Список заявок на ТО

POST   /api/maintenance                    # Создать заявку

GET    /api/maintenance/:id               # Детали заявки

PUT    /api/maintenance/:id               # Обновить заявку

PUT    /api/maintenance/:id/assign        # Назначить исполнителя

PUT    /api/maintenance/:id/start         # Начать работы

PUT    /api/maintenance/:id/complete      # Завершить работы

PUT    /api/maintenance/:id/cancel        # Отменить заявку

GET    /api/maintenance/available-executors # Доступные исполнители

POST   /api/maintenance/:id/photos                  # Добавить фото

DELETE /api/maintenance/:id/photos/:photoId         # Удалить фото

GET    /api/maintenance/:id/photos                  # Список фото
