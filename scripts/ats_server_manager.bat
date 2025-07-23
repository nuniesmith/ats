@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Server Manager - Unified Edition
:: Complete server management for Freddy's ATS Dedicated Server
:: ===========================================

title Freddy's ATS Server Manager

:: Define default directories and server settings
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%.."
set "ARCHIVE_DIR=%BASE_DIR%\archive"
set "DEFAULT_SERVER_ID=90271602251410447"
set "SERVER_TOKEN=15AE684920A1694E27BFA8B64F75AD1B"
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
echo   Freddy's ATS Server Manager v2.0
echo ===========================================
echo   Server: Freddy's ATS Dedicated Server
echo   Password: ruby
echo   Optional Mods: Enabled
echo   Collection: https://steamcommunity.com/sharedfiles/filedetails/?id=%COLLECTION_ID%
echo ===========================================
echo.
echo 1. Quick Start (Setup + Update + Start)
echo 2. Setup Server Environment
echo 3. Update Workshop Mods
echo 4. Start Server Only
echo 5. Start Server + Game Client
echo 6. Server Status ^& Diagnostics
echo 7. Stop All Servers
echo 8. Workshop Collection Manager
echo 9. Advanced Configuration
echo A. Archive Old Scripts ^& Cleanup
echo 0. Exit
echo.
set /p CHOICE="Select option: "

if /i "%CHOICE%"=="1" goto QUICK_START
if /i "%CHOICE%"=="2" goto SETUP_ENVIRONMENT
if /i "%CHOICE%"=="3" goto UPDATE_MODS
if /i "%CHOICE%"=="4" goto START_SERVER
if /i "%CHOICE%"=="5" goto START_BOTH
if /i "%CHOICE%"=="6" goto DIAGNOSTICS
if /i "%CHOICE%"=="7" goto STOP_SERVERS
if /i "%CHOICE%"=="8" goto WORKSHOP_MANAGER
if /i "%CHOICE%"=="9" goto ADVANCED_CONFIG
if /i "%CHOICE%"=="A" goto ARCHIVE_CLEANUP
if /i "%CHOICE%"=="0" goto END
goto MAIN_MENU

:QUICK_START
cls
echo ===========================================
echo   Quick Start - Complete Setup
echo ===========================================
echo.
echo This will automatically:
echo 1. Setup server environment
echo 2. Update workshop mods
echo 3. Start the server
echo.
echo Continue? (Y/N)
set /p CONFIRM=""
if /i not "%CONFIRM%"=="Y" goto MAIN_MENU

call :SETUP_ENVIRONMENT_SILENT
call :UPDATE_MODS_SILENT
call :START_SERVER_SILENT
goto MAIN_MENU

:SETUP_ENVIRONMENT
cls
echo ===========================================
echo   Setting Up Server Environment
echo ===========================================
echo.

:SETUP_ENVIRONMENT_SILENT
:: Stop any running servers
echo Stopping existing servers...
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2 >nul

:: Create necessary directories
echo Creating server directories...
if not exist "%SERVER_DIR%\mod" mkdir "%SERVER_DIR%\mod"

:: Check for server packages
if exist "%USERPROFILE%\Documents\American Truck Simulator\server_packages.sii" (
    echo Copying server packages from game directory...
    copy "%USERPROFILE%\Documents\American Truck Simulator\server_packages.sii" "%SERVER_DIR%\" /Y >nul
    copy "%USERPROFILE%\Documents\American Truck Simulator\server_packages.dat" "%SERVER_DIR%\" /Y >nul
    echo ✓ Server packages copied
) else (
    echo.
    echo ⚠️  WARNING: Server packages not found!
    echo Please start ATS, load your desired DLCs/map, open console (~), and run:
    echo export_server_packages
    echo Then run this setup again.
    echo.
    if not defined SILENT pause
)

:: Create optimized server configuration
call :CREATE_SERVER_CONFIG

