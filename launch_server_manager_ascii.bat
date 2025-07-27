@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: Freddy's ATS Complete Server Manager Launcher (ASCII Version)
:: Unified management for ATS game, dedicated server, and Steam packages
:: ===========================================

title Freddy's ATS Complete Manager

:: Configuration
set "SCRIPT_DIR=%~dp0scripts"
set "BASE_DIR=%~dp0"
set "MANAGER_SCRIPT=%SCRIPT_DIR%\ats_server_manager.bat"
set "ENV_SCRIPT=%SCRIPT_DIR%\load_env.bat"
set "STEAMCMD_DIR=%SCRIPT_DIR%\steamcmd"
set "STEAMCMD_EXE=%STEAMCMD_DIR%\steamcmd.exe"

:: Load environment if available
if exist "%ENV_SCRIPT%" (
    call "%ENV_SCRIPT%"
) else (
    :: Fallback defaults
    set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
    set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
    set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
    set "STEAM_EXE=C:\Program Files (x86)\Steam\steam.exe"
)

:MAIN_MENU
cls
echo ===============================================
echo     Freddy's ATS Complete Manager v2.0
echo ===============================================
echo     Unified management for everything ATS
echo ===============================================
echo.
echo [GAME MANAGEMENT]
echo   1. Launch ATS Game
echo   2. Launch ATS with Mods
echo   3. Launch Steam (ATS Library)
echo.
echo [SERVER MANAGEMENT]
echo   4. Start Dedicated Server (Quick)
echo   5. Advanced Server Manager
echo   6. Check Server Status
echo   7. Stop All Servers
echo.
echo [STEAM PACKAGE MANAGEMENT]
echo   8. Install/Update ATS Game
echo   9. Install/Update Dedicated Server
echo   A. Download Workshop Collection
echo   B. Manage SteamCMD
echo.
echo [UTILITIES]
echo   C. Environment Configuration
echo   D. Create Desktop Shortcuts
echo   E. System Diagnostics
echo   F. Help and Documentation
echo.
echo   0. Exit
echo.
set /p CHOICE="Select option: "

if "%CHOICE%"=="1" goto LAUNCH_GAME
if "%CHOICE%"=="2" goto LAUNCH_GAME_MODS
if "%CHOICE%"=="3" goto LAUNCH_STEAM
if "%CHOICE%"=="4" goto QUICK_SERVER
if "%CHOICE%"=="5" goto ADVANCED_MANAGER
if "%CHOICE%"=="6" goto CHECK_STATUS
if "%CHOICE%"=="7" goto STOP_SERVERS
if "%CHOICE%"=="8" goto INSTALL_GAME
if "%CHOICE%"=="9" goto INSTALL_SERVER
if /i "%CHOICE%"=="A" goto DOWNLOAD_COLLECTION
if /i "%CHOICE%"=="B" goto MANAGE_STEAMCMD
if /i "%CHOICE%"=="C" goto ENV_CONFIG
if /i "%CHOICE%"=="D" goto CREATE_SHORTCUTS
if /i "%CHOICE%"=="E" goto DIAGNOSTICS
if /i "%CHOICE%"=="F" goto HELP
if "%CHOICE%"=="0" goto END
goto MAIN_MENU

:LAUNCH_GAME
echo.
echo ===========================================
echo   Launching ATS Game
echo ===========================================
echo.
if exist "%GAME_DIR%\bin\win_x64\amtrucks.exe" (
    echo Starting American Truck Simulator...
    start "" "%GAME_DIR%\bin\win_x64\amtrucks.exe"
    echo * Game launched successfully
) else if exist "%STEAM_EXE%" (
    echo Game not found, launching via Steam...
    start "" "%STEAM_EXE%" -applaunch 270880
    echo * Game launched via Steam
) else (
    echo ! Game not found and Steam not available
    echo Please install ATS or check paths
)
pause
goto MAIN_MENU

:LAUNCH_GAME_MODS
echo.
echo ===========================================
echo   Launching ATS Game with Mods
echo ===========================================
echo.
if exist "%STEAM_EXE%" (
    echo Opening Steam Workshop for ATS...
    start "" "%STEAM_EXE%" -url steam://url/CommunityFilePage/270880
    timeout /t 3 >nul
    echo.
    echo Now launching ATS game...
    start "" "%STEAM_EXE%" -applaunch 270880
    echo * Game with workshop access launched
) else (
    echo ! Steam not found, cannot launch with mod support
)
pause
goto MAIN_MENU

