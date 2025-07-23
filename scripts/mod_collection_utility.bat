@echo off
setlocal EnableDelayedExpansion

:: ===========================================
:: ATS Dynamic Mod Collection Utility
:: Advanced workshop collection management
:: ===========================================

title ATS Dynamic Mod Collection Utility

:: Configuration
set "COLLECTION_ID=3530633316"
set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
set "SCRIPT_DIR=%~dp0"
set "STEAMCMD_DIR=%SCRIPT_DIR%\steamcmd"
set "COLLECTION_URL=https://steamcommunity.com/sharedfiles/filedetails/?id=%COLLECTION_ID%"

:MAIN_MENU
cls
echo ===========================================
echo   ATS Dynamic Mod Collection Utility
echo ===========================================
echo   Collection: %COLLECTION_ID%
echo   URL: %COLLECTION_URL%
echo ===========================================
echo.
echo 1. Analyze Collection (Fetch mod list)
echo 2. Download All Mods (SteamCMD)
echo 3. Verify Local Mods vs Collection
echo 4. Generate Mod Installation Script
echo 5. Create Mod Pack Archive
echo 6. Compare Collections
echo 7. Export Collection Data
echo 8. Import Collection from File
echo 9. Exit
echo.
set /p CHOICE="Select option: "

if "%CHOICE%"=="1" goto ANALYZE_COLLECTION
if "%CHOICE%"=="2" goto DOWNLOAD_ALL_MODS
if "%CHOICE%"=="3" goto VERIFY_LOCAL_MODS
if "%CHOICE%"=="4" goto GENERATE_INSTALL_SCRIPT
if "%CHOICE%"=="5" goto CREATE_MOD_PACK
if "%CHOICE%"=="6" goto COMPARE_COLLECTIONS
if "%CHOICE%"=="7" goto EXPORT_COLLECTION
if "%CHOICE%"=="8" goto IMPORT_COLLECTION
if "%CHOICE%"=="9" goto END
goto MAIN_MENU

:ANALYZE_COLLECTION
cls
echo ===========================================
echo   Analyzing Steam Collection
echo ===========================================
echo.

echo Fetching collection data from Steam...
echo URL: %COLLECTION_URL%
echo.

:: Create output directory
if not exist "%SCRIPT_DIR%\collection_data" mkdir "%SCRIPT_DIR%\collection_data"

:: Create PowerShell script for detailed collection analysis
set "PS_SCRIPT=%SCRIPT_DIR%\collection_data\analyze_collection.ps1"
(
echo # Advanced Steam Workshop Collection Analyzer
echo $collectionId = "%COLLECTION_ID%"
echo $url = "https://steamcommunity.com/sharedfiles/filedetails/?id=$collectionId"
echo $outputDir = "%SCRIPT_DIR%\collection_data"
echo.
echo try {
echo     Write-Host "Fetching collection page..."
echo     $response = Invoke-WebRequest -Uri $url -UseBasicParsing
echo     $content = $response.Content
echo.
echo     # Extract mod IDs and names
echo     $modPattern = 'sharedfile_(\d+)'
echo     $namePattern = '&gt;([^&lt;]+)&lt;/div&gt;\s*&lt;/a&gt;'
echo.
echo     $modMatches = [regex]::Matches($content, $modPattern^)
echo     Write-Host "Found $($modMatches.Count^) mod references"
echo.
echo     $modData = @(^)
echo     $processedIds = @(^)
echo.
echo     foreach ($match in $modMatches^) {
echo         $modId = $match.Groups[1].Value
echo         if ($processedIds -notcontains $modId^) {
echo             $processedIds += $modId
echo             
echo             # Try to get mod name from page
echo             $modName = "Unknown"
echo             $modUrl = "https://steamcommunity.com/sharedfiles/filedetails/?id=$modId"
echo             
echo             try {
echo                 $modResponse = Invoke-WebRequest -Uri $modUrl -UseBasicParsing -TimeoutSec 10
echo                 if ($modResponse.Content -match '&lt;div class="workshopItemTitle"&gt;([^&lt;]+)&lt;/div&gt;'^) {
echo                     $modName = $matches[1]
echo                 }
echo             } catch {
echo                 Write-Host "Could not fetch details for mod $modId"
echo             }
echo             
echo             $modData += [PSCustomObject]@{
echo                 ID = $modId
echo                 Name = $modName
echo                 URL = $modUrl
echo             }
echo             
echo             Write-Host "Added: $modId - $modName"
echo         }
echo     }
echo.
echo     # Export data
echo     $modData ^| Export-Csv -Path "$outputDir\collection_mods.csv" -NoTypeInformation
echo     $modData.ID ^| Out-File -Path "$outputDir\mod_ids.txt" -Encoding ASCII
echo     
echo     # Create summary
echo     $summary = @"
echo Collection Analysis Summary
echo ==========================
echo Collection ID: $collectionId
echo Total Mods: $($modData.Count^)
echo Analysis Date: $(Get-Date^)
echo Collection URL: $url
echo.
echo Mod List:
echo $($modData ^| ForEach-Object { "$($_.ID^) - $($_.Name^)" } ^| Out-String^)
echo "@
echo     $summary ^| Out-File -Path "$outputDir\analysis_summary.txt" -Encoding UTF8
echo.
echo     Write-Host "Analysis complete! Found $($modData.Count^) unique mods"
echo     Write-Host "Data exported to: $outputDir"
echo.
echo } catch {
echo     Write-Host "Error analyzing collection: $_" -ForegroundColor Red
echo     exit 1
echo }
) > "%PS_SCRIPT%"

