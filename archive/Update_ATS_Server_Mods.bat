@echo off
echo Updating ATS Server Mods...
echo.

set "SERVER_MOD_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server\mod"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"

echo Cleaning server mod directory...
del /q "%SERVER_MOD_DIR%\*.*"

echo Copying mods from Workshop...
for /r "%WORKSHOP_DIR%" %%f in (*.scs) do (
    echo Copying %%~nxf...
    copy "%%f" "%SERVER_MOD_DIR%"
)

echo.
echo Done! The following mods are now installed:
dir /b "%SERVER_MOD_DIR%"

echo.
echo Press any key to exit...
pause > nul
