@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Steam Package Installer
:: Automated installation of ATS game and dedicated server
:: ===========================================

title ATS Steam Package Installer

set "SCRIPT_DIR=%~dp0"
set "STEAMCMD_DIR=%SCRIPT_DIR%\steamcmd"
set "STEAMCMD_EXE=%STEAMCMD_DIR%\steamcmd.exe"

echo ===========================================
echo   ATS Steam Package Installer
echo ===========================================
echo.

:MAIN_MENU
echo Available packages:
echo.
echo 1. ATS Game (App ID: 270880)
echo 2. ATS Dedicated Server (App ID: 1067230)
echo 3. Both Game and Server
echo 4. Workshop Collection Download
echo 5. Exit
echo.
set /p CHOICE="Select package to install: "

if "%CHOICE%"=="1" goto INSTALL_GAME
if "%CHOICE%"=="2" goto INSTALL_SERVER
if "%CHOICE%"=="3" goto INSTALL_BOTH
if "%CHOICE%"=="4" goto WORKSHOP_DOWNLOAD
if "%CHOICE%"=="5" goto END
goto MAIN_MENU

:INSTALL_GAME
echo.
echo Installing ATS Game...
call :ENSURE_STEAMCMD
if !errorlevel! neq 0 goto END

echo.
echo NOTE: For owned games, you may need to login with your Steam account
echo For free-to-play or demos, anonymous login works
echo.
set /p LOGIN_TYPE="Use anonymous login? (Y/N): "

if /i "%LOGIN_TYPE%"=="Y" (
    "%STEAMCMD_EXE%" +login anonymous +app_update 270880 validate +quit
) else (
    set /p STEAM_USER="Enter Steam username: "
    "%STEAMCMD_EXE%" +login !STEAM_USER! +app_update 270880 validate +quit
)

echo ✓ ATS Game installation completed
pause
goto MAIN_MENU

:INSTALL_SERVER
echo.
echo Installing ATS Dedicated Server...
call :ENSURE_STEAMCMD
if !errorlevel! neq 0 goto END

echo.
echo Installing dedicated server (anonymous login)...
"%STEAMCMD_EXE%" +login anonymous +app_update 1067230 validate +quit

echo ✓ ATS Dedicated Server installation completed
pause
goto MAIN_MENU

:INSTALL_BOTH
echo.
echo Installing both ATS Game and Dedicated Server...
call :ENSURE_STEAMCMD
if !errorlevel! neq 0 goto END

echo.
echo Installing ATS Dedicated Server first (anonymous)...
"%STEAMCMD_EXE%" +login anonymous +app_update 1067230 validate +quit

echo.
echo Installing ATS Game...
set /p LOGIN_TYPE="Use anonymous login for game? (Y/N): "

if /i "%LOGIN_TYPE%"=="Y" (
    "%STEAMCMD_EXE%" +login anonymous +app_update 270880 validate +quit
) else (
    set /p STEAM_USER="Enter Steam username: "
    "%STEAMCMD_EXE%" +login !STEAM_USER! +app_update 270880 validate +quit
)

echo ✓ Both installations completed
pause
goto MAIN_MENU

:WORKSHOP_DOWNLOAD
echo.
echo ===========================================
echo   Workshop Collection Download
echo ===========================================
echo.
echo Collection ID: 3530633316
echo URL: https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316
echo.
echo Opening collection in Steam/Browser...
start "" "https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316"
echo.
echo To download workshop mods:
echo 1. Subscribe to the collection in Steam
echo 2. Launch ATS game to trigger downloads
echo 3. Mods will be downloaded to your workshop folder
echo.
echo Alternative: Use SteamCMD for direct download
set /p USE_CMD="Use SteamCMD for workshop download? (Y/N): "

if /i "%USE_CMD%"=="Y" (
    call :ENSURE_STEAMCMD
    echo.
    echo NOTE: Workshop downloads via SteamCMD require Steam login
    set /p STEAM_USER="Enter Steam username: "
    
    echo Downloading workshop collection...
    "%STEAMCMD_EXE%" +login !STEAM_USER! +workshop_download_item 270880 3530633316 +quit
    
    echo ✓ Workshop collection download completed
)

pause
goto MAIN_MENU

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
echo Installing SteamCMD...

if not exist "%STEAMCMD_DIR%" mkdir "%STEAMCMD_DIR%"

echo Downloading SteamCMD...
powershell -Command "& {try { Invoke-WebRequest -Uri 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile '%STEAMCMD_DIR%\steamcmd.zip' -ErrorAction Stop; Write-Host 'Download completed' } catch { Write-Host 'Download failed:' $_.Exception.Message; exit 1 }}"

if !errorlevel! neq 0 (
    echo ❌ Failed to download SteamCMD
    exit /b 1
)

echo Extracting SteamCMD...
powershell -Command "& {try { Expand-Archive -Path '%STEAMCMD_DIR%\steamcmd.zip' -DestinationPath '%STEAMCMD_DIR%' -Force -ErrorAction Stop; Write-Host 'Extraction completed' } catch { Write-Host 'Extraction failed:' $_.Exception.Message; exit 1 }}"

if !errorlevel! neq 0 (
    echo ❌ Failed to extract SteamCMD
    exit /b 1
)

echo Initializing SteamCMD...
"%STEAMCMD_EXE%" +quit

if !errorlevel! equ 0 (
    echo ✓ SteamCMD installed and initialized successfully
    exit /b 0
) else (
    echo ❌ SteamCMD initialization failed
    exit /b 1
)

:END
echo.
echo Steam package installer completed.
pause