:LAUNCH_STEAM
echo.
echo ===========================================
echo   Launching Steam (ATS Library)
echo ===========================================
echo.
if exist "%STEAM_EXE%" (
    echo Opening Steam ATS library page...
    start "" "%STEAM_EXE%" -url steam://nav/games/details/270880
    echo * Steam launched to ATS page
) else (
    echo ! Steam not found at expected location
    echo Please check Steam installation
)
pause
goto MAIN_MENU

:QUICK_SERVER
echo.
echo ===========================================
echo   Quick Server Start
echo ===========================================
echo.
if exist "%SCRIPT_DIR%\start_ats_dedicated_server.bat" (
    echo Launching dedicated server with quick settings...
    call "%SCRIPT_DIR%\start_ats_dedicated_server.bat"
) else (
    echo ! Quick server script not found
    echo Falling back to advanced manager...
    goto ADVANCED_MANAGER
)
goto MAIN_MENU

:ADVANCED_MANAGER
echo.
echo ===========================================
echo   Advanced Server Manager
echo ===========================================
echo.
if exist "%MANAGER_SCRIPT%" (
    echo Launching comprehensive server manager...
    call "%MANAGER_SCRIPT%" %*
) else (
    echo ! Advanced manager script not found!
    echo Expected: %MANAGER_SCRIPT%
    pause
)
goto MAIN_MENU

:CHECK_STATUS
echo.
echo ===========================================
echo   Server Status Check
echo ===========================================
echo.
echo Checking for running ATS processes...
echo.

tasklist /FI "IMAGENAME eq amtrucks_server.exe" 2>NUL | find /I /N "amtrucks_server.exe" >nul && (
    echo * ATS Dedicated Server is RUNNING
    tasklist /FI "IMAGENAME eq amtrucks_server.exe" | findstr amtrucks_server.exe
) || (
    echo ! ATS Dedicated Server is NOT running
)

echo.
tasklist /FI "IMAGENAME eq amtrucks.exe" 2>NUL | find /I /N "amtrucks.exe" >nul && (
    echo * ATS Game Client is RUNNING
    tasklist /FI "IMAGENAME eq amtrucks.exe" | findstr amtrucks.exe
) || (
    echo ! ATS Game Client is NOT running
)

echo.
tasklist /FI "IMAGENAME eq steam.exe" 2>NUL | find /I /N "steam.exe" >nul && (
    echo * Steam is RUNNING
) || (
    echo ! Steam is NOT running
)

echo.
if exist "%TEMP%\ats_server_id.txt" (
    echo Server Session Information:
    echo ============================
    type "%TEMP%\ats_server_id.txt"
)

pause
goto MAIN_MENU

:STOP_SERVERS
echo.
echo ===========================================
echo   Stopping All Servers
echo ===========================================
echo.
echo Stopping ATS dedicated servers...
taskkill /F /IM amtrucks_server.exe 2>nul && echo * Dedicated server stopped || echo i No dedicated server running

echo Stopping ATS game clients...
taskkill /F /IM amtrucks.exe 2>nul && echo * Game client stopped || echo i No game client running

echo.
echo All ATS processes stopped
pause
goto MAIN_MENU

:INSTALL_GAME
echo.
echo ===========================================
echo   Install/Update ATS Game
echo ===========================================
echo.
call :ENSURE_STEAMCMD
if !errorlevel! neq 0 goto MAIN_MENU

echo Installing/Updating American Truck Simulator...
echo.
echo This will download/update ATS game files
echo Steam login may be required for owned games
echo.
set /p CONTINUE="Continue? (Y/N): "
if /i not "%CONTINUE%"=="Y" goto MAIN_MENU

echo.
echo Launching SteamCMD for ATS game installation...
"%STEAMCMD_EXE%" +login anonymous +app_update 270880 validate +quit

if !errorlevel! equ 0 (
    echo * ATS Game installation/update completed
) else (
    echo ! Installation failed - Error code: !errorlevel!
    echo You may need to login with your Steam account for owned games
)

pause
goto MAIN_MENU

:INSTALL_SERVER
echo.
echo ===========================================
echo   Install/Update ATS Dedicated Server
echo ===========================================
echo.
call :ENSURE_STEAMCMD
if !errorlevel! neq 0 goto MAIN_MENU

echo Installing/Updating ATS Dedicated Server...
echo.
echo This will download/update dedicated server files
echo No Steam login required (free download)
echo.
set /p CONTINUE="Continue? (Y/N): "
if /i not "%CONTINUE%"=="Y" goto MAIN_MENU

echo.
echo Launching SteamCMD for dedicated server installation...
"%STEAMCMD_EXE%" +login anonymous +app_update 1067230 validate +quit

