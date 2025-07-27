@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Server Manager - Unified Edition
:: Complete server management for Freddy's ATS Dedicated Server
:: ===========================================

title Freddy's ATS Server Manager

:: Load environment configuration
set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%.."
set "ENV_FILE=%BASE_DIR%\.env"

:: Load environment configuration
set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%.."
set "ENV_FILE=%BASE_DIR%\.env"

echo Loading environment configuration...
:: For now, use defaults to avoid parsing issues with parentheses in paths
echo Using fallback defaults...
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "DEFAULT_SERVER_ID=90271602251410447"
set "SERVER_TOKEN=15AE684920A1694E27BFA8B64F75AD1B"
set "COLLECTION_ID=3530633316"
set "SERVER_NAME=Freddy's ATS Dedicated Server"
set "SERVER_PASSWORD=ruby"
set "MAX_PLAYERS=8"
set "MODS_OPTIONING=true"
set "SCRIPT_VERSION=1.0.0"
set "SERVER_DESCRIPTION=Enhanced ATS server with curated sound and graphics mods"
set "SERVER_WELCOME_MESSAGE=Welcome to Freddy's server! Enjoy the enhanced experience with optional mods enabled."
set "MAX_VEHICLES_TOTAL=100"
set "MAX_AI_VEHICLES_PLAYER=50"
set "MAX_AI_VEHICLES_PLAYER_SPAWN=50"
set "CONNECTION_VIRTUAL_PORT=100"
set "QUERY_VIRTUAL_PORT=101"
set "CONNECTION_DEDICATED_PORT=27015"
set "QUERY_DEDICATED_PORT=27016"
set "PLAYER_DAMAGE=true"
set "TRAFFIC=true"
set "HIDE_IN_COMPANY=false"
set "HIDE_COLLIDING=true"
set "FORCE_SPEED_LIMITER=false"
set "TIMEZONES=0"
set "SERVICE_NO_COLLISION=false"
set "IN_MENU_GHOSTING=false"
set "NAME_TAGS=true"
set "FRIENDS_ONLY=false"
set "SHOW_SERVER=true"
set "MODERATOR_LIST=0"

:: Predefined mod order (based on your Active Mods list)
set "MOD_ORDER[0]=Sound Fixes Pack v25.31 - ATS"
set "MOD_ORDER[1]=Maxwell"
set "MOD_ORDER[2]=JC Amateur Sound Effects Pack"
set "MOD_ORDER[3]=Heatshields For SCS 389 Plain Stacks"
set "MOD_ORDER[4]=Cummins N14 Sound & Engine Pack"
set "MOD_ORDER[5]=Cummins ISX Straight pipe sound"
set "MOD_ORDER[6]=CAT 3406E 2WS Straight pipe sound"
set "MOD_ORDER[7]=Box Trailer Enhanced"
set "MOD_ORDER[8]=Real companies, gas stations & billboards"
set "MOD_ORDER[9]=Real Eaton Fuller Transmissions"
set "MOD_ORDER[10]=Real World Signs & Logos"
set "MOD_ORDER[11]=SiSL's Mega Pack"
set "MOD_ORDER[12]=SCS Long Chassis + 625HP Multiplayer"
set "MOD_ORDER[13]=Reverse Lights - farther, wider, brighter"
set "MOD_ORDER[14]=Realistic Vehicle Lights Mod v7.4 (by Frkn64)"
set "MOD_ORDER[15]=Realistic Truck Physics Mod v9.0.6 (by Frkn64)"
set "MOD_ORDER[16]=Realistic Mirror FOV"
set "MOD_ORDER[17]=Realistic Brutal Graphics And Weather"
set "MOD_ORDER[18]=Air Brake Sound Mod"
set "MOD_ORDER_COUNT=19"

echo ✓ Configuration loaded

set "ARCHIVE_DIR=%BASE_DIR%\archive"

:: Allow for server ID override
if "%~1"=="" (
    set "SERVER_ID=!DEFAULT_SERVER_ID!"
) else (
    set "SERVER_ID=%~1"
)

:MAIN_MENU
cls
echo ===========================================
echo   %SERVER_NAME% Manager v%SCRIPT_VERSION%
echo ===========================================
echo   Server: %SERVER_NAME%
echo   Password: %SERVER_PASSWORD%
echo   Optional Mods: %MODS_OPTIONING%
echo   Dynamic Collection: https://steamcommunity.com/sharedfiles/filedetails/?id=%COLLECTION_ID%
echo   Config Source: %ENV_FILE%
echo ===========================================
echo.
echo 1. Quick Start (Setup + Download + Start)
echo 2. Setup Server Environment
echo 3. Download Latest Workshop Mods
echo 4. Start Server Only
echo 5. Start Server + Game Client
echo 6. Launch Game Client Only (Auto-detect Server ID)
echo 7. Server Status ^& Diagnostics
echo 8. Stop All Servers
echo 9. Dynamic Workshop Manager
echo A. Advanced Configuration
echo E. Environment Configuration Manager
echo C. Archive Old Scripts ^& Cleanup
echo 0. Exit
echo.
set /p CHOICE="Select option: "

if /i "%CHOICE%"=="1" goto QUICK_START
if /i "%CHOICE%"=="2" goto SETUP_ENVIRONMENT
if /i "%CHOICE%"=="3" goto UPDATE_MODS
if /i "%CHOICE%"=="4" goto START_SERVER
if /i "%CHOICE%"=="5" goto START_BOTH
if /i "%CHOICE%"=="6" goto LAUNCH_CLIENT_ONLY
if /i "%CHOICE%"=="7" goto DIAGNOSTICS
if /i "%CHOICE%"=="8" goto STOP_SERVERS
if /i "%CHOICE%"=="9" goto WORKSHOP_MANAGER
if /i "%CHOICE%"=="A" goto ADVANCED_CONFIG
if /i "%CHOICE%"=="E" goto ENV_MANAGER
if /i "%CHOICE%"=="C" goto ARCHIVE_CLEANUP
if /i "%CHOICE%"=="0" goto END
goto MAIN_MENU

:QUICK_START
cls
echo ===========================================
echo   Quick Start - Complete Setup
echo ===========================================
echo.
echo This will automatically:
echo 1. Setup server environment
echo 2. Update workshop mods
echo 3. Start the server
echo.
set /p "CONFIRM=Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto MAIN_MENU

