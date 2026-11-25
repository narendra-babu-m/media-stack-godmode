# install-flaresolverr.ps1
# Installs FlareSolverr v3.5.2 as an auto-start Windows service via NSSM.
# Run from an elevated PowerShell on the Windows box.
$ErrorActionPreference = "Stop"

$FS_VERSION = "v3.5.2"
$FS_DIR     = "C:\FlareSolverr"
$NSSM_DIR   = "C:\nssm"

# --- Download + extract FlareSolverr ---
New-Item -ItemType Directory -Force -Path $FS_DIR | Out-Null
$fsZip = "$FS_DIR\flaresolverr.zip"
$fsUrl = "https://github.com/FlareSolverr/FlareSolverr/releases/download/$FS_VERSION/flaresolverr_windows_x64.zip"
Write-Host "Downloading FlareSolverr $FS_VERSION ..."
Invoke-WebRequest -Uri $fsUrl -OutFile $fsZip
Expand-Archive -Path $fsZip -DestinationPath $FS_DIR -Force

# --- Download NSSM (service wrapper) ---
New-Item -ItemType Directory -Force -Path $NSSM_DIR | Out-Null
$nssmZip = "$NSSM_DIR\nssm.zip"
Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile $nssmZip
Expand-Archive -Path $nssmZip -DestinationPath $NSSM_DIR -Force
$nssm = (Get-ChildItem "$NSSM_DIR" -Recurse -Filter "nssm.exe" | Where-Object { $_.FullName -match "win64" } | Select-Object -First 1).FullName

# --- Install as service ---
$fsExe = "$FS_DIR\flaresolverr\flaresolverr.exe"
& $nssm install FlareSolverr $fsExe
& $nssm set FlareSolverr AppDirectory "$FS_DIR\flaresolverr"
& $nssm set FlareSolverr Start SERVICE_AUTO_START
& $nssm set FlareSolverr AppStdout "$FS_DIR\service.log"
& $nssm set FlareSolverr AppStderr "$FS_DIR\service.log"
& $nssm start FlareSolverr

Start-Sleep -Seconds 20
Write-Host "FlareSolverr health:" (Invoke-RestMethod "http://127.0.0.1:8191/" -TimeoutSec 15).msg
