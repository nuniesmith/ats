@echo off
setlocal EnableDelayedExpansion

:: Define directories
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "SERVER_ID=90271602251410447"

echo ===========================================
echo   ATS Server - Mod Testing Script
echo ===========================================
echo.

:MENU
echo 1. List Available Workshop Mods
echo 2. Clean and Setup Test Mod
echo 3. Start Server with Test Mod
echo 4. Exit
echo.
set /p CHOICE="Enter choice (1-4): "

if "%CHOICE%"=="1" goto LIST_MODS
if "%CHOICE%"=="2" goto SETUP_TEST_MOD
if "%CHOICE%"=="3" goto START_SERVER
if "%CHOICE%"=="4" goto END
goto MENU

:LIST_MODS
echo.
echo Available Workshop Mods:
echo ----------------------
for /d %%d in ("%WORKSHOP_DIR%\*") do (
    echo Workshop ID: %%~nxd
    dir /b "%%d\*.scs" 2>nul
    echo.
)
pause
goto MENU

:SETUP_TEST_MOD
echo.
echo Cleaning mod directory...
if exist "%SERVER_DIR%\mod" (
    del /q "%SERVER_DIR%\mod\*.*"
) else (
    mkdir "%SERVER_DIR%\mod"
)

echo.
echo Choose a mod to test:
set /a COUNT=0
for /d %%d in ("%WORKSHOP_DIR%\*") do (
    set /a COUNT+=1
    set "MOD_DIR[!COUNT!]=%%d"
    echo !COUNT!^) Workshop ID: %%~nxd
    dir /b "%%d\*.scs" 2>nul
    echo.
)

set /p MOD_NUM="Enter the number of the mod to test (1-%COUNT%): "
if defined MOD_DIR[%MOD_NUM%] (
    for %%f in ("!MOD_DIR[%MOD_NUM%]!\*.scs") do (
        echo Copying %%~nxf...
        copy "%%f" "%SERVER_DIR%\mod" >nul
    )
)

echo.
echo Creating test server config...
(
echo SiiNunit
echo {
echo server_config : .config {
echo  unit_settings: .mods {
echo     mods_load: true
echo     mods_enable: true
echo     mods_lock: false
echo     mods_optioning: true
echo     mods_dir: "C:/Program Files (x86^)/Steam/steamapps/common/American Truck Simulator Dedicated Server/mod"
echo  }
echo  lobby_name: "ATS Mod Test Server"
echo  description: "Testing Single Mod"
echo  welcome_message: "Mod Test Server"
echo  password: "test"
echo  max_players: 8
echo  connection_virtual_port: 100
echo  query_virtual_port: 101
echo  connection_dedicated_port: 27015
echo  query_dedicated_port: 27016
echo  player_damage: true
echo  traffic: true
echo  mods_optioning: true
echo  mod_folder: "mod"
echo  mods: .mods {
) > "%SERVER_DIR%\server_config.sii"

set /a MOD_COUNT=0
for %%f in ("%SERVER_DIR%\mod\*.scs") do (
    echo    active[!MOD_COUNT!]: "/mod/%%~nxf" >> "%SERVER_DIR%\server_config.sii"
    set /a MOD_COUNT+=1
)

(
echo  }
echo }
echo }
) >> "%SERVER_DIR%\server_config.sii"

echo Test configuration created with %MOD_COUNT% mod(s).
pause
goto MENU

:START_SERVER
echo.
echo Starting ATS Server with test mod...
echo Server config location: %SERVER_DIR%\server_config.sii
echo Mod directory contents:
dir /b "%SERVER_DIR%\mod"
echo.

cd /d "%SERVER_DIR%\bin\win_x64"

start "" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config.sii" ^
    +g_console 1 ^
    +enable_mods 1 ^
    +force_load_mods 1 ^
    +use_mod_folder 1

echo.
echo Server started with test configuration.
echo Check the server window for mod loading status.
timeout /t 5
goto MENU

:END
echo.
echo Goodbye!
timeout /t 3
exit
