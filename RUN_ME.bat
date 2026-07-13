@echo off
REM Draw2.1 Main Launcher
REM This is the main entry point for Windows users

color 0A
cls

echo.
echo.
echo   =========================================
echo       Draw2.1 - Professional Drawing App
echo   =========================================
echo.
echo   Welcome! Let's get you set up.
echo.
echo   What would you like to do?
echo.
echo   1. First-time setup (Install everything)
echo   2. Start Draw2.1 (dependencies already installed)
echo   3. Start with Docker (requires Docker Desktop)
echo   4. View setup guide
echo   5. Clean up files
echo   6. Stop all services
echo   7. Exit
echo.
set /p choice="Enter your choice (1-7): "

if "%choice%"=="1" goto setup
if "%choice%"=="2" goto start
if "%choice%"=="3" goto docker
if "%choice%"=="4" goto guide
if "%choice%"=="5" goto clean
if "%choice%"=="6" goto stop
if "%choice%"=="7" goto exit

echo Invalid choice. Please try again.
pause
goto start

:setup
cls
echo.
echo Installing Draw2.1...
echo.
echo Step 1: Checking requirements...
call install-windows.bat
echo.
echo Step 2: Setting up application...
call setup-windows.bat
goto end

:start
cls
echo.
echo Starting Draw2.1...
echo.
call start-windows.bat
goto end

:docker
cls
echo.
echo Starting Draw2.1 with Docker...
echo.
call docker-windows.bat
goto end

:guide
cls
type WINDOWS_SETUP.md
echo.
pause
goto start

:clean
cls
echo.
call clean-windows.bat
goto end

:stop
cls
echo.
call stop-windows.bat
goto end

:exit
cls
echo.
echo Thank you for using Draw2.1!
echo.
echo For more information, visit: https://github.com/soulde10-prog/Draw2.1
echo.
pause
exit /b 0

:end
pause
goto start