echo.
echo ✓ Server environment setup complete!
if not defined SILENT pause
goto :eof

:UPDATE_MODS
cls
echo ===========================================
echo   Updating Workshop Mods
echo ===========================================
echo.

:UPDATE_MODS_SILENT
:: Clean existing mods
echo Cleaning existing mods...
if exist "%SERVER_DIR%\mod\*.*" del /q "%SERVER_DIR%\mod\*.*"

echo.
echo Copying mods from Workshop Collection...
echo (Collection ID: %COLLECTION_ID%)
echo.

:: Copy all workshop mods
set /a COPIED_COUNT=0
for /d %%d in ("%WORKSHOP_DIR%\*") do (
    for %%f in ("%%d\*.scs") do (
        echo Copying: %%~nxf
        copy "%%f" "%SERVER_DIR%\mod\" >nul 2>&1
        if !errorlevel! equ 0 (
            set /a COPIED_COUNT+=1
        )
    )
)

:: Update server configuration with current mods
call :CREATE_SERVER_CONFIG

echo.
echo ✓ Mod update complete! Installed !COPIED_COUNT! mods.
if not defined SILENT (
    echo.
    echo Current mods:
    dir /b "%SERVER_DIR%\mod\*.scs" 2>nul
    echo.
    pause
)
goto :eof

:START_SERVER
cls
echo ===========================================
echo   Starting Freddy's ATS Dedicated Server
echo ===========================================
echo.

:START_SERVER_SILENT
:: Stop any existing servers
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2 >nul

echo Server Details:
echo - Name: Freddy's ATS Dedicated Server
echo - Password: ruby
echo - Max Players: 8
echo - Optional Mods: Enabled
echo - Server ID: %SERVER_ID%
echo.

:: Check server files
if not exist "%SERVER_DIR%\server_config.sii" (
    echo ❌ ERROR: Server config not found! Run Setup Environment first.
    if not defined SILENT pause
    goto :eof
)

if not exist "%SERVER_DIR%\server_packages.sii" (
    echo ⚠️  WARNING: Server packages not found! Server may not start properly.
    if not defined SILENT pause
)

echo.
echo Installed mods:
for %%f in ("%SERVER_DIR%\mod\*.scs") do echo   - %%~nxf
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
echo ✓ Server started! Window title: "Freddy's ATS Server"
echo Check the server window for:
echo - "Mods optioning: True"
echo - "Modded session: Yes"
echo - Number of active mods
if not defined SILENT (
    timeout /t 5
)
goto :eof

:START_BOTH
call :START_SERVER_SILENT
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
echo ✓ Game client started and connecting to server!
timeout /t 5
goto MAIN_MENU

:DIAGNOSTICS
cls
echo ===========================================
echo   Server Status ^& Diagnostics
echo ===========================================
echo.

echo 1. SERVER STATUS
echo ================
tasklist /FI "IMAGENAME eq amtrucks_server.exe" 2>NUL | find /I /N "amtrucks_server.exe" >nul && (
    echo ✓ ATS Server is RUNNING
) || (
    echo ❌ ATS Server is NOT running
)

echo.
echo 2. FILE CHECKS
echo ==============
if exist "%SERVER_DIR%\server_config.sii" (
    echo ✓ Server config exists
) else (
    echo ❌ Server config missing
)

if exist "%SERVER_DIR%\server_packages.sii" (
    echo ✓ Server packages exist
) else (
    echo ❌ Server packages missing
)

if exist "%SERVER_DIR%\mod" (
    echo ✓ Mod directory exists
) else (
    echo ❌ Mod directory missing
)

echo.
echo 3. MOD STATUS
echo =============
set /a MOD_COUNT=0
for %%f in ("%SERVER_DIR%\mod\*.scs") do (
    set /a MOD_COUNT+=1
    echo ✓ %%~nxf
)
echo Total mods: !MOD_COUNT!

