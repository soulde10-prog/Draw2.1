@echo off
REM Draw2.1 Complete Installation and Setup for Windows
REM This runs all setup steps automatically

setlocal enabledelayedexpansion

color 0A
cls

echo.
echo ========================================
echo   Draw2.1 v1.0.0 - Complete Setup
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] This script should be run as Administrator for best results
    echo.
    pause
)

echo [STEP 1/7] Checking Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Node.js not found. Downloading...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://nodejs.org/dist/v18.18.0/node-v18.18.0-x64.msi', 'node-installer.msi'); Start-Process msiexec.exe -ArgumentList '/i node-installer.msi /qb' -Wait; Remove-Item 'node-installer.msi'"
    echo [OK] Node.js installed. Please restart this script.
    pause
    exit /b 0
) else (
    echo [OK] Node.js found
    node --version
)

echo.
echo [STEP 2/7] Creating .env file...
if not exist ".env" (
    copy .env.example .env
    echo [OK] .env created
) else (
    echo [OK] .env already exists
)

echo.
echo [STEP 3/7] Installing frontend dependencies...
cd frontend
if not exist "node_modules" (
    call npm install
    if errorlevel 1 (
        echo [ERROR] Frontend installation failed
        pause
        exit /b 1
    )
) else (
    echo [OK] Frontend dependencies already installed
)
cd ..

echo.
echo [STEP 4/7] Installing backend dependencies...
cd backend
if not exist "node_modules" (
    call npm install
    if errorlevel 1 (
        echo [ERROR] Backend installation failed
        pause
        exit /b 1
    )
) else (
    echo [OK] Backend dependencies already installed
)
cd ..

echo.
echo [STEP 5/7] Building frontend...
cd frontend
call npm run build
if errorlevel 1 (
    echo [ERROR] Frontend build failed
    pause
    exit /b 1
)
echo [OK] Frontend built successfully
cd ..

echo.
echo [STEP 6/7] Configuring settings...
echo.
echo Please note:
echo - Edit .env file with your MongoDB URI
echo - Edit .env file with your JWT_SECRET
echo - Ensure MongoDB is running (local or Atlas)
echo.
set /p ready="Ready to start services? (y/n): "

if /i not "%ready%"=="y" (
    echo Setup complete but services not started
    echo Run: start-windows.bat
    pause
    exit /b 0
)

echo.
echo [STEP 7/7] Starting application services...
echo.

echo Starting frontend server...
start "Draw2.1 Frontend" cmd /k "cd frontend && npm run dev"

timeout /t 3 /nobreak

echo Starting backend server...
start "Draw2.1 Backend" cmd /k "cd backend && npm run dev"

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:3001
echo.
echo Services are starting in separate windows
echo Please wait 5-10 seconds for services to initialize
echo.
pause
