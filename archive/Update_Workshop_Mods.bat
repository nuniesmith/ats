@echo off
:: Steam Workshop Collection Updater for Freddy's ATS Server
:: This script helps sync mods from your Steam Workshop collection

setlocal EnableDelayedExpansion

set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "SERVER_MOD_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server\mod"

echo ===========================================
echo   Steam Workshop Collection Updater
echo ===========================================
echo   Collection: https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316
echo ===========================================
echo.

:: Check if Steam Workshop directory exists
if not exist "%WORKSHOP_DIR%" (
    echo ERROR: Steam Workshop directory not found!
    echo Make sure Steam is installed and you have subscribed to the workshop items.
    echo Expected location: %WORKSHOP_DIR%
    pause
    exit /b 1
)

:: Create server mod directory if it doesn't exist
if not exist "%SERVER_MOD_DIR%" mkdir "%SERVER_MOD_DIR%"

echo Cleaning existing server mods...
del /q "%SERVER_MOD_DIR%\*.*" 2>nul

echo.
echo Available Workshop Items:
echo ========================

:: List all workshop items
for /d %%d in ("%WORKSHOP_DIR%\*") do (
    echo Workshop ID: %%~nxd
    for %%f in ("%%d\*.scs") do (
        echo   Mod file: %%~nxf
    )
    echo.
)

echo.
echo Copying all workshop mods to server...
echo =====================================

set /a COPIED_COUNT=0
for /d %%d in ("%WORKSHOP_DIR%\*") do (
    for %%f in ("%%d\*.scs") do (
        echo Copying: %%~nxf
        copy "%%f" "%SERVER_MOD_DIR%\" >nul 2>&1
        if !errorlevel! equ 0 (
            set /a COPIED_COUNT+=1
        ) else (
            echo   ERROR copying %%~nxf
        )
    )
)

echo.
echo ===========================================
echo   Update Complete!
echo ===========================================
echo   Mods copied: %COPIED_COUNT%
echo.
echo Server mod directory contents:
dir /b "%SERVER_MOD_DIR%\*.scs" 2>nul

echo.
echo NOTE: After updating mods, make sure to:
echo 1. Update your server_config.sii with the new mod list
echo 2. Restart your ATS dedicated server
echo.
echo Press any key to exit...
pause >nul