echo.
echo 4. CONFIGURATION CHECK
echo ======================
if exist "%SERVER_DIR%\server_config.sii" (
    findstr /i "mods_optioning" "%SERVER_DIR%\server_config.sii" >nul && (
        echo ✓ mods_optioning is configured
    ) || (
        echo ❌ mods_optioning not found in config
    )
    
    findstr /i "lobby_name.*Freddy" "%SERVER_DIR%\server_config.sii" >nul && (
        echo ✓ Server name is set to Freddy's
    ) || (
        echo ❌ Server name not configured
    )
    
    findstr /i "password.*ruby" "%SERVER_DIR%\server_config.sii" >nul && (
        echo ✓ Password is set to ruby
    ) || (
        echo ❌ Password not configured
    )
)

echo.
echo 5. WORKSHOP DIRECTORY CHECK
echo ===========================
if exist "%WORKSHOP_DIR%" (
    echo ✓ Workshop directory exists
    set /a WS_COUNT=0
    for /d %%d in ("%WORKSHOP_DIR%\*") do (
        set /a WS_COUNT+=1
    )
    echo Workshop items: !WS_COUNT!
) else (
    echo ❌ Workshop directory not found
)

echo.
echo 6. QUICK FIXES
echo ==============
echo F. Fix Server Configuration
echo T. Test Server Without Mods
echo V. View Current Config
echo R. Return to Main Menu
echo.
set /p DIAG_CHOICE="Select option: "

if /i "%DIAG_CHOICE%"=="F" call :FIX_CONFIG
if /i "%DIAG_CHOICE%"=="T" call :TEST_NO_MODS
if /i "%DIAG_CHOICE%"=="V" call :VIEW_CONFIG
if /i "%DIAG_CHOICE%"=="R" goto MAIN_MENU
goto DIAGNOSTICS

:FIX_CONFIG
echo.
echo Fixing server configuration...
call :CREATE_SERVER_CONFIG
echo ✓ Configuration recreated!
pause
goto :eof

:TEST_NO_MODS
echo.
echo Creating test config without mods...
call :CREATE_TEST_CONFIG
echo Starting test server...
cd /d "%SERVER_DIR%\bin\win_x64"
start "ATS Test Server" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config_test.sii" ^
    +g_console 1
echo Test server started. Check if it shows "Mods optioning: True"
pause
goto :eof

:VIEW_CONFIG
echo.
echo Current server configuration:
echo =============================
if exist "%SERVER_DIR%\server_config.sii" (
    type "%SERVER_DIR%\server_config.sii"
) else (
    echo Configuration file not found!
)
echo =============================
pause
goto :eof

:STOP_SERVERS
echo.
echo Stopping all ATS server instances...
taskkill /F /IM amtrucks_server.exe 2>nul
echo ✓ Done.
timeout /t 2
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
echo 3. Force Refresh Workshop Mods
echo 4. Back to Main Menu
echo.
set /p WS_CHOICE="Select option: "

if "%WS_CHOICE%"=="1" (
    start "" "steam://url/CommunityFilePage/%COLLECTION_ID%"
    goto WORKSHOP_MANAGER
)
if "%WS_CHOICE%"=="2" goto LIST_WORKSHOP_MODS
if "%WS_CHOICE%"=="3" goto UPDATE_MODS
if "%WS_CHOICE%"=="4" goto MAIN_MENU
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
echo 5. Create Backup of Current Config
echo 6. Back to Main Menu
echo.
set /p ADV_CHOICE="Select option: "

if "%ADV_CHOICE%"=="1" goto EDIT_CONFIG
if "%ADV_CHOICE%"=="2" goto CHANGE_TOKEN
if "%ADV_CHOICE%"=="3" goto CHANGE_SERVER_ID
if "%ADV_CHOICE%"=="4" goto RESET_CONFIG
if "%ADV_CHOICE%"=="5" goto BACKUP_CONFIG
if "%ADV_CHOICE%"=="6" goto MAIN_MENU
goto ADVANCED_CONFIG

