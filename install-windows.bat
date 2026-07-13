@echo off
REM Draw2.1 Windows Installation Script
REM This script installs all prerequisites

echo.
echo ========================================
echo   Draw2.1 - Windows Requirements Check
echo ========================================
echo.

REM Check for Node.js
echo Checking for Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo [MISSING] Node.js is required
    echo.
    echo Installing Node.js...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://nodejs.org/dist/v18.18.0/node-v18.18.0-x64.msi', 'node-installer.msi'); Start-Process msiexec.exe -ArgumentList '/i node-installer.msi /qb' -Wait; Remove-Item 'node-installer.msi'"
    echo.
    echo Please restart this script after Node.js installation completes.
    pause
    exit /b 0
) else (
    echo [OK] Node.js is installed
    node --version
    echo.
)

REM Check for npm
echo Checking for npm...
npm --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm is required but not found
    pause
    exit /b 1
) else (
    echo [OK] npm is installed
    npm --version
    echo.
)

REM Check for Git (optional but recommended)
echo Checking for Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo [OPTIONAL] Git is not installed (recommended for updates)
    echo You can install Git from: https://git-scm.com/
    echo.
) else (
    echo [OK] Git is installed
    git --version
    echo.
)

echo ========================================
echo   All requirements are satisfied!
echo ========================================
echo.
echo Next steps:
echo 1. Edit .env file with your configuration
echo 2. Ensure MongoDB is running (local or MongoDB Atlas connection string in .env)
echo 3. Run: setup-windows.bat
echo.
pause