if !errorlevel! equ 0 (
    echo * ATS Dedicated Server installation/update completed
    echo.
    echo Server installed to: %SERVER_DIR%
) else (
    echo ! Installation failed - Error code: !errorlevel!
)

pause
goto MAIN_MENU

:DOWNLOAD_COLLECTION
echo.
echo ===========================================
echo   Download Workshop Collection
echo ===========================================
echo.
if exist "%SCRIPT_DIR%\mod_collection_utility.bat" (
    echo Launching mod collection utility...
    call "%SCRIPT_DIR%\mod_collection_utility.bat"
) else (
    echo Manual workshop collection download...
    echo.
    echo Collection ID: 3530633316
    echo URL: https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316
    echo.
    echo Opening collection in browser...
    start "" "https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316"
    
    echo.
    echo To download mods:
    echo 1. Subscribe to the collection in Steam
    echo 2. Launch ATS game to download mods
    echo 3. Mods will be in: %WORKSHOP_DIR%
)
pause
goto MAIN_MENU

:MANAGE_STEAMCMD
echo.
echo ===========================================
echo   SteamCMD Management
echo ===========================================
echo.
echo Current SteamCMD Status:
if exist "%STEAMCMD_EXE%" (
    echo * SteamCMD is installed at: %STEAMCMD_DIR%
    echo.
    echo 1. Launch SteamCMD Console
    echo 2. Update SteamCMD
    echo 3. Reinstall SteamCMD
    echo 4. Remove SteamCMD
    echo 5. Back to main menu
    echo.
    set /p STEAM_CHOICE="Select option: "
    
    if "!STEAM_CHOICE!"=="1" (
        echo Launching SteamCMD console...
        "%STEAMCMD_EXE%"
    ) else if "!STEAM_CHOICE!"=="2" (
        echo Updating SteamCMD...
        "%STEAMCMD_EXE%" +quit
    ) else if "!STEAM_CHOICE!"=="3" (
        call :INSTALL_STEAMCMD force
    ) else if "!STEAM_CHOICE!"=="4" (
        set /p CONFIRM="Are you sure you want to remove SteamCMD? (Y/N): "
        if /i "!CONFIRM!"=="Y" (
            rmdir /s /q "%STEAMCMD_DIR%" 2>nul
            echo * SteamCMD removed
        )
    )
) else (
    echo ! SteamCMD not installed
    echo.
    echo Would you like to install SteamCMD now?
    set /p INSTALL_CHOICE="Install SteamCMD? (Y/N): "
    if /i "!INSTALL_CHOICE!"=="Y" call :INSTALL_STEAMCMD
)
pause
goto MAIN_MENU

:ENV_CONFIG
echo.
echo ===========================================
echo   Environment Configuration
echo ===========================================
echo.
if exist "%SCRIPT_DIR%\env_manager.bat" (
    echo Launching environment configuration manager...
    call "%SCRIPT_DIR%\env_manager.bat"
) else (
    echo Opening environment file for editing...
    if exist "%BASE_DIR%\.env" (
        start notepad "%BASE_DIR%\.env"
    ) else (
        echo ! Environment file not found
        echo Creating default .env file...
        call :CREATE_DEFAULT_ENV
        if exist "%BASE_DIR%\.env" start notepad "%BASE_DIR%\.env"
    )
)
pause
goto MAIN_MENU

:CREATE_SHORTCUTS
echo.
echo ===========================================
echo   Create Desktop Shortcuts
echo ===========================================
echo.
if exist "%SCRIPT_DIR%\create_desktop_shortcuts.bat" (
    echo Launching desktop shortcut creator...
    call "%SCRIPT_DIR%\create_desktop_shortcuts.bat"
) else (
    echo Creating basic desktop shortcuts...
    set "DESKTOP=%USERPROFILE%\Desktop"
    set "LAUNCHER_PATH=%~f0"
    
    echo Creating main launcher shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\ATS Complete Manager.lnk'); $Shortcut.TargetPath = '%LAUNCHER_PATH%'; $Shortcut.WorkingDirectory = '%BASE_DIR%'; $Shortcut.Description = 'Freddy''s ATS Complete Manager'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo * ATS Complete Manager shortcut created
    ) else (
        echo ! Failed to create shortcut
    )
    
    pause
)
goto MAIN_MENU

