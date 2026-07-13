@echo off
REM Draw2.1 Windows Cleanup Script
REM Removes node_modules and temporary files

echo.
echo ========================================
echo   Draw2.1 - Cleanup
echo ========================================
echo.
echo WARNING: This will delete node_modules and dist folders
echo.
set /p confirm="Are you sure? (yes/no): "

if /i not "%confirm%"=="yes" (
    echo Cleanup cancelled
    exit /b 0
)

echo.
echo Cleaning up...
echo.

REM Remove frontend
echo Removing frontend node_modules...
if exist "frontend\node_modules" (
    rmdir /s /q "frontend\node_modules"
    echo [OK] Frontend node_modules removed
)

if exist "frontend\dist" (
    rmdir /s /q "frontend\dist"
    echo [OK] Frontend dist removed
)

REM Remove backend
echo Removing backend node_modules...
if exist "backend\node_modules" (
    rmdir /s /q "backend\node_modules"
    echo [OK] Backend node_modules removed
)

echo.
echo ========================================
echo   Cleanup Complete
echo ========================================
echo.
echo You can now run setup-windows.bat again to reinstall
echo.
pause
