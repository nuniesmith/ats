@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Environment Configuration Manager
:: Manage .env settings easily
:: ===========================================

title ATS Environment Configuration Manager

set "ENV_FILE=%~dp0..\env"
set "BACKUP_DIR=%~dp0..\env_backups"

:MAIN_MENU
cls
echo ===========================================
echo   ATS Environment Configuration Manager
echo ===========================================
echo   Config File: %ENV_FILE%
echo ===========================================
echo.
echo 1. View Current Configuration
echo 2. Edit Configuration (Notepad)
echo 3. Backup Current Configuration
echo 4. Restore from Backup
echo 5. Reset to Defaults
echo 6. Validate Configuration
echo 7. Quick Settings Wizard
echo 8. Export Configuration
echo 9. Import Configuration
echo A. Advanced Editor
echo 0. Exit
echo.
set /p CHOICE="Select option: "

if "%CHOICE%"=="1" goto VIEW_CONFIG
if "%CHOICE%"=="2" goto EDIT_CONFIG
if "%CHOICE%"=="3" goto BACKUP_CONFIG
if "%CHOICE%"=="4" goto RESTORE_CONFIG
if "%CHOICE%"=="5" goto RESET_CONFIG
if "%CHOICE%"=="6" goto VALIDATE_CONFIG
if "%CHOICE%"=="7" goto QUICK_WIZARD
if "%CHOICE%"=="8" goto EXPORT_CONFIG
if "%CHOICE%"=="9" goto IMPORT_CONFIG
if /i "%CHOICE%"=="A" goto ADVANCED_EDITOR
if "%CHOICE%"=="0" goto END
goto MAIN_MENU

:VIEW_CONFIG
cls
echo ===========================================
echo   Current Configuration
echo ===========================================
echo.

if exist "%ENV_FILE%" (
    :: Load and display environment variables
    call "%~dp0load_env.bat" "%ENV_FILE%"
    echo.
    echo === SERVER IDENTITY ===
    echo Name: %SERVER_NAME%
    echo Description: %SERVER_DESCRIPTION%
    echo Password: %SERVER_PASSWORD%
    echo.
    echo === CONNECTION ===
    echo Server ID: %DEFAULT_SERVER_ID%
    echo Token: %SERVER_TOKEN%
    echo Ports: %CONNECTION_DEDICATED_PORT%/%QUERY_DEDICATED_PORT%
    echo.
    echo === CAPACITY ===
    echo Max Players: %MAX_PLAYERS%
    echo Max Vehicles: %MAX_VEHICLES_TOTAL%
    echo.
    echo === MODS ===
    echo Collection ID: %COLLECTION_ID%
    echo Mods Optioning: %MODS_OPTIONING%
    echo Auto Update: %AUTO_UPDATE_MODS%
    echo.
    echo === PATHS ===
    echo Server: %SERVER_DIR%
    echo Game: %GAME_DIR%
    echo Workshop: %WORKSHOP_DIR%
    echo.
    echo === SCRIPT INFO ===
    echo Version: %SCRIPT_VERSION%
    echo Last Updated: %LAST_UPDATED%
) else (
    echo ❌ Configuration file not found: %ENV_FILE%
    echo Run option 5 to create default configuration.
)

echo.
pause
goto MAIN_MENU

:EDIT_CONFIG
echo.
if not exist "%ENV_FILE%" (
    echo Configuration file not found. Creating default...
    call :CREATE_DEFAULT_CONFIG
)

echo Opening configuration in Notepad...
start /wait notepad.exe "%ENV_FILE%"
echo Configuration editing complete.
pause
goto MAIN_MENU

:BACKUP_CONFIG
echo.
if not exist "%ENV_FILE%" (
    echo ❌ No configuration file to backup
    pause
    goto MAIN_MENU
)

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

set "BACKUP_NAME=env_backup_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "BACKUP_NAME=%BACKUP_NAME: =0%"
set "BACKUP_FILE=%BACKUP_DIR%\%BACKUP_NAME%.env"

copy "%ENV_FILE%" "%BACKUP_FILE%" >nul
echo ✓ Configuration backed up to: %BACKUP_FILE%
pause
goto MAIN_MENU