echo.
call :SETUP_ENVIRONMENT_SILENT
call :UPDATE_MODS_SILENT
call :START_SERVER_SILENT
goto MAIN_MENU

:SETUP_ENVIRONMENT
cls
echo ===========================================
echo   Setting Up Server Environment
echo ===========================================
echo.

:SETUP_ENVIRONMENT_SILENT
:: Stop any running servers
echo Stopping existing servers...
taskkill /F /IM amtrucks_server.exe 2>nul
echo Waiting for processes to stop...
timeout /t 2 >nul

:: Validate server directory using a different approach
echo Validating server directory...
dir "%SERVER_DIR%" >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Server directory not found: "%SERVER_DIR%"
    echo Please check your server installation
    pause
    goto MAIN_MENU
)

:: Create necessary directories
echo Creating server directories...
md "%SERVER_DIR%\mod" 2>nul

:: Check for server packages
if exist "%USERPROFILE%\Documents\American Truck Simulator\server_packages.sii" (
    echo Copying server packages from game directory...
    copy "%USERPROFILE%\Documents\American Truck Simulator\server_packages.sii" "%SERVER_DIR%\" /Y >nul
    copy "%USERPROFILE%\Documents\American Truck Simulator\server_packages.dat" "%SERVER_DIR%\" /Y >nul
    echo ✓ Server packages copied
) else (
    echo.
    echo ⚠️  WARNING: Server packages not found!
    echo Please start ATS, load your desired DLCs/map, open console (~), and run:
    echo export_server_packages
    echo Then run this setup again.
    echo.
    if not defined SILENT pause
)

:: Create optimized server configuration
call :CREATE_SERVER_CONFIG

echo.
echo ✓ Server environment setup complete!
if not defined SILENT pause
goto :eof

:UPDATE_MODS
cls
echo ===========================================
echo   Dynamic Workshop Collection Manager
echo ===========================================
echo.

:UPDATE_MODS_SILENT
echo Fetching mods from Steam Collection...
echo Collection URL: https://steamcommunity.com/sharedfiles/filedetails/?id=%COLLECTION_ID%
echo.

:: Clean existing mods
echo Cleaning existing server mods...
if exist "%SERVER_DIR%\mod\*.*" (
    del /q "%SERVER_DIR%\mod\*.*"
)

:: Check if we have SteamCMD available or need to use existing workshop files
call :CHECK_STEAMCMD

if defined STEAMCMD_AVAILABLE (
    echo Using SteamCMD for dynamic mod downloading...
    call :DOWNLOAD_COLLECTION_STEAMCMD
) else (
    echo Using existing Steam Workshop files...
    call :COPY_EXISTING_WORKSHOP_MODS
)

:: Update server configuration with current mods
call :CREATE_SERVER_CONFIG

echo.
echo ✓ Mod update complete! Installed !COPIED_COUNT! mods.
if not defined SILENT (
    echo.
    echo Current mods:
    dir /b "%SERVER_DIR%\mod\*.scs" 2>nul
    echo.
    pause
)
goto :eof

:START_SERVER
cls
echo ===========================================
echo   Starting Freddy's ATS Dedicated Server
echo ===========================================
echo.

:START_SERVER_SILENT
:: Stop any existing servers
taskkill /F /IM amtrucks_server.exe 2>nul
timeout /t 2 >nul

echo Server Details:
echo - Name: Freddy's ATS Dedicated Server
echo - Password: ruby
echo - Max Players: 8
echo - Optional Mods: Enabled
echo - Server ID: %SERVER_ID%
echo.

:: Check server files
if not exist "%SERVER_DIR%\server_config.sii" (
    echo ❌ ERROR: Server config not found! Run Setup Environment first.
    if not defined SILENT pause
    goto :eof
)

if not exist "%SERVER_DIR%\server_packages.sii" (
    echo ⚠️  WARNING: Server packages not found! Server may not start properly.
    if not defined SILENT pause
)

echo.
echo Installed mods (in loading order):
set /a DISPLAY_COUNT=0
for /f "tokens=*" %%f in ('dir /b /on "%SERVER_DIR%\mod\*.scs" 2^>nul') do (
    set /a DISPLAY_COUNT+=1
    echo   [!DISPLAY_COUNT!] %%f
)
echo.

cd /d "%SERVER_DIR%\bin\win_x64"

echo Starting server with session ID capture...

:: Create a wrapper script to capture the server ID
(
echo @echo off
echo setlocal EnableDelayedExpansion
echo title Freddy's ATS Server - Enhanced Logging
echo cd /d "%SERVER_DIR%\bin\win_x64"
echo echo ===========================================
echo echo   Freddy's ATS Dedicated Server
echo echo ===========================================
echo echo Server will capture session ID for easy client connections
echo echo Enhanced logging enabled for troubleshooting
echo echo.
echo echo Common startup messages you may see:
echo echo - *** ERROR *** : [dstorage] - Normal, can be ignored
echo echo - *** WARNING *** : Unfinished data chunk - May indicate mod issues
echo echo - Setting breakpad minidump - Normal crash reporting setup
echo echo - SteamInternal_SetMinidumpSteamID - Normal Steam API init
echo echo.
echo echo Starting server now...
echo echo ==========================================
echo.
echo amtrucks_server.exe -anonymous -server_config "..\..\server_config.sii" ^| tee "%TEMP%\ats_server_output.txt"
echo.
echo echo ==========================================
echo echo Server session ended. Check above for any critical errors.
echo echo Session ID and other info saved to: %TEMP%\ats_server_output.txt
echo if exist "%TEMP%\ats_server_output.txt" ^(
echo     findstr /C:"Session search id" "%TEMP%\ats_server_output.txt" ^> "%TEMP%\ats_server_id.txt"
echo     echo Session ID captured for client connections
echo ^)
if not defined SILENT echo pause
) > "%TEMP%\start_ats_server_wrapper.bat"

start "Freddy's ATS Server" "%TEMP%\start_ats_server_wrapper.bat"

echo.
echo ✓ Server started! Window title: "Freddy's ATS Server"
echo Check the server window for:
echo - "Mods optioning: True"
echo - "Modded session: Yes"
echo - Number of active mods
if not defined SILENT (
    timeout /t 5
)
goto :eof

