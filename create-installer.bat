@echo off
REM Draw2.1 Windows Installer
REM Creates a self-extracting installer for Draw2.1
REM This script packages all files into an executable installer

echo.
echo ========================================
echo   Draw2.1 Installer Builder
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "frontend" (
    echo [ERROR] frontend directory not found
    echo Please run this script from the Draw2.1 root directory
    pause
    exit /b 1
)

if not exist "backend" (
    echo [ERROR] backend directory not found
    echo Please run this script from the Draw2.1 root directory
    pause
    exit /b 1
)

echo Creating installer package...
echo.

REM Create installer directory
if not exist "installer" mkdir installer

REM Copy main files
echo [1/5] Copying source files...
xcopy /E /I /Y frontend installer\frontend >nul 2>&1
xcopy /E /I /Y backend installer\backend >nul 2>&1
xcopy /E /I /Y shared installer\shared >nul 2>&1

REM Copy batch scripts
echo [2/5] Copying setup scripts...
copy install-windows.bat installer\ >nul 2>&1
copy setup-windows.bat installer\ >nul 2>&1
copy start-windows.bat installer\ >nul 2>&1
copy stop-windows.bat installer\ >nul 2>&1
copy RUN_ME.bat installer\ >nul 2>&1

REM Copy configuration files
echo [3/5] Copying configuration files...
copy .env.example installer\ >nul 2>&1
copy .gitignore installer\ >nul 2>&1

REM Copy documentation
echo [4/5] Copying documentation...
copy README.md installer\ >nul 2>&1
copy API.md installer\ >nul 2>&1
copy WINDOWS_SETUP.md installer\ >nul 2>&1
copy DEPLOYMENT_GUIDE.md installer\ >nul 2>&1
copy CONTRIBUTING.md installer\ >nul 2>&1

REM Create package info file
echo [5/5] Creating package information...
(
    echo Draw2.1 Installer Package
    echo Version: 1.0.0
    echo Build Date: %date% %time%
    echo.
    echo Installation Instructions:
    echo 1. Extract this archive
    echo 2. Double-click RUN_ME.bat
    echo 3. Select option 1 for first-time setup
    echo 4. Follow the on-screen instructions
) > installer\INSTALL.txt

echo.
echo ========================================
echo   Installer package created!
echo ========================================
echo.
echo Package location: installer\
echo.
echo Next steps:
echo 1. Download 7-Zip: https://www.7-zip.org/
echo 2. Right-click 'installer' folder
echo 3. Select 7-Zip > Add to archive
echo 4. Create self-extracting archive (.exe)
echo 5. Rename to: Draw2.1-Setup-1.0.0.exe
echo.
pause
