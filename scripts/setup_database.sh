#!/bin/bash

# FitMan Database Setup Script
# Настройка PostgreSQL базы данных

set -e  # Выход при ошибке

echo "🗄️  Setting up FitMan Database..."
echo "================================"

# Проверка установки PostgreSQL
if ! psql -V; then
    echo "❌ Error: PostgreSQL is not installed or not in PATH"
    echo "Please install PostgreSQL from: https://www.postgresql.org/download/"
    exit 1
fi


# Переход в директорию database
cd "$(dirname "$0")/../database"

# Проверка существования setup.sql
if [ ! -f "setup.sql" ]; then
    echo "❌ Error: setup.sql not found in database directory"
    exit 1
fi

echo "📋 Executing database setup script..."
psql -U postgres -f ../database/setup.sql

echo "✅ Database setup completed successfully!"
