@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: Simple ATS Dedicated Server Starter
:: Starts American Truck Simulator Dedicated Server
:: ===========================================

title Starting ATS Dedicated Server

echo ===========================================
echo    ATS Dedicated Server Starter
echo ===========================================
echo.

:: Configuration
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "BASE_DIR=%~dp0.."
set "SERVER_EXE_PATH=!SERVER_DIR!\bin\win_x64\amtrucks_server.exe"
set "SERVER_ID=90271602251410447"
set "ATS_DOCUMENTS_DIR=%USERPROFILE%\Documents\American Truck Simulator"
set "COLLECTION_ID=3530633316"

:: Load environment if available
if exist "%BASE_DIR%\scripts\load_env.bat" (
    echo Loading environment configuration...
    call "%BASE_DIR%\scripts\load_env.bat"
    if defined SERVER_DIR (
        echo Using environment SERVER_DIR: !SERVER_DIR!
        set "SERVER_EXE_PATH=!SERVER_DIR!\bin\win_x64\amtrucks_server.exe"
    )
)

echo Checking server installation...

:: Check if server directory exists
if not exist "!SERVER_DIR!" (
    echo ERROR: ATS Dedicated Server not found at:
    echo    !SERVER_DIR!
    echo.
    echo Please install ATS Dedicated Server through Steam ^(Library ^> Tools^)
    pause
    exit /b 1
)

:: Check if server executable exists
if not exist "!SERVER_EXE_PATH!" (
    echo ERROR: Server executable not found at:
    echo    !SERVER_EXE_PATH!
    echo.
    echo Please verify ATS Dedicated Server is properly installed
    echo Expected location: !SERVER_EXE_PATH!
    echo.
    echo Common fixes:
    echo 1. Install ATS Dedicated Server from Steam Library ^> Tools
    echo 2. Check if Steam is installed in a different location
    echo 3. Verify the server files are not corrupted
    pause
    exit /b 1
)

)

echo Found ATS Dedicated Server installation
echo Found server executable
echo.

:: Create necessary directories
if not exist "!ATS_DOCUMENTS_DIR!" (
    echo Creating ATS Documents directory...
    mkdir "!ATS_DOCUMENTS_DIR!" 2>nul
)

:: Generate server configuration dynamically

:: Create the server config file in the server directory
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
) > "!SERVER_DIR!\server_config.sii"

if %errorlevel% equ 0 (
    echo ✓ Server configuration generated in server directory
) else (
    echo ❌ ERROR: Could not generate server config file
    echo    You may need to run as administrator
    pause
    exit /b 1
)

:: ALSO create the config in Documents folder since server seems to look there
copy "!SERVER_DIR!\server_config.sii" "!ATS_DOCUMENTS_DIR!\server_config.sii" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Server configuration also copied to Documents folder
)

:: Copy server packages files if they exist
if exist "!ATS_DOCUMENTS_DIR!\server_packages.sii" (
    echo Copying server packages from ATS Documents...
    copy "!ATS_DOCUMENTS_DIR!\server_packages.sii" "!SERVER_DIR!\" >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✓ Server packages SII copied from Documents
    ) else (
        echo WARNING: Could not copy server_packages.sii
    )
) else (
    echo WARNING: server_packages.sii not found in !ATS_DOCUMENTS_DIR!
    echo Please run ATS game and use console command: export_server_packages
)

if exist "!ATS_DOCUMENTS_DIR!\server_packages.dat" (
    copy "!ATS_DOCUMENTS_DIR!\server_packages.dat" "!SERVER_DIR!\" >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✓ Server packages DAT copied from Documents
    ) else (
        echo WARNING: Could not copy server_packages.dat
    )
)

:: Verify the config file was created and show some key settings
if exist "!SERVER_DIR!\server_config.sii" (
    echo.
    echo Verifying server configuration:
    findstr /i "lobby_name password max_players mods_optioning" "!SERVER_DIR!\server_config.sii"
    echo.
) else (
    echo WARNING: Config file not found in server directory!
)

echo.
echo Starting ATS Dedicated Server...
echo Server Name: Freddy's ATS Dedicated Server
echo Password: ruby
echo Max Players: 8
echo Mode: Anonymous/Offline (no Steam authentication)
echo Ports: 27015 ^(connection^), 27016 ^(query^)
echo Workshop Collection: !COLLECTION_ID!
echo Mod Collection: https://steamcommunity.com/sharedfiles/filedetails/?id=!COLLECTION_ID!
echo.
echo Press Ctrl+C to stop the server
echo ===========================================
echo.

:: Change to server working directory and start the server
cd /d "!SERVER_DIR!"
echo Server working directory: !SERVER_DIR!
echo Config file location: !SERVER_DIR!\server_config.sii
echo.
echo Starting server...
echo.
echo Server Details:
echo - Name: Freddy's ATS Dedicated Server
echo - Password: ruby
echo - Max Players: 8
echo - Ports: 27015 (connection), 27016 (query)
echo - Mode: Anonymous/Offline
echo - Collection: https://steamcommunity.com/sharedfiles/filedetails/?id=!COLLECTION_ID!
echo.
echo Starting ATS Dedicated Server...
echo Press Ctrl+C to stop the server when it's running
echo.

:: Start the server directly
echo Starting server process...
bin\win_x64\amtrucks_server.exe -server_cfg server_config.sii -homedir . -anonymous
echo 4. Verify the config file path: !SERVER_DIR!\server_config.sii
echo.
echo Press any key to close this window...
echo Server will continue running in the separate window.
echo ===========================================
pause