@echo off
REM Draw2.1 Docker Setup for Windows
REM Starts all services using Docker Compose

echo.
echo ========================================
echo   Draw2.1 - Docker Setup (Windows)
echo ========================================
echo.

REM Check if Docker is installed
echo Checking for Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed!
    echo.
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    echo After installation, restart this script.
    pause
    exit /b 1
)

echo [OK] Docker is installed
docker --version
echo.

REM Check if Docker Compose is available
echo Checking for Docker Compose...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not available!
    echo Please ensure Docker Desktop is properly installed.
    pause
    exit /b 1
)

echo [OK] Docker Compose is available
docker-compose --version
echo.

echo ========================================
echo   Starting Docker Services
echo ========================================
echo.

REM Start Docker services
echo Building and starting all services...
echo This may take a few minutes on first run...
echo.

docker-compose up --build

if errorlevel 1 (
    echo.
    echo [ERROR] Docker Compose failed to start services
    pause
    exit /b 1
)
