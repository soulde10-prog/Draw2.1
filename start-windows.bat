@echo off
REM Draw2.1 Windows Quick Start Script
REM Starts frontend and backend development servers

echo.
echo ========================================
echo   Draw2.1 - Starting Services
echo ========================================
echo.

REM Check if node_modules exists for frontend
if not exist "frontend\node_modules" (
    echo [ERROR] Frontend dependencies not installed
    echo Run setup-windows.bat first
    pause
    exit /b 1
)

REM Check if node_modules exists for backend
if not exist "backend\node_modules" (
    echo [ERROR] Backend dependencies not installed
    echo Run setup-windows.bat first
    pause
    exit /b 1
)

echo [OK] All dependencies are installed
echo.
echo Starting services in separate windows...
echo.

REM Start frontend
start "Draw2.1 Frontend - http://localhost:5173" cmd /k "cd frontend && npm run dev"

REM Wait for frontend to initialize
timeout /t 2 /nobreak

REM Start backend
start "Draw2.1 Backend - http://localhost:3001" cmd /k "cd backend && npm run dev"

echo.
echo ========================================
echo   Services Started Successfully!
echo ========================================
echo.
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:3001
echo.
echo Press any key to continue...
echo.
pause
