@echo off
REM ATS Server Master Deployment Script (Windows)
REM ===============================================

setlocal EnableDelayedExpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "DOCKER_SCRIPTS_DIR=%SCRIPT_DIR%scripts\docker"

echo ===============================================
echo    ATS Server Management - Master Deployer
echo ===============================================
echo.

REM Check for command line argument
if "%1"=="" goto show_menu

REM Direct command execution
set "command=%1"
set "arg1=%2"
set "arg2=%3"

if /i "%command%"=="local" (
    echo Launching Local Docker Deployment...
    call "%DOCKER_SCRIPTS_DIR%\deploy-local.bat" %arg1% %arg2%
    goto end
)

if /i "%command%"=="dockerhub" (
    echo Launching DockerHub Deployment...
    call "%DOCKER_SCRIPTS_DIR%\deploy-dockerhub.bat" %arg1% %arg2%
    goto end
)

if /i "%command%"=="server" (
    echo Launching ATS Server Manager...
    call "%SCRIPT_DIR%scripts\ats_server_manager.bat"
    goto end
)

goto show_help

:show_menu
echo Select deployment method:
echo.
echo 1. Local Development (Build images locally)
echo 2. Production (Pull from DockerHub)
echo 3. ATS Server Manager (Game server management)
echo 4. Help & Documentation
echo 5. Exit
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto local_deployment
if "%choice%"=="2" goto dockerhub_deployment
if "%choice%"=="3" goto server_manager
if "%choice%"=="4" goto show_help
if "%choice%"=="5" goto end
goto show_menu

:local_deployment
echo.
echo ================================================
echo           Local Development Deployment
echo ================================================
echo.
echo This will build Docker images locally and start services.
echo Perfect for development and testing.
echo.
call "%DOCKER_SCRIPTS_DIR%\deploy-local.bat" start
goto end

:dockerhub_deployment
echo.
echo ================================================
echo            Production Deployment
echo ================================================
echo.
echo Choose deployment mode:
echo 1. Standard (Use local images if DockerHub fails)
echo 2. Production (Force DockerHub images)
echo 3. Specific Version
echo 4. Back to main menu
echo.
set /p prod_choice="Enter your choice (1-4): "

if "%prod_choice%"=="1" (
    call "%DOCKER_SCRIPTS_DIR%\deploy-dockerhub.bat" start
) else if "%prod_choice%"=="2" (
    call "%DOCKER_SCRIPTS_DIR%\deploy-dockerhub.bat" start prod
) else if "%prod_choice%"=="3" (
    set /p version="Enter version tag (e.g., v1.2.3): "
    call "%DOCKER_SCRIPTS_DIR%\deploy-dockerhub.bat" start prod !version!
) else if "%prod_choice%"=="4" (
    goto show_menu
) else (
    echo Invalid choice. Returning to main menu...
    timeout /t 2 /nobreak >nul
    goto show_menu
)
goto end

:server_manager
echo.
echo ================================================
echo            ATS Server Manager
echo ================================================
echo.
echo Launching comprehensive ATS server management...
call "%SCRIPT_DIR%scripts\ats_server_manager.bat"
goto end

:show_help
echo.
echo ================================================
echo         ATS Server Management Help
echo ================================================
echo.
echo COMMAND LINE USAGE:
echo   %~nx0 local [command]          - Local development deployment
echo   %~nx0 dockerhub [command]      - DockerHub production deployment  
echo   %~nx0 server                   - ATS server management
echo.
echo AVAILABLE COMMANDS:
echo   start, stop, restart, logs, status, build, cleanup
echo.
echo EXAMPLES:
echo   %~nx0 local start              - Start local development
echo   %~nx0 dockerhub start prod     - Start production from DockerHub
echo   %~nx0 local logs ats-web       - Show web app logs
echo   %~nx0 dockerhub status         - Check service status
echo.
echo DEPLOYMENT METHODS:
echo.
echo 1. LOCAL DEVELOPMENT:
echo    - Builds Docker images from source code
echo    - Uses docker-compose.yml
echo    - Perfect for development and testing
echo    - Faster iteration on code changes
echo.
echo 2. PRODUCTION (DOCKERHUB):
echo    - Pulls pre-built images from DockerHub
echo    - Uses docker-compose.prod.yml for production
echo    - Faster deployment, smaller bandwidth usage
echo    - Supports version tags for rollbacks
echo.
echo 3. ATS SERVER MANAGER:
echo    - Comprehensive game server management
echo    - Mod collection utilities
echo    - Server configuration and monitoring
echo    - Automated server operations
echo.
echo REQUIREMENTS:
echo   - Docker Desktop installed and running
echo   - Docker Compose available
echo   - Internet connection (for DockerHub deployment)
echo.
echo DOCUMENTATION:
echo   - Check docs\ folder for detailed guides
echo   - README.md for quick start
echo   - DOCKER_README.md for Docker-specific info
echo.
pause
goto show_menu

:end
echo.
echo Script completed. Press any key to exit...
pause >nul
