# Track 3 / Agent 3: Axiom Hub MVP spec

Date: 2026-11-10. Inputs: judge verdicts (Hub 17, BUILD), repo read-only. Git behaviour below was tested locally (git 2.56.0).

## 0. Challenges to the verdict
1. **Name collision.** "Developer Hub" already exists (ADR-021, `catalog/developer-hub.json`, planned `apps/hub/`): it is a first-boot *provisioning* catalogue (install toolchains/containers). It shares nothing with a project-decision tool: no data, no code, different moment (once vs daily). Do NOT merge. Rename the new thing **Axiom Projects** (CLI `axiom-projects`, Launcher prefix `p`) and leave "Hub" to ADR-021. This spec says "Projects" from here. Only link: the Dev Hub may later be reachable from the same Launcher; no coupling.
2. **Smaller than the verdict.** Cut: panel/lock-screen widget (see 8), systemd timer, kill-by notifications (show it in the Launcher row and `today` output instead; a notification needs a daemon or timer and is the nag that gets disabled), "last N shell commands" in resume (needs shell hooks = untrusted-input and zsh-only; resume = note + branch + dirty files + last commit subject).
3. **Dependency risk.** The Launcher provider API and `ActionService` are *planned* (track-2 spec, ~4 wk), not built (`Launcher.qml` is 245 lines, apps only). So the MVP must be useful with the CLI alone and treat the Launcher provider as phase 2 of the build. Otherwise Projects is blocked on Launcher+.
4. **Honest gap.** The git half is crowded (drydock, ovw, dev-pulse). The only novel half is decision fields + kill-by + deterministic pick. If after 4 weeks of daily use `today` is ignored, kill it; that is the success test (section 9).

## 1. Problem and user
One developer, many repos, "which one today?" paralysis, weak idea validation, friction re-entering a project. Same shape fits any indie maker. Not a PM tool: one user, one machine.

