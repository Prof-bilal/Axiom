# Axiom Hub 2.0: architecture and performance strategy

Scope: research and design only. No code changes. Tags: **[V]** verified against a primary source (URL given) or the repository file named; **[A]** assumption or estimate, to be measured.

Existing code this builds on: `system/pkgd/axiom-pkgd` (root helper: install, sync, remove, update, rollback, snapshots; `pacman`, `snapper`, `logger -t axiom-pkgd`) [V]; `apps/hub/backends.js` (pure argv builders, progress parsing, `installedIds`) [V]; `apps/hub/HubBackend.qml` (one transaction at a time, `pkexec` for pacman, `flatpak --user` for Flathub, cancel by stopping the `Process`) [V].

## 1. Component diagram and process boundaries

```
+--------------------------- user session (unprivileged) -------------------------+
|                                                                                 |
|  Quickshell Hub UI (QML)  --- stdin/stdout JSON lines --->  axiom-hubd query    |
|  (renders, never does I/O  <-- results, progress events --   (session child:     |
|   on the GUI thread)                                         search, catalogue, |
|        |                                                     queue state)       |
|        | systemd-run --user --unit=axiom-hub-job-<id>       |                   |
|        v                                                    |  SQLite (XDG)     |
|  flatpak --user / npm -g --prefix ~/.local / pipx           |  cache + state     |
|  (per-job transient unit, cgroup-killable)                  +-------------------+
|                                                                                 |
+--------------|---------------------------------------------------------------+
               | pkexec + polkit action per operation (org.axiom.installer.*)  |
+--------------v---------------------------------------------------------------+
| root (short-lived): axiom-pkgd <op> <job-id>                                  |
|   runs `systemd-run --system --unit=axiom-pkg-job-<id>` around pacman/snapper |
|   flock /run/axiom-pkgd.lock (serialise), writes job events to a root-owned  |
|   jsonl file the user can read, logger -t axiom-pkgd                           |
+-------------------------------------------------------------------------------+

Read-only adapters, unprivileged, run inside axiom-hubd:
  - pacman: read /var/lib/pacman/sync/*.db (world-readable [A]) and `pacman -Q` (no root)
  - Flathub: HTTPS appstream.xml.gz with conditional GET (dl.flathub.org) [A URL]
  - npm / pipx: `npm ls -g`, `pipx list --short` (existing in backends.js) [V]
```

Why each boundary exists:
- **UI vs. axiom-hubd.** The UI must not block on disk or network. Quickshell's `Process` runs external programs asynchronously and streams stdout lines [V: `Quickshell.Io.Process`, `SplitParser` types listed at https://quickshell.org/docs/v0.1.0/types/Quickshell.Io/Process]. Parsing and indexing stay out of QML.
- **axiom-hubd vs. root helper.** Catalogue and search need no privilege, so they must not run as root. Only the install/remove/update operations cross into root, matching the existing rule "UI never runs as root; privileged APIs are narrow" (AGENTS.md) [V].
- **Root helper vs. backends.** pacman and snapper need root. The helper is the only place that authorises the target (package name validated against `^[a-z0-9@._+-]+$`, already present) [V].
- **Per-backend adapters.** Each source has different metadata, failure modes and locks. Keeping them as separate adapters behind one normalised record lets a broken source fail alone (see section 9).

Polkit: `pkexec` checks an action ID defined in a `.policy` file, per subject, per call [V: https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html]. The helper already keeps `install`, `update` and `rollback` as separate actions (`axiom-pkg-update`, `axiom-pkg-rollback`) [V]. Cancel should be its own action with `allow_active=yes`, because it only stops a job the same user started [A design choice].

## 2. Daemon or on-demand: recommendation

Options:
- **A. On-demand CLI per request.** Simplest; no state between calls. Cost: process start per keystroke. A Python or Node start is typically tens of milliseconds [A], which consumes most of the 50 ms keystroke budget (section 11).
- **B. Session child process** owned by the Hub window: started when the window opens, exits when it closes. Keeps the index open and answers queries over stdin/stdout. No persistence, no socket, no autostart.
- **C. Long-running user daemon** (`systemd --user` service). Needed only if installs must survive closing the window or logout.