:EDIT_CONFIG
if exist "%SERVER_DIR%\server_config.sii" (
    notepad "%SERVER_DIR%\server_config.sii"
) else (
    echo Server config not found!
    pause
)
goto ADVANCED_CONFIG

:CHANGE_TOKEN
echo.
echo Current token: %SERVER_TOKEN%
set /p NEW_TOKEN="Enter new server token: "
if not "%NEW_TOKEN%"=="" (
    set "SERVER_TOKEN=%NEW_TOKEN%"
    call :CREATE_SERVER_CONFIG
    echo Token updated and config recreated!
)
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
echo ✓ Configuration reset!
pause
goto ADVANCED_CONFIG

:BACKUP_CONFIG
echo.
if not exist "%SCRIPT_DIR%\backups" mkdir "%SCRIPT_DIR%\backups"
set "BACKUP_NAME=server_config_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.sii"
set "BACKUP_NAME=%BACKUP_NAME: =0%"
copy "%SERVER_DIR%\server_config.sii" "%SCRIPT_DIR%\backups\%BACKUP_NAME%" >nul
echo ✓ Configuration backed up to: backups\%BACKUP_NAME%
pause
goto ADVANCED_CONFIG

:ARCHIVE_CLEANUP
cls
echo ===========================================
echo   Archive Old Scripts ^& Cleanup
echo ===========================================
echo.

:: Create archive directory
if not exist "%ARCHIVE_DIR%" mkdir "%ARCHIVE_DIR%"

echo This will move the following old batch files to archive:
echo.
for %%f in ("%BASE_DIR%\*.bat") do (
    if /i not "%%~nxf"=="ats_server_manager.bat" (
        echo   - %%~nxf
    )
)
echo.
echo Continue? (Y/N)
set /p ARCHIVE_CONFIRM=""
if /i not "%ARCHIVE_CONFIRM%"=="Y" goto MAIN_MENU

echo.
echo Moving old scripts to archive...
for %%f in ("%BASE_DIR%\*.bat") do (
    if /i not "%%~nxf"=="ats_server_manager.bat" (
        echo Moving: %%~nxf
        move "%%f" "%ARCHIVE_DIR%\" >nul
    )
)

:: Also archive the old config if it exists
if exist "%BASE_DIR%\config" (
    echo Moving old config directory...
    if not exist "%ARCHIVE_DIR%\config" mkdir "%ARCHIVE_DIR%\config"
    xcopy "%BASE_DIR%\config\*.*" "%ARCHIVE_DIR%\config\" /Y /E >nul
    rd /s /q "%BASE_DIR%\config"
)

echo.
echo ✓ Cleanup complete! Old files moved to: archive\
echo ✓ Workspace is now clean with just the unified manager
pause
goto MAIN_MENU

:: ===== HELPER FUNCTIONS =====

:CREATE_SERVER_CONFIG
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

:: Add mod entries
set /a MOD_COUNT=0
for %%f in ("%SERVER_DIR%\mod\*.scs") do (
    echo   active[!MOD_COUNT!]: "/mod/%%~nxf" >> "%SERVER_DIR%\server_config.sii"
    set /a MOD_COUNT+=1
)

:: Close the config
(
echo  }
echo }
echo }
) >> "%SERVER_DIR%\server_config.sii"
goto :eof

:CREATE_TEST_CONFIG
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
goto :eof

:END
cls
echo.
echo ===========================================
echo   Thank you for using Freddy's ATS
echo   Server Manager v2.0!
echo ===========================================
echo.
echo Server: Freddy's ATS Dedicated Server
echo Password: ruby
echo Optional Mods: Enabled
echo.
echo Your workspace is now clean and organized!
echo.
echo Happy trucking! 🚛
timeout /t 5
exit