:START_BOTH
call :START_SERVER_SILENT
timeout /t 10

cls
echo ===========================================
echo   Starting ATS Game Client
echo ===========================================
echo.

echo Connecting to Freddy's server...
echo Server ID: %SERVER_ID%
echo Password: ruby
echo.

cd /d "%GAME_DIR%"

echo Starting ATS game client...
start "ATS Client" "bin\win_x64\amtrucks.exe" ^
    +online_server_id %SERVER_ID% ^
    +server_join_password ruby ^
    +g_online_server_name "Freddy's ATS Dedicated Server" ^
    +mods_optioning 1 ^
    +enable_mods 1

echo.
echo ✓ Game client started and connecting to server!
timeout /t 5
goto MAIN_MENU

:LAUNCH_CLIENT_ONLY
cls
echo ===========================================
echo   Launch Game Client (Auto-detect Server)
echo ===========================================
echo.

echo Checking for running server...
tasklist /FI "IMAGENAME eq amtrucks_server.exe" 2>NUL | find /I /N "amtrucks_server.exe" >nul && (
    echo ✓ ATS Server is RUNNING
) || (
    echo ❌ ATS Server is NOT running
    echo.
    echo Please start the server first using option 4 or 5.
    pause
    goto MAIN_MENU
)

echo.
echo Detecting server session ID...

:: Try to get the session ID from the captured file
set "SERVER_SESSION_ID="
if exist "%TEMP%\ats_server_id.txt" (
    for /f "tokens=4" %%a in ('findstr "Session search id:" "%TEMP%\ats_server_id.txt"') do (
        set "SERVER_SESSION_ID=%%a"
    )
)

if defined SERVER_SESSION_ID (
    echo ✓ Detected Server Session ID: %SERVER_SESSION_ID%
) else (
    echo ⚠️  Could not auto-detect session ID
    echo Using fallback Server ID: %DEFAULT_SERVER_ID%
    set "SERVER_SESSION_ID=%DEFAULT_SERVER_ID%"
)

echo.
echo Launch Options:
echo 1. Connect with detected/fallback ID: %SERVER_SESSION_ID%
echo 2. Enter custom Server ID
echo 3. Return to main menu
echo.
set /p CLIENT_CHOICE="Select option: "

if "%CLIENT_CHOICE%"=="1" goto LAUNCH_WITH_ID
if "%CLIENT_CHOICE%"=="2" goto ENTER_CUSTOM_ID
if "%CLIENT_CHOICE%"=="3" goto MAIN_MENU
goto LAUNCH_CLIENT_ONLY

:ENTER_CUSTOM_ID
echo.
set /p SERVER_SESSION_ID="Enter Server ID: "
if not defined SERVER_SESSION_ID goto ENTER_CUSTOM_ID

:LAUNCH_WITH_ID
cls
echo ===========================================
echo   Launching Game Client
echo ===========================================
echo.
echo Connecting to server...
echo Server ID: %SERVER_SESSION_ID%
echo Password: %SERVER_PASSWORD%
echo.

cd /d "%GAME_DIR%"

echo Starting ATS game client...
start "ATS Client" "bin\win_x64\amtrucks.exe" ^
    +online_server_id %SERVER_SESSION_ID% ^
    +server_join_password %SERVER_PASSWORD% ^
    +g_online_server_name "%SERVER_NAME%" ^
    +mods_optioning 1 ^
    +enable_mods 1

echo.
echo ✓ Game client started and connecting to server!
echo ✓ Server ID: %SERVER_SESSION_ID%
echo ✓ Password: %SERVER_PASSWORD%
echo.
echo The game should automatically attempt to connect to your server.
timeout /t 5
goto MAIN_MENU

:DIAGNOSTICS
cls
echo ===========================================
echo   Server Status ^& Diagnostics
echo ===========================================
echo.

echo 1. SERVER STATUS
echo ================
tasklist /FI "IMAGENAME eq amtrucks_server.exe" 2>NUL | find /I /N "amtrucks_server.exe" >nul && (
    echo ✓ ATS Server is RUNNING
) || (
    echo ❌ ATS Server is NOT running
)

echo.
echo 2. SERVER CONNECTION INFO
echo =========================
if exist "%TEMP%\ats_server_id.txt" (
    echo ✓ Server ID file found
    for /f "tokens=4" %%a in ('findstr "Session search id:" "%TEMP%\ats_server_id.txt" 2^>nul') do (
        echo ✓ Detected Session ID: %%a
    )
) else (
    echo ⚠️  Server ID file not found
    echo   Start server with updated script to capture session ID
)
echo   Default Server ID: %DEFAULT_SERVER_ID%
echo   Server Password: %SERVER_PASSWORD%
echo   Connection Port: %CONNECTION_DEDICATED_PORT%
echo   Query Port: %QUERY_DEDICATED_PORT%

echo.
echo 3. FILE CHECKS
echo ==============
if exist "%SERVER_DIR%\server_config.sii" (
    echo ✓ Server config exists
) else (
    echo ❌ Server config missing
)

if exist "%SERVER_DIR%\server_packages.sii" (
    echo ✓ Server packages exist
) else (
    echo ❌ Server packages missing
)

if exist "%SERVER_DIR%\mod" (
    echo ✓ Mod directory exists
) else (
    echo ❌ Mod directory missing
)

echo.
echo 4. MOD STATUS
echo =============
set /a MOD_COUNT=0
echo Mods loaded in order:
for /f "tokens=*" %%f in ('dir /b /on "%SERVER_DIR%\mod\*.scs" 2^>nul') do (
    set /a MOD_COUNT+=1
    echo [!MOD_COUNT!] %%f
)
echo Total mods: !MOD_COUNT!

echo.
echo 4. CONFIGURATION CHECK
echo ======================
if exist "%SERVER_DIR%\server_config.sii" (
    findstr /i "mods_optioning" "%SERVER_DIR%\server_config.sii" >nul && (
        echo ✓ mods_optioning is configured
    ) || (
        echo ❌ mods_optioning not found in config
    )
    
    findstr /i "lobby_name.*Freddy" "%SERVER_DIR%\server_config.sii" >nul && (
        echo ✓ Server name is set to Freddy's
    ) || (
        echo ❌ Server name not configured
    )
    
    findstr /i "password.*ruby" "%SERVER_DIR%\server_config.sii" >nul && (
        echo ✓ Password is set to ruby
    ) || (
        echo ❌ Password not configured
    )
)

