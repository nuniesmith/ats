@echo off
REM ATS Server Docker Deployment Script with DockerHub Support (Windows)
REM =====================================================================

setlocal enabledelayedexpansion

REM Get script directory and project root
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%..\.."

REM Configuration
set "COMPOSE_FILE=%PROJECT_ROOT%\docker-compose.yml"
set "PROD_COMPOSE_FILE=%PROJECT_ROOT%\docker-compose.prod.yml"
set "ENV_FILE=%PROJECT_ROOT%\.env"
set "DOCKERHUB_REPO=nuniesmith/ats"

REM Change to project root
cd /d "%PROJECT_ROOT%"

REM ANSI Color codes for Windows
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

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
where docker >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker is not installed or not in PATH"
    exit /b 1
)

where docker-compose >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker Compose is not installed or not in PATH"
    exit /b 1
)
exit /b 0

:check_environment
if not exist "%ENV_FILE%" (
    call :log_warning "Environment file .env not found. Creating with defaults..."
    call :create_env_file
)
exit /b

:create_env_file
(
echo # ATS Server Configuration
echo NODE_ENV=production
echo JWT_SECRET=your-jwt-secret-change-this-in-production
echo DOMAIN_NAME=ats.7gram.xyz
echo ATS_DEFAULT_PASSWORD=ruby
echo STEAM_COLLECTION_ID=3530633316
echo.
echo # DockerHub Images ^(leave empty to build locally^)
echo WEB_IMAGE=
echo API_IMAGE=
echo.
echo # Optional External Services
echo CLOUDFLARE_API_TOKEN=
echo CLOUDFLARE_ZONE_ID=
echo DISCORD_WEBHOOK_URL=
) > "%ENV_FILE%"

call :log_success "Created default environment file: .env"
call :log_info "Please edit .env with your configuration"
exit /b

:pull_images
set "tag=%~1"
if "%tag%"=="" set "tag=latest"

call :log_info "Pulling Docker images from DockerHub..."

docker pull "%DOCKERHUB_REPO%:web-%tag%" >nul 2>&1
if errorlevel 0 (
    set "WEB_IMAGE=%DOCKERHUB_REPO%:web-%tag%"
    call :log_success "Pulled web image: !WEB_IMAGE!"
) else (
    call :log_warning "Failed to pull web image, will build locally"
    set "WEB_IMAGE="
)

docker pull "%DOCKERHUB_REPO%:api-%tag%" >nul 2>&1
if errorlevel 0 (
    set "API_IMAGE=%DOCKERHUB_REPO%:api-%tag%"
    call :log_success "Pulled API image: !API_IMAGE!"
) else (
    call :log_warning "Failed to pull API image, will build locally"
    set "API_IMAGE="
)
exit /b

:build_images
call :log_info "Building Docker images locally..."
docker-compose -f "%COMPOSE_FILE%" build --no-cache
if errorlevel 1 (
    call :log_error "Failed to build Docker images"
    exit /b 1
)
call :log_success "Docker images built successfully"
exit /b

:start_services
set "use_prod=%~1"
set "tag=%~2"
if "%use_prod%"=="" set "use_prod=false"
if "%tag%"=="" set "tag=latest"

call :check_docker
if errorlevel 1 exit /b 1

call :check_environment

if "%use_prod%"=="true" (
    call :log_info "Starting services with production configuration..."
    call :pull_images "%tag%"
    set "WEB_IMAGE=!WEB_IMAGE!" & set "API_IMAGE=!API_IMAGE!" & docker-compose -f "%PROD_COMPOSE_FILE%" up -d
) else (
    call :log_info "Starting services with local configuration..."
    docker-compose -f "%COMPOSE_FILE%" up -d
)

if errorlevel 1 (
    call :log_error "Failed to start services"
    exit /b 1
)

call :log_success "Services started successfully"
call :show_status
exit /b

:stop_services
call :log_info "Stopping all services..."
docker-compose -f "%COMPOSE_FILE%" down

if exist "%PROD_COMPOSE_FILE%" (
    docker-compose -f "%PROD_COMPOSE_FILE%" down >nul 2>&1
)

call :log_success "All services stopped"
exit /b

