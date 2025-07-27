@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Desktop Shortcut Creator
:: Creates convenient desktop shortcuts for all ATS management tools
:: ===========================================

title ATS Desktop Shortcut Creator

set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%.."
set "DESKTOP=%USERPROFILE%\Desktop"

:: Load environment
if exist "%SCRIPT_DIR%\load_env.bat" (
    call "%SCRIPT_DIR%\load_env.bat"
) else (
    set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator"
    set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
    set "STEAM_EXE=C:\Program Files (x86)\Steam\steam.exe"
)

echo ===========================================
echo   ATS Desktop Shortcut Creator
echo ===========================================
echo.
echo Creating desktop shortcuts for easy ATS management...
echo Desktop location: %DESKTOP%
echo.

set /a SHORTCUT_COUNT=0

:: Main launcher shortcut
echo Creating ATS Complete Manager shortcut...
powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\🚛 ATS Complete Manager.lnk'); $Shortcut.TargetPath = '%BASE_DIR%\launch_server_manager.bat'; $Shortcut.WorkingDirectory = '%BASE_DIR%'; $Shortcut.Description = 'Freddy''s ATS Complete Manager - All-in-one ATS management'; $Shortcut.Save()}" 2>nul

if !errorlevel! equ 0 (
    echo ✓ ATS Complete Manager
    set /a SHORTCUT_COUNT+=1
) else (
    echo ❌ Failed to create ATS Complete Manager shortcut
)

:: Quick server shortcut
if exist "%SCRIPT_DIR%\ats_quick_server.bat" (
    echo Creating ATS Quick Server shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\🖥️ ATS Quick Server.lnk'); $Shortcut.TargetPath = '%SCRIPT_DIR%\ats_quick_server.bat'; $Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; $Shortcut.Description = 'Quick start ATS Dedicated Server'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo ✓ ATS Quick Server
        set /a SHORTCUT_COUNT+=1
    )
) else if exist "%SCRIPT_DIR%\start_ats_dedicated_server.bat" (
    echo Creating ATS Quick Server shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\🖥️ ATS Quick Server.lnk'); $Shortcut.TargetPath = '%SCRIPT_DIR%\start_ats_dedicated_server.bat'; $Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; $Shortcut.Description = 'Quick start ATS Dedicated Server'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo ✓ ATS Quick Server
        set /a SHORTCUT_COUNT+=1
    )
)

:: Game launcher shortcut
if exist "%GAME_DIR%\bin\win_x64\amtrucks.exe" (
    echo Creating ATS Game shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\🎮 ATS Game.lnk'); $Shortcut.TargetPath = '%GAME_DIR%\bin\win_x64\amtrucks.exe'; $Shortcut.WorkingDirectory = '%GAME_DIR%\bin\win_x64'; $Shortcut.Description = 'American Truck Simulator Game'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo ✓ ATS Game
        set /a SHORTCUT_COUNT+=1
    )
) else if exist "%STEAM_EXE%" (
    echo Creating ATS Game (Steam) shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\🎮 ATS Game.lnk'); $Shortcut.TargetPath = '%STEAM_EXE%'; $Shortcut.Arguments = '-applaunch 270880'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.Description = 'American Truck Simulator (via Steam)'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo ✓ ATS Game (Steam)
        set /a SHORTCUT_COUNT+=1
    )
)

:: Steam ATS Library shortcut
if exist "%STEAM_EXE%" (
    echo Creating Steam ATS Library shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\📚 ATS Steam Library.lnk'); $Shortcut.TargetPath = '%STEAM_EXE%'; $Shortcut.Arguments = '-url steam://nav/games/details/270880'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.Description = 'Steam ATS Library Page'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo ✓ Steam ATS Library
        set /a SHORTCUT_COUNT+=1
    )
)

:: Workshop Collection shortcut
echo Creating Workshop Collection shortcut...
powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\📦 ATS Mod Collection.lnk'); $Shortcut.TargetPath = 'https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316'; $Shortcut.Description = 'Freddy''s ATS Mod Collection'; $Shortcut.Save()}" 2>nul

if !errorlevel! equ 0 (
    echo ✓ ATS Mod Collection
    set /a SHORTCUT_COUNT+=1
)

