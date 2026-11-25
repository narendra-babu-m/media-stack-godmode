# 🏴‍☠️ Media Stack — qBittorrent + Jackett + FlareSolverr (God Mode)

A self-hosted, one-search-box media & learning aggregation stack for Windows.
One search in qBittorrent → **movies, TV, games, audiobooks, courses, ebooks** across ~36 torrent trackers, with Cloudflare-protected sites handled automatically.

> Best-practice configs, install scripts, and hard-won lessons. All secrets are templated — fill in your own before use.

---

## Architecture

```
qBittorrent (Search tab)
      │  jackett.py plugin
      ▼
   Jackett  ──(Cloudflare-walled trackers)──▶  FlareSolverr (headless Chromium)
      │
      ▼
  ~36 torrent trackers  ──▶  aggregated results back in qBittorrent
```

| Component | Role | Default port |
|---|---|---|
| **qBittorrent** v5.1.0 | Download client + unified Search tab | WebUI `8080` |
| **Jackett** v0.25 | Torznab proxy — one query → every tracker | `9117` |
| **FlareSolverr** v3.5.2 | Solves Cloudflare challenges | `8191` |

---

## Quick start

1. Install qBittorrent, then run the scripts in [`scripts/`](scripts/) (PowerShell, from the Windows box):
   - `install-flaresolverr.ps1` — downloads FlareSolverr + NSSM, installs it as an auto-start Windows **service**.
   - `install-jackett.ps1` — points Jackett at FlareSolverr and enables the search cache.
   - `setup-power.ps1` — the "Windows caffeinate": never sleep, lid-close = do nothing, so the box keeps running with the lid shut.
   - `setup-qbit-autostart.ps1` — scheduled task so qBittorrent's GUI + WebUI return after reboot.
2. Copy the templates, fill in your own secrets:
   - `qbittorrent/qBittorrent.ini.template` → `%APPDATA%\qBittorrent\qBittorrent.ini` (generate your own WebUI password hash — see below).
   - `jackett/ServerConfig.template.json` → `C:\ProgramData\Jackett\ServerConfig.json` (paste your own Jackett API key).
3. Install the search plugin: drop `jackett.py` into `%LOCALAPPDATA%\qBittorrent\nova3\engines\` and set the Python path in qBittorrent → Options → Search.

Full step-by-step + troubleshooting in [`docs/SETUP.md`](docs/SETUP.md).

---

## How to search (the part that matters)

qBittorrent → **Search** → type → **All plugins**.

| Want | Search for |
|---|---|
| Movies / TV | the title |
| PC games | `FitGirl <game>` or `DODI <game>` |
| Audiobooks | title or author |
| **Courses** (Udemy/Coursera/MasterClass) | the **instructor name**, not the platform |
| Ebooks | title, or `<topic> megapack` |

Courses are mis-tagged into generic "Other" categories on public trackers, so platform names return junk — search **people**: `Andrew Ng`, `Jeff Nippard`, `Wharton`, `Hormozi`, `Precision Nutrition`.

---

## Lessons learned (the expensive ones)

1. **A dead tracker is usually DNS, not the tracker.** ISPs sinkhole torrent domains via DNS poisoning → silent timeouts. Set static DNS (`1.1.1.1` / `8.8.8.8`) and test with `Resolve-DnsName <site> -Server 1.1.1.1`.
2. **FlareSolverr must be a Windows *service*, never a Scheduled Task.** Session 0 has no desktop → bundled Chromium won't launch. NSSM service runs it correctly.
3. **GUI apps can't be launched over SSH** (SSH lands in session 0). Use a scheduled task to inject into the interactive session.
4. **qBittorrent rewrites its `.ini` on exit** — stop qBittorrent *before* editing the file, or your edits get clobbered.
5. **qBittorrent v5.1.0 Python detection is buggy** — set the explicit Python path in the `.ini`; don't rely on auto-detect.
6. **De-dupe search plugins.** Remove native plugins that duplicate your Jackett indexers, or every result shows twice.

More in [`docs/LESSONS.md`](docs/LESSONS.md).

---

## Generating a WebUI password hash

qBittorrent stores the WebUI password as a PBKDF2-HMAC-SHA512 hash. Generate your own:

```python
import hashlib, base64, os
pw = "your-password-here"
salt = os.urandom(16)
dk = hashlib.pbkdf2_hmac("sha512", pw.encode(), salt, 100000, dklen=64)
print(f'@ByteArray({base64.b64encode(salt).decode()}:{base64.b64encode(dk).decode()})')
```

Paste the output into `WebUI\Password_PBKDF2=` in the ini.

---

## ⚠️ Legal

This repo contains **configuration and automation only** — no copyrighted content and no tracker credentials. Use it to access content you have the legal right to (public-domain works, Linux ISOs, content you own, Creative-Commons media). You are responsible for complying with the laws of your jurisdiction. A VPN is strongly recommended.

---

## License

MIT — see [LICENSE](LICENSE).
