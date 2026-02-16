# Сборка дебажного APK для Mobile Dev
$EnvName = "dev.mobile"
$Release = $false

Write-Host "Начинаю сборку Flutter APK для окружения '$EnvName' (Debug)..." -ForegroundColor Cyan

# Формируем команду сборки
$buildCommand = "flutter build apk --dart-define=env=$EnvName"
if ($Release) {
    $buildCommand += " --release"
}

Write-Host "Выполняемая команда: $buildCommand" -ForegroundColor DarkGray
Invoke-Expression $buildCommand

if ($LASTEXITCODE -eq 0) {
    $sourceApkFileName = if ($Release) { "app-release.apk" } else { "app-debug.apk" }
    $sourcePath = "build\app\outputs\flutter-apk\$sourceApkFileName"
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $newFileName = "app_$EnvName"
    if ($Release) { $newFileName += "_release" } else { $newFileName += "_debug" }
    $newFileName += "_$timestamp.apk"
    
    Copy-Item -Path $sourcePath -Destination $newFileName
    
    Write-Host ""
    Write-Host "УСПЕХ!" -ForegroundColor Green
    Write-Host "Создан файл: $newFileName" -ForegroundColor Yellow
    Write-Host "Размер: $([math]::Round((Get-Item $newFileName).Length/1MB, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "Ошибка при сборке! Код выхода: $LASTEXITCODE" -ForegroundColor Red
}