## 2. Features
**MVP**
- `axiom-projects scan`: discover repos, cache git facts.
- Per-project record: `stage` (idea|validating|building|shipped|maintenance|parked|killed), `next_action` (one line), `resume` note (free text), `priority` 0-3, and idea fields `hypothesis`, `test`, `result`, `decision` (continue|kill|park), `kill_by` (date).
- `axiom-projects today`: prints ONE project plus a "why" list; `today --skip` shows the next; `today --pin <id>` overrides.
- `axiom-projects capture "text"`: append to inbox. `inbox` lists, `promote <n>` turns a line into a project stub (stage idea, kill_by default +14 d, user can edit).
- `axiom-projects open <id>`: working set = terminal in repo (`TerminalService`/foot `--working-directory`), editor on the repo (`$VISUAL`/desktop entry, argv only), notes file (the project's .md in the editor).
- Launcher provider (after Launcher+ lands): prefix `p`, rows = projects ranked as `today` ranks them, Enter runs typed action `projects.open{id}`; action `projects.capture` (text field).
- Hotkey: labwc `rc.xml` keybind (Super+Shift+I) -> `qs ipc` -> Launcher in capture mode. The harness has no GlobalShortcuts portal (track-2 finding), so this is a keybind, same as Super+D.
**Later:** panel/lock widget, kill-by notification, per-project time spent, release-notes helper, AI summary, cross-machine sync (git the notes dir yourself).
**Out of scope:** daemon, watcher/inotify on repos, cloud/accounts/sync, telemetry, issue tracker import, time tracking, window-layout restore (Wayland cannot), shell history capture, running project scripts/Makefiles, fetching from remotes, GUI app (the Launcher IS the UI; a QML page is optional later).

## 3. Data format
Plain files, no database. Human-first, git-friendly, no secrets.
```
~/.config/axiom/projects/            # user data; `git init` it if you want history
  config.toml                        # roots, depth, ignore globs, weights
  inbox.md                           # one "- 2026-11-10T09:12 text" per line, append-only
  projects/<slug>.md                 # one file per project: TOML front matter + markdown body (resume note)
~/.cache/axiom/projects/scan.json    # derived facts; disposable, never edited
```
- Record = `+++` TOML front matter (`schema=1`, `repo="~/Projects/foo"`, stage, next_action, priority, hypothesis, test, result, decision, kill_by) then free markdown (the resume note). TOML because Python 3.11+ has `tomllib` (stdlib; the installer is already stdlib Python) and it is comment-friendly. One file per project = clean diffs, no merge conflicts.
- Key facts live in the cache, user judgement lives in the records. Rescan never touches records.
- **Validation:** hand-written checker (stdlib; no jsonschema dependency): known keys, enum values, ISO dates, string length <=500 (note <=64 KiB), file <=128 KiB. Unknown keys are preserved on rewrite and warned about.
- **Versioning/migration:** `schema = N` per file. Reader accepts N and N-1; a newer N is read-only with a warning. `axiom-projects migrate` rewrites after copying to `<file>.bak-<schema>`. Never auto-migrates on read.
- **Corruption:** a bad file is skipped and shown as a row "foo.md: invalid (line 7: ...)" in `list`/Launcher; never deleted, never overwritten. Writes are atomic (temp file + fsync + rename in same dir), so a crash leaves the old file. Bad `scan.json` = delete and rescan. Bad `config.toml` = built-in defaults + visible error (same rule as `SettingsService.loadError`).
- Capture appends with `O_APPEND` single write (< PIPE_BUF line), so concurrent captures cannot interleave.

## 4. Ranking for `today` (deterministic, explainable, no model)
Score = sum of integer terms, all shown to the user as "why". Ties: older `last_commit`, then slug. Excluded: stage in {shipped, parked, killed} and decision in {kill, park}, unless pinned.
| Input | Term |
|---|---|
| `kill_by` passed (decision still empty) | +100 ("kill-by was 3 d ago: decide: continue/kill/park") |
| `kill_by` within 3 days | +40 |
| user `priority` p (0-3) | +15*p |
| stage = building / validating | +20 / +10 (idea = 0) |
| has `next_action` set | +10 (no next action = -10: "write one first" is itself the action) |
| dirty working tree | +15 (unfinished work), capped |
| last commit 3-14 days ago | +10 (warm, resumable) ; 15-45 d: +5 ; >45 d: 0 (cold; a kill-or-park prompt instead) |
| last commit <1 day ago | -10 ("you touched it today") |
| stale local branches (no commit >30 d, unmerged) | +2 each, max 6 |
| `--skip` | skips already-shown picks for this day (stored in cache, resets at local midnight) |
Output example: `foo  score 87: kill-by 2026-11-08 passed (+100); priority 2 (+30); dirty (+15); last commit 4 d (+10); no next action (-10)`. Weights live in `config.toml` (user-editable); defaults ship in code. Overrides: `today --pin <id>` (today only), `priority` field, `decision=park`, or edit weights. A killed-by-date project is never silently dropped: it surfaces first and forces a decision, which is the whole point.
A fixed-input test (same repo facts + date -> same pick) is part of acceptance; `now` is injected, never read inside the ranker.

## 5. Repo discovery (safe and cheap)
- Roots: `config.toml roots = ["~/Projects"]` (default: that dir if it exists, else `~`-top-level only, never `/`). Depth <= 3 (`~/Projects/org/repo/`). Detect a repo by a `.git` dir or file (worktrees/submodules) via `os.scandir`, no git call. Do not descend into a repo once found, nor into `node_modules`, `.cache`, `target`, `.venv`, `vendor`, plus user ignore globs.
- `os.scandir` with `follow_symlinks=False`; a symlink is recorded, not followed, so loops cannot happen. Device-id check: do not cross mount points (stops network/FUSE mounts). Hard caps: 2000 dirs visited, 300 repos, 2 s walk budget, then "partial scan" is displayed (never silent).
- Per repo facts (one git call each, 5 s timeout, 4 in parallel): HEAD branch, last commit time+subject, dirty flag, ahead/behind of the *already-fetched* upstream, local branch list with last commit dates. **No fetch, no network.** Huge repos: `status` has `--untracked-files=normal` replaced by `no` when the index exceeds 200k entries or the call exceeds the timeout; mark `dirty=unknown`, never block the UI.
- Cache keyed on `.git/HEAD` + `.git/index` mtimes: skip unchanged repos. Scan runs on demand (CLI, Launcher open) in a subprocess; the Launcher shows cached data instantly and refreshes asynchronously.

## 6. Security: repo contents are untrusted
Tested: with `core.fsmonitor='touch /tmp/PWNED_fsmon'` in a repo's `.git/config`, a plain `git status` EXECUTED it (file created); the same call with `-c core.fsmonitor=false` did not. So this is real, not theoretical.
- Every git call goes through ONE function, argv-only (no shell), with `env -i`-style minimal environment (`PATH`, `HOME`, `LC_ALL=C`, `GIT_CONFIG_NOSYSTEM=1`, `GIT_CONFIG_GLOBAL=/dev/null`, `GIT_TERMINAL_PROMPT=0`, `GIT_OPTIONAL_LOCKS=0`, `GIT_ASKPASS=/bin/false`, `GIT_PAGER=cat`, `GIT_EXTERNAL_DIFF` unset), and the prefix `-c core.fsmonitor=false -c core.hooksPath=/dev/null -c core.sshCommand=/bin/false -c core.pager=cat -c core.editor=/bin/false -c core.askPass=/bin/false -c protocol.ext.allow=never -c diff.external= -c core.untrackedCache=false`. `-C <repo>` is always an absolute path that passed the discovery filter.
- Hooks do not run for `status`/`log`/`for-each-ref`/`rev-list`, but `hooksPath` is pinned anyway. Allow-list of subcommands: `status --porcelain=v2 --branch`, `log -1 --format=...`, `for-each-ref`, `rev-list --count`. No `fetch`, `pull`, `diff` (textconv/external diff), `submodule`, `grep`, `blame`, `gc`, `maintenance`, or any command that can run filters (`filter.*.clean`, attributes-driven drivers; `status` can invoke clean filters when stat data is dirty, so `--no-optional-locks` plus `-c filter.*` cannot be wildcarded: instead skip dirty detection on repos whose `.gitattributes`/`info/attributes` contains `filter=` and mark `dirty=unknown`).
- Ownership: honour git's `safe.directory`/dubious-ownership check; a repo owned by another uid is listed as "untrusted owner, not scanned", never forced via `safe.directory=*`.
- Do not read `.git/config` ourselves except to display nothing. Strings from git (branch names, subjects) are rendered as plain text: strip control/escape chars, cap 200 chars (terminal-escape injection in a commit subject), no markup in QML (`Text.PlainText`).
- Never run `next_action`, notes, or any repo file. `open` launches terminal/editor with argv list and cwd only; editor is started in the repo, but a terminal in an untrusted repo is the user's act (same as `cd`). Warn in the row if `.envrc`/`.git/hooks/*` non-sample exist? No: skip, not our threat.
- Runs as the user, no root, no network (can be run under `unshare -n` / `systemd-run --user -p PrivateNetwork=yes` where available; optional hardening, not required).
- Adversarial corpus (`tests/projects/corpus/`, generated by a script, each repo asserts "no canary file created, scan finishes, row shows plausibly"): (1) `core.fsmonitor` pointing to a canary script; (2) `core.sshCommand`, `core.pager`, `core.editor`, `core.askPass` canaries; (3) `core.hooksPath` to a dir with `post-checkout`/`pre-commit`/`reference-transaction` canaries; (4) `.git/hooks/*` canaries; (5) `.gitattributes` `* filter=evil` with `filter.evil.clean` canary and dirty files; (6) `diff.external` and textconv; (7) `include.path` / `includeIf` chain to a config that sets fsmonitor; (8) `url.<x>.insteadOf` + `ext::` remote; (9) symlink loop `a/b -> ..`; symlink to `/`; (10) `.git` that is a file pointing (`gitdir:`) at an attacker dir with hostile config; (11) bare-repo-in-repo and `core.bare=true` + `core.worktree=/`; (12) 50k-file repo and 200k-entry index (timeout path); (13) branch named with ANSI escapes and a commit subject with `\x1b]0;..` OSC and bidi chars; (14) 10 MB `.git/config`; (15) corrupt HEAD/index/packed-refs; (16) repo owned by another user; (17) directory with 5000 empty subdirs (walk cap); (18) mount-point crossing (bind mount in QEMU); (19) a project .md with huge strings, duplicate keys, bad dates, `schema=99`; (20) `inbox.md` with 1 MB line and NULs. Run under `strace -f -e trace=execve` and assert the only execve targets are `git` (and git's own `git-*` helpers).

## 7. Privacy and AI boundary
No network code path exists in the program (assert: `unshare -n` run passes; no socket imports). No telemetry, no usage logging. Files stay `0600`/dir `0700`. Notes may contain private ideas: never pushed anywhere; if the user `git init`s the dir, that is theirs. Logs contain slugs and counts only, never note text, paths of unscanned dirs, or commit messages.
AI is absent in the MVP and the core never calls it. Later (Phase 12 provider router, user opt-in per call): only `suggest-next-action` and `summarize-resume`, input = the explicit fields the user selects (commit subjects, note), output = a *proposed text shown for accept/edit*, written through the same validated writer. No tools, no shell, no file-system access, no auto-apply, `today` never uses a model (the ranking stays the table above).

## 8. Launcher, ActionService, Profiles, Settings
- Typed actions registered once in `ActionService` (not built yet; build it with Launcher+): `projects.open{id}`, `projects.capture{text}`, `projects.today{}`, `projects.setStage{id,stage}`. Args validated (id must match a known slug; no free command). The Launcher calls them; Automate could bind them later. Until `ActionService` exists, the CLI is the single implementation and the provider shells to it with an argv list; swap is localised.
- Settings: only `roots` and `depth` in a Settings page later (via `config.toml`, not `settings.json`, to keep the CLI independent of QML). Not in Settings at MVP.
- Profiles (Track 1, data-only profiles): a profile could carry *widget placement* ("show today's pick on panel"). **Judgement: not worth it in the MVP.** It needs a panel widget host that does not exist and a polling/refresh path (a timer/daemon, which the brief forbids). The pick is shown where the user already looks: Launcher open (one row at top: "Today: foo - next action"). Revisit after 4 weeks of use; the lock screen is a poor spot because project names/notes are private on a locked screen.

## 9. Acceptance (QEMU, repo evidence rules)
In the Phase 6 ISO in disposable QEMU, retained serial/journal/screenshot per milestone:
1. Corpus script creates fixtures in the guest; `axiom-projects scan` finishes, zero canary files, `execve` trace shows only git; plain `git status` on corpus repo 1 DOES create the canary (proves test sensitivity).
2. Scan of a 100-repo fixture <= 5 s cold, <= 0.5 s warm cache; partial-scan banner appears when caps are hit.
3. Fixed-input ranking tests (unit, host and guest) incl. kill-by-passed beats priority, pin override, skip, deterministic across runs.
4. Corrupt-file tests: bad record skipped and listed, others load; crash during write (kill -9 loop) never leaves partial file; schema=99 read-only.
5. Capture keybind in the real shell: keypress -> text -> `inbox.md` contains line; 100 rapid captures, no loss.
6. Launcher (phase 2): `p` shows ranked rows with "why"; Enter opens foot with `pwd` == repo (verified by a marker command), editor started; screenshot retained. Real shell, no mock data.
7. No network: run under `unshare -n`; AGENTS rules: no root, no telemetry (grep for socket use).
8. `python3 scripts/validate-repo.py` passes; docs updated (ADR-0xx "Axiom Projects", note that it is separate from ADR-021).
**Measure** (retained JSON): scan time vs 10/50/100/300 repos (cold and warm), peak RSS of CLI (target < 50 MB) and of Launcher with provider (delta), keypress-to-first-row latency (target < 100 ms from cache), keypress-to-capture-written (< 150 ms), git calls per repo (target <= 3). No performance claim without these numbers.
**Product success (dogfood, 4 weeks):** you open `today` on >= 15 of 20 working days and killed/parked >= 1 project via kill-by. If not, kill the feature.

## 10. Effort (one dev + AI, weeks)
Data format + validator + writer 0.5; discovery + safe git runner + cache 1; ranking + `today` + explain 0.5; capture/inbox/promote 0.3; adversarial corpus + QEMU evidence 1; ADR/docs 0.3 => **CLI MVP about 3.5 weeks**. Launcher provider + keybind + `ActionService` hookup: +1 week *if* Launcher+ exists (else its 4 wk is the real cost). Total 4.5 weeks, of which only the CLI is on the critical path to being useful.

## 11. Risks
1. (top) Safe-git completeness: git has many config-triggered exec paths; allow-list + corpus + execve trace is the defence; if any new canary passes, drop dirty detection (use `git for-each-ref`/`log` only, which run no filters).
2. It is not used (judge's poor-validation problem applies to this tool too): the dogfood gate in section 9.
3. Launcher+ slips and the provider waits.
4. Crowded niche; do not expect external reach.