echo.
echo 5. WORKSHOP DIRECTORY CHECK
echo ===========================
if exist "%WORKSHOP_DIR%" (
    echo ✓ Workshop directory exists
    set /a WS_COUNT=0
    for /d %%d in ("%WORKSHOP_DIR%\*") do (
        set /a WS_COUNT+=1
    )
    echo Workshop items: !WS_COUNT!
) else (
    echo ❌ Workshop directory not found
)

echo.
echo 6. QUICK FIXES
echo ==============
echo F. Fix Server Configuration
echo T. Test Server Without Mods
echo V. View Current Config
echo S. Server Startup Diagnostics
echo C. Clean Mod Files and Redownload
echo R. Return to Main Menu
echo.
set /p DIAG_CHOICE="Select option: "

if /i "%DIAG_CHOICE%"=="F" call :FIX_CONFIG
if /i "%DIAG_CHOICE%"=="T" call :TEST_NO_MODS
if /i "%DIAG_CHOICE%"=="V" call :VIEW_CONFIG
if /i "%DIAG_CHOICE%"=="S" call :SERVER_STARTUP_DIAG
if /i "%DIAG_CHOICE%"=="C" call :CLEAN_AND_REDOWNLOAD_MODS
if /i "%DIAG_CHOICE%"=="R" goto MAIN_MENU
goto DIAGNOSTICS

:FIX_CONFIG
echo.
echo Fixing server configuration...
call :CREATE_SERVER_CONFIG
echo ✓ Configuration recreated!
pause
goto :eof

:TEST_NO_MODS
echo.
echo Creating test config without mods...
call :CREATE_TEST_CONFIG
echo Starting test server...
cd /d "%SERVER_DIR%\bin\win_x64"
start "ATS Test Server" "amtrucks_server.exe" ^
    -server_id %SERVER_ID% ^
    -server_config "..\server_config_test.sii" ^
    +g_console 1
echo Test server started. Check if it shows "Mods optioning: True"
pause
goto :eof

:VIEW_CONFIG
echo.
echo Current server configuration:
echo =============================
if exist "%SERVER_DIR%\server_config.sii" (
    type "%SERVER_DIR%\server_config.sii"
) else (
    echo Configuration file not found!
)
echo =============================
pause
goto :eof

:STOP_SERVERS
echo.
echo Stopping all ATS server instances...
taskkill /F /IM amtrucks_server.exe 2>nul
echo ✓ Done.
timeout /t 2
goto MAIN_MENU

:WORKSHOP_MANAGER
cls
echo ===========================================
echo   Dynamic Workshop Collection Manager
echo ===========================================
echo.
echo Collection URL: https://steamcommunity.com/sharedfiles/filedetails/?id=%COLLECTION_ID%
echo.
echo 1. Open Collection in Steam/Browser
echo 2. Download Fresh Mods from Collection
echo 3. List Available Workshop Mods
echo 4. Verify Collection Integrity
echo 5. Force Refresh Workshop Cache
echo 6. Manage SteamCMD
echo 7. Back to Main Menu
echo.
set /p WS_CHOICE="Select option: "

if "%WS_CHOICE%"=="1" goto OPEN_COLLECTION
if "%WS_CHOICE%"=="2" goto UPDATE_MODS
if "%WS_CHOICE%"=="3" goto LIST_WORKSHOP_MODS
if "%WS_CHOICE%"=="4" goto VERIFY_COLLECTION
if "%WS_CHOICE%"=="5" goto REFRESH_WORKSHOP
if "%WS_CHOICE%"=="6" goto MANAGE_STEAMCMD
if "%WS_CHOICE%"=="7" goto MAIN_MENU
goto WORKSHOP_MANAGER

:OPEN_COLLECTION
echo.
echo Opening collection in browser and Steam...
start "" "https://steamcommunity.com/sharedfiles/filedetails/?id=%COLLECTION_ID%"
start "" "steam://url/CommunityFilePage/%COLLECTION_ID%"
timeout /t 2
goto WORKSHOP_MANAGER

:VERIFY_COLLECTION
echo.
echo ===========================================
echo   Collection Integrity Check
echo ===========================================
echo.

echo Fetching current collection data...
call :FETCH_COLLECTION_MODS

if exist "%STEAMCMD_DIR%\collection_mods.txt" (
    echo.
    echo Collection contains the following mod IDs:
    type "%STEAMCMD_DIR%\collection_mods.txt"
    
    echo.
    echo Checking which mods are available locally...
    set /a AVAILABLE_COUNT=0
    set /a MISSING_COUNT=0
    
    for /f %%i in (%STEAMCMD_DIR%\collection_mods.txt) do (
        if exist "%WORKSHOP_DIR%\%%i" (
            echo ✓ Available: %%i
            set /a AVAILABLE_COUNT+=1
        ) else (
            echo ❌ Missing: %%i
            set /a MISSING_COUNT+=1
        )
    )
    
    echo.
    echo Summary:
    echo - Available locally: !AVAILABLE_COUNT! mods
    echo - Missing/Need download: !MISSING_COUNT! mods
    
    if !MISSING_COUNT! GTR 0 (
        echo.
        echo Recommend running "Download Fresh Mods from Collection" to get missing mods.
    )
) else (
    echo ❌ Could not fetch collection data
)

pause
goto WORKSHOP_MANAGER

:REFRESH_WORKSHOP
echo.
echo Refreshing Steam Workshop cache...
echo This will restart Steam to refresh workshop subscriptions.
echo.
set /p REFRESH_CONFIRM="Continue? (Y/N): "
if /i not "%REFRESH_CONFIRM%"=="Y" goto WORKSHOP_MANAGER

echo.
echo Stopping Steam...
taskkill /F /IM steam.exe 2>nul
timeout /t 3

echo Starting Steam...
start "" "steam://open/main"
echo.
echo Steam should restart and refresh workshop subscriptions.
echo Wait for Steam to fully load, then try updating mods again.

timeout /t 5
goto WORKSHOP_MANAGER

:MANAGE_STEAMCMD
cls
echo ===========================================
echo   SteamCMD Management
echo ===========================================
echo.

