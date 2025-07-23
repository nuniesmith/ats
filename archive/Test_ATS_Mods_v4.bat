@echo off
setlocal EnableDelayedExpansion

:: Define directories
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "SERVER_ID=90271602251410447"
set "BASE_PORT=27015"

echo ===========================================
echo   ATS Server - Mod Testing Script v4
echo ===========================================
echo.

:MENU
echo 1. Setup Server Environment
echo 2. Start Server with Mods
echo 3. Stop All ATS Servers
echo 4. Exit
echo.
set /p CHOICE="Enter choice (1-4): "

if "%CHOICE%"=="1" goto SETUP_ENV
if "%CHOICE%"=="2" goto START_SERVER
if "%CHOICE%"=="3" goto STOP_SERVERS
if "%CHOICE%"=="4" goto END
goto MENU

:SETUP_ENV
echo.
echo Setting up server environment...

:: Stop any running servers
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2

:: Create mod directories in server root
echo Creating mod directories...
if exist "%SERVER_DIR%\mods" (
    rd /s /q "%SERVER_DIR%\mods"
)
mkdir "%SERVER_DIR%\mods"

:: Copy mods
echo.
echo Copying mods from Workshop...
copy "%WORKSHOP_DIR%\830663438\154_content.scs" "%SERVER_DIR%\mods\" >nul
copy "%WORKSHOP_DIR%\830663438\downgrade_info_package.scs" "%SERVER_DIR%\mods\" >nul
copy "%WORKSHOP_DIR%\830663438\sound.scs" "%SERVER_DIR%\mods\" >nul

echo.
echo Creating server config...
(
echo SiiNunit
echo {
echo server_config : .config {
echo  unit_settings: .mods {
echo     mods_enable: true
echo     mods_load: true
echo     mods_lock: false
echo     mods_optioning: true
echo     mods_dir: "mods"
echo  }
echo  lobby_name: "ATS Mod Test Server"
echo  description: "Testing Mods"
echo  welcome_message: "Mod Test Server"
echo  password: "test"
echo  max_players: 8
echo  connection_virtual_port: 100
echo  query_virtual_port: 101
echo  connection_dedicated_port: %BASE_PORT%
echo  query_dedicated_port: !BASE_PORT!1
echo  allow_modding: true
echo  force_loading_mods: true
echo  mods_optioning: true
echo  mod_folder: "mods"
echo  mods: .mods {
) > "%SERVER_DIR%\server_config.sii"

set /a MOD_COUNT=0
for %%f in ("%SERVER_DIR%\mods\*.scs") do (
    echo    active[!MOD_COUNT!]: "/mods/%%~nxf" >> "%SERVER_DIR%\server_config.sii"
    set /a MOD_COUNT+=1
)

(
echo  }
echo }
echo }
) >> "%SERVER_DIR%\server_config.sii"

echo Configuration created with %MOD_COUNT% mods:
dir /b "%SERVER_DIR%\mods"

:: Create local mod config
echo.
echo Creating mod config...
cd /d "%SERVER_DIR%\bin\win_x64"
(
echo SiiNunit
echo {
echo config_mod : _nameless {
echo   mod_dir: "../mods"
echo   mods_enable: true
echo   mods_load: true
echo   force_load_mods: true
echo   mods_optioning: true
echo }
echo }
) > mod_config.cfg

echo.
echo Environment setup complete.
pause
goto MENU

:START_SERVER
echo.
echo Starting ATS Server...
echo Mod directory contents:
dir /b "%SERVER_DIR%\mods"
echo.

cd /d "%SERVER_DIR%\bin\win_x64"

start "" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config.sii" ^
    -mod_config "mod_config.cfg" ^
    +g_console 1 ^
    +enable_mods 1 ^
    +force_load_mods 1 ^
    +mods_enable 1 ^
    +mods_optioning 1 ^
    +use_mod_folder 1 ^
    +use_mods_folder 1 ^
    +force_enable_all_mods 1

echo.
echo Server started. Check the server window for status.
timeout /t 5
goto MENU

:STOP_SERVERS
echo.
echo Stopping all ATS server instances...
taskkill /F /IM amtrucks_server.exe 2>nul
echo Done.
timeout /t 2
goto MENU

:END
echo.
echo Goodbye!
timeout /t 3
exit