**Recommendation: B for search and catalogue, transient units for jobs, a user timer for metadata refresh. No daemon.**
- B avoids per-keystroke spawn cost and dies with the UI, so there is nothing to supervise.
- Jobs run as `systemd-run` transient units [V: https://www.freedesktop.org/software/systemd/man/latest/systemd-run.html, `--user` selects the user manager, units are created and started, `-p` sets unit properties]. A job then survives a Quickshell reload and is cancelled by stopping its unit, which stops the whole cgroup including pacman's child processes [A: cgroup kill semantics]. This also fixes the current cancel path, which only stops the `Process` wrapper (`proc.running = false` in HubBackend.qml) and may leave a root pacman running.
- A refresh runs as a `oneshot` service started by a user timer (section 8). A oneshot is not a daemon.
- Promote to C only if a measured requirement appears: installs must continue after the window closes, or unattended updates are wanted. Each is a separate ADR under AGENTS.md ("every daemon requires justification").

## 3. Search index

Corpus estimate: Arch core+extra+multilib is on the order of 12k to 15k packages [A]; Flathub is a few thousand apps [A]. Total roughly 15k to 25k rows [A]. The user's "tens of thousands" is consistent with this.

Row size: name, description, version, repo, URL, categories, license: about 0.5 to 1.5 KB per row [A]. Raw corpus: about 10 to 40 MB [A]. The Flathub appstream XML is typically tens of megabytes uncompressed, and the gzip copy is several megabytes [A, must measure on the real URL].

Options:
- **In-memory JS array** (what `catalog.js` does today for ~tens of apps). For 20k rows, a linear substring filter costs roughly 1 to 5 ms per keystroke in a JS engine [A]. Heap cost roughly 15 to 30 MB [A]. Cold start requires re-parsing sources: seconds [A]. No ranking beyond hand-written rules.
- **SQLite with FTS5** [V: https://sqlite.org/fts5.html: `CREATE VIRTUAL TABLE ... USING fts5`, `MATCH`, prefix queries with `*`, `bm25()` ranking, `unicode61` and `porter` tokenizers, `prefix=` option for faster prefix queries, available since 3.9.0]. Index size roughly 1.5 to 2.5 times the raw text [A]. Query time for prefix plus bm25 over 20k rows: low single-digit milliseconds [A]. Opens in tens of milliseconds [A]. Persistent, so the index is built once per refresh, not per launch.

**Recommendation: SQLite FTS5 in `axiom-hubd`**, with one `apps` table for normalised metadata plus an FTS5 table over name, summary and keywords, `prefix='2 3'` [A]. Ranking: bm25 with column weights (name > summary > keywords), plus an exact-name boost. Use `unicode61 remove_diacritics 2`. The trigram tokenizer is an option for substring matching in package names, at roughly 3 times the index size [A].

Build: `pacman` sync DBs are read directly rather than by shelling out per package [A: they are tar archives of `desc` files; verify format against pacman's source before relying on it]. Flathub appstream is parsed once per refresh with a streaming XML parser, not loaded whole.

## 4. Result caching

| Source | Refresh trigger | Policy | Conditional request |
|---|---|---|---|
| pacman sync DB | user presses Refresh, or a user timer at most once per 24 h, skipped on metered connections [A] | Never refreshed by a search. The helper's `sync` already runs `pacman -Syu` on an installed system, so no second refresh is needed before install [V: axiom-pkgd] | Not applicable; pacman handles it |
| Flathub appstream | on Hub open if older than 24 h, or on Refresh [A] | TTL 24 h | `If-None-Match` with the stored ETag, and `If-Modified-Since` with the stored `Last-Modified`. On 304, only update `fetched_at` [V: RFC 9110 defines `If-None-Match`, `If-Modified-Since`, `ETag`, `Last-Modified` and 304 semantics in section 13; https://www.rfc-editor.org/rfc/rfc9110.html. Only the section list was confirmed by fetch, the semantics are from the RFC] |
| npm / pipx lists | on demand, never for search | Local listing only, no network | Not applicable |
| Icons, screenshots | first view | Cache by URL hash | ETag as above |

Disk location:
- Index and icons: `$XDG_CACHE_HOME/axiom-hub/` (default `~/.cache/axiom-hub/`) [A: XDG Base Directory spec]. Regenerable, so it may be deleted at any time.
- **Installed-app database is not cache.** It is state and must go under `$XDG_STATE_HOME/axiom-hub/` [A], so a cache cleanup never loses install records.
- Downloads: `.part` files, renamed on success, removed on failure.

Size cap: 300 MB total for cache, with LRU eviction of icons and screenshots only. The catalogue index is rebuilt, not evicted [A default; tune after measuring].

## 5. Installation queue and locking

Rules:
1. **pacman:** one transaction at a time system-wide. pacman already takes `/var/lib/pacman/db.lck` [A: pacman's standard lock], but a second `pkexec` would then fail with a lock error instead of queuing. The helper takes `flock` on `/run/axiom-pkgd.lock` before any op; the UI queue holds the job until the lock is free. Both layers are needed: the UI prevents the common case, the helper prevents two windows or a stale UI from racing.
2. **Flatpak user installs:** one at a time per user, via a user lock at `$XDG_RUNTIME_DIR/axiom-hub/flatpak.lock` [A]. Flatpak's own repo lock is an additional safety, not the design.
3. **Per (source, ref):** a job key `source:ref:action` is unique among non-terminal jobs. A second request for the same key returns the existing job ID.
4. **Across sources:** pacman and Flathub may run in parallel, since they use different locks and disks. npm and pipx run in parallel with each other only if they use different prefixes [A].

Idempotency (double-click):
- The UI disables the action on the first click (`busy` in HubBackend.qml already guards one UI instance) [V].
- The durable guard is the job table: `INSERT ... ON CONFLICT(job_key) WHERE state IN ('queued','running') DO NOTHING` [A, SQLite partial unique index], so a reload or a second window cannot start a duplicate.
- The helper rejects an op whose job ID is already running [A].

Duplicate downloads:
- pacman caches packages in `/var/cache/pacman/pkg` and skips already-cached files [A]. Two jobs for the same package are impossible under the pacman lock.
- Flatpak deduplicates objects through ostree [A]. Serialising by ref avoids two concurrent pulls of the same commit.
- Helper and UI write to `.part` and rename atomically [A].

Queue model: FIFO per lock domain. Batch installs (several apps) run as one job so polkit prompts once. Note: polkit `auth_admin_keep` can keep authorisation for a few minutes [V: polkit.8], but the docs warn it applies to later checks of the same action and subject. Use `auth_admin` (prompt every time) for installs, and use `_keep` only if measured prompt fatigue justifies it [A design choice].

## 6. Progress and cancellation

Sources of progress, best first:
- **pacman:** prints `(n/m) installing <pkg>` and similar phase lines [A: verify exact wording on the target pacman version]. These are structured enough to map to steps. The current `parseProgress` (percent or `done/total` regex) matches neither reliably [V: backends.js].
- **pacman download bytes:** pacman's progress bar is suppressed when stdout is not a TTY [A]. Estimate by polling the `.part` size in the cache against `CSize` from the sync DB every 250 ms [A]. This is the only real byte progress without patching pacman.
- **flatpak:** prints per-object progress lines; parse these, and fall back to a phase spinner [A].
- **npm / pipx:** no reliable percentage [A]. Phase spinner only, and say so in the UI.

Transport: the helper and worker append JSON-lines events (`job`, `phase`, `pct` or null, `msg`) to a per-job file. The root-side file is root-owned and world-readable, so the UI can read it but not write it [A]. The UI tails the file through a `Process`. Events are rate-limited to 4 per second.

UI mapping: the ring shows `pct` when known, a phase label otherwise. Never show a percentage that the source did not produce.

Cancellation delivery:
1. UI calls `pkexec axiom-pkgd cancel <job-id>` (separate action `org.axiom.installer.cancel`, `allow_active=yes` [A design]) for root jobs, or `systemctl --user stop axiom-hub-job-<id>.service` for user jobs.
2. The helper validates that `<job-id>` belongs to a job it started and runs `systemctl stop axiom-pkg-job-<id>.service`. Stopping the unit sends SIGTERM to the cgroup, and SIGKILL after the timeout [A: systemd default; systemd-run doc mentions the termination signal path].
3. A cancelled pacman transaction may leave `db.lck` and partial files. Those go to section 9 as "interrupted", not "canceled cleanly".
4. Cancel is refused during the post-transaction step (hooks, snapshot cleanup) to avoid stopping in the middle of a hook [A].

## 7. Installed-application database

Schema (single table, as required):

```sql
CREATE TABLE installed_apps (
  source       TEXT NOT NULL,      -- pacman | flatpak | npm | pip | local
  ref          TEXT NOT NULL,      -- package name or flatpak app id
  version      TEXT,
  installed_at INTEGER NOT NULL,   -- unix seconds
  origin       TEXT NOT NULL,      -- hub | external (found on start, not installed by Hub)
  prev_commit  TEXT,               -- flatpak only: commit before last update, for rollback
  PRIMARY KEY (source, ref)
);
```

The job table is separate and small (`job_key`, `state`, `action`, `started_at`, `pid`, `unit`). The "single table" requirement covers installed state; jobs need persistence to deduplicate across reloads, which is a justified second table [A].

Reconciliation on each start (under 200 ms target):
- pacman: `pacman -Q` (names and versions). Apps in the Hub catalogue that are present are added as `origin=external` if no row exists.
- flatpak: `flatpak list --app --columns=application,version` [A].
- npm / pipx: existing listings in backends.js [V].
- Drift:
  - Present on the system, missing in DB: insert with `origin=external`, `installed_at` = first seen.
  - In DB, missing on the system: mark `state=missing` (show it, do not delete silently). Remove the row after the user confirms or after a successful Hub remove.
  - Version changed: update `version`, keep `origin`.
- Reconciliation only reads. It never installs, removes or repairs.

Current behaviour to change: `installedIds` only reports installed items that exist in the catalogue [V: backends.js]. Apps outside the catalogue are invisible, which is why the DB must be built from the system listings, not the catalogue.

## 8. Update manager

When to check:
- Not on every launch. Check when the user opens the Updates view, and by a user timer (`OnCalendar` daily, `Persistent=true`, skipped on metered connections) [A]. Timer activation runs a oneshot unit, not a daemon.
- pacman updates: `pacman -Qu` after a sync, which requires a refresh. Reuse the timer refresh; do not sync on launch.
- Flatpak updates: `flatpak remote-ls --updates` (existing) [V: HubBackend.qml].

Showing: a badge with a count on the Updates item, and a list with current and new version. Do not show a badge from a stale check older than 48 h [A].

Snapshot first:
- pacman: the helper already snapshots with snapper and deletes the snapshot if the update fails [V: axiom-pkgd `update`]. Keep that; if snapper is absent, refuse, as now.
- Flatpak: record `prev_commit` in the DB before updating [A]; rollback is then `flatpak update --commit=<prev>`. Verify this command on the target flatpak version before promising it.
- npm / pipx: record the installed version before updating; rollback is reinstalling the old version [A].
- Never promise universal undo (AGENTS.md). The UI should say "snapshot available" or "rollback not available for this source".

Finding to fix: installing one package from the Hub on an installed system runs `pacman -Syu` (full upgrade), not a single-package install [V: axiom-pkgd `sync`, "Installed: a database refresh without a full upgrade is an unsupported partial upgrade, so upgrade too"]. This is correct for Arch, but the Hub should say that an install may upgrade the whole system, and ideally offer to run the update first.

## 9. Logging and error recovery

Logging:
- User side: `logger -t axiom-hub` with fields `job=<id> source=<s> ref=<r> action=<a> state=<s>` [A]. Search queries are never logged; log counts and timings only (privacy).
- Root side: keep `logger -t axiom-pkgd`, which already records sha256 and uid [V], and add `job=<id>`.
- Read back with `journalctl -t axiom-pkgd -t axiom-hub -o json` [A].

Job states: `queued -> running -> succeeded | failed | canceled | interrupted`.
- On start, any `running` job whose PID or unit is gone becomes `interrupted`.

Recovery per backend after a crash mid-install:
- **pacman:** `db.lck` remains. Recovery only when no `pacman` process is alive (check by `pgrep -x pacman` and the unit state, not by file age) [A]. Then the helper op `unlock` removes `db.lck` as root, logs it, and runs `pacman -Qk <pkg>` on the job's package. If files are missing or half-written, run `pacman -S --noconfirm <pkg>` to reinstall the same version. If the package set is unclear, offer snapshot rollback (`axiom-pkgd rollback`), not a guess. Never delete `db.lck` while pacman runs.
- **flatpak:** ostree commits are atomic, so the app is either deployed or not [A]. Run `flatpak repair --user` (verify flags on the target version), then re-run the install. Clean any `.part` files.
- **npm / pipx:** remove the partial prefix entry (`npm uninstall -g`, or `pipx reinstall`), then reinstall [A].
- **UI reload mid-job:** the worker continues in its own unit. On reconnect, the UI reads the job file and state, and shows the live job, not a fresh start.

Error messages: show the last meaningful line plus a link to the journal entry, not raw stderr only. Note that the current `finish()` takes the last log line as the error, which is often a progress line [V: HubBackend.qml].

## 10. Preventing listed failures

| Risk | Mechanism |
|---|---|
| Duplicate downloads | Job key unique among non-terminal jobs; per-source lock; `.part` + atomic rename; pacman cache |
| Conflicting transactions | `flock /run/axiom-pkgd.lock` in helper; user `flatpak.lock`; UI queue |
| Multiple simultaneous pacman runs | pacman `db.lck` plus helper `flock`; UI queues instead of failing |
| Broken installation | Snapshot before pacman `sync`/`remove` (exists); signature enforcement `LocalFileSigLevel = Required` (exists per helper comments); post-check `pacman -Qk <pkg>` |
| Unnecessary metadata downloads | Conditional GET with ETag and `If-Modified-Since`; TTLs; no refresh on search or launch |
| Untrusted installation scripts | pacman install scripts run as root: mitigate with signed repos and the existing `LocalFileSigLevel`; show "runs install scripts" for local packages; npm: `--ignore-scripts` by default with an opt-in, since postinstall runs as the user [A]; flatpak: sandboxed by default [A] |
| Inconsistent application records | DB row written in the same step as job success; reconciliation on start; `origin` field; `missing` state instead of silent delete |
| Unauthorised root actions | Narrow polkit actions per operation; helper validates package names; cancel only stops its own job IDs |
| Runaway resource use | Transient units with `MemoryMax=` and `CPUWeight=` for user jobs [A: systemd.resource-control(5), which the systemd-run doc points to; not verified here] |
| Cancel leaves processes | Cancel via unit stop (cgroup), not by killing the wrapper |

## 11. Performance budget and measurement

| Target | Budget (proposed) | Method |
|---|---|---|
| First paint of Discover, warm cache | under 300 ms [A] | Timestamp at Hub `Component.onCompleted` and at first frame; Qt Quick render timing (`QSG_RENDER_TIMING=1` [A, verify]); run 20 cold/warm starts and report p50/p95 |
| First paint, cold cache (no index) | under 1.5 s, with a skeleton list shown immediately [A] | Same; the index build runs off the UI thread and never blocks paint |
| Search keystroke to results (20k rows) | p95 under 50 ms, including the IPC round trip [A] | Timestamp at key event, at result render; drive with a scripted keystroke sequence in the Hub; also time `axiom-hubd` query alone with `hyperfine` or an in-process timer |
| Index open and query, helper-free | p95 under 10 ms for the query itself [A] | Microbenchmark in `tests/apps` using a fixture index of 20k generated rows |
| Install start (click to first job event) | under 500 ms, excluding the polkit prompt [A] | Timestamp at click, at first `running` event in the job file; polkit time is measured separately so it is not hidden |
| Reconciliation on start | under 200 ms [A] | Timestamp around the listing commands |
| Memory, Hub idle | under 150 MB RSS including the session child [A] | `/proc/<pid>/status` VmRSS after 60 s idle, for the UI and `axiom-hubd` separately |

Method rules (AGENTS.md: performance claims require measurements):
- Report p50 and p95 over at least 20 runs, on the QEMU image and on real hardware, with the machine described.
- Keep the fixture size and the real corpus size as separate numbers.
- Do not claim a figure from this document until it is measured; every number above marked [A] is a target to test.

## Open questions

1. Should installs survive closing the Hub window? If yes, the design moves to option C (user service) and needs an ADR.
2. Should a Hub install on an installed system run a full upgrade silently, or ask first? Today it does `pacman -Syu` (section 8).
3. Is `auth_admin` on every install acceptable, or is the prompt fatigue of batch-free installs a problem to measure?
4. Does the target flatpak version support `flatpak update --commit=` and `flatpak repair --user` as described? Needs a test in QEMU with networked flatpak.
5. Is `pkexec` with the program path enough for the new per-operation actions, or should the helper be invoked via `systemd` activation to avoid argument-based policy? Needs a check of the current `.policy` file.
6. Does pacman's sync DB format parse reliably from unprivileged Python, and are the sync DB files world-readable on the target image?
7. Is SQLite with FTS5 available in the Python build the helper uses, or does it need to be bundled? Check on the image.
8. Where should `axiom-hubd` be written: Python (stdlib sqlite3) or a compiled language? The choice affects startup and the 10 ms query budget; measure both before deciding.
9. Trigrams for substring package-name matching: is the 3 times index size worth it, or do prefix queries cover real use?
10. npm `--ignore-scripts` by default: acceptable breakage for the catalogue entries that need postinstall?
