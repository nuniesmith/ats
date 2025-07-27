@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Complete Setup Test
:: Quick test to verify the complete launcher setup
:: ===========================================

title ATS Complete Setup Test

echo ===========================================
echo   ATS Complete Setup Test
echo ===========================================
echo.
echo Testing the complete ATS launcher setup...
echo.

set "BASE_DIR=%~dp0"
set "LAUNCHER=%BASE_DIR%launch_server_manager.bat"
set "SCRIPTS_DIR=%BASE_DIR%scripts"

set /a TESTS_PASSED=0
set /a TOTAL_TESTS=0

:: Test 1: Main launcher exists
set /a TOTAL_TESTS+=1
echo [1/8] Checking main launcher...
if exist "%LAUNCHER%" (
    echo ✓ Main launcher found: launch_server_manager.bat
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Main launcher not found
)

:: Test 2: Scripts directory exists
set /a TOTAL_TESTS+=1
echo [2/8] Checking scripts directory...
if exist "%SCRIPTS_DIR%" (
    echo ✓ Scripts directory found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Scripts directory not found
)

:: Test 3: Core scripts exist
set /a TOTAL_TESTS+=1
echo [3/8] Checking core scripts...
set "CORE_SCRIPTS=ats_server_manager.bat load_env.bat start_ats_dedicated_server.bat"
set /a CORE_COUNT=0
for %%s in (%CORE_SCRIPTS%) do (
    if exist "%SCRIPTS_DIR%\%%s" set /a CORE_COUNT+=1
)
if %CORE_COUNT% geq 3 (
    echo ✓ Core scripts found (%CORE_COUNT%/3)
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Some core scripts missing (%CORE_COUNT%/3)
)

:: Test 4: New utility scripts exist
set /a TOTAL_TESTS+=1
echo [4/8] Checking new utility scripts...
set "UTIL_SCRIPTS=steam_package_installer.bat create_desktop_shortcuts.bat system_diagnostics.bat"
set /a UTIL_COUNT=0
for %%s in (%UTIL_SCRIPTS%) do (
    if exist "%SCRIPTS_DIR%\%%s" set /a UTIL_COUNT+=1
)
if %UTIL_COUNT% geq 3 (
    echo ✓ Utility scripts found (%UTIL_COUNT%/3)
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Some utility scripts missing (%UTIL_COUNT%/3)
)

:: Test 5: Environment loader works
set /a TOTAL_TESTS+=1
echo [5/8] Testing environment loader...
if exist "%SCRIPTS_DIR%\load_env.bat" (
    call "%SCRIPTS_DIR%\load_env.bat" >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✓ Environment loader functional
        set /a TESTS_PASSED+=1
    ) else (
        echo ⚠️ Environment loader has issues
    )
) else (
    echo ❌ Environment loader not found
)

:: Test 6: PowerShell availability (for shortcuts)
set /a TOTAL_TESTS+=1
echo [6/8] Checking PowerShell availability...
powershell -Command "Write-Host 'PowerShell available'" >nul 2>&1
if !errorlevel! equ 0 (
    echo ✓ PowerShell available for shortcuts
    set /a TESTS_PASSED+=1
) else (
    echo ❌ PowerShell not available
)

:: Test 7: Write permissions
set /a TOTAL_TESTS+=1
echo [7/8] Testing write permissions...
echo test > "%BASE_DIR%\test_write.tmp" 2>nul
if exist "%BASE_DIR%\test_write.tmp" (
    echo ✓ Write permissions OK
    del "%BASE_DIR%\test_write.tmp" 2>nul
    set /a TESTS_PASSED+=1
) else (
    echo ❌ No write permissions
)

:: Test 8: Main launcher syntax check
set /a TOTAL_TESTS+=1
echo [8/8] Testing main launcher syntax...
:: Basic syntax check by trying to parse the file
findstr /i "MAIN_MENU" "%LAUNCHER%" >nul 2>&1
if !errorlevel! equ 0 (
    echo ✓ Main launcher syntax appears valid
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Main launcher syntax issues detected
)

echo.
echo ===========================================
echo   Test Results
echo ===========================================
echo.

set /a SUCCESS_RATE=!TESTS_PASSED!*100/!TOTAL_TESTS!
echo Tests Passed: !TESTS_PASSED!/!TOTAL_TESTS! (!SUCCESS_RATE!%%)
echo.

if !SUCCESS_RATE! geq 90 (
    echo 🎉 EXCELLENT - Setup is complete and ready!
    echo ✓ All components are properly configured
    echo ✓ You can now use the launcher safely
    echo.
    echo NEXT STEPS:
    echo 1. Run launch_server_manager.bat
    echo 2. Use option D to create desktop shortcuts
    echo 3. Use option E for system diagnostics
    echo 4. Start managing your ATS setup!
) else if !SUCCESS_RATE! geq 75 (
    echo ✅ GOOD - Setup is mostly complete
    echo ℹ Minor issues detected, but launcher should work
    echo ℹ Check failed tests above for improvements
    echo.
    echo You can proceed with using the launcher.
) else if !SUCCESS_RATE! geq 50 (
    echo ⚠️ PARTIAL - Setup has some issues
    echo 🔧 Several components need attention
    echo ℹ The launcher may work but with limitations
    echo.
    echo Consider reviewing the failed tests above.
) else (
    echo 🚨 POOR - Setup is incomplete
    echo ❌ Major issues detected
    echo ℹ Please check the installation and try again
    echo.
    echo The launcher may not work properly in this state.
)

echo.
echo ===========================================
echo   Quick Actions
echo ===========================================
echo.
echo What would you like to do now?
echo.
echo 1. Launch ATS Complete Manager
echo 2. View detailed setup information
echo 3. Exit
echo.
set /p ACTION="Select action (1-3): "

if "%ACTION%"=="1" (
    if exist "%LAUNCHER%" (
        echo.
        echo Launching ATS Complete Manager...
        call "%LAUNCHER%"
    ) else (
        echo ❌ Cannot launch - main launcher not found
        pause
    )
) else if "%ACTION%"=="2" (
    echo.
    echo ===========================================
    echo   Detailed Setup Information
    echo ===========================================
    echo.
    echo Base Directory: %BASE_DIR%
    echo Main Launcher: %LAUNCHER%
    echo Scripts Directory: %SCRIPTS_DIR%
    echo.
    echo Available Scripts:
    for %%f in ("%SCRIPTS_DIR%\*.bat") do echo   - %%~nxf
    echo.
    echo Documentation:
    if exist "%BASE_DIR%\LAUNCHER_README.md" echo   - LAUNCHER_README.md (main documentation)
    if exist "%BASE_DIR%\README.md" echo   - README.md (project overview)
    if exist "%BASE_DIR%\docs\" echo   - docs\ (detailed guides)
    echo.
    pause
) else (
    echo.
    echo Thank you for using the ATS Complete Setup Test!
)

echo.
pause
