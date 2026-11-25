# setup-power.ps1  —  "Windows caffeinate"
# Keeps the machine awake and SSH-reachable with the lid closed.
# Run from an elevated PowerShell.
$ErrorActionPreference = "SilentlyContinue"

# Never sleep / hibernate / blank display on AC power
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /change monitor-timeout-ac 0

# Lid close = Do Nothing (both AC and battery)
$sub = "4f971e89-eebd-4455-a8de-9e59040e7347"   # Power buttons and lid
$set = "5ca83367-6e45-459f-a27b-476b1d01c936"   # Lid close action
powercfg /setacvalueindex SCHEME_CURRENT $sub $set 0
powercfg /setdcvalueindex SCHEME_CURRENT $sub $set 0
powercfg /setactive SCHEME_CURRENT

# Disable hibernate entirely
powercfg /hibernate off

# Stop the NIC from being powered down to save energy (keeps SSH alive)
# NOTE: this briefly bounces the adapter — an SSH session will drop and reconnect.
$nic = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
Set-NetAdapterPowerManagement -Name $nic.Name -AllowComputerToTurnOffDevice Disabled

Write-Host "Power config applied. Machine will stay on with the lid closed."
