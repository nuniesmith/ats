@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Master Server Manager
:: Unified script for managing Freddy's ATS Dedicated Server
:: ===========================================

title Freddy's ATS Master Server Manager

:: Define default directories and server settings
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "CONFIG_DIR=%~dp0config"
set "DEFAULT_SERVER_ID=90271602251410447"
set "SERVER_TOKEN=15AE684920A1694E27BFA8B64F75AD1B"

:: Collection ID for the workshop collection (from the URL provided)
set "COLLECTION_ID=3530633316"

:: Allow for server ID override
if "%~1"=="" (
    set "SERVER_ID=!DEFAULT_SERVER_ID!"
) else (
    set "SERVER_ID=%~1"
)

:MAIN_MENU
cls
echo ===========================================
echo   Freddy's ATS Master Server Manager
echo ===========================================
echo   Server: Freddy's ATS Dedicated Server
echo   Password: ruby
echo   Optional Mods: Enabled
echo   Server Token: %SERVER_TOKEN%
echo ===========================================
echo.
echo 1. Setup Server Environment (First Time)
echo 2. Update Mods from Workshop Collection
echo 3. Start Server Only
echo 4. Start Server + Game Client
echo 5. Stop All ATS Servers
echo 6. View Server Status
echo 7. Workshop Collection Manager
echo 8. Advanced Configuration
echo 9. Troubleshoot Server Issues
echo 0. Exit
echo.
set /p CHOICE="Select option (0-9): "

if "%CHOICE%"=="1" goto SETUP_ENVIRONMENT
if "%CHOICE%"=="2" goto UPDATE_MODS
if "%CHOICE%"=="3" goto START_SERVER
if "%CHOICE%"=="4" goto START_BOTH
if "%CHOICE%"=="5" goto STOP_SERVERS
if "%CHOICE%"=="6" goto VIEW_STATUS
if "%CHOICE%"=="7" goto WORKSHOP_MANAGER
if "%CHOICE%"=="8" goto ADVANCED_CONFIG
if "%CHOICE%"=="9" goto TROUBLESHOOT
if "%CHOICE%"=="0" goto END
goto MAIN_MENU

:SETUP_ENVIRONMENT
cls
echo ===========================================
echo   Setting Up Server Environment
echo ===========================================
echo.

:: Stop any running servers
echo Stopping existing servers...
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2

:: Create necessary directories
echo Creating server directories...
if not exist "%SERVER_DIR%\mod" mkdir "%SERVER_DIR%\mod"
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

:: Create optimized server configuration
echo Creating server configuration for Freddy...
call :CREATE_SERVER_CONFIG

:: Copy server packages if they exist in game directory
if exist "%USERPROFILE%\Documents\American Truck Simulator\server_packages.sii" (
    echo Copying server packages from game directory...
    copy "%USERPROFILE%\Documents\American Truck Simulator\server_packages.sii" "%SERVER_DIR%\" /Y
    copy "%USERPROFILE%\Documents\American Truck Simulator\server_packages.dat" "%SERVER_DIR%\" /Y
) else (
    echo.
    echo WARNING: Server packages not found!
    echo Please start ATS, load your desired DLCs/map, open console (~), and run:
    echo export_server_packages
    echo Then run this setup again.
    echo.
    pause
)

echo.
echo Server environment setup complete!
echo Next step: Update mods from workshop collection
pause
goto MAIN_MENU

:UPDATE_MODS
cls
echo ===========================================
echo   Updating Mods from Workshop Collection
echo ===========================================
echo   Collection ID: %COLLECTION_ID%
echo ===========================================
echo.

:: Clean existing mods
echo Cleaning existing mods...
if exist "%SERVER_DIR%\mod\*.*" del /q "%SERVER_DIR%\mod\*.*"

echo.
echo Copying mods from Workshop Collection...
echo (This includes the curated sound and enhancement mods)
echo.

:: Copy specific mods from the collection workshop IDs
:: These are the main mods from your collection
set MOD_SOURCES[0]="%WORKSHOP_DIR%\830663438"
set MOD_SOURCES[1]="%WORKSHOP_DIR%\2516863653"
set MOD_SOURCES[2]="%WORKSHOP_DIR%\2555618611"
set MOD_SOURCES[3]="%WORKSHOP_DIR%\2476073994"
set MOD_SOURCES[4]="%WORKSHOP_DIR%\1979736425"

for /L %%i in (0,1,4) do (
    if defined MOD_SOURCES[%%i] (
        if exist !MOD_SOURCES[%%i]! (
            echo Copying mods from workshop folder %%i...
            for %%f in ("!MOD_SOURCES[%%i]!\*.scs") do (
                echo   - %%~nxf
                copy "%%f" "%SERVER_DIR%\mod\" >nul
            )
        )
    )
)