:RESTORE_CONFIG
echo.
echo Available backups:
echo ==================
if exist "%BACKUP_DIR%\*.env" (
    set /a BACKUP_COUNT=0
    for %%f in ("%BACKUP_DIR%\*.env") do (
        set /a BACKUP_COUNT+=1
        echo !BACKUP_COUNT!. %%~nf
        set "BACKUP_!BACKUP_COUNT!=%%f"
    )
    
    echo.
    set /p RESTORE_CHOICE="Select backup to restore (0 to cancel): "
    
    if "!RESTORE_CHOICE!"=="0" goto MAIN_MENU
    
    if defined BACKUP_!RESTORE_CHOICE! (
        copy "!BACKUP_%RESTORE_CHOICE%!" "%ENV_FILE%" >nul
        echo ✓ Configuration restored from backup
    ) else (
        echo ❌ Invalid selection
    )
) else (
    echo No backups found in %BACKUP_DIR%
)

pause
goto MAIN_MENU

:RESET_CONFIG
echo.
echo This will reset configuration to defaults.
echo Current configuration will be backed up first.
echo.
set /p RESET_CONFIRM="Continue? (Y/N): "
if /i not "%RESET_CONFIRM%"=="Y" goto MAIN_MENU

if exist "%ENV_FILE%" call :BACKUP_CONFIG
call :CREATE_DEFAULT_CONFIG
echo ✓ Configuration reset to defaults
pause
goto MAIN_MENU

:VALIDATE_CONFIG
cls
echo ===========================================
echo   Configuration Validation
echo ===========================================
echo.

if not exist "%ENV_FILE%" (
    echo ❌ Configuration file not found
    pause
    goto MAIN_MENU
)

echo Validating configuration...
echo.

:: Load environment
call "%~dp0load_env.bat" "%ENV_FILE%"

set /a ERROR_COUNT=0

:: Validate required fields
if "%SERVER_NAME%"=="" (
    echo ❌ SERVER_NAME is not set
    set /a ERROR_COUNT+=1
) else (
    echo ✓ SERVER_NAME: %SERVER_NAME%
)

if "%SERVER_PASSWORD%"=="" (
    echo ❌ SERVER_PASSWORD is not set
    set /a ERROR_COUNT+=1
) else (
    echo ✓ SERVER_PASSWORD: %SERVER_PASSWORD%
)

if "%DEFAULT_SERVER_ID%"=="" (
    echo ❌ DEFAULT_SERVER_ID is not set
    set /a ERROR_COUNT+=1
) else (
    echo ✓ DEFAULT_SERVER_ID: %DEFAULT_SERVER_ID%
)

if "%SERVER_TOKEN%"=="" (
    echo ❌ SERVER_TOKEN is not set
    set /a ERROR_COUNT+=1
) else (
    echo ✓ SERVER_TOKEN: %SERVER_TOKEN%
)

if "%COLLECTION_ID%"=="" (
    echo ❌ COLLECTION_ID is not set
    set /a ERROR_COUNT+=1
) else (
    echo ✓ COLLECTION_ID: %COLLECTION_ID%
)

:: Validate paths
if exist "%SERVER_DIR%" (
    echo ✓ SERVER_DIR: %SERVER_DIR%
) else (
    echo ⚠️  SERVER_DIR not found: %SERVER_DIR%
)

if exist "%GAME_DIR%" (
    echo ✓ GAME_DIR: %GAME_DIR%
) else (
    echo ⚠️  GAME_DIR not found: %GAME_DIR%
)

if exist "%WORKSHOP_DIR%" (
    echo ✓ WORKSHOP_DIR: %WORKSHOP_DIR%
) else (
    echo ⚠️  WORKSHOP_DIR not found: %WORKSHOP_DIR%
)

echo.
if %ERROR_COUNT% EQU 0 (
    echo ✅ Configuration validation passed!
) else (
    echo ❌ Found %ERROR_COUNT% configuration errors
)

pause
goto MAIN_MENU

:QUICK_WIZARD
cls
echo ===========================================
echo   Quick Settings Wizard
echo ===========================================
echo.

echo This wizard will help you configure the most important settings.
echo.

:: Load current config if exists
if exist "%ENV_FILE%" call "%~dp0load_env.bat" "%ENV_FILE%"

echo Current Server Name: %SERVER_NAME%
set /p NEW_SERVER_NAME="Enter new server name (or press Enter to keep current): "
if not "%NEW_SERVER_NAME%"=="" set "SERVER_NAME=%NEW_SERVER_NAME%"

