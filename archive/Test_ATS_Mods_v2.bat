@echo off
setlocal EnableDelayedExpansion

:: Define directories
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "SERVER_ID=90271602251410447"

echo ===========================================
echo   ATS Server - Mod Testing Script v2
echo ===========================================
echo.

:MENU
echo 1. List Available Workshop Mods
echo 2. Setup Known Working Mods
echo 3. Start Server with Mods
echo 4. Exit
echo.
set /p CHOICE="Enter choice (1-4): "

if "%CHOICE%"=="1" goto LIST_MODS
if "%CHOICE%"=="2" goto SETUP_MODS
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

:SETUP_MODS
echo.
echo Setting up known working mods...
if exist "%SERVER_DIR%\mod" (
    del /q "%SERVER_DIR%\mod\*.*"
) else (
    mkdir "%SERVER_DIR%\mod"
)

:: Copy specific mods from Workshop ID 830663438
echo Copying mods from Workshop ID 830663438...
copy "%WORKSHOP_DIR%\830663438\154_content.scs" "%SERVER_DIR%\mod\" >nul
copy "%WORKSHOP_DIR%\830663438\downgrade_info_package.scs" "%SERVER_DIR%\mod\" >nul
copy "%WORKSHOP_DIR%\830663438\sound.scs" "%SERVER_DIR%\mod\" >nul

echo.
echo Creating server config...
(
echo SiiNunit
echo {
echo server_config : .config {
echo  unit_settings: .mods {
echo     mods_load: true
echo     mods_enable: true
echo     mods_lock: false
echo     mods_optioning: true
echo     mods_dir: "mod"
echo  }
echo  lobby_name: "ATS Mod Test Server"
echo  description: "Testing Known Working Mods"
echo  welcome_message: "Mod Test Server"
echo  password: "test"
echo  max_players: 8
echo  connection_virtual_port: 100
echo  query_virtual_port: 101
echo  connection_dedicated_port: 27015
echo  query_dedicated_port: 27016
echo  allow_modding: true
echo  force_loading_mods: true
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

echo Configuration created with %MOD_COUNT% mods:
dir /b "%SERVER_DIR%\mod"
pause
goto MENU

:START_SERVER
echo.
echo Starting ATS Server...
echo Server config location: %SERVER_DIR%\server_config.sii
echo Mod directory contents:
dir /b "%SERVER_DIR%\mod"
echo.

cd /d "%SERVER_DIR%\bin\win_x64"

:: Create a local mod config
echo SiiNunit > mod_config.cfg
echo { >> mod_config.cfg
echo config_mod : _nameless { >> mod_config.cfg
echo   mod_dir: "../mod" >> mod_config.cfg
echo   mod_folder: "../mod" >> mod_config.cfg
echo   mods_load: true >> mod_config.cfg
echo   mods_enable: true >> mod_config.cfg
echo   force_load_mods: true >> mod_config.cfg
echo } >> mod_config.cfg
echo } >> mod_config.cfg

start "" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config.sii" ^
    -mod_config "mod_config.cfg" ^
    +g_console 1 ^
    +enable_mods 1 ^
    +force_load_mods 1 ^
    +force_mods 1 ^
    +use_mod_folder 1 ^
    +mods_enable 1 ^
    +mods_optioning 1

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