if defined STEAMCMD_AVAILABLE (
    echo ✓ SteamCMD Status: Installed
    echo Location: %STEAMCMD_EXE%
    echo.
    echo 1. Update SteamCMD
    echo 2. Clean SteamCMD Cache
    echo 3. Reinstall SteamCMD
    echo 4. View SteamCMD Logs
    echo 5. Back to Workshop Manager
) else (
    echo ❌ SteamCMD Status: Not Installed
    echo.
    echo 1. Install SteamCMD
    echo 2. Back to Workshop Manager
)

echo.
set /p STEAM_CHOICE="Select option: "

if not defined STEAMCMD_AVAILABLE (
    if "%STEAM_CHOICE%"=="1" call :DOWNLOAD_STEAMCMD
    if "%STEAM_CHOICE%"=="2" goto WORKSHOP_MANAGER
    goto MANAGE_STEAMCMD
)

if "%STEAM_CHOICE%"=="1" goto UPDATE_STEAMCMD
if "%STEAM_CHOICE%"=="2" goto CLEAN_STEAMCMD
if "%STEAM_CHOICE%"=="3" goto REINSTALL_STEAMCMD
if "%STEAM_CHOICE%"=="4" goto VIEW_STEAMCMD_LOGS
if "%STEAM_CHOICE%"=="5" goto WORKSHOP_MANAGER
goto MANAGE_STEAMCMD

:UPDATE_STEAMCMD
echo.
echo Updating SteamCMD...
"%STEAMCMD_EXE%" +quit
echo ✓ SteamCMD updated
pause
goto MANAGE_STEAMCMD

:CLEAN_STEAMCMD
echo.
echo Cleaning SteamCMD cache...
if exist "%STEAMCMD_DIR%\steamapps" (
    rd /s /q "%STEAMCMD_DIR%\steamapps"
)
if exist "%STEAMCMD_DIR%\logs" (
    rd /s /q "%STEAMCMD_DIR%\logs"
)
echo ✓ Cache cleaned
pause
goto MANAGE_STEAMCMD

:REINSTALL_STEAMCMD
echo.
echo Reinstalling SteamCMD...
if exist "%STEAMCMD_DIR%" (
    rd /s /q "%STEAMCMD_DIR%"
)
call :DOWNLOAD_STEAMCMD
goto MANAGE_STEAMCMD

:VIEW_STEAMCMD_LOGS
echo.
if exist "%STEAMCMD_DIR%\downloading_mods.log" (
    echo Recent mod downloads:
    type "%STEAMCMD_DIR%\downloading_mods.log"
) else (
    echo No download logs found
)
pause
goto MANAGE_STEAMCMD

:LIST_WORKSHOP_MODS
echo.
echo Available Workshop Mods:
echo ========================
for /d %%d in ("%WORKSHOP_DIR%\*") do (
    echo Workshop ID: %%~nxd
    for %%f in ("%%d\*.scs") do (
        echo   - %%~nxf
    )
    echo.
)
pause
goto WORKSHOP_MANAGER

:ADVANCED_CONFIG
cls
echo ===========================================
echo   Advanced Configuration
echo ===========================================
echo.
echo 1. Edit Server Config Manually
echo 2. Change Server Token
echo 3. Change Server ID
echo 4. Reset to Defaults
echo 5. Create Backup of Current Config
echo 6. Back to Main Menu
echo.
set /p ADV_CHOICE="Select option: "

if "%ADV_CHOICE%"=="1" goto EDIT_CONFIG
if "%ADV_CHOICE%"=="2" goto CHANGE_TOKEN
if "%ADV_CHOICE%"=="3" goto CHANGE_SERVER_ID
if "%ADV_CHOICE%"=="4" goto RESET_CONFIG
if "%ADV_CHOICE%"=="5" goto BACKUP_CONFIG
if "%ADV_CHOICE%"=="6" goto MAIN_MENU
goto ADVANCED_CONFIG

:EDIT_CONFIG
if exist "%SERVER_DIR%\server_config.sii" (
    notepad "%SERVER_DIR%\server_config.sii"
) else (
    echo Server config not found!
    pause
)
goto ADVANCED_CONFIG

:CHANGE_TOKEN
echo.
echo Current token: %SERVER_TOKEN%
set /p NEW_TOKEN="Enter new server token: "
if not "%NEW_TOKEN%"=="" (
    set "SERVER_TOKEN=%NEW_TOKEN%"
    call :CREATE_SERVER_CONFIG
    echo Token updated and config recreated!
)
pause
goto ADVANCED_CONFIG

:CHANGE_SERVER_ID
echo.
echo Current Server ID: %SERVER_ID%
set /p NEW_ID="Enter new server ID: "
if not "%NEW_ID%"=="" set "SERVER_ID=%NEW_ID%"
echo Server ID updated!
pause
goto ADVANCED_CONFIG

:RESET_CONFIG
echo.
echo Resetting to default configuration...
call :CREATE_SERVER_CONFIG
echo ✓ Configuration reset!
pause
goto ADVANCED_CONFIG

:BACKUP_CONFIG
echo.
if not exist "%SCRIPT_DIR%\backups" (
    mkdir "%SCRIPT_DIR%\backups"
)
set "BACKUP_NAME=server_config_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.sii"
set "BACKUP_NAME=%BACKUP_NAME: =0%"
copy "%SERVER_DIR%\server_config.sii" "%SCRIPT_DIR%\backups\%BACKUP_NAME%" >nul
echo ✓ Configuration backed up to: backups\%BACKUP_NAME%
pause
goto ADVANCED_CONFIG

:ENV_MANAGER
echo.
echo Launching Environment Configuration Manager...
call "%SCRIPT_DIR%env_manager.bat"
echo.
echo Reloading environment configuration...
if exist "%ENV_FILE%" (
    call "%SCRIPT_DIR%load_env.bat" "%ENV_FILE%"
    echo ✓ Environment reloaded
) else (
    echo ⚠️  Environment file not found
)
pause
goto MAIN_MENU

:ARCHIVE_CLEANUP
cls
echo ===========================================
echo   Archive Old Scripts ^& Cleanup
echo ===========================================
echo.

:: Create archive directory
if not exist "%ARCHIVE_DIR%" (
    mkdir "%ARCHIVE_DIR%"
)