echo.
echo Current Password: %SERVER_PASSWORD%
set /p NEW_PASSWORD="Enter new password (or press Enter to keep current): "
if not "%NEW_PASSWORD%"=="" set "SERVER_PASSWORD=%NEW_PASSWORD%"

echo.
echo Current Max Players: %MAX_PLAYERS%
set /p NEW_MAX_PLAYERS="Enter max players (or press Enter to keep current): "
if not "%NEW_MAX_PLAYERS%"=="" set "MAX_PLAYERS=%NEW_MAX_PLAYERS%"

echo.
echo Current Collection ID: %COLLECTION_ID%
set /p NEW_COLLECTION="Enter Steam Collection ID (or press Enter to keep current): "
if not "%NEW_COLLECTION%"=="" set "COLLECTION_ID=%NEW_COLLECTION%"

echo.
echo Saving configuration...
call :SAVE_QUICK_CONFIG
echo ✓ Configuration saved!
pause
goto MAIN_MENU

:SAVE_QUICK_CONFIG
:: Create backup first
if exist "%ENV_FILE%" (
    if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
    set "QUICK_BACKUP=%BACKUP_DIR%\before_wizard_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%.env"
    copy "%ENV_FILE%" "!QUICK_BACKUP!" >nul
)

:: Update the .env file with new values
if exist "%ENV_FILE%" (
    :: Create temporary file with updates
    set "TEMP_ENV=%ENV_FILE%.tmp"
    
    for /f "usebackq tokens=1,* delims==" %%a in ("%ENV_FILE%") do (
        set "LINE=%%a"
        set "VALUE=%%b"
        
        if "!LINE!"=="SERVER_NAME" (
            echo SERVER_NAME=%SERVER_NAME%>> "!TEMP_ENV!"
        ) else if "!LINE!"=="SERVER_PASSWORD" (
            echo SERVER_PASSWORD=%SERVER_PASSWORD%>> "!TEMP_ENV!"
        ) else if "!LINE!"=="MAX_PLAYERS" (
            echo MAX_PLAYERS=%MAX_PLAYERS%>> "!TEMP_ENV!"
        ) else if "!LINE!"=="COLLECTION_ID" (
            echo COLLECTION_ID=%COLLECTION_ID%>> "!TEMP_ENV!"
        ) else (
            echo %%a=%%b>> "!TEMP_ENV!"
        )
    )
    
    move "!TEMP_ENV!" "%ENV_FILE%" >nul
) else (
    call :CREATE_DEFAULT_CONFIG
)
goto :eof

:EXPORT_CONFIG
echo.
set /p EXPORT_PATH="Enter export path (or press Enter for desktop): "
if "%EXPORT_PATH%"=="" set "EXPORT_PATH=%USERPROFILE%\Desktop\ats_config_export.env"

if exist "%ENV_FILE%" (
    copy "%ENV_FILE%" "%EXPORT_PATH%" >nul
    echo ✓ Configuration exported to: %EXPORT_PATH%
) else (
    echo ❌ No configuration to export
)
pause
goto MAIN_MENU

:IMPORT_CONFIG
echo.
set /p IMPORT_PATH="Enter path to configuration file to import: "

if exist "%IMPORT_PATH%" (
    if exist "%ENV_FILE%" call :BACKUP_CONFIG
    copy "%IMPORT_PATH%" "%ENV_FILE%" >nul
    echo ✓ Configuration imported successfully
) else (
    echo ❌ Import file not found: %IMPORT_PATH%
)
pause
goto MAIN_MENU

:ADVANCED_EDITOR
echo.
echo Advanced Editor Options:
echo 1. Edit with VS Code
echo 2. Edit with System Default
echo 3. View Raw File
echo 4. Back to Main Menu
echo.
set /p ADV_CHOICE="Select option: "

if "%ADV_CHOICE%"=="1" (
    code "%ENV_FILE%" 2>nul || (
        echo VS Code not found. Opening with notepad...
        start /wait notepad.exe "%ENV_FILE%"
    )
) else if "%ADV_CHOICE%"=="2" (
    start "" "%ENV_FILE%"
) else if "%ADV_CHOICE%"=="3" (
    type "%ENV_FILE%"
    pause
) else if "%ADV_CHOICE%"=="4" (
    goto MAIN_MENU
)

goto MAIN_MENU

:CREATE_DEFAULT_CONFIG
call "%~dp0load_env.bat"
goto :eof

:END
echo.
echo Environment configuration manager closed.
timeout /t 2
exit
