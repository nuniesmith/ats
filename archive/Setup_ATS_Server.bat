@echo off
setlocal EnableDelayedExpansion

:: Define directories
set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "GAME_HOME=C:\Users\Jordan\Documents\American Truck Simulator"
set "SERVER_ID=90271602251410447"

echo ===========================================
echo   ATS Server Complete Setup Script
echo ===========================================
echo.

:MENU
echo 1. Enable Game Console
echo 2. Export Server Packages
echo 3. Setup Server Environment
echo 4. Start Server
echo 5. Stop Servers
echo 6. Exit
echo.
set /p CHOICE="Enter choice (1-6): "

if "%CHOICE%"=="1" goto ENABLE_CONSOLE
if "%CHOICE%"=="2" goto EXPORT_PACKAGES
if "%CHOICE%"=="3" goto SETUP_SERVER
if "%CHOICE%"=="4" goto START_SERVER
if "%CHOICE%"=="5" goto STOP_SERVERS
if "%CHOICE%"=="6" goto END
goto MENU

:ENABLE_CONSOLE
echo.
echo Enabling console in config.cfg...
echo uset g_console "1" > "%GAME_HOME%\config.cfg"
echo Console enabled. Start the game and press ~ to open console.
echo Then use the command: export_server_packages
pause
goto MENU

:EXPORT_PACKAGES
echo.
echo Please make sure you have:
echo 1. Started the game
echo 2. Loaded all mods you want to use
echo 3. Opened console with ~
echo 4. Typed: export_server_packages
echo.
echo Once done, press any key to copy the files...
pause

if exist "%GAME_HOME%\server_packages.sii" (
    copy "%GAME_HOME%\server_packages.sii" "%SERVER_DIR%\" /Y
    echo Copied server_packages.sii
) else (
    echo server_packages.sii not found! Please export it first.
)

if exist "%GAME_HOME%\server_packages.dat" (
    copy "%GAME_HOME%\server_packages.dat" "%SERVER_DIR%\" /Y
    echo Copied server_packages.dat
) else (
    echo server_packages.dat not found! Please export it first.
)
pause
goto MENU

:SETUP_SERVER
echo.
echo Setting up server environment...

:: Stop any running servers
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2

:: Create mod directories
echo Creating mod directories...
if exist "%SERVER_DIR%\mod" (
    rd /s /q "%SERVER_DIR%\mod"
)
mkdir "%SERVER_DIR%\mod"

:: Create server config
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
echo     mods_dir: "mod"
echo  }
echo  lobby_name: "Freddy's ATS Dedicated Server"
echo  description: "Testing Mods"
echo  welcome_message: "Welcome to Freddy's server!"
echo  password: "ruby"
echo  max_players: 8
echo  connection_virtual_port: 100
echo  query_virtual_port: 101
echo  connection_dedicated_port: 27015
echo  query_dedicated_port: 27016
echo  allow_modding: true
echo  force_loading_mods: true
echo  mods_optioning: true
echo  mod_folder: "mod"
echo  force_speed_limiter: false
echo  timezones: 0
echo  service_no_collision: false
echo  name_tags: true
echo  friends_only: false
echo  show_server: true
echo  mods: .mods {
echo    active[0]: "/mod/154_content.scs"
echo    active[1]: "/mod/downgrade_info_package.scs"
echo    active[2]: "/mod/sound.scs"
echo  }
echo }
echo }
) > "%SERVER_DIR%\server_config.sii"

:: Copy mods
echo.
echo Copying mods...
copy "%GAME_DIR%\mod\*.scs" "%SERVER_DIR%\mod\" >nul

echo.
echo Server environment setup complete.
dir /b "%SERVER_DIR%\mod"
pause
goto MENU

:START_SERVER
echo.
echo Starting ATS Server...
cd /d "%SERVER_DIR%\bin\win_x64"

start "" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config.sii" ^
    +g_console 1 ^
    +enable_mods 1 ^
    +force_load_mods 1 ^
    +mods_enable 1 ^
    +mods_optioning 1

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