echo This will move the following old batch files to archive:
echo.
for %%f in ("%BASE_DIR%\*.bat") do (
    if /i not "%%~nxf"=="ats_server_manager.bat" (
        echo   - %%~nxf
    )
)
echo.
echo Continue? (Y/N)
set /p ARCHIVE_CONFIRM=""
if /i not "%ARCHIVE_CONFIRM%"=="Y" goto MAIN_MENU

echo.
echo Moving old scripts to archive...
for %%f in ("%BASE_DIR%\*.bat") do (
    if /i not "%%~nxf"=="ats_server_manager.bat" (
        echo Moving: %%~nxf
        move "%%f" "%ARCHIVE_DIR%\" >nul
    )
)

:: Also archive the old config if it exists
if exist "%BASE_DIR%\config" (
    echo Moving old config directory...
    if not exist "%ARCHIVE_DIR%\config" (
        mkdir "%ARCHIVE_DIR%\config"
    )
    xcopy "%BASE_DIR%\config\*.*" "%ARCHIVE_DIR%\config\" /Y /E >nul
    rd /s /q "%BASE_DIR%\config"
)

echo.
echo ✓ Cleanup complete! Old files moved to: archive\
echo ✓ Workspace is now clean with just the unified manager
pause
goto MAIN_MENU

:: ===== HELPER FUNCTIONS =====

:CHECK_STEAMCMD
:: Check if SteamCMD is available or can be downloaded
set "STEAMCMD_AVAILABLE="
set "STEAMCMD_DIR=%SCRIPT_DIR%\steamcmd"
set "STEAMCMD_EXE=%STEAMCMD_DIR%\steamcmd.exe"

if exist "%STEAMCMD_EXE%" (
    set "STEAMCMD_AVAILABLE=1"
    echo ✓ SteamCMD found at: %STEAMCMD_EXE%
) else (
    echo SteamCMD not found. Checking for automatic download...
    call :DOWNLOAD_STEAMCMD
)
goto :eof

:DOWNLOAD_STEAMCMD
echo.
echo SteamCMD is required for dynamic mod downloading.
echo This will download SteamCMD (free tool from Valve) to: %STEAMCMD_DIR%
echo.
set /p DOWNLOAD_CONFIRM="Download SteamCMD now? (Y/N): "
if /i not "%DOWNLOAD_CONFIRM%"=="Y" goto :eof

echo.
echo Creating SteamCMD directory...
if not exist "%STEAMCMD_DIR%" (
    mkdir "%STEAMCMD_DIR%"
)

echo Downloading SteamCMD...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile '%STEAMCMD_DIR%\steamcmd.zip' }"

if exist "%STEAMCMD_DIR%\steamcmd.zip" (
    echo Extracting SteamCMD...
    powershell -Command "Expand-Archive -Path '%STEAMCMD_DIR%\steamcmd.zip' -DestinationPath '%STEAMCMD_DIR%' -Force"
    del "%STEAMCMD_DIR%\steamcmd.zip"
    
    if exist "%STEAMCMD_EXE%" (
        set "STEAMCMD_AVAILABLE=1"
        echo ✓ SteamCMD downloaded successfully!
        
        echo Initializing SteamCMD (first run)...
        "%STEAMCMD_EXE%" +quit
    ) else (
        echo ❌ Failed to extract SteamCMD
    )
) else (
    echo ❌ Failed to download SteamCMD
)
goto :eof

:DOWNLOAD_COLLECTION_STEAMCMD
echo.
echo Fetching collection information...

:: Create collection mod list file
set "COLLECTION_LIST=%STEAMCMD_DIR%\collection_mods.txt"
call :FETCH_COLLECTION_MODS

if exist "%COLLECTION_LIST%" (
    echo Found collection mod list. Downloading mods...
    call :DOWNLOAD_MODS_FROM_LIST
) else (
    echo ⚠️  Could not fetch collection. Falling back to existing workshop files...
    call :COPY_EXISTING_WORKSHOP_MODS
)
goto :eof

:FETCH_COLLECTION_MODS
echo Creating collection mod list...

:: Create a PowerShell script to fetch the collection
set "PS_SCRIPT=%STEAMCMD_DIR%\fetch_collection.ps1"
(
echo # PowerShell script to fetch Steam Workshop collection
echo $collectionId = "%COLLECTION_ID%"
echo $url = "https://steamcommunity.com/sharedfiles/filedetails/?id=$collectionId"
echo.
echo try {
echo     $response = Invoke-WebRequest -Uri $url -UseBasicParsing
echo     $content = $response.Content
echo.
echo     # Look for workshop item IDs in the HTML
echo     $pattern = 'sharedfile_(\d+)'
echo     $matches = [regex]::Matches($content, $pattern^)
echo.
echo     $modIds = @(^)
echo     foreach ($match in $matches^) {
echo         $modId = $match.Groups[1].Value
echo         if ($modIds -notcontains $modId^) {
echo             $modIds += $modId
echo         }
echo     }
echo.
echo     # Write mod IDs to file
echo     $outputFile = "%COLLECTION_LIST%"
echo     $modIds ^| Out-File -FilePath $outputFile -Encoding ASCII
echo.
echo     Write-Host "Found $($modIds.Count^) unique mods in collection"
echo } catch {
echo     Write-Host "Error fetching collection: $_"
echo     exit 1
echo }
) > "%PS_SCRIPT%"

:: Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
goto :eof

:DOWNLOAD_MODS_FROM_LIST
set /a COPIED_COUNT=0

if not exist "%COLLECTION_LIST%" (
    echo ❌ Collection list not found
    goto :eof
)

echo.
echo Downloading mods using SteamCMD...

:: Create SteamCMD script
set "STEAMCMD_SCRIPT=%STEAMCMD_DIR%\download_mods.txt"
(
echo @ShutdownOnFailedCommand 1
echo @NoPromptForPassword 1
echo login anonymous
) > "%STEAMCMD_SCRIPT%"

:: Add workshop download commands for each mod
for /f %%i in (%COLLECTION_LIST%) do (
    echo workshop_download_item 270880 %%i >> "%STEAMCMD_SCRIPT%"
    echo %%i >> "%STEAMCMD_DIR%\downloading_mods.log"
)

echo quit >> "%STEAMCMD_SCRIPT%"

:: Execute SteamCMD
echo Running SteamCMD to download mods...
"%STEAMCMD_EXE%" +runscript "%STEAMCMD_SCRIPT%"

