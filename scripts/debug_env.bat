@echo off
setlocal EnableDelayedExpansion

echo ===========================================
echo   Environment Debug Test
echo ===========================================

set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%."
set "ENV_FILE=%BASE_DIR%\.env"

echo Loading environment from: %ENV_FILE%
echo.

if exist "%ENV_FILE%" (
    echo ✓ Found .env file
    
    for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%ENV_FILE%") do (
        if not "%%a"=="" (
            echo Loading: %%a=%%b
            set "%%a=%%b"
        )
    )
    
    echo.
    echo ✓ Environment loaded
    echo.
    echo Testing key variables:
    echo SERVER_DIR=!SERVER_DIR!
    echo GAME_DIR=!GAME_DIR!
    echo WORKSHOP_DIR=!WORKSHOP_DIR!
    
    echo.
    echo Testing if exist with SERVER_DIR...
    if exist "!SERVER_DIR!" (
        echo ✓ SERVER_DIR path exists
    ) else (
        echo ❌ SERVER_DIR path does not exist or has issues
    )
    
    echo.
    echo Testing mkdir...
    if not exist "!SERVER_DIR!\mod" (
        echo Creating mod directory...
        mkdir "!SERVER_DIR!\mod"
        if !errorlevel! equ 0 (
            echo ✓ Mod directory created successfully
        ) else (
            echo ❌ Failed to create mod directory
        )
    ) else (
        echo ✓ Mod directory already exists
    )
    
) else (
    echo ❌ .env file not found
)

echo.
echo Press any key to continue...
pause >nul
