@echo off
setlocal EnableDelayedExpansion

:: Define default directories and server ID
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "DEFAULT_SERVER_ID=90271602251410447"

:: Allow for server ID override
if "%~1"=="" (
    set "SERVER_ID=!DEFAULT_SERVER_ID!"
) else (
    set "SERVER_ID=%~1"
)

echo ===========================================
echo   ATS Dedicated Server Management Script
echo ===========================================
echo.

:MENU
echo Choose an option:
echo 1. Update Mods and Start Server
echo 2. Start Server Only
echo 3. Update Mods Only
echo 4. Start ATS Game and Connect to Server
echo 5. Start Both Server and Game
echo 6. Exit
echo.
set /p CHOICE="Enter your choice (1-6): "

if "%CHOICE%"=="1" goto UPDATE_AND_START
if "%CHOICE%"=="2" goto START_SERVER
if "%CHOICE%"=="3" goto UPDATE_MODS
if "%CHOICE%"=="4" goto START_GAME
if "%CHOICE%"=="5" goto START_BOTH
if "%CHOICE%"=="6" goto END
goto MENU

:UPDATE_MODS
echo.
echo Updating ATS Server Mods...
echo Cleaning server mod directory...
del /q "!SERVER_DIR!\mod\*.*"

echo.
echo Copying mods from Workshop...
for /r "!WORKSHOP_DIR!" %%f in (*.scs) do (
    echo Copying %%~nxf...
    copy "%%f" "!SERVER_DIR!\mod"
)

echo.
echo Mods updated. The following mods are now installed:
dir /b "!SERVER_DIR!\mod"
echo.

if "%CHOICE%"=="3" goto MENU
goto START_SERVER

:START_SERVER
echo.
echo Starting ATS Dedicated Server...
echo Server Name: Freddy's ATS Dedicated Server
echo Password: ruby
echo Mods: Enabled
echo Server ID: !SERVER_ID!
echo.

echo Current directory: !SERVER_DIR!
echo.

echo Server config exists:
if exist "!SERVER_DIR!\server_config.sii" (echo Yes) else (echo No)
echo.

echo Mod directory exists:
if exist "!SERVER_DIR!\mod" (echo Yes) else (echo No)
echo.

echo Mods in directory:
dir /b "!SERVER_DIR!\mod\*.scs" 2>nul
echo.

cd /d "!SERVER_DIR!\bin\win_x64"

start "" "amtrucks_server.exe" ^
    -server_id !SERVER_ID! ^
    -server_config "..\server_config.sii" ^
    -mod_config "mod_config.cfg" ^
    +g_console 1 ^
    +enable_mods 1 ^
    +force_mods 1 ^
    +mods_settings_server 1 ^
    +mods_optional_server 1 ^
    +g_console_mods_optioning 1 ^
    +g_mods_optioning_server 1 ^
    +optional_mods 1 ^
    +mods_optioning 1 ^
    +force_enable_all_mods 1

echo.
echo Server has been started with ID: !SERVER_ID!
timeout /t 5
if "%CHOICE%"=="5" goto START_GAME
goto MENU

:START_GAME
echo.
echo Starting American Truck Simulator...
echo Connecting to Server ID: !SERVER_ID!
echo.

cd /d "!GAME_DIR!"

start "" "amtrucks.exe" ^
    -normal-cpu ^
    +online_server_id !SERVER_ID! ^
    +server_join_password ruby ^
    +g_online_server_name "Freddy's ATS Dedicated Server" ^
    +g_console_mods_optioning 1 ^
    +g_mods_optioning_server 1 ^
    +optional_mods 1 ^
    +mods_optioning 1

echo Game has been started and will connect to the server.
timeout /t 5
goto MENU

:START_BOTH
echo Starting both server and game...
goto START_SERVER

:UPDATE_AND_START
goto UPDATE_MODS

:END
echo.
echo Goodbye!
timeout /t 3
exit
