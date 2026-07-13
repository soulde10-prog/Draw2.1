@echo off
REM Draw2.1 Windows Setup Script
REM This script will install all dependencies and start the application

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Draw2.1 - Windows Setup & Launch
echo ========================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed!
    echo Please download and install Node.js from: https://nodejs.org/
    echo After installation, restart this script.
    pause
    exit /b 1
)

echo [OK] Node.js is installed
node --version
echo.

REM Check if MongoDB is available (local or Atlas)
echo [INFO] Checking MongoDB availability...
echo.

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo [INFO] Creating .env file from template...
    copy .env.example .env
    echo [OK] .env file created. Please edit it with your settings.
    echo.
)

REM Install frontend dependencies
echo [STEP 1/4] Installing frontend dependencies...
cd frontend
if exist node_modules (
    echo [OK] Frontend dependencies already installed
) else (
    call npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install frontend dependencies
        pause
        exit /b 1
    )
)
cd ..
echo.

REM Install backend dependencies
echo [STEP 2/4] Installing backend dependencies...
cd backend
if exist node_modules (
    echo [OK] Backend dependencies already installed
) else (
    call npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install backend dependencies
        pause
        exit /b 1
    )
endlocal & setlocal enabledelayedexpansion
cd ..
echo.

echo [STEP 3/4] Building frontend...
cd frontend
call npm run build
if errorlevel 1 (
    echo [ERROR] Frontend build failed
    pause
    exit /b 1
)
cd ..
echo [OK] Frontend build completed
echo.

echo [STEP 4/4] Starting application...
echo.
echo ========================================
echo   Launching Draw2.1 Services
echo ========================================
echo.
echo Frontend will start in a new window...
echo Backend will start in a new window...
echo.

REM Start frontend in a new window
start "Draw2.1 Frontend" cmd /k "cd frontend && npm run dev"

REM Wait a moment for frontend to start
timeout /t 3 /nobreak

REM Start backend in a new window
start "Draw2.1 Backend" cmd /k "cd backend && npm run dev"

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:3001
echo.
echo Services are starting in separate windows...
echo.
pause