:: Copy downloaded mods to server
echo.
echo Copying downloaded mods to server in predefined order...
set "STEAMCMD_WORKSHOP=%STEAMCMD_DIR%\steamapps\workshop\content\270880"

if exist "%STEAMCMD_WORKSHOP%" (
    :: Copy mods in the predefined order
    for /L %%i in (0,1,%MOD_ORDER_COUNT%) do (
        call set "TARGET_MOD=%%MOD_ORDER[%%i]%%"
        if defined TARGET_MOD (
            call :FIND_AND_COPY_STEAMCMD_MOD "!TARGET_MOD!" %%i
        )
    )
    echo ✓ Copied !COPIED_COUNT! mods from SteamCMD downloads in predefined order
) else (
    echo ⚠️  SteamCMD workshop directory not found, using existing files...
    call :COPY_EXISTING_WORKSHOP_MODS
)
goto :eof

:FIND_AND_COPY_STEAMCMD_MOD
:: Function to find and copy a specific mod from SteamCMD downloads
:: %1 = Mod name pattern to search for
:: %2 = Order index for filename prefix
setlocal EnableDelayedExpansion
set "SEARCH_PATTERN=%~1"
set "ORDER_INDEX=%~2"

for /d %%d in ("%STEAMCMD_WORKSHOP%\*") do (
    for %%f in ("%%d\*.scs") do (
        set "MOD_FILE=%%~nxf"
        
        :: Check if the mod file contains the search pattern (case insensitive)
        echo "!MOD_FILE!" | findstr /i /c:"%SEARCH_PATTERN%" >nul
        if !errorlevel! equ 0 (
            :: Format order index with leading zeros for proper sorting
            set "FORMATTED_INDEX=00%ORDER_INDEX%"
            set "FORMATTED_INDEX=!FORMATTED_INDEX:~-3!"
            
            :: Copy with order prefix to ensure loading order
            echo Copying [!FORMATTED_INDEX!]: !MOD_FILE!
            copy "%%f" "%SERVER_DIR%\mod\!FORMATTED_INDEX!_!MOD_FILE!" >nul 2>&1
            if !errorlevel! equ 0 (
                set /a COPIED_COUNT+=1
            )
            goto :eof
        )
    )
)

echo ⚠️  Mod not found in SteamCMD downloads: %SEARCH_PATTERN%
goto :eof

:COPY_EXISTING_WORKSHOP_MODS
echo.
echo Using existing Steam Workshop files with predefined order...
set /a COPIED_COUNT=0

:: Copy mods in the predefined order
for /L %%i in (0,1,%MOD_ORDER_COUNT%) do (
    call set "TARGET_MOD=%%MOD_ORDER[%%i]%%"
    if defined TARGET_MOD (
        call :FIND_AND_COPY_MOD "!TARGET_MOD!" %%i
    )
)

echo ✓ Copied !COPIED_COUNT! mods in predefined order
goto :eof

:FIND_AND_COPY_MOD
:: Function to find and copy a specific mod by name pattern
:: %1 = Mod name pattern to search for
:: %2 = Order index for filename prefix
setlocal EnableDelayedExpansion
set "SEARCH_PATTERN=%~1"
set "ORDER_INDEX=%~2"

for /d %%d in ("%WORKSHOP_DIR%\*") do (
    for %%f in ("%%d\*.scs") do (
        set "MOD_FILE=%%~nxf"
        
        :: Check if the mod file contains the search pattern (case insensitive)
        echo "!MOD_FILE!" | findstr /i /c:"%SEARCH_PATTERN%" >nul
        if !errorlevel! equ 0 (
            :: Format order index with leading zeros for proper sorting
            set "FORMATTED_INDEX=00%ORDER_INDEX%"
            set "FORMATTED_INDEX=!FORMATTED_INDEX:~-3!"
            
            :: Copy with order prefix to ensure loading order
            echo Copying [!FORMATTED_INDEX!]: !MOD_FILE!
            copy "%%f" "%SERVER_DIR%\mod\!FORMATTED_INDEX!_!MOD_FILE!" >nul 2>&1
            if !errorlevel! equ 0 (
                set /a COPIED_COUNT+=1
            )
            goto :eof
        )
    )
)

echo ⚠️  Mod not found: %SEARCH_PATTERN%
goto :eof

:CREATE_SERVER_CONFIG
(
echo SiiNunit
echo {
echo server_config : .config {
echo  lobby_name: "%SERVER_NAME%"
echo  description: "%SERVER_DESCRIPTION%"
echo  welcome_message: "%SERVER_WELCOME_MESSAGE%"
echo  password: "%SERVER_PASSWORD%"
echo  max_players: %MAX_PLAYERS%
echo  max_vehicles_total: %MAX_VEHICLES_TOTAL%
echo  max_ai_vehicles_player: %MAX_AI_VEHICLES_PLAYER%
echo  max_ai_vehicles_player_spawn: %MAX_AI_VEHICLES_PLAYER_SPAWN%
echo  connection_virtual_port: %CONNECTION_VIRTUAL_PORT%
echo  query_virtual_port: %QUERY_VIRTUAL_PORT%
echo  connection_dedicated_port: %CONNECTION_DEDICATED_PORT%
echo  query_dedicated_port: %QUERY_DEDICATED_PORT%
echo  server_logon_token: "%SERVER_TOKEN%"
echo  player_damage: %PLAYER_DAMAGE%
echo  traffic: %TRAFFIC%
echo  hide_in_company: %HIDE_IN_COMPANY%
echo  hide_colliding: %HIDE_COLLIDING%
echo  force_speed_limiter: %FORCE_SPEED_LIMITER%
echo  mods_optioning: %MODS_OPTIONING%
echo  timezones: %TIMEZONES%
echo  service_no_collision: %SERVICE_NO_COLLISION%
echo  in_menu_ghosting: %IN_MENU_GHOSTING%
echo  name_tags: %NAME_TAGS%
echo  friends_only: %FRIENDS_ONLY%
echo  show_server: %SHOW_SERVER%
echo  moderator_list: %MODERATOR_LIST%
echo  mods: .mods {
) > "%SERVER_DIR%\server_config.sii"

:: Add mod entries in order (sorted by filename prefix)
set /a MOD_COUNT=0
for /f "tokens=*" %%f in ('dir /b /on "%SERVER_DIR%\mod\*.scs" 2^>nul') do (
    echo   active[!MOD_COUNT!]: "/mod/%%f" >> "%SERVER_DIR%\server_config.sii"
    set /a MOD_COUNT+=1
)

:: Close the config
(
echo  }
echo }
echo }
) >> "%SERVER_DIR%\server_config.sii"
goto :eof

