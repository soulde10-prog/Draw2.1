@echo off
REM Draw2.1 Windows Stop Services Script
REM Stops all running services

echo.
echo ========================================
echo   Draw2.1 - Stopping Services
echo ========================================
echo.

echo Stopping services...
echo.

REM Kill Node processes
echo Stopping Node.js processes...
taskkill /IM node.exe /F >nul 2>&1

if errorlevel 1 (
    echo [INFO] No Node.js processes were running
) else (
    echo [OK] Node.js processes stopped
)

echo.
echo Stopping Docker services...
docker-compose down >nul 2>&1

if errorlevel 1 (
    echo [INFO] No Docker services were running
) else (
    echo [OK] Docker services stopped
)

echo.
echo ========================================
echo   All services stopped
echo ========================================
echo.
pause
