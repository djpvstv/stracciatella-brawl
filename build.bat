@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
cls
cd /d "%~dp0"

:: =============================================
:: Configuration
:: =============================================
set "GCT=sd_base\sBrawl\GCTRealMate.exe"
set "ENTER=sd_base\sBrawl\enter.txt"
set "SRC_INJECT=sd_base\sBrawl\Source\Community\Injects"
set "DEST_INJECT=sd_base\private\wii\app\rsbe\pf\injects"

echo.
echo ╔══════════════════════════════════════════════════╗
echo ║     Codes Builder + Injects → pf\injects         ║
echo ╚══════════════════════════════════════════════════╝
echo.

:: Check GCTRealMate
if not exist "%GCT%" (
    echo [ERROR] GCTRealMate.exe not found! >&2
    echo         Expected in: %GCT%
    goto :finalpause
)

:: Create destination folder
if not exist "%DEST_INJECT%" mkdir "%DEST_INJECT%"

:: 1. Main codes
echo .
echo ========================
echo [1/5] Building Codes RSBE01...
echo ========================
"%GCT%" "sd_base\sBrawl\RSBE01.txt" < "%ENTER%"
echo.

echo .
echo =======================
echo [2/5] Building Codes BOOST...
echo =======================
"%GCT%" "sd_base\sBrawl\BOOST.txt" < "%ENTER%"
echo.

echo .
echo ========================
echo [3/5] Building Codes NETPLAY...
echo ========================
"%GCT%" "sd_base\sBrawl\NETPLAY.txt" < "%ENTER%"
echo.

echo .
echo =======================
echo [4/5] Building Codes NETBOOST...
echo =======================
"%GCT%" "sd_base\sBrawl\NETBOOST.txt" < "%ENTER%"
echo.

:: 2. Injects
echo .
echo =====================================
echo [5/5] Building Fighter Inject GCTs...
echo =====================================
echo.
set "count=0"
for /r "%SRC_INJECT%" %%F in (*.txt) do (
    set /a count+=1
    set "fullname=%%F"
    set "basename=%%~nF"
    set "gct_temp=%SRC_INJECT%\!basename!.GCT"
    set "gct_final=%DEST_INJECT%\!basename!.GCT"

    echo   • Building: !basename!.GCT

    :: Clean up any previous GCT with same name first
    if exist "%GCT_FOLDER%\!basename!.GCT" del /q "%GCT_FOLDER%\!basename!.GCT"

    :: Run GCTRealMate
    "%GCT%" "!fullname!" < "%ENTER%" >nul

    :: Move to final destination (force overwrite)
    if exist "!gct_temp!" (
        move /Y "!gct_temp!" "!gct_final!" >nul 2>&1
        echo     → Success: !basename!.GCT → rsbe\pf\injects\fighter\
    ) else (
        echo     [WARNING] Failed to create !basename!.GCT
    )
)

if %count%==0 (
    echo   No .txt files found anywhere under:
    echo   %SRC_INJECT%
    echo.
    echo   (Make sure your files are in subfolders like fighter\, stage\, etc.)
) else (
    echo.
    echo   Successfully processed %count% inject file(s).
)
echo.

:: 3. VDS Sync
if exist "tools\VSDsync\VSDSync.exe" (
    echo Syncing with VDS Sync...
    "tools\VSDsync\VSDSync.exe" < "%ENTER%"
    echo.
    echo Complete!
) else (
    echo [WARNING] VDS Sync not found — skipping.
)

:: =============================================
:: FINAL PAUSE — THIS IS WHAT KEEPS THE WINDOW OPEN
:: =============================================
:finalpause
echo.
echo ╔══════════════════════════════════════════╗
echo ║      ALL DONE! PRESS ENTER TO EXIT       ║
echo ╚══════════════════════════════════════════╝
echo.
pause >nul
endlocal
exit /b 0