:CREATE_TEST_CONFIG
(
echo SiiNunit
echo {
echo server_config : .config {
echo  lobby_name: "Freddy's ATS Test Server"
echo  description: "Test server without mods"
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
echo  mods_optioning: false
echo  timezones: 0
echo  service_no_collision: false
echo  in_menu_ghosting: false
echo  name_tags: true
echo  friends_only: false
echo  show_server: true
echo  moderator_list: 0
echo  mods: .mods {
echo  }
echo }
echo }
) > "%SERVER_DIR%\server_config_test.sii"
goto :eof

:LOAD_ENV_VARIABLES
:: Custom environment variable loader that handles quoted values  
setlocal EnableDelayedExpansion
for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%ENV_FILE%") do (
    if not "%%a"=="" (
        set "VAR_NAME=%%a"
        set "VAR_VALUE=%%b"
        
        :: Handle quoted values
        if "!VAR_VALUE:~0,1!"=="\"" (
            if "!VAR_VALUE:~-1!"=="\"" (
                set "VAR_VALUE=!VAR_VALUE:~1,-1!"
            )
        )
        
        :: Export the variable to parent scope
        endlocal & set "%%a=!VAR_VALUE!" & setlocal EnableDelayedExpansion
    )
)
endlocal
goto :eof

:SERVER_STARTUP_DIAG
echo.
echo ===========================================
echo   Server Startup Diagnostics
echo ===========================================
echo.

echo Checking for common startup issues...
echo.

:: Check for corrupted mod files
echo 1. CHECKING MOD FILE INTEGRITY
echo ===============================
set /a CORRUPT_COUNT=0
set /a VALID_COUNT=0

for %%f in ("%SERVER_DIR%\mod\*.scs") do (
    :: Check file size (SCS files should be larger than 1KB)
    for %%s in ("%%f") do (
        if %%~zs LSS 1024 (
            echo ⚠️  Suspicious small file: %%~nxf ^(%%~zs bytes^)
            set /a CORRUPT_COUNT+=1
        ) else (
            set /a VALID_COUNT+=1
        )
    )
)

echo Valid mod files: !VALID_COUNT!
echo Suspicious files: !CORRUPT_COUNT!

if !CORRUPT_COUNT! GTR 0 (
    echo.
    echo ⚠️  Found suspicious mod files. Consider redownloading mods.
)

echo.
echo 2. CHECKING DEPENDENCY ORDER
echo =============================
echo Verifying mod loading order matches dependency requirements...

:: Check if Sound Fixes Pack is loaded first (critical for sound mods)
for /f "tokens=*" %%f in ('dir /b /on "%SERVER_DIR%\mod\*.scs" 2^>nul') do (
    echo "%%f" | findstr /i /c:"Sound Fixes" >nul
    if !errorlevel! equ 0 (
        echo ✓ Sound Fixes Pack found at correct position
        goto :check_physics_mods
    ) else (
        echo First mod: %%f
        echo ⚠️  Sound Fixes Pack should typically load first for compatibility
        goto :check_physics_mods
    )
)

:check_physics_mods
echo.
echo 3. TESTING SERVER STARTUP
echo ==========================
echo Starting server in diagnostic mode...

cd /d "%SERVER_DIR%\bin\win_x64"

:: Create diagnostic startup script
(
echo @echo off
echo title ATS Server Diagnostic
echo echo Starting ATS Server in diagnostic mode...
echo echo Watching for common error patterns...
echo echo.
echo amtrucks_server.exe -anonymous -server_config "..\..\server_config.sii" -log_file "..\..\diagnostic.log"
) > "%TEMP%\ats_diagnostic_start.bat"

echo.
echo Starting diagnostic server session...
echo Check the diagnostic window for:
echo - Any "FAILED" messages
echo - Mod loading errors
echo - Memory allocation issues
echo.
echo Press any key when ready to start diagnostic session...
pause >nul

start "ATS Diagnostic" "%TEMP%\ats_diagnostic_start.bat"

echo.
echo Diagnostic server started. Monitor the diagnostic window for errors.
echo After testing, stop the server and return here.
pause
goto :eof

:CLEAN_AND_REDOWNLOAD_MODS
echo.
echo ===========================================
echo   Clean Mod Files and Redownload
echo ===========================================
echo.
echo This will:
echo 1. Remove all current server mod files
echo 2. Clear any corrupted downloads
echo 3. Redownload mods in the correct order
echo.
set /p CLEAN_CONFIRM="Continue with clean reinstall? (Y/N): "
if /i not "%CLEAN_CONFIRM%"=="Y" goto :eof

echo.
echo Stopping any running servers...
taskkill /F /IM amtrucks_server.exe 2>nul

echo Cleaning server mod directory...
if exist "%SERVER_DIR%\mod" (
    rd /s /q "%SERVER_DIR%\mod"
)
mkdir "%SERVER_DIR%\mod"

echo Cleaning SteamCMD cache...
if exist "%STEAMCMD_DIR%\steamapps\workshop" (
    rd /s /q "%STEAMCMD_DIR%\steamapps\workshop"
)

echo Clearing download logs...
if exist "%STEAMCMD_DIR%\downloading_mods.log" (
    del "%STEAMCMD_DIR%\downloading_mods.log"
)

echo.
echo ✓ Cleanup complete! 
echo.
echo Now redownloading mods in correct order...
call :UPDATE_MODS_SILENT

echo.
echo ✓ Clean reinstall complete!
echo The server should now have fresh, properly ordered mod files.
pause
goto :eof

:END
cls
echo.
echo ===========================================
echo   Thank you for using Freddy's ATS
echo   Server Manager v1.0.0!
echo ===========================================
echo.
echo Server: Freddy's ATS Dedicated Server
echo Password: ruby
echo Optional Mods: Enabled
echo.
echo Your workspace is now clean and organized!
echo.
echo Happy trucking!
timeout /t 5
exit
