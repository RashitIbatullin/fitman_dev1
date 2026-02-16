#!/bin/bash

# FitMan Backend Startup Script
# Запуск Dart Frog backend сервера

set -e  # Выход при ошибке

echo "🚀 Starting FitMan Backend..."
echo "================================"

# Проверка установки Dart
if ! command -v dart &> /dev/null; then
    echo "❌ Error: Dart SDK is not installed or not in PATH"
    echo "Please install Dart SDK from: https://dart.dev/get-dart"
    exit 1
fi

echo "✅ Dart SDK found: $(dart --version)"

# Переход в директорию backend
cd "$(dirname "$0")/../backend"

# Проверка существования pubspec.yaml
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found in backend directory"
    exit 1
fi

echo "📦 Installing dependencies..."
dart pub get

echo "🔨 Building application..."
dart run build_runner build --delete-conflicting-outputs

echo "Press Ctrl+C to stop the server"
echo "================================"

# Запуск сервера в режиме разработки с доступом по сети
dart_frog dev --host 0.0.0.0