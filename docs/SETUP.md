# Setup Guide

Target: Windows 10/11 machine. All PowerShell scripts live in [`../scripts/`](../scripts/).

## 0. Prerequisites
- qBittorrent v5.x installed (`C:\Program Files\qBittorrent\`)
- Jackett v0.25+ installed as a service
- Python 3.12+ installed (for the qBittorrent search plugin)

## 1. FlareSolverr (Cloudflare bypass)
Run elevated:
```powershell
.\scripts\install-flaresolverr.ps1
```
Installs FlareSolverr as an auto-start Windows **service** (NSSM). Verify: `http://127.0.0.1:8191/` returns `FlareSolverr is ready!`.

## 2. DNS (critical — fixes "dead" trackers)
Many ISPs DNS-poison torrent domains. Set clean DNS on the active adapter:
```powershell
$nic = Get-NetAdapter | ? {$_.Status -eq "Up"} | select -First 1
Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses ("1.1.1.1","8.8.8.8","1.0.0.1")
Clear-DnsClientCache
Resolve-DnsName 1337x.to -Server 1.1.1.1   # should return a real Cloudflare IP
```

## 3. Jackett
```powershell
.\scripts\install-jackett.ps1
```
Then open `http://127.0.0.1:9117`, add indexers (see below), and copy your API key into the live `ServerConfig.json` (template in [`../jackett/`](../jackett/)).

**Recommended public indexers:** 1337x, The Pirate Bay, YTS, TorrentGalaxy, LimeTorrents, EZTV, AudioBookBay, EBookBay, AcademicTorrents, Zooqle, plus region-specific ones (e.g. 1TamilMV).

## 4. qBittorrent config
1. **Stop qBittorrent fully** (it rewrites the ini on exit).
2. Copy `qbittorrent/qBittorrent.ini.template` → `%APPDATA%\qBittorrent\qBittorrent.ini`.
3. Generate your own WebUI password hash (see README) and paste into `WebUI\Password_PBKDF2=`.
4. Fix the `FileLogger\Path` and `Search\PythonExecutablePath` to your real username.

## 5. Search plugin
```powershell
$eng = "$env:LOCALAPPDATA\qBittorrent\nova3\engines"
mkdir $eng -Force
curl.exe -L -o "$eng\jackett.py" "https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/jackett.py"
```
Create `$eng\jackett.json` with your Jackett URL + API key:
```json
{ "api_key": "YOUR_KEY", "thread_count": 20, "tracker_first": false, "url": "http://127.0.0.1:9117" }
```
Set the Python path in qBittorrent → Options → Search → Python executable.

## 6. Stay-awake + auto-start
```powershell
.\scripts\setup-power.ps1          # lid-shut operation
.\scripts\setup-qbit-autostart.ps1 # WebUI returns after reboot
```

## 7. Verify end-to-end
qBittorrent → Search → "interstellar" → All plugins. You should get hundreds of results.
