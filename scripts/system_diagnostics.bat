@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS System Diagnostics
:: Comprehensive system check for ATS setup
:: ===========================================

title ATS System Diagnostics

set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%.."

echo ===========================================
echo   ATS System Diagnostics v1.0
echo ===========================================
echo   Checking your ATS setup for issues...
echo ===========================================
echo.

:: Load environment
if exist "%SCRIPT_DIR%\load_env.bat" (
    echo Loading environment configuration...
    call "%SCRIPT_DIR%\load_env.bat"
    echo ✓ Environment loaded
) else (
    echo ⚠️ Environment loader not found, using defaults
    set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
    set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
    set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
    set "STEAM_EXE=C:\Program Files (x86)\Steam\steam.exe"
)

echo.
echo ===========================================
echo   1. DIRECTORY STRUCTURE CHECK
echo ===========================================
echo.

set /a PASSED_CHECKS=0
set /a TOTAL_CHECKS=0

:: Check script directory
set /a TOTAL_CHECKS+=1
echo Checking script directory...
if exist "%SCRIPT_DIR%" (
    echo ✓ Script directory: %SCRIPT_DIR%
    set /a PASSED_CHECKS+=1
) else (
    echo ❌ Script directory not found: %SCRIPT_DIR%
)

:: Check base directory
set /a TOTAL_CHECKS+=1
echo Checking base directory...
if exist "%BASE_DIR%" (
    echo ✓ Base directory: %BASE_DIR%
    set /a PASSED_CHECKS+=1
) else (
    echo ❌ Base directory not found: %BASE_DIR%
)

:: Check ATS game directory
set /a TOTAL_CHECKS+=1
echo Checking ATS game directory...
if exist "%GAME_DIR%" (
    echo ✓ Game directory: %GAME_DIR%
    set /a PASSED_CHECKS+=1
    
    :: Check game executable
    if exist "%GAME_DIR%\bin\win_x64\amtrucks.exe" (
        echo ✓ Game executable found
    ) else (
        echo ⚠️ Game executable not found
    )
) else (
    echo ❌ Game directory not found: %GAME_DIR%
)

:: Check ATS server directory
set /a TOTAL_CHECKS+=1
echo Checking ATS dedicated server directory...
if exist "%SERVER_DIR%" (
    echo ✓ Server directory: %SERVER_DIR%
    set /a PASSED_CHECKS+=1
    
    :: Check server executable
    if exist "%SERVER_DIR%\bin\win_x64\amtrucks_server.exe" (
        echo ✓ Server executable found
    ) else (
        echo ⚠️ Server executable not found
    )
) else (
    echo ❌ Server directory not found: %SERVER_DIR%
)

:: Check workshop directory
set /a TOTAL_CHECKS+=1
echo Checking Steam workshop directory...
if exist "%WORKSHOP_DIR%" (
    echo ✓ Workshop directory: %WORKSHOP_DIR%
    set /a PASSED_CHECKS+=1
    
    :: Count workshop items
    set /a MOD_COUNT=0
    for /d %%d in ("%WORKSHOP_DIR%\*") do set /a MOD_COUNT+=1
    echo ℹ Workshop mods found: !MOD_COUNT!
) else (
    echo ❌ Workshop directory not found: %WORKSHOP_DIR%
)

:: Check Steam executable
set /a TOTAL_CHECKS+=1
echo Checking Steam installation...
if exist "%STEAM_EXE%" (
    echo ✓ Steam executable: %STEAM_EXE%
    set /a PASSED_CHECKS+=1
) else (
    echo ❌ Steam executable not found: %STEAM_EXE%
)

echo.
echo ===========================================
echo   2. CONFIGURATION FILES CHECK
echo ===========================================
echo.

:: Check environment file
if exist "%BASE_DIR%\.env" (
    echo ✓ Environment file found: %BASE_DIR%\.env
    echo ℹ Last modified: 
    forfiles /p "%BASE_DIR%" /m ".env" /c "cmd /c echo @fdate @ftime" 2>nul || echo Unknown
) else (
    echo ⚠️ Environment file not found: %BASE_DIR%\.env
    echo ℹ Using default configuration
)

:: Check server config
if exist "%SERVER_DIR%\server_config.sii" (
    echo ✓ Server config found: %SERVER_DIR%\server_config.sii
) else (
    echo ⚠️ Server config not found (will be generated on first run)
)

:: Check server packages
if exist "%SERVER_DIR%\server_packages.sii" (
    echo ✓ Server packages config found
) else (
    echo ⚠️ Server packages config not found
)

if exist "%SERVER_DIR%\server_packages.dat" (
    echo ✓ Server packages data found
) else (
    echo ⚠️ Server packages data not found
)

echo.
echo ===========================================
echo   3. PROCESS STATUS CHECK
echo ===========================================
echo.

:: Check for running processes
echo Checking for running ATS processes...
tasklist /FI "IMAGENAME eq amtrucks.exe" 2>NUL | find /I "amtrucks.exe" >nul && (
    echo ✓ ATS Game is currently RUNNING
    tasklist /FI "IMAGENAME eq amtrucks.exe" | findstr amtrucks.exe
) || (
    echo ℹ ATS Game is not running
)

tasklist /FI "IMAGENAME eq amtrucks_server.exe" 2>NUL | find /I "amtrucks_server.exe" >nul && (
    echo ✓ ATS Dedicated Server is currently RUNNING
    tasklist /FI "IMAGENAME eq amtrucks_server.exe" | findstr amtrucks_server.exe
) || (
    echo ℹ ATS Dedicated Server is not running
)

tasklist /FI "IMAGENAME eq steam.exe" 2>NUL | find /I "steam.exe" >nul && (
    echo ✓ Steam is currently RUNNING
) || (
    echo ⚠️ Steam is not running
)

