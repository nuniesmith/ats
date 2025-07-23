@echo off
setlocal EnableDelayedExpansion

:: Advanced ATS Server Configuration Fix
:: This tries multiple approaches to fix the mods_optioning issue

title ATS Advanced Server Fix

set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "SERVER_TOKEN=15AE684920A1694E27BFA8B64F75AD1B"
set "SERVER_ID=90271602251410447"

echo ===========================================
echo   ATS Advanced Server Configuration Fix
echo ===========================================
echo.

:: Stop any running servers
echo Stopping existing servers...
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 3

echo.
echo Current server directory contents:
dir /b "%SERVER_DIR%\*.sii" 2>nul
echo.
echo Current mod directory contents:
dir /b "%SERVER_DIR%\mod\*.scs" 2>nul
echo.

:: Create the most basic working config with explicit settings
echo Creating basic working server configuration...
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

:: Add mods with proper indexing
set /a MOD_COUNT=0
for %%f in ("%SERVER_DIR%\mod\*.scs") do (
    echo   active[!MOD_COUNT!]: "/mod/%%~nxf" >> "%SERVER_DIR%\server_config.sii"
    echo Adding mod !MOD_COUNT!: %%~nxf
    set /a MOD_COUNT+=1
)

:: Close the config
(
echo  }
echo }
echo }
) >> "%SERVER_DIR%\server_config.sii"

echo.
echo Created configuration with !MOD_COUNT! mods.
echo.

:: Try different startup parameter combinations
echo Testing different server startup approaches...
echo.
echo Test 1: Standard approach with all mod parameters
cd /d "%SERVER_DIR%\bin\win_x64"

start "ATS Test 1" "amtrucks_server.exe" ^
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
echo Test server started. Check the console output for:
echo - "Mods optioning: True"
echo - "Modded session: Yes" 
echo - "[mods] Active X mods"
echo.
echo If it still shows "Mods optioning: False", press any key to try Test 2...
pause

:: Test 2: Try with different parameter order
echo.
echo Stopping test 1...
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2

echo.
echo Test 2: Different parameter order and approach
start "ATS Test 2" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config.sii" ^
    +mods_optioning 1 ^
    +enable_mods 1 ^
    +mods_enable 1 ^
    +g_console 1 ^
    +force_load_mods 1 ^
    +use_mod_folder 1

echo.
echo Test 2 started. Check the output again...
echo Press any key to try Test 3...
pause

:: Test 3: Minimal approach
echo.
echo Stopping test 2...
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2

echo.
echo Test 3: Minimal parameters
start "ATS Test 3" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config.sii" ^
    +mods_optioning 1 ^
    +g_console 1

echo.
echo Test 3 started. This should at least show "Mods optioning: True"
echo.
echo If none of these work, the issue might be in the server_config.sii format
echo or the ATS server version might not support some parameters.
echo.
echo Press any key to see the final configuration file...
pause

echo.
echo Final server configuration:
echo ===========================
type "%SERVER_DIR%\server_config.sii"
echo ===========================
echo.

echo.
echo Troubleshooting complete! 
echo If the issue persists, try:
echo 1. Update ATS Dedicated Server via Steam
echo 2. Verify the server packages are properly exported
echo 3. Check if workshop mods are downloaded correctly
echo.
pause
