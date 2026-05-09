# init_db_dev.ps1 - Инициализация базы данных FitMan для DEV окружения (Windows PowerShell)
# Использование: 
#   .\utils\init_db_dev.ps1 (запустит режим 'medium' по умолчанию)
#   .\utils\init_db_dev.ps1 -Mode demo

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('demo', 'medium')]
    [string]$Mode = 'medium'
)

# --- Начало изменений ---
# Определяем корень проекта относительно расположения скрипта
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Write-Host "Корень проекта определен как: $ProjectRoot" -ForegroundColor DarkGray
# --- Конец изменений ---


Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Инициализация DEV базы данных FitMan" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Загрузка переменных окружения из backend\.env.dev
Write-Host "Загрузка настроек из backend\.env.dev..." -ForegroundColor Yellow
$envFile = Join-Path $ProjectRoot "backend\.env.dev"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and !$line.StartsWith("#")) {
            $parts = $line.Split("=", 2)
            if ($parts.Length -eq 2) {
                $key = $parts[0].Trim()
                $value = $parts[1].Trim()
                if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                    $value = $value.Substring(1, $value.Length - 2)
                }
                [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }
    Write-Host "✓ Настройки для DEV окружения загружены." -ForegroundColor Green
} else {
    Write-Host "✗ Ошибка: Файл окружения '$envFile' не найден!" -ForegroundColor Red
    Write-Host "Убедитесь, что структура проекта корректна." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Настройки подключения
$DB_HOST = if ($env:DB_HOST) { $env:DB_HOST } else { "localhost" }
$DB_PORT = if ($env:DB_PORT) { $env:DB_PORT } else { "5432" }
$DB_NAME = if ($env:DB_NAME) { $env:DB_NAME } else { "fitman" }
$DB_USER = if ($env:DB_USER) { $env:DB_USER } else { "postgres" }
$DB_PASSWORD = if ($env:DB_PASSWORD) { $env:DB_PASSWORD } else { "postgres" }

# Пути к файлам SQL (учитывая структуру проекта)
$USERS_FILE = Join-Path $ProjectRoot "database\users.sql"
$INFRA_FILE = Join-Path $ProjectRoot "database\infrastructure.sql"
$EQUIPMENT_FILE = Join-Path $ProjectRoot "database\equipment.sql"
$GROUPS_FILE = Join-Path $ProjectRoot "database\groups.sql"
$LESSONS_FILE = Join-Path $ProjectRoot "database\lessons.sql"
$CHAT_FILE = Join-Path $ProjectRoot "database\chat.sql"
$BODY_FILE = Join-Path $ProjectRoot "database\body.sql"

Write-Host "Настройки подключения:" -ForegroundColor Yellow
Write-Host "Хост: $DB_HOST"
Write-Host "Порт: $DB_PORT"
Write-Host "База данных: $DB_NAME"
Write-Host "Пользователь: $DB_USER"
Write-Host ""

# Проверка наличия psql
function Test-Psql {
    try {
        $null = Get-Command psql -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

if (-not (Test-Psql)) {
    Write-Host "Ошибка: psql не найден!" -ForegroundColor Red
    Write-Host "Установите PostgreSQL или добавьте в PATH" -ForegroundColor Yellow
    Write-Host "Скачать: https://www.postgresql.org/download/windows/" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Путь к psql обычно: C:\Program Files\PostgreSQL\*\bin\psql.exe" -ForegroundColor Yellow
    exit 1
}

# Проверка наличия файлов
function Test-SqlFile($file) {
    if (-not (Test-Path $file)) {
        Write-Host "Ошибка: Файл $file не найден!" -ForegroundColor Red
        Write-Host "Текущая директория: $((Get-Location).Path)" -ForegroundColor Yellow
        Write-Host "Ожидаемый путь: $file" -ForegroundColor Yellow
        return $false
    }
    return $true
}

if (-not (Test-SqlFile $USERS_FILE)) { exit 1 }
if (-not (Test-SqlFile $INFRA_FILE)) { exit 1 }
if (-not (Test-SqlFile $EQUIPMENT_FILE)) { exit 1 }
if (-not (Test-SqlFile $GROUPS_FILE)) { exit 1 }
if (-not (Test-SqlFile $LESSONS_FILE)) { exit 1 }
if (-not (Test-SqlFile $CHAT_FILE)) { exit 1 }
if (-not (Test-SqlFile $BODY_FILE)) { exit 1 }

# Функция выполнения SQL-файла
function Execute-SqlFile {
    param(
        [string]$File,
        [string]$Description
    )
    
    Write-Host ""
    Write-Host "Выполнение: $Description..." -ForegroundColor Green
    Write-Host "Файл: $File" -ForegroundColor Gray
    
    $env:PGPASSWORD = $DB_PASSWORD
    $result = & psql -v ON_ERROR_STOP=1 -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $File 2>&1
    $env:PGPASSWORD = $null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $Description успешно выполнено" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "✗ Ошибка при выполнении $Description" -ForegroundColor Red
        Write-Host "Код ошибки: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Детали:" -ForegroundColor Yellow
        Write-Host $result -ForegroundColor Red
        return $false
    }
}

# Проверка подключения к PostgreSQL
Write-Host "Проверка подключения к PostgreSQL..." -ForegroundColor Yellow
$env:PGPASSWORD = $DB_PASSWORD
$testResult = & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "SELECT version();" 2>&1
$env:PGPASSWORD = $null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Подключение к PostgreSQL успешно" -ForegroundColor Green
    $postgresVersion = ($testResult | Select-String "PostgreSQL").ToString()
    Write-Host "Версия: $postgresVersion" -ForegroundColor Gray
}
else {
    Write-Host "✗ Не удалось подключиться к PostgreSQL" -ForegroundColor Red
    Write-Host "Убедитесь что:" -ForegroundColor Yellow
    Write-Host "1. Служба PostgreSQL запущена (Win+R -> services.msc)" -ForegroundColor Yellow
    Write-Host "2. Порт $DB_PORT открыт" -ForegroundColor Yellow
    Write-Host "3. Пользователь '$DB_USER' существует" -ForegroundColor Yellow
    Write-Host "4. Пароль правильный (по умолчанию: postgres)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Проверьте службы командой: Get-Service postgresql*" -ForegroundColor Cyan
    exit 1
}

# 1. Проверка/создание базы данных
Write-Host ""
Write-Host "Проверка базы данных '$DB_NAME'..." -ForegroundColor Yellow
$env:PGPASSWORD = $DB_PASSWORD
$dbExists = & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -lqt 2>&1 | ForEach-Object { if ($_ -match "\s+$DB_NAME\s+\|") { $true } }
$env:PGPASSWORD = $null

if ($dbExists) {
    Write-Host "✓ База данных '$DB_NAME' уже существует. Пересоздание не требуется, только накатываются схемы." -ForegroundColor Green
}
else {
    Write-Host "Создание базы данных '$DB_NAME'..." -ForegroundColor Yellow
    $env:PGPASSWORD = $DB_PASSWORD
    & createdb -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME 2>&1 | Out-Null
    $env:PGPASSWORD = $null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ База данных '$DB_NAME' создана" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Ошибка при создании базы данных" -ForegroundColor Red
        exit 1
    }
}

