# Path to GCTRealMate
$gctPath = ".\sd_base\sBrawl\GCTRealMate.exe"
$enterFile = ".\sd_base\sBrawl\enter.txt"
$sourceInjectDir = ".\sd_base\sBrawl\Source\Community\Injects"
$destInjectDir   = ".\sd_base\sBrawl\pf\injects"

# Check if GCTRealMate exists
if (-not (Test-Path $gctPath)) {
    Write-Host "`nError: Cannot find GCTRealMate.exe" -ForegroundColor Red
    pause
    exit
}
# Create destination folder if it doesn't exist
if (-not (Test-Path $destInjectDir)) {
    New-Item -ItemType Directory -Path $destInjectDir -Force | Out-Null
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