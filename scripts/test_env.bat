@echo off
setlocal EnableDelayedExpansion

echo Testing environment loading...

:: Load environment configuration
set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%.."
set "ENV_FILE=%BASE_DIR%\.env"

echo ENV_FILE path: %ENV_FILE%

if exist "%ENV_FILE%" (
    echo ✓ Found .env file
    
    :: Load environment variables, skipping comment lines
    for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%ENV_FILE%") do (
        if not "%%a"=="" (
            echo Setting %%a=%%b
            set "%%a=%%b"
        )
    )
) else (
    echo ❌ .env file not found
    exit /b 1
)

echo.
echo Testing variables:
echo SERVER_NAME=%SERVER_NAME%
echo SERVER_DIR=%SERVER_DIR%
echo SERVER_PASSWORD=%SERVER_PASSWORD%

pause