# 2. Выполнение основных файлов схемы
if (-not (Execute-SqlFile -File $USERS_FILE -Description "Базовая структура (Пользователи, Роли)")) { exit 1 }
if (-not (Execute-SqlFile -File $INFRA_FILE -Description "Структура инфраструктуры (Здания, Помещения)")) { exit 1 }
if (-not (Execute-SqlFile -File $EQUIPMENT_FILE -Description "Структура оборудования")) { exit 1 }
if (-not (Execute-SqlFile -File $GROUPS_FILE -Description "Структура таблиц для Групп")) { exit 1 }
if (-not (Execute-SqlFile -File $LESSONS_FILE -Description "Структура таблиц для Занятий и Планов")) { exit 1 }
if (-not (Execute-SqlFile -File $CHAT_FILE -Description "Структура таблиц для Чата")) { exit 1 }
if (-not (Execute-SqlFile -File $BODY_FILE -Description "Структура и данные для Рекомендаций")) { exit 1 }

# 5. Выполнение Dart-сидера для наполнения данными
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Наполнение базы данными в режиме '$Mode'..." -ForegroundColor Green
Push-Location (Join-Path $ProjectRoot "backend")
& dart run bin/seed.dart --$Mode 2>&1 | ForEach-Object { Write-Host "  " $_ }
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Ошибка при выполнении seed.dart" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Инициализация завершена успешно!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Проверка итоговых данных
Write-Host "Проверка итоговых данных..." -ForegroundColor Yellow
$env:PGPASSWORD = $DB_PASSWORD
$summary = @"
SELECT 'buildings' as table_name, COUNT(*) as records FROM buildings
UNION ALL
SELECT 'roles', COUNT(*) FROM roles
UNION ALL
SELECT 'users', COUNT(*) FROM users
ORDER BY table_name;
"@

& psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c $summary 2>&1 | ForEach-Object {
    if ($_ -match "|\s+\d+") {
        Write-Host $_ -ForegroundColor Gray
    }
}
$env:PGPASSWORD = $null
