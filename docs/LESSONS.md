# Lessons Learned

Hard-won notes from building this stack. Each one cost real debugging time.

### 1. A "dead" tracker is almost always DNS poisoning
ISPs sinkhole torrent domains at the DNS layer — the site resolves to a fake IP and every connection silently times out, looking exactly like the tracker is down. **Always** test with `Resolve-DnsName <site> -Server 1.1.1.1` before blaming the indexer. Fix: static Cloudflare/Google DNS on the adapter.

### 2. FlareSolverr must be a Windows *service*, never a Scheduled Task
FlareSolverr bundles a headless Chromium. Scheduled Tasks run in **session 0**, which has no interactive desktop, so Chromium fails to launch and FlareSolverr dies on startup. Install it as a service (NSSM) — services get a usable context. This cost the most time of anything in the build.

### 3. You cannot launch GUI apps over SSH
An SSH session lands in session 0. GUI apps (like qBittorrent) need the interactive user session (session 1/2). Launching qbittorrent.exe directly over SSH starts a process that immediately exits. Fix: a Scheduled Task with `schtasks /Run` injects the process into the logged-in session.

### 4. qBittorrent rewrites its .ini on exit
Edit the ini while qBittorrent is running and your changes vanish when it closes. **Stop the process first**, edit, then relaunch.

### 5. qBittorrent v5.1.0 Python detection loop
v5.1.0 has a bug where it fails to auto-detect Python for the Search tab, looping "Python not found". Fix: set `Search\PythonExecutablePath=` explicitly in the ini to the full `python.exe` path.

### 6. De-duplicate search plugins vs Jackett indexers
qBittorrent ships native search plugins (1337x, piratebay, eztv, ...). If Jackett already covers those trackers, every result appears twice. Remove the overlapping native plugins from `nova3/engines/`; keep only ones Jackett doesn't cover (e.g. fitgirl_repacks, dodi_repacks) plus the `jackett` bridge.

### 7. Toggling Wi-Fi/NIC settings bounces SSH
Disabling NIC power-saving (or any adapter change) resets the adapter — any live SSH session drops and takes ~2–3 minutes to recover. This is expected. Because all services are detached (Windows service / scheduled task), they keep running through the bounce.

### 8. Courses are the weakest category on public torrents
Online courses (Udemy/Coursera/MasterClass) are sparse and mis-tagged on public trackers. Search by **instructor name**, not platform. For serious course hunting, direct-download sites (SAnet, FreeCourseSite) often beat torrents.

### 9. Public trackers are flaky by design
Any given search will have a few trackers time out (magnetcat, eztv mirrors, etc.). This is normal — the aggregate of ~36 still returns plenty. Don't chase individual tracker failures.
