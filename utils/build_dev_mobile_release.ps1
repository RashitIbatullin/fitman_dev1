# Сборка релизного APK для Mobile Dev
$EnvName = "dev.mobile"
$Release = $true

Write-Host "Начинаю сборку Flutter APK для окружения '$EnvName' (Release)..." -ForegroundColor Cyan

# Формируем команду сборки
$buildCommand = "flutter build apk --dart-define=env=$EnvName"
if ($Release) {
    $buildCommand += " --release"
}

Write-Host "Выполняемая команда: $buildCommand" -ForegroundColor DarkGray
Invoke-Expression $buildCommand

if ($LASTEXITCODE -eq 0) {
    $projectRoot = (Get-Item $PSScriptRoot).Parent.FullName

    $sourceApkFileName = if ($Release) { "app-release.apk" } else { "app-debug.apk" }
    $sourcePath = Join-Path $projectRoot "build\app\outputs\flutter-apk\$sourceApkFileName"
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $baseFileName = "app_$EnvName"
    if ($Release) { $baseFileName += "_release" } else { $baseFileName += "_debug" }
    $newFileName = "$baseFileName" + "_$timestamp.apk"
    $destinationPath = Join-Path $projectRoot $newFileName
    
    Copy-Item -Path $sourcePath -Destination $destinationPath
    
    Write-Host ""
    Write-Host "УСПЕХ!" -ForegroundColor Green
    Write-Host "Создан файл: $destinationPath" -ForegroundColor Yellow
    Write-Host "Размер: $([math]::Round((Get-Item $destinationPath).Length/1MB, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "Ошибка при сборке! Код выхода: $LASTEXITCODE" -ForegroundColor Red
}
