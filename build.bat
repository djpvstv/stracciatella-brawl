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

set "BUILDER_DIR=Code Menu Builder"
set "BUILDER_EXE=%BUILDER_DIR%\PowerPC Assembly Functions.exe"
set "CM_OUTPUT=%BUILDER_DIR%\Code_Menu_Output"
set "CM_CMNU=%CM_OUTPUT%\data.cmnu"
set "CM_ASM=%CM_OUTPUT%\CodeMenu.asm"
set "CM_ADDONS_SRC=%CM_OUTPUT%\CM_Addons"
set "CM_CMNU_DST=sd_base\sBrawl\pf\menu3\data.cmnu"
set "CM_ASM_DST=sd_base\sBrawl\Source\CodeMenu\CodeMenu.asm"
set "CM_ADDONS_DST=sd_base\sBrawl\Source\CM_Addons"

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
if not exist "%BUILDER_EXE%" (
    echo [ERROR] PowerPC Assembly Functions.exe not found! >&2
    echo         Expected in: %BUILDER_EXE%
    goto :finalpause
)

:: Create destination folder
if not exist "%DEST_INJECT%" mkdir "%DEST_INJECT%"

:: 1. Code Menu Builder (blocks on _getch; delete-then-poll-then-kill)
echo .
echo ===================================
echo [1/6] Running Code Menu Builder...
echo ===================================
if exist "%CM_CMNU%" del /q "%CM_CMNU%"
pushd "%BUILDER_DIR%"
start "" /B "PowerPC Assembly Functions.exe"
popd

set /a cm_tries=0
:cmwait
if %cm_tries% GEQ 120 goto :cmtimeout
if exist "%CM_CMNU%" (
    timeout /t 1 /nobreak >nul
    taskkill /F /IM "PowerPC Assembly Functions.exe" >nul 2>&1
    goto :cmdeploy
)
timeout /t 1 /nobreak >nul
set /a cm_tries+=1
goto :cmwait

:cmtimeout
echo   [WARNING] Builder did not produce data.cmnu within 120 s, terminating.
taskkill /F /IM "PowerPC Assembly Functions.exe" >nul 2>&1

:cmdeploy
echo.
echo Deploying Code Menu Builder output:
if exist "%CM_ADDONS_SRC%" (
    if exist "%CM_ADDONS_DST%" rmdir /S /Q "%CM_ADDONS_DST%"
    xcopy /E /I /Y /Q "%CM_ADDONS_SRC%" "%CM_ADDONS_DST%" >nul
    echo   Replaced CM_Addons
) else (
    echo   [ERROR] %CM_ADDONS_SRC% not found!
)
if exist "%CM_CMNU%" (
    copy /Y "%CM_CMNU%" "%CM_CMNU_DST%" >nul
    echo   Replaced data.cmnu
) else (
    echo   [ERROR] %CM_CMNU% not found!
)
if exist "%CM_ASM%" (
    copy /Y "%CM_ASM%" "%CM_ASM_DST%" >nul
    echo   Replaced CodeMenu.asm
) else (
    echo   [ERROR] %CM_ASM% not found!
)
echo.

:: 2. Main codes
echo .
echo ========================
echo [2/6] Building Codes RSBE01...
echo ========================
"%GCT%" "sd_base\sBrawl\RSBE01.txt" < "%ENTER%"
echo.

echo .
echo =======================
echo [3/6] Building Codes BOOST...
echo =======================
"%GCT%" "sd_base\sBrawl\BOOST.txt" < "%ENTER%"
echo.

echo .
echo ========================
echo [4/6] Building Codes NETPLAY...
echo ========================
"%GCT%" "sd_base\sBrawl\NETPLAY.txt" < "%ENTER%"
echo.

echo .
echo =======================
echo [5/6] Building Codes NETBOOST...
echo =======================
"%GCT%" "sd_base\sBrawl\NETBOOST.txt" < "%ENTER%"
echo.

:: 3. Injects
echo .
echo =====================================
echo [6/6] Building Fighter Inject GCTs...
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