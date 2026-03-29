-- Удаление старых таблиц, если они существуют, для идемпотентности скрипта
DROP TABLE IF EXISTS 
"message_statuses",
"messages",
"chat_participants",
"chats"
CASCADE;

-- Таблица для хранения чатов (бесед)
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255),
    type SMALLINT NOT NULL, -- 0: Peer-to-Peer, 1: Group
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Таблица для хранения участников чата
CREATE TABLE chat_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role SMALLINT, -- 0: Участник, 1: Администратор чата
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (chat_id, user_id)
);

-- Таблица для хранения сообщений
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    attachment_url VARCHAR(512),
    attachment_type VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    parent_message_id UUID REFERENCES messages(id)
);

-- Таблица для отслеживания статусов сообщений
CREATE TABLE message_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status SMALLINT NOT NULL, -- 0: sent, 1: delivered, 2: read
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (message_id, user_id)
);

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
