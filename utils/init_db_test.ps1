# init_db_test.ps1 - Инициализация тестовой базы FitMan (Windows PowerShell)
#
# Отличия от init_db_dev.ps1:
#   - база и учётная запись задаются параметрами, а не берутся жёстко из env;
#   - можно пересоздать базу с нуля (-Recreate);
#   - для Dart-шагов (миграции, сид) пишется временный env-файл, потому что
#     AppConfig читает .env.$DART_ENV и не учитывает переменные процесса.
#
# Примеры:
#   .\utils\init_db_test.ps1 -DbName fitman_test_1 -Mode demo
#   .\utils\init_db_test.ps1 -DbName fitman_test_1 -Recreate -Mode medium
#   .\utils\init_db_test.ps1 -DbUser fitman_test -DbPass '***' -DbName fitman_test_1

param(
    [Parameter(Mandatory = $false)]
    [string]$DbName = '',

    [Parameter(Mandatory = $false)]
    [string]$DbHost = '',

    [Parameter(Mandatory = $false)]
    [int]$DbPort = 0,

    [Parameter(Mandatory = $false)]
    [string]$DbUser = '',

    [Parameter(Mandatory = $false)]
    [string]$DbPass = '',

    # Учётная запись с правом создавать базы (по умолчанию — та же DbUser).
    # Нужна, когда прикладная роль не имеет CREATEDB: создание и удаление
    # базы выполняются под администратором, а владельцем ставится DbUser.
    [Parameter(Mandatory = $false)]
    [string]$AdminUser = '',

    [Parameter(Mandatory = $false)]
    [string]$AdminPass = '',

    # Базовый env-файл: из него берутся значения, не заданные параметрами
    [Parameter(Mandatory = $false)]
    [string]$EnvFile = 'backend\.env.test',

    [Parameter(Mandatory = $false)]
    [ValidateSet('demo', 'medium')]
    [string]$Mode = 'demo',

    # Оставить существующую базу и накатить схемы поверх.
    # Не рекомендуется: базовые скрипты делают DROP TABLE ... CASCADE и
    # теряют внешние ключи таблиц, созданных миграциями.
    [Parameter(Mandatory = $false)]
    [switch]$KeepDatabase,

    # Не запускать сид (только схема и миграции)
    [Parameter(Mandatory = $false)]
    [switch]$SkipSeed
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Инициализация ТЕСТОВОЙ базы FitMan" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# --- psql ---
$psqlCommand = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlCommand) {
    Write-Host "✗ psql не найден в PATH" -ForegroundColor Red
    Write-Host "Добавьте каталог bin PostgreSQL в PATH или запустите из его окружения." -ForegroundColor Yellow
    exit 1
}
$psql = $psqlCommand.Source

# --- базовый env ---
$envPath = Join-Path $ProjectRoot $EnvFile
if (-not (Test-Path $envPath)) {
    Write-Host "✗ Не найден env-файл: $envPath" -ForegroundColor Red
    exit 1
}

$envLines = Get-Content $envPath
function Get-EnvValue([string[]]$lines, [string]$key) {
    foreach ($line in $lines) {
        if ($line -match "^\s*$key\s*=") {
            $value = ($line -split '=', 2)[1].Trim()
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
                ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            return $value
        }
    }
    return ''
}

# Параметры важнее env; env важнее умолчаний
$resolvedName = if ($DbName) { $DbName } else { Get-EnvValue $envLines 'DB_NAME' }
$resolvedHost = if ($DbHost) { $DbHost } else { Get-EnvValue $envLines 'DB_HOST' }
$resolvedPort = if ($DbPort -gt 0) { $DbPort } else { [int](Get-EnvValue $envLines 'DB_PORT') }
$resolvedUser = if ($DbUser) { $DbUser } else { Get-EnvValue $envLines 'DB_USER' }
$resolvedPass = if ($DbPass) { $DbPass } else { Get-EnvValue $envLines 'DB_PASS' }
$adminUser = if ($AdminUser) { $AdminUser } else { $resolvedUser }
$adminPass = if ($AdminPass) { $AdminPass } else { $resolvedPass }

