# setup-qbit-autostart.ps1
# Registers qBittorrent to auto-launch in the interactive user session on logon,
# so its GUI + WebUI come back after a reboot. Run as the logged-in user.
$ErrorActionPreference = "Stop"

$exe = "C:\Program Files\qBittorrent\qbittorrent.exe"
if (-not (Test-Path $exe)) { throw "qBittorrent not found at $exe — edit this path." }

Unregister-ScheduledTask -TaskName "qBittorrent-GUI" -Confirm:$false -ErrorAction SilentlyContinue

$action   = New-ScheduledTaskAction -Execute $exe
$trigger  = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask -TaskName "qBittorrent-GUI" -Action $action -Trigger $trigger `
  -Settings $settings -User $env:USERNAME -RunLevel Limited -Force

Start-ScheduledTask -TaskName "qBittorrent-GUI"
Write-Host "qBittorrent will auto-start on logon and is launching now."
