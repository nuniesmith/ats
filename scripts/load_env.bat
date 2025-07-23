@echo off
:: ===========================================
:: Environment Variable Loader for ATS Scripts
:: Loads configuration from .env file
:: ===========================================

:: Set default .env file location
set "ENV_FILE=%~dp0..\.env"

:: Check if custom .env path provided
if not "%~1"=="" set "ENV_FILE=%~1"

:: Check if .env file exists
if not exist "%ENV_FILE%" (
    echo ❌ Environment file not found: %ENV_FILE%
    echo Creating default .env file...
    call :CREATE_DEFAULT_ENV
    if exist "%ENV_FILE%" (
        echo ✓ Default .env file created
    ) else (
        echo ❌ Failed to create .env file
        exit /b 1
    )
)

echo Loading environment from: %ENV_FILE%

:: Simple approach - create a temporary batch file and call it
set "TEMP_LOADER=%TEMP%\ats_env_loader.bat"
echo @echo off > "%TEMP_LOADER%"

:: Parse .env file and create set commands
for /f "usebackq tokens=1,* delims==" %%a in ("%ENV_FILE%") do (
    if not "%%a"=="" (
        if not "%%a:~0,1"=="#" (
            echo set "%%a=%%b" >> "%TEMP_LOADER%"
        )
    )
)

:: Execute the temporary batch file to set variables
call "%TEMP_LOADER%"

:: Clean up
del "%TEMP_LOADER%" 2>nul

echo ✓ Environment variables loaded successfully
goto :eof

echo ✓ Environment variables loaded successfully

:: Export variables to calling script
endlocal & (
    for /f "usebackq tokens=1,2 delims==" %%a in ("%ENV_FILE%") do (
        set "LINE=%%a"
        set "VALUE=%%b"
        if not "%%a"=="" (
            if not "%%a:~0,1"=="#" (
                for /f "tokens=* delims= " %%x in ("%%a") do (
                    set "%%x=%%b"
                )
            )
        )
    )
)

goto :eof

:CREATE_DEFAULT_ENV
(
echo # ===========================================
echo # ATS Server Environment Configuration
echo # Default configuration - modify as needed
echo # ===========================================
echo.
echo # SERVER IDENTITY SETTINGS
echo SERVER_NAME=Freddy's ATS Dedicated Server
echo SERVER_DESCRIPTION=Enhanced ATS server with curated sound and graphics mods
echo SERVER_WELCOME_MESSAGE=Welcome to Freddy's server! Enjoy the enhanced experience with optional mods enabled.
echo SERVER_PASSWORD=ruby
echo.
echo # SERVER CONNECTION SETTINGS
echo DEFAULT_SERVER_ID=90271602251410447
echo SERVER_TOKEN=15AE684920A1694E27BFA8B64F75AD1B
echo.
echo # PORT CONFIGURATION
echo CONNECTION_VIRTUAL_PORT=100
echo QUERY_VIRTUAL_PORT=101
echo CONNECTION_DEDICATED_PORT=27015
echo QUERY_DEDICATED_PORT=27016
echo.
echo # SERVER CAPACITY
echo MAX_PLAYERS=8
echo MAX_VEHICLES_TOTAL=100
echo MAX_AI_VEHICLES_PLAYER=50
echo MAX_AI_VEHICLES_PLAYER_SPAWN=50
echo.
echo # GAMEPLAY SETTINGS
echo PLAYER_DAMAGE=true
echo TRAFFIC=true
echo HIDE_IN_COMPANY=false
echo HIDE_COLLIDING=true
echo FORCE_SPEED_LIMITER=false
echo MODS_OPTIONING=true
echo TIMEZONES=0
echo SERVICE_NO_COLLISION=false
echo IN_MENU_GHOSTING=false
echo NAME_TAGS=true
echo FRIENDS_ONLY=false
echo SHOW_SERVER=true
echo MODERATOR_LIST=0
echo.
echo # MOD MANAGEMENT
echo COLLECTION_ID=3530633316
echo COLLECTION_URL=https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316
echo AUTO_UPDATE_MODS=true
echo ENABLE_DYNAMIC_DOWNLOADS=true
echo.
echo # DIRECTORY PATHS
echo SERVER_DIR=C:\Program Files ^(x86^)\Steam\steamapps\common\American Truck Simulator Dedicated Server
echo GAME_DIR=C:\Program Files ^(x86^)\Steam\steamapps\common\American Truck Simulator
echo WORKSHOP_DIR=C:\Program Files ^(x86^)\Steam\steamapps\workshop\content\270880
echo.
echo # STEAMCMD SETTINGS
echo STEAMCMD_AUTO_INSTALL=true
echo STEAMCMD_AUTO_UPDATE=true
echo STEAMCMD_DOWNLOAD_RETRIES=3
echo.
echo # LOGGING
echo ENABLE_CONSOLE=true
echo DEBUG_MODE=false
echo LOG_LEVEL=INFO
echo AUTO_DIAGNOSTICS=true
echo.
echo # BACKUP SETTINGS
echo AUTO_BACKUP_CONFIG=true
echo BACKUP_RETENTION_DAYS=7
echo BACKUP_MODS=false
echo.
echo # STARTUP BEHAVIOR
echo AUTO_START_GAME_CLIENT=false
echo STARTUP_DELAY_SECONDS=10
echo SHOW_STARTUP_MESSAGES=true
echo PAUSE_ON_ERRORS=true
echo.
echo # SCRIPT INFO
echo SCRIPT_VERSION=1.0.0
echo CONFIG_VERSION=1.0.0
echo LAST_UPDATED=2025-07-23
) > "%ENV_FILE%"
goto :eof