if (-not $resolvedName) { $resolvedName = 'fitman_test_1' }
if (-not $resolvedHost) { $resolvedHost = 'localhost' }
if ($resolvedPort -le 0) { $resolvedPort = 5432 }
if (-not $resolvedUser) { $resolvedUser = 'postgres' }

Write-Host ""
Write-Host "Подключение:" -ForegroundColor Yellow
Write-Host "  хост:     $resolvedHost`:$resolvedPort"
Write-Host "  база:     $resolvedName"
Write-Host "  пользователь: $resolvedUser"
Write-Host "  админ БД: $adminUser"
Write-Host "  env-файл: $EnvFile"
Write-Host "  режим сида: $Mode"
Write-Host ""

# --- проверка подключения ---
function Invoke-Psql {
    param(
        [string[]]$Arguments,
        [string]$Description,
        [switch]$AllowFailure
    )

    # psql пишет NOTICE в stderr; при ErrorActionPreference=Stop PowerShell
    # считает это ошибкой и прерывает скрипт. Поэтому на время вызова
    # переключаемся на Continue и сами проверяем код возврата.
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $env:PGPASSWORD = $resolvedPass
        $output = & $psql @Arguments 2>&1
        $exitCode = $LASTEXITCODE
        $env:PGPASSWORD = $null
    } finally {
        $ErrorActionPreference = $previousPreference
    }

    if ($exitCode -ne 0 -and -not $AllowFailure) {
        Write-Host "✗ $Description" -ForegroundColor Red
        Write-Host ($output | Out-String) -ForegroundColor Red
        exit 1
    }
    return $output
}