:restart_services
set "use_prod=%~1"
set "tag=%~2"

call :log_info "Restarting services..."
call :stop_services
timeout /t 2 /nobreak >nul
call :start_services "%use_prod%" "%tag%"
exit /b

:show_logs
set "service=%~1"

if not "%service%"=="" (
    call :log_info "Showing logs for service: %service%"
    docker-compose -f "%COMPOSE_FILE%" logs -f "%service%"
) else (
    call :log_info "Showing logs for all services..."
    docker-compose -f "%COMPOSE_FILE%" logs -f
)
exit /b

:show_status
call :log_info "Service Status:"
docker-compose -f "%COMPOSE_FILE%" ps

echo.
call :log_info "Health Checks:"

REM Check web app health
curl -sf http://localhost/health >nul 2>&1
if errorlevel 0 (
    call :log_success "Web App: Healthy (http://localhost)"
) else (
    call :log_error "Web App: Unhealthy or not accessible"
)

REM Check API health
curl -sf http://localhost:3001/health >nul 2>&1
if errorlevel 0 (
    call :log_success "API Server: Healthy (http://localhost:3001)"
) else (
    call :log_error "API Server: Unhealthy or not accessible"
)

REM Check Redis
docker-compose -f "%COMPOSE_FILE%" exec -T redis redis-cli ping >nul 2>&1
if errorlevel 0 (
    call :log_success "Redis: Healthy"
) else (
    call :log_error "Redis: Unhealthy or not accessible"
)
exit /b

:cleanup
call :log_warning "This will remove all containers, networks, and unused images"
set /p "confirm=Are you sure? (y/N): "

if /i "%confirm%"=="y" (
    call :log_info "Cleaning up Docker resources..."
    docker-compose down --volumes --remove-orphans
    if exist "%PROD_COMPOSE_FILE%" (
        docker-compose -f "%PROD_COMPOSE_FILE%" down --volumes --remove-orphans
    )
    docker system prune -f
    call :log_success "Cleanup completed"
) else (
    call :log_info "Cleanup cancelled"
)
exit /b

:update_images
set "tag=%~1"
if "%tag%"=="" set "tag=latest"

call :log_info "Updating to latest images..."
call :pull_images "%tag%"

if not "!WEB_IMAGE!"=="" if not "!API_IMAGE!"=="" (
    call :restart_services "true" "%tag%"
) else (
    call :restart_services "false"
)
exit /b

:show_help
echo ATS Server Docker Deployment Script with DockerHub Support
echo ==========================================================
echo.
echo Usage: %~nx0 ^<command^> [options]
echo.
echo Commands:
echo   start [prod] [tag]    Start services (prod=use DockerHub images)
echo   stop                  Stop all services
echo   restart [prod] [tag]  Restart services
echo   build                 Build Docker images locally
echo   logs [service]        Show logs (optionally for specific service)
echo   status                Show service status and health
echo   pull [tag]            Pull images from DockerHub
echo   update [tag]          Update to latest images and restart
echo   cleanup               Remove all containers and unused resources
echo   help                  Show this help message
echo.
echo Examples:
echo   %~nx0 start              # Start with local images
echo   %~nx0 start prod         # Start with DockerHub images (latest)
echo   %~nx0 start prod v1.2.3  # Start with specific version
echo   %~nx0 logs ats-web       # Show logs for web service
echo   %~nx0 update v1.2.3      # Update to specific version
echo.
echo DockerHub Repository: %DOCKERHUB_REPO%
exit /b

:main
set "command=%~1"

if "%command%"=="start" (
    call :start_services "%~2" "%~3"
) else if "%command%"=="stop" (
    call :stop_services
) else if "%command%"=="restart" (
    call :restart_services "%~2" "%~3"
) else if "%command%"=="build" (
    call :build_images
) else if "%command%"=="logs" (
    call :show_logs "%~2"
) else if "%command%"=="status" (
    call :show_status
) else if "%command%"=="pull" (
    call :pull_images "%~2"
) else if "%command%"=="update" (
    call :update_images "%~2"
) else if "%command%"=="cleanup" (
    call :cleanup
) else if "%command%"=="help" (
    call :show_help
) else (
    call :show_help
)
