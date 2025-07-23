@echo off
setlocal EnableDelayedExpansion

:: Quick Fix for ATS Server Configuration Issues
:: This script addresses the "Mods optioning: False" problem

title ATS Server Quick Fix

set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "SERVER_TOKEN=15AE684920A1694E27BFA8B64F75AD1B"
set "SERVER_ID=90271602251410447"

echo ===========================================
echo   ATS Server Quick Fix
echo ===========================================
echo.
echo This script will fix the server configuration
echo to ensure mods are properly loaded and
echo optional mods are enabled.
echo.

:: Stop any running servers
echo Stopping existing servers...
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2

:: Create proper server config
echo Creating fixed server configuration...
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
) > "%SERVER_DIR%\server_config.sii"

:: Add mods if they exist
if exist "%SERVER_DIR%\mod\*.scs" (
    echo  mods: .mods { >> "%SERVER_DIR%\server_config.sii"
    set /a MOD_COUNT=0
    for %%f in ("%SERVER_DIR%\mod\*.scs") do (
        echo   active[!MOD_COUNT!]: "/mod/%%~nxf" >> "%SERVER_DIR%\server_config.sii"
        set /a MOD_COUNT+=1
    )
    echo  } >> "%SERVER_DIR%\server_config.sii"
    echo Added !MOD_COUNT! mods to configuration.
) else (
    echo  mods: .mods { >> "%SERVER_DIR%\server_config.sii"
    echo  } >> "%SERVER_DIR%\server_config.sii"
    echo No mods found - created empty mods section.
)

:: Close config file
(
echo }
echo }
) >> "%SERVER_DIR%\server_config.sii"

echo.
echo Configuration fixed! Current mods in directory:
dir /b "%SERVER_DIR%\mod\*.scs" 2>nul
echo.

echo Do you want to start the server now? (Y/N)
set /p START_NOW=""

if /i "%START_NOW%"=="Y" (
    echo.
    echo Starting server with fixed configuration...
    cd /d "%SERVER_DIR%\bin\win_x64"
    
    start "Freddy's ATS Server - Fixed" "amtrucks_server.exe" ^
        -server_id %SERVER_ID% ^
        -server_config "..\server_config.sii" ^
        +g_console 1 ^
        +enable_mods 1 ^
        +force_load_mods 1 ^
        +mods_enable 1 ^
        +mods_optioning 1 ^
        +force_enable_all_mods 1 ^
        +use_mod_folder 1 ^
        +mods_settings_server 1 ^
        +mods_optional_server 1
    
    echo.
    echo Server started! Check the server window to verify:
    echo - "Mods optioning: True" should appear
    echo - "Modded session: Yes" should appear if mods are loaded
    echo.
)

echo Fix complete! Press any key to exit...
pause >nul
