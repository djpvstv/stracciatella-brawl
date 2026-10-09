# Path to GCTRealMate
$gctPath = ".\sd_base\sBrawl\GCTRealMate.exe"
$enterFile = ".\sd_base\sBrawl\enter.txt"
$sourceInjectDir = ".\sd_base\sBrawl\Source\Community\Injects"
$destInjectDir   = ".\sd_base\sBrawl\pf\injects"

# Code Menu Builder paths
$builderDir       = ".\Code Menu Builder"
$builderExe       = "$builderDir\PowerPC Assembly Functions.exe"
$menuOutputDir    = "$builderDir\Code_Menu_Output"
$cmAddonsSrc      = "$menuOutputDir\CM_Addons"
$cmAddonsDst      = ".\sd_base\sBrawl\Source\CM_Addons"
$cmnuSrc          = "$menuOutputDir\data.cmnu"
$cmnuDst          = ".\sd_base\sBrawl\pf\menu3\data.cmnu"
$codeMenuAsmSrc   = "$menuOutputDir\CodeMenu.asm"
$codeMenuAsmDst   = ".\sd_base\sBrawl\Source\CodeMenu\CodeMenu.asm"

# Check if GCTRealMate exists
if (-not (Test-Path $gctPath)) {
    Write-Host "`nError: Cannot find GCTRealMate.exe" -ForegroundColor Red
    pause
    exit
}
if (-not (Test-Path $builderExe)) {
    Write-Host "`nError: Cannot find PowerPC Assembly Functions.exe" -ForegroundColor Red
    pause
    exit
}
# Create destination folder if it doesn't exist
if (-not (Test-Path $destInjectDir)) {
    New-Item -ItemType Directory -Path $destInjectDir -Force | Out-Null
}

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nRunning Code Menu Builder`n"
# The builder blocks on "Press any key to exit" via _getch(), which reads the
# console directly and ignores redirected stdin. Launch it, wait until data.cmnu
# is freshly rewritten (= real work finished), then terminate.
$cmnuSrcFull = [System.IO.Path]::GetFullPath($cmnuSrc)
$preRunTime = Get-Date
Push-Location $builderDir
$proc = Start-Process -FilePath ".\PowerPC Assembly Functions.exe" -NoNewWindow -PassThru
Pop-Location

$timeoutSec = 120
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.Elapsed.TotalSeconds -lt $timeoutSec) {
    if ($proc.HasExited) { break }
    if ((Test-Path $cmnuSrcFull) -and ((Get-Item $cmnuSrcFull).LastWriteTime -gt $preRunTime)) {
        Start-Sleep -Milliseconds 500
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        break
    }
    Start-Sleep -Milliseconds 250
}
if (-not $proc.HasExited) {
    Write-Host "  Warning: builder did not produce data.cmnu within $timeoutSec s, terminating." -ForegroundColor Yellow
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
}
$proc.WaitForExit()

Write-Host "`nDeploying Code Menu Builder output:"
if (Test-Path $cmAddonsSrc) {
    if (Test-Path $cmAddonsDst) { Remove-Item -Path $cmAddonsDst -Recurse -Force }
    Copy-Item -Path $cmAddonsSrc -Destination $cmAddonsDst -Recurse -Force
    Write-Host "  Replaced CM_Addons" -ForegroundColor Green
} else {
    Write-Host "  Error: $cmAddonsSrc not found!" -ForegroundColor Red
}
if (Test-Path $cmnuSrc) {
    Copy-Item -Path $cmnuSrc -Destination $cmnuDst -Force
    Write-Host "  Replaced data.cmnu" -ForegroundColor Green
} else {
    Write-Host "  Error: $cmnuSrc not found!" -ForegroundColor Red
}
if (Test-Path $codeMenuAsmSrc) {
    Copy-Item -Path $codeMenuAsmSrc -Destination $codeMenuAsmDst -Force
    Write-Host "  Replaced CodeMenu.asm" -ForegroundColor Green
} else {
    Write-Host "  Error: $codeMenuAsmSrc not found!" -ForegroundColor Red
}

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nCreating codes for RSBE01`n"
Start-Process -FilePath $gctPath ".\sd_base\sBrawl\RSBE01.txt" -RedirectStandardInput $enterFile -NoNewWindow -Wait
Write-Host "`n###################################################################################################`n"
Write-Host "`n`nCreating codes for NETPLAY`n"
Start-Process -FilePath $gctPath ".\sd_base\sBrawl\NETPLAY.txt" -RedirectStandardInput $enterFile -NoNewWindow -Wait
Write-Host "`n###################################################################################################`n"
Write-Host "`n`nCreating codes for BOOST`n"
Start-Process -FilePath $gctPath ".\sd_base\sBrawl\BOOST.txt" -RedirectStandardInput $enterFile -NoNewWindow -Wait
Write-Host "`n###################################################################################################`n"
Write-Host "`n`nCreating codes for NETBOOST`n"
Start-Process -FilePath $gctPath ".\sd_base\sBrawl\NETBOOST.txt" -RedirectStandardInput $enterFile -NoNewWindow -Wait

Write-Host "`n###################################################################################################`n"
Write-Host "`n`n`Creating Fighter Inject GCTs`n"
$asmFiles = Get-ChildItem -Path $sourceInjectDir -Filter "*.txt" -File

if ($asmFiles.Count -eq 0) {
    Write-Host "No .txt files found in $sourceInjectDir" -ForegroundColor Gray
} else {
    foreach ($asm in $asmFiles) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($asm.Name)
        $inputTxt = "$sourceInjectDir\$baseName.txt"
        $outputGct = "$baseName.GCT"

        Write-Host "  Building: $baseName.GCT" -ForegroundColor White

        # Run GCTRealMate on the corresponding .asm file (assumes .txt has same base name as .asm)
        if (Test-Path $inputTxt) {
            Start-Process -FilePath $gctPath $inputTxt -RedirectStandardInput $enterFile -NoNewWindow -Wait

            # Move the generated .GCT to the pf\injects folder (overwrite if exists)
            if (Test-Path "$sourceInjectDir\$outputGct") {
                Move-Item -Path "$sourceInjectDir\$outputGct" -Destination "$destInjectDir\$outputGct" -Force
                Write-Host "    → Moved to pf\injects\$outputGct" -ForegroundColor Green
            } else {
                Write-Host "    Warning: "$sourceInjectDir\$outputGct" was not created!" -ForegroundColor Red
            }
        } else {
            Write-Host "    Skipping: $baseName.asm not found!" -ForegroundColor Red
        }
    }
}

# Path to VDSSync
$vdsPath = ".\tools\VSDsync\VSDSync.exe"

if (Test-Path $vdsPath) {
    Write-Host "`n`nSyncing:"
    Start-Process -FilePath $vdsPath -RedirectStandardInput $enterFile -Wait
    Write-Host "`nComplete!"
} else {
    Write-Host "`nError: Cannot find VDSSync.exe"
}