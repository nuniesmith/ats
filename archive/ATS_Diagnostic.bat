@echo off
setlocal EnableDelayedExpansion

:: ATS Server Configuration Diagnostic Tool
:: This script helps identify why mods_optioning isn't working

title ATS Server Diagnostic Tool

set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "SERVER_TOKEN=15AE684920A1694E27BFA8B64F75AD1B"
set "SERVER_ID=90271602251410447"

echo ===========================================
echo   ATS Server Configuration Diagnostic
echo ===========================================
echo.

echo 1. CHECKING SERVER INSTALLATION
echo ================================
if exist "%SERVER_DIR%" (
    echo ✓ Server directory exists
) else (
    echo ✗ Server directory NOT found!
    echo Expected: %SERVER_DIR%
    pause
    exit /b 1
)

if exist "%SERVER_DIR%\bin\win_x64\amtrucks_server.exe" (
    echo ✓ Server executable exists
) else (
    echo ✗ Server executable NOT found!
    pause
    exit /b 1
)

echo.
echo 2. CHECKING CURRENT CONFIGURATION
echo ==================================
if exist "%SERVER_DIR%\server_config.sii" (
    echo ✓ Server config exists
    echo.
    echo Current config content:
    type "%SERVER_DIR%\server_config.sii" | findstr /i "mods_optioning\|lobby_name\|password"
) else (
    echo ✗ Server config NOT found!
)

echo.
echo 3. CHECKING MOD DIRECTORY
echo ==========================
if exist "%SERVER_DIR%\mod" (
    echo ✓ Mod directory exists
    echo.
    echo Mods found:
    for %%f in ("%SERVER_DIR%\mod\*.scs") do (
        echo   - %%~nxf (%%~zf bytes)
    )
) else (
    echo ✗ Mod directory NOT found!
    mkdir "%SERVER_DIR%\mod"
    echo Created mod directory.
)

echo.
echo 4. CHECKING SERVER PACKAGES
echo ============================
if exist "%SERVER_DIR%\server_packages.sii" (
    echo ✓ Server packages exist
) else (
    echo ✗ Server packages NOT found!
    echo This is required for the server to start properly.
)

if exist "%SERVER_DIR%\server_packages.dat" (
    echo ✓ Server packages data exists
) else (
    echo ✗ Server packages data NOT found!
)

echo.
echo 5. CREATING TEST CONFIGURATION
echo ===============================

:: Create a minimal test config that should work
echo Creating minimal test configuration...
(
echo SiiNunit
echo {
echo server_config : .config {
echo  lobby_name: "Freddy Test Server"
echo  description: "Test configuration"
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
echo  mods_optioning: true
echo  timezones: 0
echo  service_no_collision: false
echo  in_menu_ghosting: false
echo  name_tags: true
echo  friends_only: false
echo  show_server: true
echo  moderator_list: 0
echo  mods: .mods {
) > "%SERVER_DIR%\server_config_test.sii"

:: Add a few mods if they exist
set /a MOD_COUNT=0
for %%f in ("%SERVER_DIR%\mod\*.scs") do (
    if !MOD_COUNT! LSS 3 (
        echo   active[!MOD_COUNT!]: "/mod/%%~nxf" >> "%SERVER_DIR%\server_config_test.sii"
        set /a MOD_COUNT+=1
    )
)

(
echo  }
echo }
echo }
) >> "%SERVER_DIR%\server_config_test.sii"

echo ✓ Test configuration created with !MOD_COUNT! mods

echo.
echo 6. TESTING DIFFERENT SERVER PARAMETERS
echo =======================================

cd /d "%SERVER_DIR%\bin\win_x64"

echo.
echo Test A: Minimal parameters
echo Starting: amtrucks_server.exe -server_id %SERVER_ID% -server_config ..\server_config_test.sii +mods_optioning 1 +g_console 1
echo.
start "ATS Diagnostic Test A" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config_test.sii" ^
    +mods_optioning 1 ^
    +g_console 1

echo Server started. Check the console output for "Mods optioning: True"
echo.
echo Press any key to stop this test and try the next one...
pause

taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2

echo.
echo Test B: Standard parameters
echo Starting: amtrucks_server.exe -server_id %SERVER_ID% -server_config ..\server_config_test.sii +enable_mods 1 +mods_optioning 1 +g_console 1
echo.
start "ATS Diagnostic Test B" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config_test.sii" ^
    +enable_mods 1 ^
    +mods_optioning 1 ^
    +g_console 1

echo Server started. Check the console output again.
echo.
echo Press any key to stop this test...
pause

taskkill /F /IM amtrucks_server.exe 2>nul

echo.
echo 7. DIAGNOSTIC COMPLETE
echo =======================
echo.
echo If both tests showed "Mods optioning: False", the issue might be:
echo 1. The ATS server version doesn't support this parameter
echo 2. The parameter syntax has changed
echo 3. There's a conflict with the server_config.sii format
echo.
echo If Test A showed "True" but Test B showed "False", then some
echo parameters are conflicting.
echo.
echo Check the server console windows for exact error messages.
echo.
pause