:: Also copy any other workshop mods
echo.
echo Scanning for additional workshop mods...
for /d %%d in ("%WORKSHOP_DIR%\*") do (
    for %%f in ("%%d\*.scs") do (
        if not exist "%SERVER_DIR%\mod\%%~nxf" (
            echo   + Adding: %%~nxf
            copy "%%f" "%SERVER_DIR%\mod\" >nul
        )
    )
)

:: Update server configuration with current mods
call :UPDATE_SERVER_CONFIG_MODS

echo.
echo Mod update complete! Installed mods:
dir /b "%SERVER_DIR%\mod\*.scs"
echo.
pause
goto MAIN_MENU

:START_SERVER
cls
echo ===========================================
echo   Starting Freddy's ATS Dedicated Server
echo ===========================================
echo.

:: Stop any existing servers
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2

echo Server Details:
echo - Name: Freddy's ATS Dedicated Server
echo - Password: ruby
echo - Max Players: 8
echo - Optional Mods: Enabled
echo - Server ID: %SERVER_ID%
echo - Token: %SERVER_TOKEN%
echo.

echo Checking server files...
if not exist "%SERVER_DIR%\server_config.sii" (
    echo ERROR: Server config not found! Run Setup Environment first.
    pause
    goto MAIN_MENU
)

if not exist "%SERVER_DIR%\server_packages.sii" (
    echo WARNING: Server packages not found! Server may not start properly.
    echo Run Setup Environment and export server packages from the game first.
    pause
)

echo.
echo Installed mods:
dir /b "%SERVER_DIR%\mod\*.scs" 2>nul
echo.

cd /d "%SERVER_DIR%\bin\win_x64"

echo Starting server...
start "Freddy's ATS Server" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config.sii" ^
    +mods_optioning 1 ^
    +enable_mods 1 ^
    +g_console 1 ^
    +force_load_mods 1 ^
    +use_mod_folder 1

echo.
echo Server started! Window title: "Freddy's ATS Server"
echo Check the server window for detailed status information.
timeout /t 5
goto MAIN_MENU

:START_BOTH
call :START_SERVER
timeout /t 10

cls
echo ===========================================
echo   Starting ATS Game Client
echo ===========================================
echo.

echo Connecting to Freddy's server...
echo Server ID: %SERVER_ID%
echo Password: ruby
echo.

cd /d "%GAME_DIR%"

start "ATS Client" "amtrucks.exe" ^
    +online_server_id %SERVER_ID% ^
    +server_join_password ruby ^
    +g_online_server_name "Freddy's ATS Dedicated Server" ^
    +mods_optioning 1 ^
    +enable_mods 1

echo.
echo Game client started and connecting to server!
timeout /t 5
goto MAIN_MENU

:STOP_SERVERS
echo.
echo Stopping all ATS server instances...
taskkill /F /IM amtrucks_server.exe 2>nul
echo Done.
timeout /t 2
goto MAIN_MENU

:VIEW_STATUS
cls
echo ===========================================
echo   Server Status
echo ===========================================
echo.

echo Checking for running ATS servers...
tasklist /FI "IMAGENAME eq amtrucks_server.exe" 2>NUL | find /I /N "amtrucks_server.exe" && (
    echo ✓ ATS Server is RUNNING
) || (
    echo ✗ ATS Server is NOT running
)

echo.
echo Server Configuration:
if exist "%SERVER_DIR%\server_config.sii" (
    echo ✓ Server config exists
) else (
    echo ✗ Server config missing
)

echo.
echo Server Packages:
if exist "%SERVER_DIR%\server_packages.sii" (
    echo ✓ Server packages exist
) else (
    echo ✗ Server packages missing
)

echo.
echo Installed Mods:
if exist "%SERVER_DIR%\mod\*.scs" (
    dir /b "%SERVER_DIR%\mod\*.scs" 2>nul
) else (
    echo No mods installed
)

echo.
pause
goto MAIN_MENU

:WORKSHOP_MANAGER
cls
echo ===========================================
echo   Workshop Collection Manager
echo ===========================================
echo.
echo Collection URL: https://steamcommunity.com/sharedfiles/filedetails/?id=%COLLECTION_ID%
echo.
echo 1. Open Collection in Steam
echo 2. List Available Workshop Mods
echo 3. Back to Main Menu
echo.
set /p WS_CHOICE="Select option (1-3): "

