@echo off
title FitMan SSH Tunnel (Port 54330)
color 0A

echo ========================================
echo    SSH Tunnel to Production Database
echo ========================================
echo.
echo Local port : 5434
echo Remote DB  : localhost:5432
echo Server     : 95.163.226.147
echo.
echo Press Ctrl+C to stop
echo ========================================
echo bejRrUA0Zdwah6bt

ssh -L 54330:localhost:5432 root@95.163.226.147

echo.
echo Tunnel closed.
pause