:DIAGNOSTICS
echo.
echo ===========================================
echo   System Diagnostics
echo ===========================================
echo.
if exist "%SCRIPT_DIR%\system_diagnostics.bat" (
    echo Running comprehensive system diagnostics...
    call "%SCRIPT_DIR%\system_diagnostics.bat"
) else (
    echo Running basic diagnostics...
    echo.
    echo Checking paths...
    echo.
    echo Game Directory: %GAME_DIR%
    if exist "%GAME_DIR%" (echo * Exists) else (echo ! Not found)
    
    echo Server Directory: %SERVER_DIR%
    if exist "%SERVER_DIR%" (echo * Exists) else (echo ! Not found)
    
    echo Workshop Directory: %WORKSHOP_DIR%
    if exist "%WORKSHOP_DIR%" (echo * Exists) else (echo ! Not found)
    
    echo Steam Executable: %STEAM_EXE%
    if exist "%STEAM_EXE%" (echo * Exists) else (echo ! Not found)
    
    echo SteamCMD: %STEAMCMD_EXE%
    if exist "%STEAMCMD_EXE%" (echo * Exists) else (echo ! Not found)
    
    pause
)
goto MAIN_MENU

:HELP
echo.
echo ===========================================
echo   Help and Documentation
echo ===========================================
echo.
echo FREDDY'S ATS COMPLETE MANAGER
echo =============================
echo.
echo This launcher provides unified management for:
echo - American Truck Simulator game
echo - ATS Dedicated Server
echo - Steam Workshop mods
echo - SteamCMD package management
echo.
echo KEY FEATURES:
echo - One-click game and server launching
echo - Automatic Steam package installation
echo - Workshop collection management
echo - Desktop shortcut creation
echo - Environment configuration
echo - System diagnostics
echo.
echo GETTING STARTED:
echo 1. Use option 8-9 to install ATS game/server if needed
echo 2. Use option A to download workshop mods
echo 3. Use option D to create desktop shortcuts
echo 4. Use option 1-7 for daily game/server management
echo.
echo REQUIREMENTS:
echo - Windows 10/11
echo - Steam (for game launching and mods)
echo - Internet connection (for downloads)
echo.
echo SUPPORT:
echo - Check environment with option E
echo - View documentation in /docs folder
echo - Report issues on GitHub
echo.
pause
goto MAIN_MENU

:: ===========================================
:: UTILITY FUNCTIONS
:: ===========================================

:ENSURE_STEAMCMD
if exist "%STEAMCMD_EXE%" (
    exit /b 0
) else (
    echo SteamCMD not found. Installing...
    call :INSTALL_STEAMCMD
    exit /b !errorlevel!
)

:INSTALL_STEAMCMD
echo.
echo ===========================================
echo   Installing SteamCMD
echo ===========================================
echo.

if not exist "%STEAMCMD_DIR%" mkdir "%STEAMCMD_DIR%"

:: Check if we have the zip file
if exist "%STEAMCMD_DIR%\steamcmd.zip" (
    echo Found existing SteamCMD zip file
) else (
    echo Downloading SteamCMD...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile '%STEAMCMD_DIR%\steamcmd.zip'}"
    
    if !errorlevel! neq 0 (
        echo ! Failed to download SteamCMD
        exit /b 1
    )
)

echo Extracting SteamCMD...
powershell -Command "& {Expand-Archive -Path '%STEAMCMD_DIR%\steamcmd.zip' -DestinationPath '%STEAMCMD_DIR%' -Force}"

if !errorlevel! neq 0 (
    echo ! Failed to extract SteamCMD
    exit /b 1
)

echo Initializing SteamCMD...
"%STEAMCMD_EXE%" +quit

if !errorlevel! equ 0 (
    echo * SteamCMD installed successfully
    exit /b 0
) else (
    echo ! SteamCMD initialization failed
    exit /b 1
)

:CREATE_DEFAULT_ENV
echo Creating default environment configuration...
(
echo # ATS Complete Manager Configuration
echo # Modify these paths as needed for your system
echo.
echo # Game Paths
echo GAME_DIR=C:\Program Files ^(x86^)\Steam\steamapps\common\American Truck Simulator
echo SERVER_DIR=C:\Program Files ^(x86^)\Steam\steamapps\common\American Truck Simulator Dedicated Server
echo WORKSHOP_DIR=C:\Program Files ^(x86^)\Steam\steamapps\workshop\content\270880
echo.
echo # Steam Configuration
echo STEAM_EXE=C:\Program Files ^(x86^)\Steam\steam.exe
echo.
echo # Server Configuration
echo SERVER_NAME=Freddy's ATS Dedicated Server
echo SERVER_PASSWORD=ruby
echo COLLECTION_ID=3530633316
) > "%BASE_DIR%\.env"
goto :eof

:END
echo.
echo Thank you for using Freddy's ATS Complete Manager!
echo.
pause