:: Run analysis
powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

echo.
echo Analysis complete! Check the following files:
echo - collection_data\collection_mods.csv (Full data)
echo - collection_data\mod_ids.txt (Just IDs)
echo - collection_data\analysis_summary.txt (Summary)
echo.
pause
goto MAIN_MENU

:DOWNLOAD_ALL_MODS
cls
echo ===========================================
echo   Download All Collection Mods
echo ===========================================
echo.

if not exist "%SCRIPT_DIR%\collection_data\mod_ids.txt" (
    echo ❌ Mod list not found. Please run "Analyze Collection" first.
    pause
    goto MAIN_MENU
)

echo This will download ALL mods from the collection using SteamCMD.
echo This may take a while depending on the number and size of mods.
echo.
set /p DOWNLOAD_CONFIRM="Continue? (Y/N): "
if /i not "%DOWNLOAD_CONFIRM%"=="Y" goto MAIN_MENU

:: Check/setup SteamCMD
call :SETUP_STEAMCMD

if not defined STEAMCMD_AVAILABLE (
    echo ❌ SteamCMD not available. Cannot download mods.
    pause
    goto MAIN_MENU
)

echo.
echo Creating download script...
set "DOWNLOAD_SCRIPT=%STEAMCMD_DIR%\download_collection.txt"
(
echo @ShutdownOnFailedCommand 1
echo @NoPromptForPassword 1
echo login anonymous
) > "%DOWNLOAD_SCRIPT%"

:: Add each mod to download script
for /f %%i in (%SCRIPT_DIR%\collection_data\mod_ids.txt) do (
    echo workshop_download_item 270880 %%i >> "%DOWNLOAD_SCRIPT%"
)

echo quit >> "%DOWNLOAD_SCRIPT%"

echo.
echo Starting SteamCMD download...
echo This will download to: %STEAMCMD_DIR%\steamapps\workshop\content\270880\
echo.

"%STEAMCMD_DIR%\steamcmd.exe" +runscript "%DOWNLOAD_SCRIPT%"

echo.
echo Download complete! Mods are available in SteamCMD workshop directory.
pause
goto MAIN_MENU

:VERIFY_LOCAL_MODS
cls
echo ===========================================
echo   Verify Local Mods vs Collection
echo ===========================================
echo.

if not exist "%SCRIPT_DIR%\collection_data\mod_ids.txt" (
    echo ❌ Collection data not found. Please run "Analyze Collection" first.
    pause
    goto MAIN_MENU
)

echo Checking local mods against collection...
echo.

set /a TOTAL_MODS=0
set /a AVAILABLE_LOCAL=0
set /a AVAILABLE_STEAMCMD=0
set /a MISSING=0

echo Mod Status Report:
echo ==================
for /f %%i in (%SCRIPT_DIR%\collection_data\mod_ids.txt) do (
    set /a TOTAL_MODS+=1
    set "MOD_STATUS=❌ MISSING"
    
    if exist "%WORKSHOP_DIR%\%%i" (
        set /a AVAILABLE_LOCAL+=1
        set "MOD_STATUS=✓ LOCAL"
    ) else if exist "%STEAMCMD_DIR%\steamapps\workshop\content\270880\%%i" (
        set /a AVAILABLE_STEAMCMD+=1
        set "MOD_STATUS=✓ STEAMCMD"
    ) else (
        set /a MISSING+=1
    )
    
    echo %%i - !MOD_STATUS!
)

echo.
echo Summary:
echo ========
echo Total mods in collection: !TOTAL_MODS!
echo Available in Steam Workshop: !AVAILABLE_LOCAL!
echo Available in SteamCMD: !AVAILABLE_STEAMCMD!
echo Missing: !MISSING!

