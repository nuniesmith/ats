@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Quick Server Launcher
:: Simple, reliable ATS dedicated server starter
:: ===========================================

title ATS Quick Server

echo ===========================================
echo    ATS Quick Server Launcher
echo ===========================================
echo.

:: Load environment configuration if available
set "BASE_DIR=%~dp0.."
if exist "%BASE_DIR%\scripts\load_env.bat" (
    call "%BASE_DIR%\scripts\load_env.bat"
)

:: Set defaults if not loaded from environment
if not defined SERVER_DIR set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
if not defined SERVER_NAME set "SERVER_NAME=Freddy's ATS Dedicated Server"
if not defined SERVER_PASSWORD set "SERVER_PASSWORD=ruby"
if not defined MAX_PLAYERS set "MAX_PLAYERS=8"

echo Configuration:
echo - Server Directory: %SERVER_DIR%
echo - Server Name: %SERVER_NAME%
echo - Password: %SERVER_PASSWORD%
echo - Max Players: %MAX_PLAYERS%
echo.

:: Check if server is installed
if not exist "%SERVER_DIR%\bin\win_x64\amtrucks_server.exe" (
    echo ERROR: ATS Dedicated Server not found!
    echo.
    echo Expected location: %SERVER_DIR%
    echo.
    echo Please install ATS Dedicated Server:
    echo 1. Open Steam
    echo 2. Go to Library ^> Tools
    echo 3. Install "American Truck Simulator - Dedicated Server"
    echo.
    echo Or use the main launcher option 9 to install automatically.
    pause
    exit /b 1
)

echo ✓ ATS Dedicated Server found
echo.

:: Create server configuration
echo Creating server configuration...
(
echo SiiNunit
echo {
echo server_config : .config {
echo  lobby_name: "%SERVER_NAME%"
echo  description: "Enhanced ATS server with curated mods"
echo  welcome_message: "Welcome to %SERVER_NAME%! Enjoy the enhanced experience."
echo  password: "%SERVER_PASSWORD%"
echo  max_players: %MAX_PLAYERS%
echo  max_vehicles_total: 100
echo  max_ai_vehicles_player: 50
echo  max_ai_vehicles_player_spawn: 50
echo  connection_virtual_port: 100
echo  query_virtual_port: 101
echo  connection_dedicated_port: 27015
echo  query_dedicated_port: 27016
echo  server_logon_token: ""
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
echo }
echo }
) > "%SERVER_DIR%\server_config.sii"

if %ERRORLEVEL% equ 0 (
    echo ✓ Server configuration created
) else (
    echo ❌ Failed to create server configuration
    echo You may need to run as administrator
    pause
    exit /b 1
)

:: Start server
echo.
echo ===========================================
echo   Starting ATS Dedicated Server
echo ===========================================
echo.
echo Server: %SERVER_NAME%
echo Password: %SERVER_PASSWORD%
echo Max Players: %MAX_PLAYERS%
echo Ports: 27015 (connection), 27016 (query)
echo Mode: Anonymous (no Steam login required)
echo.
echo The server will start in this window.
echo Press Ctrl+C to stop the server.
echo.
echo Starting in 3 seconds...
timeout /t 3 >nul

cd /d "%SERVER_DIR%"
bin\win_x64\amtrucks_server.exe -server_cfg server_config.sii -homedir . -anonymous