if "%WS_CHOICE%"=="1" (
    start "" "steam://url/CommunityFilePage/%COLLECTION_ID%"
    goto WORKSHOP_MANAGER
)
if "%WS_CHOICE%"=="2" goto LIST_WORKSHOP_MODS
if "%WS_CHOICE%"=="3" goto MAIN_MENU
goto WORKSHOP_MANAGER

:LIST_WORKSHOP_MODS
echo.
echo Available Workshop Mods:
echo ========================
for /d %%d in ("%WORKSHOP_DIR%\*") do (
    echo Workshop ID: %%~nxd
    for %%f in ("%%d\*.scs") do (
        echo   - %%~nxf
    )
    echo.
)
pause
goto WORKSHOP_MANAGER

:ADVANCED_CONFIG
cls
echo ===========================================
echo   Advanced Configuration
echo ===========================================
echo.
echo 1. Edit Server Config Manually
echo 2. Change Server Token
echo 3. Change Server ID
echo 4. Reset to Defaults
echo 5. Back to Main Menu
echo.
set /p ADV_CHOICE="Select option (1-5): "

if "%ADV_CHOICE%"=="1" (
    if exist "%SERVER_DIR%\server_config.sii" (
        notepad "%SERVER_DIR%\server_config.sii"
    ) else (
        echo Server config not found!
        pause
    )
    goto ADVANCED_CONFIG
)
if "%ADV_CHOICE%"=="2" goto CHANGE_TOKEN
if "%ADV_CHOICE%"=="3" goto CHANGE_SERVER_ID
if "%ADV_CHOICE%"=="4" goto RESET_CONFIG
if "%ADV_CHOICE%"=="5" goto MAIN_MENU
goto ADVANCED_CONFIG

:CHANGE_TOKEN
echo.
echo Current token: %SERVER_TOKEN%
set /p NEW_TOKEN="Enter new server token: "
if not "%NEW_TOKEN%"=="" set "SERVER_TOKEN=%NEW_TOKEN%"
echo Token updated!
pause
goto ADVANCED_CONFIG

:CHANGE_SERVER_ID
echo.
echo Current Server ID: %SERVER_ID%
set /p NEW_ID="Enter new server ID: "
if not "%NEW_ID%"=="" set "SERVER_ID=%NEW_ID%"
echo Server ID updated!
pause
goto ADVANCED_CONFIG

:RESET_CONFIG
echo.
echo Resetting to default configuration...
call :CREATE_SERVER_CONFIG
echo Configuration reset!
pause
goto ADVANCED_CONFIG

:: ===== FUNCTIONS =====

:CREATE_SERVER_CONFIG
echo Creating server configuration...

:: First create the base config
(
echo SiiNunit
echo {
echo server_config : .config {
echo  lobby_name: "Freddy's ATS Dedicated Server"
echo  description: "Enhanced ATS server with curated sound and graphics mods"
echo  welcome_message: "Welcome to Freddy's server! Enjoy the enhanced experience with optional mods enabled."
echo  password: "ruby"
echo  max_players: 8
echo  max_vehicles_total: 100
echo  max_ai_vehicles_player: 50
echo  max_ai_vehicles_player_spawn: 50
echo  connection_virtual_port: 100
echo  query_virtual_port: 101
echo  connection_dedicated_port: 27015
echo  query_dedicated_port: 27016
echo  server_logon_token: "%SERVER_TOKEN%"
echo  player_damage: true
echo  traffic: true
echo  hide_in_company: false
echo  hide_colliding: true
echo  force_speed_limiter: false
echo  mods_optioning: true
echo  timezones: 0
echo  service_no_collision: false
echo  in_menu_ghosting: false
echo  name_tags: true
echo  friends_only: false
echo  show_server: true
echo  moderator_list: 0
echo  mods: .mods {
) > "%SERVER_DIR%\server_config.sii"

:: Add mod entries if any exist
if exist "%SERVER_DIR%\mod\*.scs" (
    set /a MOD_COUNT=0
    for %%f in ("%SERVER_DIR%\mod\*.scs") do (
        echo   active[!MOD_COUNT!]: "/mod/%%~nxf" >> "%SERVER_DIR%\server_config.sii"
        set /a MOD_COUNT+=1
    )
    echo Added !MOD_COUNT! mods to configuration.
) else (
    echo No mods found - creating empty mods section.
)

:: Close the mods section and config
(
echo  }
echo }
echo }
) >> "%SERVER_DIR%\server_config.sii"

:: Also copy to local config directory for backup
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
copy "%SERVER_DIR%\server_config.sii" "%CONFIG_DIR%\server_config.sii" /Y >nul

echo Server configuration created successfully.
goto :eof

:UPDATE_SERVER_CONFIG_MODS
echo Updating server configuration with current mods...

