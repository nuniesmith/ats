@echo off
setlocal EnableDelayedExpansion

echo ===========================================
echo   Quick Test of Setup Environment
echo ===========================================

:: Set environment variables directly for testing
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"

echo.
echo Testing setup environment functionality...
echo.

:: Stop any running servers
echo Stopping existing servers...
taskkill /F /IM amtrucks_server.exe 2>nul
echo Waiting for processes to stop...
timeout /t 2 >nul

:: Validate server directory
if not exist "%SERVER_DIR%" (
    echo ❌ ERROR: Server directory not found: "%SERVER_DIR%"
    echo Please check your server installation
    pause
    exit /b 1
)

:: Create necessary directories
echo Creating server directories...
if not exist "%SERVER_DIR%\mod" (
    echo Creating mod directory...
    mkdir "%SERVER_DIR%\mod"
    if !errorlevel! equ 0 (
        echo ✓ Mod directory created successfully
    ) else (
        echo ❌ Failed to create mod directory - Error: !errorlevel!
    )
) else (
    echo ✓ Mod directory already exists
)

echo.
echo ✓ Setup test completed successfully!
echo Server directory: %SERVER_DIR%
echo Mod directory exists: 
if exist "%SERVER_DIR%\mod" (
    echo   ✓ Yes
) else (
    echo   ❌ No
)

echo.
pause