:: Server Status Checker shortcut
if exist "%SCRIPT_DIR%\check_server_id.bat" (
    echo Creating Server Status Checker shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\📊 ATS Server Status.lnk'); $Shortcut.TargetPath = '%SCRIPT_DIR%\check_server_id.bat'; $Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; $Shortcut.Description = 'Check ATS Server Status and Session ID'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo ✓ ATS Server Status
        set /a SHORTCUT_COUNT+=1
    )
)

:: Environment Configuration shortcut
if exist "%SCRIPT_DIR%\env_manager.bat" (
    echo Creating Environment Configuration shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\⚙️ ATS Configuration.lnk'); $Shortcut.TargetPath = '%SCRIPT_DIR%\env_manager.bat'; $Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; $Shortcut.Description = 'ATS Environment Configuration Manager'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo ✓ ATS Configuration
        set /a SHORTCUT_COUNT+=1
    )
)

:: Steam Package Installer shortcut
if exist "%SCRIPT_DIR%\steam_package_installer.bat" (
    echo Creating Steam Package Installer shortcut...
    powershell -Command "& {$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\💿 ATS Steam Installer.lnk'); $Shortcut.TargetPath = '%SCRIPT_DIR%\steam_package_installer.bat'; $Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; $Shortcut.Description = 'Install ATS Game and Server via Steam'; $Shortcut.Save()}" 2>nul
    
    if !errorlevel! equ 0 (
        echo ✓ Steam Package Installer
        set /a SHORTCUT_COUNT+=1
    )
)

:: Create a shortcuts folder on desktop for organization
echo.
echo Creating organized shortcuts folder...
set "SHORTCUTS_FOLDER=%DESKTOP%\ATS Management"
if not exist "%SHORTCUTS_FOLDER%" mkdir "%SHORTCUTS_FOLDER%"

:: Move shortcuts to folder (optional)
echo.
set /p ORGANIZE="Move shortcuts to 'ATS Management' folder? (Y/N): "
if /i "%ORGANIZE%"=="Y" (
    echo Moving shortcuts to organized folder...
    move "%DESKTOP%\🚛*.lnk" "%SHORTCUTS_FOLDER%" 2>nul
    move "%DESKTOP%\🖥️*.lnk" "%SHORTCUTS_FOLDER%" 2>nul
    move "%DESKTOP%\🎮*.lnk" "%SHORTCUTS_FOLDER%" 2>nul
    move "%DESKTOP%\📚*.lnk" "%SHORTCUTS_FOLDER%" 2>nul
    move "%DESKTOP%\📦*.lnk" "%SHORTCUTS_FOLDER%" 2>nul
    move "%DESKTOP%\📊*.lnk" "%SHORTCUTS_FOLDER%" 2>nul
    move "%DESKTOP%\⚙️*.lnk" "%SHORTCUTS_FOLDER%" 2>nul
    move "%DESKTOP%\💿*.lnk" "%SHORTCUTS_FOLDER%" 2>nul
    
    echo ✓ Shortcuts organized in folder
    echo Folder location: %SHORTCUTS_FOLDER%
)

echo.
echo ===========================================
echo   Shortcut Creation Complete
echo ===========================================
echo.
echo ✓ Created %SHORTCUT_COUNT% desktop shortcuts
echo.
echo SHORTCUTS CREATED:
echo • 🚛 ATS Complete Manager - Main management interface
echo • 🖥️ ATS Quick Server - Quick dedicated server start
echo • 🎮 ATS Game - Launch the game directly
echo • 📚 ATS Steam Library - Steam library page
echo • 📦 ATS Mod Collection - Workshop collection
echo • 📊 ATS Server Status - Check server status
echo • ⚙️ ATS Configuration - Environment settings
echo • 💿 ATS Steam Installer - Install game/server
echo.
echo You can now manage your ATS setup directly from desktop shortcuts!
echo.
echo RECOMMENDED USAGE:
echo 1. Use 'ATS Complete Manager' for daily management
echo 2. Use 'ATS Quick Server' for fast server starts
echo 3. Use 'ATS Steam Installer' if you need to install/update
echo.
pause
