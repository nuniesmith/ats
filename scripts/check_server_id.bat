@echo off
:: Quick Server ID Checker
:: Shows the current server session ID if available

title ATS Server ID Checker

echo ===========================================
echo   ATS Server Session ID Checker
echo ===========================================
echo.

echo Checking for running server...
tasklist /FI "IMAGENAME eq amtrucks_server.exe" 2>NUL | find /I /N "amtrucks_server.exe" >nul && (
    echo ✓ ATS Server is RUNNING
) || (
    echo ❌ ATS Server is NOT running
    echo.
    echo Start the server first to capture session ID.
    pause
    exit /b 1
)

echo.
echo Checking captured session ID...

if exist "%TEMP%\ats_server_id.txt" (
    echo ✓ Server ID file found
    echo.
    echo Session Information:
    echo ====================
    type "%TEMP%\ats_server_id.txt"
    echo.
    
    for /f "tokens=4" %%a in ('findstr "Session search id:" "%TEMP%\ats_server_id.txt" 2^>nul') do (
        echo Session ID for game client: %%a
        echo.
        echo To connect manually:
        echo 1. Start ATS game
        echo 2. Go to Multiplayer ^> Join Server
        echo 3. Enter Session ID: %%a
        echo 4. Enter Password: ruby
    )
) else (
    echo ❌ Server ID file not found
    echo.
    echo The server needs to be started with the updated script
    echo to capture the session ID automatically.
)

echo.
pause