tasklist /FI "IMAGENAME eq steamcmd.exe" 2>NUL | find /I "steamcmd.exe" >nul && (
    echo ✓ SteamCMD is currently RUNNING
) || (
    echo ℹ SteamCMD is not running
)

echo.
echo ===========================================
echo   4. STEAMCMD CHECK
echo ===========================================
echo.

set "STEAMCMD_DIR=%SCRIPT_DIR%\steamcmd"
set "STEAMCMD_EXE=%STEAMCMD_DIR%\steamcmd.exe"

if exist "%STEAMCMD_EXE%" (
    echo ✓ SteamCMD installed: %STEAMCMD_EXE%
    
    :: Check SteamCMD version/status
    echo ℹ Testing SteamCMD functionality...
    "%STEAMCMD_EXE%" +quit >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✓ SteamCMD is functional
    ) else (
        echo ⚠️ SteamCMD may have issues
    )
) else (
    echo ❌ SteamCMD not installed
    echo ℹ Use main launcher option B to install SteamCMD
)

echo.
echo ===========================================
echo   5. NETWORK CONNECTIVITY CHECK
echo ===========================================
echo.

echo Checking internet connectivity...
ping -n 1 8.8.8.8 >nul 2>&1 && (
    echo ✓ Internet connection active
) || (
    echo ❌ No internet connection detected
)

echo Checking Steam connectivity...
ping -n 1 steamcommunity.com >nul 2>&1 && (
    echo ✓ Steam services reachable
) || (
    echo ❌ Cannot reach Steam services
)

echo.
echo ===========================================
echo   6. PERMISSIONS CHECK
echo ===========================================
echo.

echo Checking write permissions...

:: Check if we can write to server directory
if exist "%SERVER_DIR%" (
    echo test > "%SERVER_DIR%\write_test.tmp" 2>nul && (
        echo ✓ Server directory is writable
        del "%SERVER_DIR%\write_test.tmp" 2>nul
    ) || (
        echo ❌ Server directory is not writable (may need admin rights)
    )
)

:: Check if we can write to workshop directory
if exist "%WORKSHOP_DIR%" (
    echo test > "%WORKSHOP_DIR%\write_test.tmp" 2>nul && (
        echo ✓ Workshop directory is writable
        del "%WORKSHOP_DIR%\write_test.tmp" 2>nul
    ) || (
        echo ❌ Workshop directory is not writable
    )
)

:: Check if we can write to script directory
echo test > "%SCRIPT_DIR%\write_test.tmp" 2>nul && (
    echo ✓ Script directory is writable
    del "%SCRIPT_DIR%\write_test.tmp" 2>nul
) || (
    echo ❌ Script directory is not writable
)

echo.
echo ===========================================
echo   7. SYSTEM REQUIREMENTS CHECK
echo ===========================================
echo.

echo Checking system requirements...

:: Check Windows version
for /f "tokens=4-7 delims=[.] " %%i in ('ver') do (
    if %%i==Version (
        echo ℹ Windows Version: %%j.%%k.%%l
        if %%j geq 10 (
            echo ✓ Windows version supported
        ) else (
            echo ⚠️ Windows version may be too old
        )
    )
)

:: Check available disk space
echo.
echo Checking disk space...
for /f "skip=1 tokens=3" %%a in ('wmic logicaldisk where caption^="C:" get size /value') do (
    for /f "skip=1 tokens=3" %%b in ('wmic logicaldisk where caption^="C:" get freespace /value') do (
        set /a FREE_GB=%%b/1024/1024/1024 2>nul
        if !FREE_GB! gtr 50 (
            echo ✓ Available disk space: !FREE_GB! GB
        ) else (
            echo ⚠️ Low disk space: !FREE_GB! GB
        )
        goto :disk_done
    )
)
:disk_done

echo.
echo ===========================================
echo   DIAGNOSTIC SUMMARY
echo ===========================================
echo.

set /a SUCCESS_RATE=!PASSED_CHECKS!*100/!TOTAL_CHECKS!

echo Directory Structure: !PASSED_CHECKS!/!TOTAL_CHECKS! checks passed (!SUCCESS_RATE!%%)
echo.

if !SUCCESS_RATE! geq 80 (
    echo 🎉 EXCELLENT - Your ATS setup looks great!
    echo ✓ Most components are properly configured
    echo ℹ You should be able to run servers and games without issues
) else if !SUCCESS_RATE! geq 60 (
    echo ⚠️ GOOD - Your setup is mostly working
    echo ℹ Some components may need attention
    echo ℹ Check the items marked with ❌ above
) else if !SUCCESS_RATE! geq 40 (
    echo 🔧 NEEDS WORK - Several issues detected
    echo ⚠️ You may experience problems running ATS
    echo ℹ Consider reinstalling missing components
) else (
    echo 🚨 POOR - Major setup issues detected
    echo ❌ Your ATS setup needs significant attention
    echo ℹ Consider fresh installation of game/server
)

echo.
echo RECOMMENDATIONS:
if not exist "%STEAM_EXE%" echo • Install Steam from https://store.steampowered.com/
if not exist "%GAME_DIR%" echo • Install ATS game via Steam or use main launcher option 8
if not exist "%SERVER_DIR%" echo • Install ATS Dedicated Server via main launcher option 9
if not exist "%STEAMCMD_EXE%" echo • Install SteamCMD via main launcher option B
if not exist "%BASE_DIR%\.env" echo • Create environment configuration via main launcher option C

echo.
echo For additional help:
echo • Use main launcher option F for documentation
echo • Check /docs folder for detailed guides
echo • Report persistent issues on GitHub
echo.
pause
