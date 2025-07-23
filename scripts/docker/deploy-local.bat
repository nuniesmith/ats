@echo off
REM ATS Server Local Docker Deployment Script (Windows)
REM ====================================================

setlocal EnableDelayedExpansion

REM Configuration
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%..\.."
set "COMPOSE_FILE=%PROJECT_ROOT%\docker-compose.yml"
set "ENV_FILE=%PROJECT_ROOT%\.env"

REM Colors for Windows
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM Change to project root
cd /d "%PROJECT_ROOT%"

REM Functions
goto :main

:log_info
echo %BLUE%ℹ️  %~1%NC%
exit /b

:log_success
echo %GREEN%✅ %~1%NC%
exit /b

:log_warning
echo %YELLOW%⚠️  %~1%NC%
exit /b

:log_error
echo %RED%❌ %~1%NC%
exit /b

:check_docker
call :log_info "Checking Docker installation..."
where docker >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker is not installed. Please install Docker Desktop first."
    exit /b 1
)

where docker-compose >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker Compose is not installed. Please install Docker Compose first."
    exit /b 1
)

call :log_success "Docker and Docker Compose are installed"
exit /b

:create_env_file
if not exist "%ENV_FILE%" (
    call :log_warning "Environment file .env not found. Creating with defaults..."
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
    call :log_warning "Created .env file - please edit it with your configuration"
    call :log_info "You can start with default values for local development"
) else (
    call :log_info "Using existing .env file"
)
exit /b

:build_images
call :log_info "Building Docker images locally..."
docker-compose build --no-cache
if errorlevel 1 (
    call :log_error "Failed to build Docker images"
    exit /b 1
)
call :log_success "Docker images built successfully"
exit /b

:start_services
call :log_info "Starting ATS services..."

REM Stop any existing containers
docker-compose down 2>nul

REM Start new containers
docker-compose up -d
if errorlevel 1 (
    call :log_error "Failed to start services"
    exit /b 1
)

call :log_success "Services started successfully"
exit /b

:check_health
call :log_info "Checking service health..."

REM Wait for services to start
timeout /t 10 /nobreak >nul

REM Check if containers are running
docker-compose ps | findstr "Up" >nul
if errorlevel 1 (
    call :log_error "Some containers failed to start"
    docker-compose logs
    exit /b 1
)

call :log_success "Containers are running"

REM Check web app health
call :log_info "Checking web application health..."
for /l %%i in (1,1,30) do (
    curl -f http://localhost/health >nul 2>&1
    if !errorlevel! equ 0 (
        call :log_success "Web application is healthy"
        goto check_api
    )
    call :log_info "Waiting for web application... (attempt %%i/30)"
    timeout /t 2 /nobreak >nul
)

:check_api
call :log_info "Checking API server health..."
for /l %%i in (1,1,30) do (
    curl -f http://localhost:3001/health >nul 2>&1
    if !errorlevel! equ 0 (
        call :log_success "API server is healthy"
        goto health_done
    )
    call :log_info "Waiting for API server... (attempt %%i/30)"
    timeout /t 2 /nobreak >nul
)

:health_done
exit /b

:show_info
echo.
call :log_success "🚀 ATS Server Management System is running!"
echo.
echo 📍 Access Points:
echo    🌐 Web Interface: http://localhost
echo    🔧 API Server: http://localhost:3001
echo    📊 Health Check: http://localhost/health
echo.
echo 🔧 Management Commands:
echo    📋 View logs: %~nx0 logs
echo    📊 View status: %~nx0 status
echo    🛑 Stop services: %~nx0 stop
echo    🔄 Restart services: %~nx0 restart
echo.
echo 🔐 Default Login:
echo    👤 Username: admin
echo    🔑 Password: admin123
echo.
exit /b

:start
call :check_docker
call :create_env_file
call :build_images
call :start_services
call :check_health
call :show_info
pause
exit /b

:stop
call :log_info "Stopping ATS services..."
docker-compose down
call :log_success "Services stopped"
exit /b

:restart
call :log_info "Restarting ATS services..."
docker-compose down
docker-compose up -d
call :check_health
call :show_info
exit /b

:logs
set "service=%~2"
if not "%service%"=="" (
    call :log_info "Showing logs for service: %service%"
    docker-compose logs --tail=50 -f "%service%"
) else (
    call :log_info "Showing container logs..."
    docker-compose logs --tail=50 -f
)
exit /b

:build
call :check_docker
call :build_images
exit /b

:cleanup
call :log_warning "This will remove all containers, networks, and unused images"
set /p "confirm=Are you sure? (y/N): "

if /i "%confirm%"=="y" (
    call :log_info "Cleaning up Docker resources..."
    docker-compose down --volumes --remove-orphans
    docker rmi ats-web:latest ats-api:latest 2>nul
    call :log_success "Cleanup completed"
) else (
    call :log_info "Cleanup cancelled"
)
exit /b

:status
call :log_info "Service Status:"
docker-compose ps
echo.
call :log_info "Quick Health Check:"

curl -sf http://localhost/health >nul 2>&1
if errorlevel 0 (
    call :log_success "Web App: Healthy"
) else (
    call :log_error "Web App: Unhealthy"
)

curl -sf http://localhost:3001/health >nul 2>&1
if errorlevel 0 (
    call :log_success "API Server: Healthy"
) else (
    call :log_error "API Server: Unhealthy"
)
exit /b

:show_help
echo ATS Server Local Docker Deployment Script
echo ==========================================
echo.
echo Usage: %~nx0 {command} [options]
echo.
echo Commands:
echo   start      - Build and start all services
echo   stop       - Stop all services
echo   restart    - Restart all services
echo   logs [svc] - Show container logs (optionally for specific service)
echo   build      - Build Docker images only
echo   cleanup    - Stop services and remove containers/images
echo   status     - Show container status and health
echo   help       - Show this help message
echo.
echo Examples:
echo   %~nx0 start           # Start everything
echo   %~nx0 logs ats-web    # Show web app logs
echo   %~nx0 status          # Check service health
echo.
exit /b

:main
set "command=%~1"

if "%command%"=="" goto show_help
if "%command%"=="start" goto start
if "%command%"=="stop" goto stop
if "%command%"=="restart" goto restart
if "%command%"=="logs" goto logs
if "%command%"=="build" goto build
if "%command%"=="cleanup" goto cleanup
if "%command%"=="status" goto status
if "%command%"=="help" goto show_help
goto show_help
