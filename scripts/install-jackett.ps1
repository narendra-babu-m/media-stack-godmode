# install-jackett.ps1
# Points an existing Jackett install at FlareSolverr and enables the search cache.
# Assumes Jackett is already installed (service "Jackett") with ServerConfig.json.
$ErrorActionPreference = "Stop"

$cfgPath = "C:\ProgramData\Jackett\ServerConfig.json"
if (-not (Test-Path $cfgPath)) { throw "Jackett config not found at $cfgPath" }

$cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
$cfg.FlareSolverrUrl          = "http://127.0.0.1:8191"
$cfg.FlareSolverrMaxTimeout   = 55000
$cfg.CacheEnabled             = $true
$cfg.CacheTtl                 = 2100
$cfg.CacheMaxResultsPerIndexer = 1000
$cfg.AllowExternal            = $false

$cfg | ConvertTo-Json -Depth 10 | Set-Content $cfgPath -Encoding UTF8
Restart-Service Jackett -Force
Start-Sleep -Seconds 6
Write-Host "Jackett reconfigured for FlareSolverr. Dashboard: http://127.0.0.1:9117"
Write-Host "Add indexers from the dashboard; Cloudflare-walled ones will route through FlareSolverr automatically."