# Административные операции (CREATE/DROP DATABASE): прикладная роль может
# не иметь права CREATEDB, поэтому используется отдельная учётная запись.
function Invoke-AdminPsql {
    param(
        [string]$Sql,
        [string]$Description
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $env:PGPASSWORD = $adminPass
        $output = & $psql -h $resolvedHost -p $resolvedPort -U $adminUser `
            -d postgres -tAc $Sql 2>&1
        $exitCode = $LASTEXITCODE
        $env:PGPASSWORD = $null
    } finally {
        $ErrorActionPreference = $previousPreference
    }

    if ($exitCode -ne 0) {
        Write-Host "✗ $Description" -ForegroundColor Red
        Write-Host ($output | Out-String) -ForegroundColor Red
        Write-Host "  Проверьте права '$adminUser' (нужно CREATEDB) или задайте -AdminUser/-AdminPass." -ForegroundColor Yellow
        exit 1
    }
    return ($output | Out-String).Trim()
}

$null = Invoke-Psql -Arguments @(
    '-h', $resolvedHost, '-p', $resolvedPort, '-U', $resolvedUser,
    '-d', 'postgres', '-tAc', 'SELECT 1'
) -Description "Не удалось подключиться к серверу PostgreSQL под '$resolvedUser'"

$exists = Invoke-AdminPsql -Sql "SELECT 1 FROM pg_database WHERE datname = '$resolvedName'" `
    -Description 'Не удалось проверить существование базы'

if ($exists -eq '1' -and -not $KeepDatabase) {
    Write-Host "Удаление базы '$resolvedName' (пересоздание с нуля)..." -ForegroundColor Yellow
    $null = Invoke-AdminPsql -Sql "DROP DATABASE `"$resolvedName`" WITH (FORCE)" `
        -Description 'Не удалось удалить базу'
    $exists = ''
}

if ($exists -ne '1') {
    Write-Host "Создание базы '$resolvedName' (владелец '$resolvedUser')..." -ForegroundColor Yellow
    $null = Invoke-AdminPsql -Sql "CREATE DATABASE `"$resolvedName`" OWNER `"$resolvedUser`"" `
        -Description 'Не удалось создать базу'
    Write-Host "✓ База создана" -ForegroundColor Green
} else {
    Write-Host "⚠ База оставлена как есть (-KeepDatabase): внешние ключи таблиц," -ForegroundColor Yellow
    Write-Host "  созданных миграциями, могут быть потеряны из-за DROP TABLE ... CASCADE." -ForegroundColor Yellow
}

# --- временный env для Dart-шагов ---
$tempEnvName = '.env.__testrun'
$tempEnvPath = Join-Path $ProjectRoot "backend\$tempEnvName"
$dbKeys = @('DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASS')
$tempLines = foreach ($line in $envLines) {
    $handled = $false
    foreach ($key in $dbKeys) {
        if ($line -match "^\s*$key\s*=") {
            $value = switch ($key) {
                'DB_HOST' { $resolvedHost }
                'DB_PORT' { $resolvedPort }
                'DB_NAME' { $resolvedName }
                'DB_USER' { $resolvedUser }
                'DB_PASS' { $resolvedPass }
            }
            "$key=$value"
            $handled = $true
            break
        }
    }
    if (-not $handled) { $line }
}

try {
    Set-Content -Path $tempEnvPath -Value $tempLines -Encoding UTF8

    # --- схемы ---
    $schemaFiles = @(
        @{ File = 'database\users.sql';          Description = 'Пользователи и роли' },
        @{ File = 'database\infrastructure.sql'; Description = 'Здания и помещения' },
        @{ File = 'database\equipment.sql';      Description = 'Оборудование' },
        @{ File = 'database\groups.sql';         Description = 'Группы' },
        @{ File = 'database\lessons.sql';        Description = 'Занятия и планы' },
        @{ File = 'database\chat.sql';           Description = 'Чат' },
        @{ File = 'database\body.sql';           Description = 'Антропометрия и рекомендации' }
    )

    foreach ($item in $schemaFiles) {
        $path = Join-Path $ProjectRoot $item.File
        if (-not (Test-Path $path)) {
            Write-Host "✗ Не найден файл $path" -ForegroundColor Red
            exit 1
        }

        Write-Host "Выполнение: $($item.Description)..." -ForegroundColor Green
        $output = Invoke-Psql -Arguments @(
            '-h', $resolvedHost, '-p', $resolvedPort, '-U', $resolvedUser,
            '-d', $resolvedName, '-v', 'ON_ERROR_STOP=1', '-q', '-f', $path
        ) -Description "Ошибка в $($item.File)"
        $null = $output
    }

    # --- миграции ---
    Write-Host ""
    Write-Host "Применение миграций..." -ForegroundColor Green
    Push-Location (Join-Path $ProjectRoot 'backend')
    try {
        $env:DART_ENV = $tempEnvName.Substring('.env.'.Length)
        & dart run bin/migrate.dart 2>&1 | ForEach-Object { Write-Host "  $_" }
        $migrationsExit = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    if ($migrationsExit -ne 0) {
        Write-Host "✗ Ошибка при применении миграций" -ForegroundColor Red
        exit 1
    }

    # --- сид ---
    if (-not $SkipSeed) {
        Write-Host ""
        Write-Host "Наполнение данными (режим '$Mode')..." -ForegroundColor Green
        Push-Location (Join-Path $ProjectRoot 'backend')
        try {
            $env:DART_ENV = $tempEnvName.Substring('.env.'.Length)
            & dart run bin/seed.dart "--$Mode" 2>&1 | ForEach-Object { Write-Host "  $_" }
            $seedExit = $LASTEXITCODE
        } finally {
            Pop-Location
        }
        if ($seedExit -ne 0) {
            Write-Host "✗ Ошибка при выполнении сида" -ForegroundColor Red
            exit 1
        }
    }

    # --- сводка ---
    Write-Host ""
    Write-Host "Итоговые данные:" -ForegroundColor Yellow
    $summary = @"
SELECT 'users' AS table_name, COUNT(*) AS records FROM users
UNION ALL SELECT 'roles', COUNT(*) FROM roles
UNION ALL SELECT 'services', COUNT(*) FROM services
UNION ALL SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL SELECT 'buildings', COUNT(*) FROM buildings
UNION ALL SELECT 'schema_migrations', COUNT(*) FROM schema_migrations
ORDER BY table_name;
"@
    $summaryOutput = Invoke-Psql -Arguments @(
        '-h', $resolvedHost, '-p', $resolvedPort, '-U', $resolvedUser,
        '-d', $resolvedName, '-c', $summary
    ) -Description 'Не удалось получить сводку'
    $summaryOutput | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
}
finally {
    if (Test-Path $tempEnvPath) {
        Remove-Item $tempEnvPath -Force
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Тестовая база '$resolvedName' готова" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
