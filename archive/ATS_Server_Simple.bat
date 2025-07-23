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

:MENU
echo ===========================================
echo   ATS Server - Simple Version
echo ===========================================
echo.
echo 1. Start Server
echo 2. Update Mods
echo 3. Exit
echo.
set /p CHOICE="Enter choice (1-3): "

if "%CHOICE%"=="1" goto START_SERVER
if "%CHOICE%"=="2" goto UPDATE_MODS
if "%CHOICE%"=="3" goto END
goto MENU

:UPDATE_MODS
echo.
echo Updating mods...
echo Cleaning mod directory...
del /q "!SERVER_DIR!\mod\*.*"

echo Copying Workshop mods...
for /r "!WORKSHOP_DIR!" %%f in (*.scs) do (
    echo Copying %%~nxf...
    copy "%%f" "!SERVER_DIR!\mod"
)

echo.
echo Mods installed:
dir /b "!SERVER_DIR!\mod"
echo.
pause
goto MENU

:START_SERVER
echo.
echo Starting ATS Dedicated Server...
echo Server ID: !SERVER_ID!

cd /d "!SERVER_DIR!\bin\win_x64"

start "" "amtrucks_server.exe" ^
    -server_id !SERVER_ID! ^
    -server_config "..\server_config.sii" ^
    +g_console 1 ^
    +enable_mods 1 ^
    +force_load_mods 1 ^
    +use_mod_folder 1 ^
    +force_enable_all_mods 1

echo.
echo Server started. Check the server window for status.
timeout /t 5
goto MENU

:END
echo.
echo Goodbye!
timeout /t 3
exit
