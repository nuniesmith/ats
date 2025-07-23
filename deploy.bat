@echo off
title ATS Server Docker Deployment

REM ATS Server Docker Deployment Script (Windows)
REM ==============================================

setlocal EnableDelayedExpansion

REM Configuration
set COMPOSE_FILE=docker-compose.yml
set ENV_FILE=.env

REM Check command line argument
if "%1"=="" goto usage
if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="logs" goto logs
if "%1"=="build" goto build
if "%1"=="cleanup" goto cleanup
if "%1"=="status" goto status
goto usage

:check_docker
echo Checking Docker installation...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

echo ✅ Docker and Docker Compose are installed
goto :eof

:create_env_file
if not exist "%ENV_FILE%" (
    echo Creating environment file...
    (
        echo # ATS Server Environment Configuration
        echo # ===================================
        echo.
        echo # Security
        echo JWT_SECRET=your-jwt-secret-change-this-in-production
        echo.
        echo # Domain Configuration
        echo DOMAIN_NAME=ats.7gram.xyz
        echo.
        echo # ATS Configuration
        echo ATS_DEFAULT_PASSWORD=ruby
        echo STEAM_COLLECTION_ID=3530633316
        echo.
        echo # API URLs ^(automatically configured for Docker^)
        echo VITE_API_URL=http://localhost/api
        echo VITE_SOCKET_URL=http://localhost
        echo.
        echo # Optional: External Services
        echo CLOUDFLARE_API_TOKEN=
        echo CLOUDFLARE_ZONE_ID=
        echo DISCORD_WEBHOOK_URL=
    ) > "%ENV_FILE%"
    echo ⚠️  Created %ENV_FILE% - please edit it with your configuration
    echo ℹ️  You can start with default values for local development
) else (
    echo ℹ️  Using existing %ENV_FILE%
)
goto :eof

:build_images
echo Building Docker images...

echo Building React web application...
cd web
docker build -t ats-web:latest .
if %errorlevel% neq 0 (
    echo ❌ Failed to build web application image
    cd ..
    pause
    exit /b 1
)
cd ..

echo Building Node.js API server...
cd api
docker build -t ats-api:latest .
if %errorlevel% neq 0 (
    echo ❌ Failed to build API server image
    cd ..
    pause
    exit /b 1
)
cd ..

echo ✅ Docker images built successfully
goto :eof

:start_services
echo Starting ATS services...

REM Stop any existing containers
docker-compose down 2>nul

REM Start new containers
docker-compose up -d
if %errorlevel% neq 0 (
    echo ❌ Failed to start services
    pause
    exit /b 1
)

echo ✅ Services started successfully
goto :eof

:check_health
echo Checking service health...

REM Wait for services to start
timeout /t 10 /nobreak >nul

REM Check if containers are running
docker-compose ps | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo ❌ Some containers failed to start
    docker-compose logs
    pause
    exit /b 1
)

echo ✅ Containers are running

REM Check web app health (simple approach for Windows)
echo Checking web application health...
for /l %%i in (1,1,30) do (
    curl -f http://localhost/health >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✅ Web application is healthy
        goto check_api
    )
    echo Waiting for web application... ^(attempt %%i/30^)
    timeout /t 2 /nobreak >nul
)

:check_api
echo Checking API server health...
for /l %%i in (1,1,30) do (
    curl -f http://localhost:3001/health >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✅ API server is healthy
        goto health_done
    )
    echo Waiting for API server... ^(attempt %%i/30^)
    timeout /t 2 /nobreak >nul
)

:health_done
goto :eof

:show_info
echo.
echo ✅ 🚀 ATS Server Management System is running!
echo.
echo 📍 Access Points:
echo    🌐 Web Interface: http://localhost
echo    🔧 API Server: http://localhost:3001
echo    📊 Health Check: http://localhost/health
echo.
echo 🔧 Management Commands:
echo    📋 View logs: deploy.bat logs
echo    📊 View status: deploy.bat status
echo    🛑 Stop services: deploy.bat stop
echo    🔄 Restart services: deploy.bat restart
echo.
echo 🔐 Default Login:
echo    👤 Username: admin
echo    🔑 Password: admin123
echo.
goto :eof

:start
call :check_docker
call :create_env_file
call :build_images
call :start_services
call :check_health
call :show_info
pause
goto :eof

:stop
echo Stopping ATS services...
docker-compose down
echo ✅ Services stopped
goto :eof

:restart
echo Restarting ATS services...
docker-compose down
docker-compose up -d
call :check_health
call :show_info
goto :eof

:logs
echo Showing container logs...
docker-compose logs --tail=50 -f
goto :eof

:build
call :check_docker
call :build_images
goto :eof

:cleanup
echo Cleaning up Docker resources...
docker-compose down --volumes --remove-orphans
docker rmi ats-web:latest ats-api:latest 2>nul
echo ✅ Cleanup completed
goto :eof

:status
docker-compose ps
goto :eof

:usage
echo ATS Server Docker Deployment Script
echo ==================================
echo.
echo Usage: %0 {start^|stop^|restart^|logs^|build^|cleanup^|status}
echo.
echo Commands:
echo   start    - Build and start all services
echo   stop     - Stop all services
echo   restart  - Restart all services
echo   logs     - Show container logs
echo   build    - Build Docker images only
echo   cleanup  - Stop services and remove containers/images
echo   status   - Show container status
echo.
pause
goto :eof
