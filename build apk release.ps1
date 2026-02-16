# build_apk.ps1
Write-Host "Начинаю сборку Flutter APK..." -ForegroundColor Cyan

# Запускаем сборку
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    # Создаем уникальное имя с временной меткой
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $newFileName = "app_$timestamp.apk"
    
    # Копируем с новым именем
    $sourcePath = "build\app\outputs\flutter-apk\app-release.apk"
    Copy-Item -Path $sourcePath -Destination $newFileName
    
    Write-Host ""
    Write-Host "УСПЕХ!" -ForegroundColor Green
    Write-Host "Создан файл: $newFileName" -ForegroundColor Yellow
    Write-Host "Размер: $([math]::Round((Get-Item $newFileName).Length/1MB, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "Ошибка при сборке!" -ForegroundColor Red
}