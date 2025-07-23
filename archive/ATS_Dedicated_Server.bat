@echo off
title Freddy's ATS Dedicated Server
echo Starting ATS Dedicated Server...
echo Server Name: Freddy's ATS Dedicated Server
echo Password: ruby
echo Mods: Enabled
echo.
cd "C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
echo Current directory: %CD%
echo.
echo Server config exists:
if exist server_config.sii (echo Yes) else (echo No)
echo.
echo Mod directory exists:
if exist mod (echo Yes) else (echo No)
echo.
echo Mods in directory:
dir /b mod\*.scs 2>nul
echo.
cd bin\win_x64
amtrucks_server.exe -server_config "..\server_config.sii" +g_console 1 +enable_mods 1 +force_mods 1 +mods_settings_server 1 +mods_optional_server 1
echo.
echo Server has stopped. Press any key to close this window.
pause > nul
