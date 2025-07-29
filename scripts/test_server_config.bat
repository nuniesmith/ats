@echo off
echo ===========================================
echo   Testing ATS Server Configuration
echo ===========================================
echo.

echo Testing server configuration creation...

set "TEST_DIR=%TEMP%\ats_test"
if not exist "%TEST_DIR%" mkdir "%TEST_DIR%"

echo Creating test server config...
(
echo SiiNunit
echo {
echo server_config : .config {
echo  lobby_name: "Test ATS Server"
echo  description: "Test server configuration"
echo  password: "test"
echo  max_players: 8
echo  connection_dedicated_port: 27015
echo  query_dedicated_port: 27016
echo  mods_optioning: true
echo }
echo }
) > "%TEST_DIR%\server_config.sii"

if exist "%TEST_DIR%\server_config.sii" (
    echo ✓ Server config created successfully
    echo.
    echo Contents:
    type "%TEST_DIR%\server_config.sii"
    echo.
    echo ✓ Configuration test passed
    
    :: Cleanup
    del "%TEST_DIR%\server_config.sii" 2>nul
    rmdir "%TEST_DIR%" 2>nul
) else (
    echo ❌ Failed to create server config
)

echo.
echo Server configuration test completed.
pause