:: Recreate the entire config to avoid formatting issues
call :CREATE_SERVER_CONFIG

echo Server configuration updated with mods!
goto :eof

:TROUBLESHOOT
cls
echo ===========================================
echo   Server Troubleshooting
echo ===========================================
echo.
echo 1. Fix Server Config File
echo 2. Recreate Server Environment
echo 3. Test Server Without Mods
echo 4. Check Mod File Integrity
echo 5. View Server Config Content
echo 6. Copy Config to Server Directory
echo 7. Back to Main Menu
echo.
set /p TROUBLE_CHOICE="Select option (1-7): "

if "%TROUBLE_CHOICE%"=="1" goto FIX_CONFIG
if "%TROUBLE_CHOICE%"=="2" goto RECREATE_ENV
if "%TROUBLE_CHOICE%"=="3" goto TEST_NO_MODS
if "%TROUBLE_CHOICE%"=="4" goto CHECK_MODS
if "%TROUBLE_CHOICE%"=="5" goto VIEW_CONFIG
if "%TROUBLE_CHOICE%"=="6" goto COPY_CONFIG
if "%TROUBLE_CHOICE%"=="7" goto MAIN_MENU
goto TROUBLESHOOT

:FIX_CONFIG
echo.
echo Fixing server configuration file...
call :CREATE_SERVER_CONFIG
echo Configuration file recreated!
echo.
echo Current mods in server directory:
dir /b "%SERVER_DIR%\mod\*.scs" 2>nul
pause
goto TROUBLESHOOT

:RECREATE_ENV
echo.
echo Recreating entire server environment...
call :SETUP_ENVIRONMENT
goto TROUBLESHOOT

:TEST_NO_MODS
echo.
echo Creating test config without mods...
(
echo SiiNunit
echo {
echo server_config : .config {
echo  lobby_name: "Freddy's ATS Test Server"
echo  description: "Test server without mods"
echo  welcome_message: "Test server"
echo  password: "ruby"
echo  max_players: 8
echo  max_vehicles_total: 100
echo  max_ai_vehicles_player: 50
echo  max_ai_vehicles_player_spawn: 50
echo  connection_virtual_port: 100
echo  query_virtual_port: 101
echo  connection_dedicated_port: 27015
echo  query_dedicated_port: 27016
echo  server_logon_token: "%SERVER_TOKEN%"
echo  player_damage: true
echo  traffic: true
echo  hide_in_company: false
echo  hide_colliding: true
echo  force_speed_limiter: false
echo  mods_optioning: false
echo  timezones: 0
echo  service_no_collision: false
echo  in_menu_ghosting: false
echo  name_tags: true
echo  friends_only: false
echo  show_server: true
echo  moderator_list: 0
echo  mods: .mods {
echo  }
echo }
echo }
) > "%SERVER_DIR%\server_config_test.sii"

echo Test config created. Starting server without mods...
cd /d "%SERVER_DIR%\bin\win_x64"
start "ATS Test Server" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config_test.sii" ^
    +g_console 1

echo Test server started. Check if it runs without mods.
pause
goto TROUBLESHOOT

:CHECK_MODS
echo.
echo Checking mod file integrity...
echo.
echo Server mod directory: %SERVER_DIR%\mod
if exist "%SERVER_DIR%\mod\*.scs" (
    for %%f in ("%SERVER_DIR%\mod\*.scs") do (
        echo Checking: %%~nxf
        if %%~zf LSS 1000 (
            echo   WARNING: File is very small ^(%%~zf bytes^) - possibly corrupted
        ) else (
            echo   OK: %%~zf bytes
        )
    )
) else (
    echo No mod files found in server directory!
)
echo.
pause
goto TROUBLESHOOT

:VIEW_CONFIG
echo.
echo Current server configuration:
echo =============================
if exist "%SERVER_DIR%\server_config.sii" (
    type "%SERVER_DIR%\server_config.sii"
) else (
    echo Configuration file not found!
)
echo.
pause
goto TROUBLESHOOT

:COPY_CONFIG
echo.
echo Copying configuration from local config to server directory...
if exist "%CONFIG_DIR%\server_config.sii" (
    copy "%CONFIG_DIR%\server_config.sii" "%SERVER_DIR%\" /Y
    echo Configuration copied!
) else (
    echo Local config file not found!
    call :CREATE_SERVER_CONFIG
    echo New configuration created!
)
pause
goto TROUBLESHOOT

:END
cls
echo.
echo Thank you for using Freddy's ATS Master Server Manager!
echo.
echo Server: Freddy's ATS Dedicated Server
echo Password: ruby
echo Optional Mods: Enabled
echo.
echo Have fun trucking!
timeout /t 3
exit