if !MISSING! GTR 0 (
    echo.
    echo Recommendation: Run "Download All Mods" to get missing mods.
)

pause
goto MAIN_MENU

:GENERATE_INSTALL_SCRIPT
cls
echo ===========================================
echo   Generate Mod Installation Script
echo ===========================================
echo.

if not exist "%SCRIPT_DIR%\collection_data\mod_ids.txt" (
    echo ❌ Collection data not found. Please run "Analyze Collection" first.
    pause
    goto MAIN_MENU
)

set "INSTALL_SCRIPT=%SCRIPT_DIR%\install_collection_mods.bat"
echo Creating installation script: %INSTALL_SCRIPT%

(
echo @echo off
echo setlocal EnableDelayedExpansion
echo.
echo :: Auto-generated mod installation script
echo :: Collection ID: %COLLECTION_ID%
echo :: Generated: %DATE% %TIME%
echo.
echo set "SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server"
echo set "WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880"
echo set "STEAMCMD_WORKSHOP=%%~dp0steamcmd\steamapps\workshop\content\270880"
echo.
echo echo Installing mods from collection %COLLECTION_ID%...
echo echo.
echo.
echo if not exist "%%SERVER_DIR%%\mod" mkdir "%%SERVER_DIR%%\mod"
echo.
echo set /a COPIED_COUNT=0
) > "%INSTALL_SCRIPT%"

:: Add copy commands for each mod
for /f %%i in (%SCRIPT_DIR%\collection_data\mod_ids.txt) do (
    echo. >> "%INSTALL_SCRIPT%"
    echo echo Checking for mod %%i... >> "%INSTALL_SCRIPT%"
    echo if exist "%%WORKSHOP_DIR%%\%%i\*.scs" ^( >> "%INSTALL_SCRIPT%"
    echo     echo Copying from Steam Workshop... >> "%INSTALL_SCRIPT%"
    echo     copy "%%WORKSHOP_DIR%%\%%i\*.scs" "%%SERVER_DIR%%\mod\" ^>nul >> "%INSTALL_SCRIPT%"
    echo     set /a COPIED_COUNT+=1 >> "%INSTALL_SCRIPT%"
    echo ^) else if exist "%%STEAMCMD_WORKSHOP%%\%%i\*.scs" ^( >> "%INSTALL_SCRIPT%"
    echo     echo Copying from SteamCMD... >> "%INSTALL_SCRIPT%"
    echo     copy "%%STEAMCMD_WORKSHOP%%\%%i\*.scs" "%%SERVER_DIR%%\mod\" ^>nul >> "%INSTALL_SCRIPT%"
    echo     set /a COPIED_COUNT+=1 >> "%INSTALL_SCRIPT%"
    echo ^) else ^( >> "%INSTALL_SCRIPT%"
    echo     echo ❌ Mod %%i not found locally >> "%INSTALL_SCRIPT%"
    echo ^) >> "%INSTALL_SCRIPT%"
)

(
echo.
echo echo.
echo echo Installation complete! Copied %%COPIED_COUNT%% mods.
echo pause
) >> "%INSTALL_SCRIPT%"

echo ✓ Installation script created: %INSTALL_SCRIPT%
echo.
echo This script can be used to install the collection mods on any server.
pause
goto MAIN_MENU

:CREATE_MOD_PACK
echo.
echo Creating mod pack archive...
echo This feature will be implemented in a future version.
pause
goto MAIN_MENU

:COMPARE_COLLECTIONS
echo.
echo Collection comparison...
echo This feature will be implemented in a future version.
pause
goto MAIN_MENU

:EXPORT_COLLECTION
echo.
echo Exporting collection data...
if exist "%SCRIPT_DIR%\collection_data\analysis_summary.txt" (
    copy "%SCRIPT_DIR%\collection_data\*.*" "%SCRIPT_DIR%\exported_collection_%COLLECTION_ID%_%DATE:~-4%%DATE:~4,2%%DATE:~7,2%\" >nul 2>&1
    echo ✓ Collection data exported
) else (
    echo ❌ No collection data to export. Run "Analyze Collection" first.
)
pause
goto MAIN_MENU

:IMPORT_COLLECTION
echo.
echo Import collection from file...
echo This feature will be implemented in a future version.
pause
goto MAIN_MENU

:SETUP_STEAMCMD
set "STEAMCMD_AVAILABLE="
if exist "%STEAMCMD_DIR%\steamcmd.exe" (
    set "STEAMCMD_AVAILABLE=1"
) else (
    echo SteamCMD not found. Please run the main server manager to set it up.
)
goto :eof

:END
echo.
echo Thank you for using the ATS Dynamic Mod Collection Utility!
timeout /t 3
exit
