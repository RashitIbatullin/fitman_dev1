-- Удаление старых таблиц, если они существуют, для идемпотентности скрипта
DROP TABLE IF EXISTS 
"message_statuses",
"messages",
"chat_participants"
"chats"
CASCADE;

-- Таблица для хранения чатов (бесед)
CREATE TABLE chats (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255), -- Название группового чата, для личных может быть NULL
    type SMALLINT NOT NULL, -- 0: Peer-to-Peer, 1: Group
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE chats IS 'Хранит информацию о каждой беседе (личной или групповой)';
COMMENT ON COLUMN chats.type IS '0: Peer-to-Peer (личный), 1: Group (групповой)';

-- Таблица для хранения участников чата
CREATE TABLE chat_participants (
    id BIGSERIAL PRIMARY KEY,
    chat_id BIGINT NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role SMALLINT, -- 0: Участник, 1: Администратор чата (опционально)
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (chat_id, user_id)
);

COMMENT ON TABLE chat_participants IS 'Связывает пользователей с чатами, в которых они состоят';
COMMENT ON COLUMN chat_participants.role IS '0: Участник, 1: Администратор чата (может добавлять/удалять участников)';

-- Таблица для хранения сообщений
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    chat_id BIGINT NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    sender_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT, -- Текстовое содержимое сообщения
    attachment_url VARCHAR(512), -- Ссылка на вложение (файл)
    attachment_type VARCHAR(50), -- Тип вложения (image, file, etc.)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    parent_message_id BIGINT REFERENCES messages(id) -- Для ответов на сообщения
);

COMMENT ON TABLE messages IS 'Хранит все сообщения всех чатов';
COMMENT ON COLUMN messages.parent_message_id IS 'Ссылка на сообщение, на которое был дан ответ';


-- Таблица для отслеживания статусов сообщений (доставлено, прочитано) для каждого участника
CREATE TABLE message_statuses (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Получатель
    status SMALLINT NOT NULL, -- 0: sent, 1: delivered, 2: read
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), -- Время установки статуса
    UNIQUE (message_id, user_id)
);

COMMENT ON TABLE message_statuses IS 'Отслеживает статус каждого сообщения для каждого получателя';
COMMENT ON COLUMN message_statuses.status IS '0: Отправлено, 1: Доставлено, 2: Прочитано';

-- Индексы для ускорения запросов
CREATE INDEX idx_chat_participants_user_id ON chat_participants(user_id);
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_message_statuses_user_id ON message_statuses(user_id);

-- Триггер для автоматического обновления updated_at в таблице chats при новом сообщении
CREATE OR REPLACE FUNCTION update_chat_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chats
    SET updated_at = NOW()
    WHERE id = NEW.chat_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_chat_on_new_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_chat_updated_at();

-- Триггер для автоматического добавления отправителя в таблицу статусов
CREATE OR REPLACE FUNCTION add_sender_to_message_statuses()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO message_statuses (message_id, user_id, status, created_at)
    VALUES (NEW.id, NEW.sender_id, 2, NOW()); -- Отправитель сразу "прочитал" свое сообщение
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_sender_status
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION add_sender_to_message_statuses();
