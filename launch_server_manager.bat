@echo off
:: Quick Launcher for Freddy's ATS Server Manager
:: This script launches the main server manager from anywhere

title Freddy's ATS Server Manager - Launcher

set "SCRIPT_DIR=%~dp0scripts"
set "MANAGER_SCRIPT=%SCRIPT_DIR%\ats_server_manager.bat"

echo ===========================================
echo   Freddy's ATS Server Manager Launcher
echo ===========================================
echo.

if exist "%MANAGER_SCRIPT%" (
    echo Launching ATS Server Manager...
    echo.
    call "%MANAGER_SCRIPT%" %*
) else (
    echo ERROR: Manager script not found!
    echo Expected location: %MANAGER_SCRIPT%
    echo.
    echo Please ensure the script is in the correct location.
    pause
)
