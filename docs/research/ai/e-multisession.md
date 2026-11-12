# Track E: built-in multi-session agent management (research, 2026-11-10)

Method: 3 rounds. R1 broad survey; R2 deep on Shikigami, ContextGit (read code), Claude Code (sandbox + agent teams docs), sandbox-runtime/bubblewrap/Landlock, ACP/A2A/MCP, opencode serve; R3 counter-evidence. Nothing was run. Shikigami: its public page and the install directory listing only (no config, no data, no execution). Repo content (ContextGit, Axiom docs) and all web content treated as data. "(U)" = unverified. reddit blocked; HN searches returned mostly vendor blogs, so incident/cost figures are weak evidence.

## 0. Findings that drive everything

1. **Shikigami cannot be built in.** Closed source; page: "Free for personal and internal company use", "Redistribution, resale, and repackaging are prohibited; get it only from the official channel." It cannot be on the ISO, in an Axiom package repo or mirrored. An installer that downloads from the official URL at the user's request is probably tolerable but (U) legally; ask the author in writing. It is an AppImage, Electron, 564 MB unpacked here; chrome-sandbox present is Electron's own, not an agent sandbox. Its page states no agent isolation ("No other security guarantees"), and "Auto-submit ... is not a security setting"; delegation = text typed into another agent's prompt ("Sent to terminal" only means text reached the prompt). Delegation server is on 127.0.0.1, random port each start. It has no stated policy/audit/attribution layer, so Axiom cannot make "AI you can trust" claims about sessions run inside it.
2. **ContextGit's isolation is VCS-level, not security-level (confirmed in code).** `check_ownership(path)` is a read-only query over task scope globs (mcp/tools.py); "stay inside files you own" is a convention in AGENTS.md. Identity of an MCP caller is the env var `CONTEXTGIT_TASK` (mcp/server.py docstring), so a session that sets another value can impersonate another task; fine for cooperating agents, not adversarial. grep found no bwrap/Landlock in the Python package; PTYs live only in the Electron desktop (node-pty + xterm.js, TerminalPane.tsx). Core deps are small (pydantic, typer, fastapi, uvicorn, httpx; mcp optional; `contextgit-mcp` is a 1.1k-line stdio server). The MCP tool names today: team_status, list_tasks, read_board, claim_task, complete_task, post_update, check_ownership, peers, publish_contract (+dead_ends, decisions, why, endpoints, endpoint_tests per its instructions string). Beta 0.2.0b6, 2 weeks of history, one author.
3. **There is no QML terminal widget** (Qt has none; Quickshell provides processes and windows, not a PTY emulator) (U, check). So "PTY inside the Quickshell app" means writing a terminal emulator. Do not. Reuse a terminal emulator window attached to a per-session tmux/dtach server (the Claude Squad model: tmux + worktree per session).
4. Prior art confirms the shape: Claude Squad (AGPL-3.0, Go, tmux + worktrees, 8.8k stars, `-y` auto-accept "experimental"), Crystal (MIT, deprecated Feb 2026 -> Nimbalyst), Vibe Kanban (Apache-2.0, Rust/TS, local server + MCP, README says "sunsetting"), Conductor (desktop GUI, license/status (U)). All isolate with worktrees only; none sandbox processes (U for Conductor/Nimbalyst).
5. Claude Code's own sandbox (bubblewrap + socat proxy, Apache-2.0 `sandbox-runtime`) is the closest existing design to what Axiom needs and documents the costs: network namespace removed, host proxy with domain allowlist (empty by default), ssh/DB drivers/UDP can't leave, userns/mount blocked by seccomp so Chromium and rootless Podman fail, deny globs are snapshots (files created later not covered), Linux write rules take literal paths, escape hatches (`dangerouslyDisableSandbox`, `excludedCommands`) exist, **reads default to the whole machine including ~/.ssh** unless denied, and the sandbox covers only Bash (built-in file tools, MCP servers, hooks run outside). Lesson: wrap the whole agent process, not individual tool calls.

## 1. Landscape (R1)

| Tool | License | Isolation | Delegation | Notes |
|---|---|---|---|---|
| Shikigami 0.53 | closed, free personal/internal | worktree per agent; no stated sandbox | local server, text injected into other agent's PTY, optional auto-submit | Electron, Monaco IDE, resume, notifications, Linux AppImage |
| Claude Code subagents / agent teams | proprietary CLI | worktrees optional; optional bwrap Bash sandbox | in-process or tmux teammates, JSON mailboxes under ~/.claude/teams, shared task list with file locking; messages are labelled as from another session and cannot carry approval | experimental, no session resume of in-process teammates, one team per session, teammates inherit lead's permission mode (incl. bypass), "significantly more tokens" |
| Codex CLI | Apache-2.0 (from memory, U) | bwrap/Landlock + seccomp on Linux, network off by default (search snippet only; Codex docs fetch failed, U) | none native | |
| opencode | MIT (memory, U) | none native | `opencode serve`: OpenAPI HTTP, SSE `/event`, permission responses, basic auth via env password, default 127.0.0.1:4096 | best structured API of the CLIs |
| Claude Squad | AGPL-3.0 | tmux + worktree | none | do not embed (AGPL vs Apache-2.0) |
| Crystal / Nimbalyst | MIT / (U) | worktree | none | Crystal deprecated |
| Vibe Kanban | Apache-2.0 | worktree | local MCP | sunsetting; too heavy (Rust+TS+Node) |
| smurf (owner) | no LICENSE | worktree per task, learned router, verify-before-accept | n8n/vault driven | prior art for Lane 1 orchestration, not shippable as is |
| ContextGit (owner) | Apache-2.0 | worktree+branch, advisory claims | board + MCP + merge queue | see §0.2 |

Protocols:
- **MCP**: agent-to-tool. Every CLI above is an MCP client; stdio servers started by the agent.
- **ACP (Zed, JSON-RPC 2.0 over stdio, SDKs in TS/Python/Rust/Kotlin/Java)**: editor-to-agent: sessions, diffs, permission requests as structured events. Reuses MCP JSON types. Claude Code reached via an adapter, Gemini CLI native (secondary sources); Codex/opencode support (U). IBM's "ACP" is a different, merged-into-A2A protocol; do not confuse.
- **A2A (Google -> Linux Foundation)**: HTTP/JSON-RPC/SSE agent-to-agent with agent cards; designed for networked/enterprise agents; governance dates conflict across sources (U). Wrong weight for same-machine delegation.
- Claude Code mailbox/teams files: product-internal, not a standard.

Worktree pitfalls at scale (blogs agree; no hard numbers found): only tracked files exist in a new worktree (node_modules, .env, caches missing); ports collide; shared dev DB/Redis defeats isolation; docker compose project names, PID files, tmp collide; symlinked node_modules re-shares state; pnpm store hard links cut disk; prune/list hygiene; merge one at a time with rebase. Additional ones from git itself (my analysis): a worktree's `.git` points into the main repo's `.git/worktrees/<n>`; objects, refs and **hooks/config are shared**, so a session with write access to the shared `.git` can plant a hook or `core.fsmonitor` that executes outside the sandbox the next time the user runs git (Axiom R3 already records the fsmonitor finding). One branch cannot be checked out in two worktrees.

## 2. Options (deliverable 1)

| | A. Shikigami optional, user-installed | B. Build "Axiom Sessions" from scratch | C. ContextGit core + MCP as engine, Axiom UI | D. Recommended: C engine (headless) + minimal B UI/sandbox launcher + A documented as external |
|---|---|---|---|---|
| Licensing | cannot bundle or redistribute; link only; permission needed for any installer help | Apache-2.0 clean | Apache-2.0 (owner's), clean | clean; A is link-only |
| Security | none provided by Axiom; Shikigami's own posture unreviewed; cross-session text injection by design | whatever Axiom builds; can be correct | engine gives no isolation; Axiom adds launcher | Axiom-owned sandbox launcher, session identity from socket, typed delegation |
| Resource (7 GB box) | Electron+Monaco, unmeasured (U, measure); disk 564 MB | QML ~120-280 MB PSS per ADR-017 app, plus tmux and agents | + Python interpreter on demand (no resident server if FastAPI/uvicorn not used) | same as C; nothing resident but the shell |
| Effort (one student) | ~1 week docs + Developer Hub entry | 4-6 months incl. data model, merge, board | 1-2 weeks glue + UI 3-4 weeks | ~3-4 months to preview, + hardening in Phase 11/12 |
| Maintenance | none, but no control; upstream may change terms or die | highest (reinvents ContextGit) | low, owner controls both ends; Python dependency; beta quality | low-medium; engine owned, UI small |
| Fit with Axiom rules | violates "attribute, verify, no mistaken identity" claims; fine as a user's own app | fits | fits except Electron/FastAPI parts which are skipped | fits |
| Gives users | immediate value, polished (IDE, resume) | | | immediate value later, plus differentiator "sessions you can trust" |

Verdict: **D.** Option A alone is acceptable as a stopgap and is always allowed (user choice), but it is not an Axiom feature. B from scratch is wasted work because the data model exists. C alone has no security. Use ContextGit's `ctx` core + `contextgit-mcp` headless (no FastAPI daemon, no Electron) as the board/claims/merge-queue/audit store, and write only: sandbox launcher, session UI, broker, notification hooks. If Python on the image is a problem (U: check whether Axiom ships python3; pacman tooling often drags it in), port the small data model later; keep the tool names and board file format as the stable contract.

### Why not just Shikigami, if you prefer it (plain answer)
- It is the better product today (IDE, polish, real users, resume). Use it yourself; Axiom should list it in the Developer Hub as "works on Axiom, user-installed, not sandboxed or audited by Axiom".
- But Axiom cannot ship it, cannot change it, cannot attach policy/audit/sandbox to individual sessions (it spawns agents as plain child processes under your user, per its page), cannot make the delegation channel safe (the vendor says auto-submit is not a security setting and is a loop hazard), and cannot guarantee it still exists, is free, or keeps the terms. A distro whose headline is "AI you can trust" cannot make its multi-agent story a closed app that gives no guarantee.
- You can run Shikigami inside an Axiom launcher profile (home hidden, only the worktree root visible) as partial mitigation, but Electron's Chromium sandbox needs user namespaces and setuid helper (chrome-sandbox present), which conflicts with a seccomp userns block; likely needs `--no-sandbox` or weaker profile (U, test). It would also be one sandbox for all sessions, not one per session.
- Honest counter: ContextGit is a 2-week-old beta from one author. If you will not maintain it, the Shikigami route is cheaper. The deciding axis is whether "trusted sessions" is a differentiator you want to own.

## 3. Recommended architecture (deliverable 2)

```
Axiom Sessions app (Quickshell, ADR-017)        shell panel indicator + notifications (resident already)
        |  argv-only calls                                ^ unix socket (shell listens)
        v                                                 |
  axiom-session CLI  --> systemd --user transient units (supervisor = systemd, no new daemon)
        |                     axiom-session-<id>.service : bwrap -> tmux server -> agent CLI
        |                     axiom-session-<id>-broker.service (BindsTo): MCP broker + egress proxy
        v
  ContextGit core (ctx, headless) : board, tasks, claims, merge queue, events   | git (session clone or worktree)
```
- **Session = one systemd user service** (cgroup scope for MemoryMax/TasksMax/CPUWeight, journal, `systemctl --user stop` = kill, `Restart=no`). The UI can crash; sessions keep running; reopening the app re-lists them from `systemctl --user list-units 'axiom-session-*'` plus per-session metadata files (S2/S8 style, under ~/.local/state/axiom/sessions/<id>/).
- **PTY**: tmux (or dtach/abduco, lighter, no panes) server per session inside the sandbox; the UI opens the user's terminal emulator attached to the session socket. Persistence and resume come for free (detach/attach); agent-level resume uses each CLI's own resume flag via a data-only adapter table (id, argv template, resume argv, notify hook mechanism). Escape-sequence hardening is the emulator's job; choose one that disables OSC 52 clipboard write/read and title queries for session windows (U, check emulator).
- **Git**: default **session clone** (`git clone --local` with alternates to the main repo objects read-only, own `.git`, own hooks, own config), sandbox gets only that directory. The broker (outside the sandbox) fetches the session branch into the main repo with `-c core.hooksPath=/dev/null -c core.fsmonitor=false` and `transfer.fsckObjects`; the user reviews the diff; merge via ContextGit queue + its quality gate. Advanced mode: true worktree with `.git/hooks` and `config` bind-mounted read-only (shared refs remain writable: weaker, label it). Per-session `.env`, ports (port range allocated per session id), DB name, compose project name injected from the broker. Large deps: reflink copy where fs supports, otherwise pnpm/cargo shared caches mounted read-only.
- **Engine reuse**: ContextGit stays the source of tasks/claims/board; Axiom's UI reads its SQLite/JSON through `ctx` JSON output (argv) not an HTTP server.

### Per-session sandbox profile (default "Dev agent")
Wrapper: Axiom-owned launcher around bubblewrap (LGPL binary, exec only), with seccomp + no_new_privs; Landlock as second layer in Phase 11 (kernel ABI gate; network rules need ABI 4 / kernel 6.7+ (U for Axiom's kernel)). Optional Warden adapter decided in Phase 11 (ai-d2: MIT, bwrap-based, host allowlist proxy, no daemon in run mode, but "beta", no seccomp/Landlock, re-pin needed). systemd-run scope alone gives resource limits only (no filesystem or network protection); rootless Podman gives strong FS but breaks bind-mount ergonomics, needs image management, and per-session overhead; microVMs (Firecracker/cloud-hypervisor/QEMU microvm) give the strongest boundary but need KVM, ~hundreds of MB per VM, hostile to 7 GB and to worktree sharing (virtiofs): list as a future "high isolation" tier.

| Resource | Rule |
|---|---|
| Namespaces | new mount, pid, ipc, uts, user, **net**; `--new-session`, `--die-with-parent`, `--unshare-all` |
| Filesystem | `/usr` ro, minimal `/etc` (resolv conf stub, ssl certs, passwd stub), `/proc`,`/dev` minimal, tmpfs `$HOME`, session dir rw at same path. **No real home**, no ~/.ssh, ~/.gnupg, ~/.config (other than a per-session copy of the agent's own config), no /run/user/UID (no Wayland, D-Bus, pipewire, ssh-agent, keyring), no docker/podman socket |
| Env | cleared; allowlist TERM, LANG, PATH (sandbox-resolved), HOME (fake), AXIOM_SESSION, per-session ports; deny LD_PRELOAD, NODE_OPTIONS and friends not set by launcher; no SSH_AUTH_SOCK, GPG_*, DBUS_*, WAYLAND_*, cloud credential vars |
| Network | no route; only unix sockets to the broker: (a) HTTP/SOCKS egress proxy with host allowlist (default: the agent's model API hosts only, e.g. api.anthropic.com, api.openai.com, per adapter table (U exact hosts per agent/auth mode); DNS resolved by proxy after allow; refuse private/link-local ranges), (b) the MCP broker. Per-session optional grants: package registry hosts, git host over HTTPS, web-search/docs hosts. Telemetry/update hosts denied |
| Credentials | agent login token is needed by the agent itself: mount only that file read-only into the fake home (U where each CLI keeps it); known residual risk: a prompt-injected agent can read it and send it to an allowed model API host (limited usefulness) but not elsewhere. Better later: proxy injects the API key so the sandbox holds a placeholder (Warden `agent` mode does placeholders; OAuth subscription logins make this hard, U). Git push credentials never inside; the broker pushes after human review |
| ssh agent / GPG | **off by default**; grant = per-session, time-boxed, a filtered agent socket exposing only named keys (e.g. a deploy key), user-confirmed in shell UI, logged. Commit signing done by the broker at integrate time |
| Syscalls | seccomp: deny mount, unshare/userns, ptrace on others, kexec, bpf, perf_event, io_uring (U, measure impact), keyctl; unix sockets limited to bound paths |
| Resources | cgroup: MemoryHigh 1.5 G / MemoryMax 2.5 G default on 7 GB (U tune), TasksMax 512, CPUWeight low (below shell), IOWeight, wall-clock `RuntimeMaxSec`, max concurrent sessions derived from MemAvailable |
| What it breaks (document in UI) | rootless Podman/Docker, Chromium/Playwright with sandbox (needs a declared "browser" grant using `--no-sandbox` inside the netns, or none), ssh git remotes, DB drivers needing direct TCP (grant per-host via SOCKS), UDP/ping, GUI apps, desktop notifications from inside (use the hook channel), keyring/credential helpers, anything reading ~/ dotfiles (language servers needing global config: provide read-only copies) |
| Fail mode | no bwrap/userns/seccomp -> session refuses to start. A visible, per-session, user-acknowledged "Unsandboxed (my authority)" mode may exist for Lane 1 only, with permanent red badge and audit flag (owner decision, Q2) |

### Attribution and audit
- Session id (ULID) on everything: systemd unit name, env `AXIOM_SESSION`, git committer/author "Axiom session <agent>@<id>" plus trailer `Axiom-Session: <id>` and `Axiom-Task: <task>`, MCP broker calls, proxy log lines.
- Append-only per-session JSONL (0600) in the user's state dir: spawn (argv, adapter, profile hash, grants, budgets, base commit), every broker call (tool, args hash, caller session, decision), every egress CONNECT (host, bytes, allowed/denied), delegation messages, notifications raised, integrate/merge, kill (who/why). Mirror key events to journald (the unit gives it for free). ContextGit events table already stores board events; reuse.
- PTY transcripts: **off by default** (scrollback holds secrets, tokens printed by tools, .env contents). If enabled, 0600, size-capped ring buffer, shown to the user as "may contain secrets", excluded from any export/bug report.
- Limits to say honestly: audit proves what crossed the broker/proxy, not what the agent did inside the worktree; verify by diffing the session branch, not by trusting transcripts.

### Preventing "Lane 1 session = the Axiom AI"
1. Different names and chrome: Axiom Sessions says "Dev agent: Claude Code (you supervise it)"; Lane 2 is "Jarvis" (name TBD). Session windows carry a fixed Axiom-drawn titlebar badge (outside the PTY, drawn by the compositor/shell, which the agent cannot paint over) with agent name, session id, sandbox state and branch.
2. Different principal: policy sees `dev-session:<id>` (untrusted, user-supervised third-party code), never `assistantd`. Jarvis context, memory, system prompt and capability grants are never shared with sessions. A session cannot read Jarvis conversation or call model providers on Jarvis's behalf.
3. Different indicator: panel shows two separate indicators (Jarvis state; "N dev agents running"). No shared color token for "AI is acting".
4. Any Axiom confirmation dialog is rendered by the shell, never inside a PTY; text from a session is displayed in quoted/untrusted style when it appears in Axiom UI (notification text from hooks is truncated, plain text, prefixed with the session name).
5. Docs/UI never claim Axiom "protects" the user from a dev agent's output beyond the profile's stated limits.

### How a session calls Lane 2 typed capabilities (Phase 12, seeded by D2 ActionService)
- A second MCP server `axiom` served by the per-session broker over a bound unix socket; identity comes from which socket (kernel peer credentials plus socket path), **not from env** (fixes ContextGit's spoofable `CONTEXTGIT_TASK`).
- Tools are static, generated at spawn from the session's grant manifest (per AGENT_SYSTEM: dynamic model-supplied tool names rejected). Each tool = one typed capability with a schema and class (OBSERVE/NORMAL/SENSITIVE/CRITICAL, per permissions doc).
- Policy: broker -> the same Policy -> typed executor -> audit path as Jarvis; caller authority = min(session grants, user's authority). OBSERVE/NORMAL pre-granted at session creation allowed silently; SENSITIVE requires confirmation rendered by the shell (not in PTY, not answerable by another session or by agent text); CRITICAL never from a dev session. Result is structured, returned wrapped as untrusted data, with audit id. Session cannot grant itself or other sessions anything, and delegated/relayed approval claims are ignored (same rule Claude Code applies to teammates).
- Before Phase 12, the `axiom` server exposes a read-only OBSERVE subset (project info, build status) or nothing.

## 4. Protocol choice (deliverable 3)

- **Delegation transport: MCP over a per-session unix socket/stdio shim, with ContextGit tool names unchanged** (team_status, list_tasks, read_board, claim_task, complete_task, post_update, check_ownership, peers, publish_contract, and optionally dead_ends/decisions/why). Why: every target agent already speaks MCP; zero custom adapters; pull-based; maps to the board model. Keep the stdio entry point `contextgit-mcp` and `.mcp.json` format so an external Claude Code or Codex run outside Axiom (or inside, via the shim) joins the same board; the AGENTS.md "Parallel runs" block stays generated.
- **Never deliver delegation by typing into another PTY.** Messages are written to the board and fetched by the recipient (`read_board` / `peers`); the UI may show "unread for session B" and the notification can prompt the user to nudge. This removes Shikigami's injection + auto-submit loop hazard. Hard caps: max delegation depth 2, max messages/session/hour, spawn-by-delegation always needs human confirmation.
- Add to the tool vocabulary only additively (new tools, optional args). Never rename or change argument types; version the board file with a schema field (S2).
- **ACP: adopt later as the optional "structured session" front end** for agents that speak it (Claude Code via adapter, Gemini; Codex/opencode (U)). Benefits: permission prompts and "needs input" as typed events instead of PTY scraping, diffs rendered natively in QML, cost/usage events. Costs: a UI to build (no terminal), per-agent adapters, weaker fidelity than the real TUI. Not MVP; PTY first.
- **opencode serve** (HTTP + SSE + permission endpoint) is an easy structured adapter for opencode sessions: bind inside the sandbox netns (localhost private), password from env, broker proxies.
- **A2A: do not adopt now.** Designed for remote/networked agents with agent cards, HTTP + auth; same-machine delegation through a board is simpler and auditable. Revisit only if Jarvis must talk to remote agents. Do not adopt Claude Code's mailbox files (product-internal).

## 5. UX sketch (deliverable 4)

- **Panel**: chip "3 dev" (gray idle, blue running, amber "needs you", red failed/over budget), separate from the Jarvis indicator. Click opens the attention queue popover. Middle-click or hotkey opens the Sessions app.
- **Sessions app** (Quickshell FloatingWindow, ADR-017): left list (name, agent, task, branch, state: running/needs-input/idle/done/failed, elapsed, RAM, requests, budget bar), right pane: summary, diff stat, board messages, grants and egress log; actions: Attach (opens terminal window on session socket), Review diff, Integrate (via queue + gate), Stop, Stop and discard, Duplicate. New-session form: repo, agent (adapter list), task text, profile (Dev agent default), grants checklist (ssh key no, registries, extra hosts), budgets.
- **Attention queue**: ordered by oldest waiting; item types: needs input, permission prompt (if hook/ACP supplies), finished, failed, budget reached, egress denied (explain which host and offer one-time allow), integration conflict. Each item: one line, session badge, Attach / Allow once / Dismiss. Desktop notification (via the shell notification service) only for needs-input and failed; coalesce bursts; respect Do Not Disturb. Needs-input detection ladder: agent hooks/notify (Claude Code Notification/Stop hooks, Codex notify (U), opencode SSE permission events) > BEL > PTY silence timeout. Heuristic detection is a fallback and can miss (declare it).
- **Kill-all**: global hotkey (Super+Shift+Esc, rebindable) runs `axiom-session kill-all` = `systemctl --user stop 'axiom-session-*'`, works without the UI process; two-stage (SIGTERM then SIGKILL after 3 s), leaves worktrees/clones intact, board marks "killed by user". Also a panel menu item.
- **Budgets** (per session and global): wall-clock, max requests, max bytes via the proxy (hard, enforced by cgroup/stop); concurrency cap; token/cost caps only where the agent reports usage (hooks, status, opencode API) or provides its own flag (U per agent); the proxy cannot read token counts inside TLS and Axiom should not MITM. Over budget = stop session (not warn), mark needs-attention. Never claim a dollar cap Axiom cannot enforce.
- Resume: closing the app does nothing to sessions; reboot ends them (no lingering by default), the list shows "ended" with resume buttons using each agent's resume command and the preserved clone.

## 6. "No new daemon" (deliverable 5)

Resident: nothing new. The Quickshell shell already runs and hosts the panel chip, the notification receiver and the Sessions window.
On demand only: systemd transient service per session (supervisor, cgroup, journal); tmux server per session (dies with it); broker + egress proxy per session as a companion unit (BindsTo, socket path in a session dir), or one socket-activated instance serving all sessions if measured cheaper (decide by RSS measurement); `ctx` CLI and `contextgit-mcp` as short processes; git. Kill-all and listing need only systemctl. Needs an ADR line for S9 (transient services are not a daemon; the broker is a new privileged-adjacent component, justified: only mediator of network and capability calls, runs as the user, never root). Do not use the ContextGit FastAPI server or its Electron app. If a resident index/watcher is later wanted for the panel, prefer inotify on the state dir inside the shell.

## 7. Tests (deliverable 6)

### QEMU acceptance (retained serial/journal/screenshot evidence)
1. Create 3 sessions on a fixture repo with a stub agent (a scripted fake agent binary, deterministic, no network) and 1 real-CLI smoke when networked; each gets its own clone, unit, tmux socket, board entry; `systemctl --user list-units` matches the app list.
2. Needs-input: the stub prints a prompt and waits; chip turns amber, notification appears, queue entry attaches to the right session.
3. Quit and restart the Sessions app and the shell (labwc session survives or restarts): sessions persist and re-list; attach shows scrollback.
4. Kill-all hotkey with UI frozen (SIGSTOP the app): all units stopped < 5 s, repo intact.
5. Integrate flow: session branch fetched with hooks disabled, diff shown, quality gate runs, merge; second session conflicting is flagged by the queue.
6. Delegation: session A posts to board; B reads via MCP and sees it tagged untrusted with sender; no text appears in B's PTY unprompted.
7. Memory: 3 stub sessions + shell + Sessions app within the whole-session budget (measure PSS; the Phase 4 gate was < 1.8 GiB of 2 GiB for shell + 3 apps; define a new number after measurement). Overhead per idle session (tmux + broker + proxy) recorded.
8. Fail closed: remove bwrap or set userns sysctl off; session refuses to start with a clear message.
9. Budget stop: wall-clock and request-count caps stop a stub that loops.
10. External join: a host-side Claude Code/Codex (or stub MCP client) using the `contextgit-mcp` config lists tasks, claims, posts; names unchanged (contract test against the tool list).

### Adversarial list (must fail to harm the host; run as a stub "malicious agent" script inside the sandbox)
- **Worktree/clone escape**: write via `../`, symlink inside the session dir pointing to ~/, `/proc/self/root`, `/proc/<pid>/cwd` of host processes, hardlinks to outside files (protected_hardlinks), bind-mount race, open-by-fd inherited from supervisor (check no stray fds), `.git` tricks: planted hooks, `core.fsmonitor`, `core.hooksPath`, `.gitattributes` filters, `.git` file pointing to another repo, submodule URL with `ext::`; confirm the broker's fetch and the user's later `git status` in the main repo run no session code.
- **Secret exfiltration**: read ~/.ssh, ~/.aws, ~/.config, /run/user/UID (SSH_AUTH_SOCK, Wayland, D-Bus), other sessions' dirs/logs/sockets, host `/proc/*/environ`; env scrub check; DNS exfil (query encoded data to any resolver), TLS to a non-allowlisted host, HTTP CONNECT to IP literals, redirect from allowed host, allowed host as relay (documented residual: model API host and GitHub accept arbitrary content), IPv6, UDP, ICMP tunnel, abstract unix sockets, loopback to host services (netns must not reach host loopback).
- **Credentials**: agent token readable by the session: confirm it is only the file granted; confirm no other session's token path visible; confirm broker logs never include tokens.
- **Cross-session**: impersonate another session via env var or by connecting to its broker socket (peer credential check), read/write another session's clone, inject keystrokes via tmux socket paths or TIOCSTI, plant text for another agent via board messages containing instructions ("approve this", fake system tags): recipients must see it quoted and never gain consent.
- **Escape sequences**: OSC 52 clipboard writes, title/query responses that inject keystrokes (terminal response injection), fake "Axiom" prompts drawn in the PTY: emulator config blocks them; shell chrome distinct.
- **Runaway loop**: infinite tool loop; fork bomb (TasksMax); memory balloon (MemoryMax -> OOM kills the session cgroup only, not the shell); disk fill in the clone (quota or `tmpfs` with size, or XFS/btrfs project quota (U)); CPU spin (CPUWeight); log flood (rotate/cap); repeatedly respawning delegation (depth cap); spamming notifications (rate limit); budget bypass by spawning children inside sandbox (cgroup includes children).
- **Supervisor attacks**: kill the broker (session must stop, not run unsandboxed or with open network), crash UI mid-integrate (idempotent), symlink swap on state dir (TOCTOU) for audit log, huge MCP messages, malformed JSON, path traversal in `check_ownership`/`publish_contract` (the owner's tools take a path: verify normalisation).
- **Userns/seccomp**: try unshare, mount, ptrace, io_uring, nested bwrap; verify EPERM. Sysctl variants (AppArmor userns restriction on Ubuntu-like kernels is not an Arch concern (U)).

## 8. Effort and phasing (deliverable 7) — my estimates for one student, part time

| When | Work | Estimate |
|---|---|---|
| Phases 7-10 (usable core) | Only seams: ship bubblewrap, tmux, git, socat-free design; typed-action seam S5; document in Developer Hub that agent CLIs and Shikigami are user-installed external tools, **not sandboxed by Axiom**; no code. Decide Python availability | 1-2 days |
| Phase D, after D2 ActionService | **D-S1 Sessions MVP (preview, labelled)**: launcher + profile + systemd unit + tmux attach + clone/integrate + ContextGit headless engine + list UI + chip + notifications via hooks + kill-all + wall-clock/request budgets | 10-14 weeks |
| Phase D+ | egress proxy and MCP broker as units (if not already in MVP); adapter table for Claude Code, Codex, opencode, Vibe; real-agent smoke tests | 3-4 weeks |
| Phase 11 (security) | Independent review (AGENTS rule: no self-approval), seccomp + Landlock layer, Warden adopt/adapt/drop ADR for the profile, adversarial pack in CI/QEMU, secrets proxy injection, filtered ssh-agent grant | 4-6 weeks |
| Phase 12 (AI) | `axiom` capability MCP for Lane 2, Policy integration, shell-rendered confirmations, Jarvis<->sessions separation tests, ACP structured mode (optional) | 4-6 weeks |
Total to "trusted": ~6-8 months part time; MVP alone preview-grade in about 3 months. Risk order: sandbox correctness > terminal attach UX > engine integration.
Do not start Lane 1 before D2 and Phase 8 services; the launcher benefits from the typed-action/service patterns.

## 9. Counter-evidence summary (R3) and how each is handled

| Failure mode | Evidence | Handling |
|---|---|---|
| Semantic merge conflicts, same-file edits | Claude Code docs: two teammates editing one file overwrite; "avoid file conflicts" | claims advisory + merge queue + human diff review; fewer sessions (3-5 cited) |
| Runaway/cost | vendor blogs only (U figures, e.g. $47k 11-day loop, unconfirmed); Claude Code docs: teams use "significantly more tokens" | hard stop budgets; no auto-submit; cap concurrency |
| Disk | multiplying installs per worktree; no hard numbers found | reflink/shared caches, quota, cleanup on discard, show size in list |
| Secrets in PTYs | scrollback and logs; Claude Code sandbox reads whole machine by default | no real home, transcripts off, scrubbed env |
| Cross-session injection | Shikigami's own warning about auto-submit loops; Claude Code labels inter-session messages and ignores relayed approvals | board pull + quoted messages + no consent transfer |
| Prompt injection exfiltration | arXiv 2603.12277 pattern (.env search + curl); CVE-2026-75130 Context7 MCP (6.4 CVSS4.0, vendor writeups differ) | no network except allowlist, no .env in clone unless granted |
| Permission inheritance | Claude Code teammates start with lead's mode incl. bypassPermissions | per-session profile, never inherit; unsandboxed is explicit |
| Experimental fragility | Claude Code teams: no resume of in-process teammates, task status lag, orphan tmux sessions | state in systemd/ctx files; reap orphans on app start; resume via CLI's own resume |
| Tool churn | Crystal deprecated, Vibe Kanban sunsetting | own the contract (tool names, board format), not an app |
| Sandbox breakage | sandbox-runtime: Chromium/rootless Podman fail, snapshot globs | explicit grants UI, document breakages, tests |

## 10. Open questions for the owner (max 5) and decisions they enable

1. Do you want sessions to be a flagship differentiator (own and harden it, Option D) or a convenience (Option A only, cheapest)? Enables: whether any Phase D time is booked for Sessions.
2. May a Lane 1 session ever run unsandboxed (red badge, per-session acknowledgement), or must it fail closed like Lane 2? Enables: launcher fail mode and test expectations.
3. Is a Python runtime (for ContextGit core/MCP) acceptable on the image, or should the engine be ported to the Axiom services language first? Enables: engine packaging and the Phase 7 package list.
4. Which agent CLIs are first-class adapters (Claude Code, Codex, opencode, Vibe)? and are subscription logins (OAuth files) acceptable to expose read-only inside the sandbox until a key-injecting proxy exists? Enables: adapter table, credential handling, exact egress allowlist.
5. Session default: separate clone (strong, slower, more disk) or true worktree with read-only hooks/config (weaker, faster)? Enables: git layer design and the escape tests.
Also worth one email: ask Shikigami's author whether an Axiom-provided downloader/launcher for the official AppImage is permitted.

## Not verified / limits
Did not run Shikigami or any agent; its RAM use, telemetry and actual process isolation are unknown (page says nothing). Codex and opencode sandbox/ACP specifics and licenses are from memory or snippets. Conductor/Nimbalyst internals unchecked. Kernel Landlock ABI and userns settings on Axiom's ISO not checked. Per-agent hook mechanisms for needs-input (Codex, Vibe) unverified. Cost incident figures are unverified vendor claims. No QML terminal widget claim is from knowledge of Qt/Quickshell, to be confirmed.

## Sources
- Shikigami: https://shikigami.dev/ ; local dir listing /home/abullah/Applications/Shikigami-0.53.0 (names and sizes only)
- Claude Code agent teams: https://code.claude.com/docs/en/agent-teams
- Claude Code sandboxing: https://code.claude.com/docs/en/sandboxing
- sandbox-runtime (Apache-2.0): https://github.com/anthropics/sandbox-runtime
- Claude Squad (AGPL-3.0): https://github.com/smtg-ai/claude-squad
- Vibe Kanban (Apache-2.0, sunsetting): https://github.com/BloopAI/vibe-kanban
- Crystal (MIT, deprecated): https://github.com/stravu/crystal
- opencode server docs: https://opencode.ai/docs/server/
- ACP: https://agentclientprotocol.com/overview/introduction ; search summary https://www.morphllm.com/agent-client-protocol
- A2A vs MCP: https://blog.mcpservers.org/posts/a2a-vs-mcp ; https://www.flowhunt.io/blog/agentic-ai-foundation-a2a-mcp-standards/ (governance dates conflict)
- Orchestrator comparisons: https://nimbalyst-website.pages.dev/blog/best-git-worktree-tools-ai-coding-2026/ ; https://loopengineering-app.pages.dev/guides/worktree-orchestrators-compared/
- Worktree pitfalls: https://www.mindstudio.ai/blog/git-worktrees-parallel-ai-coding-agents ; https://dev.to/sahil_kat/how-to-keep-parallel-coding-agents-from-stepping-on-each-other-e5g ; https://codeongrass.com/blog/parallel-coding-agents-worktree-isolation-ownership/
- Sandboxing: https://github.com/containers/bubblewrap ; https://advancedweb.hu/shorts/hardening-with-firejail-landlock-and-bubblewrap/ ; https://github.com/zouuup/landrun
- Injection: https://arxiv.org/pdf/2603.12277 ; https://nvd.nist.gov/vuln/detail/CVE-2026-75130
- Cost: https://dev.to/maximsaplin/the-ai-bill-grows-in-the-agent-loop-87n ; https://futureagi.com/blog/loop-engineering/ai-agent-loop-cost-control/ ; https://waxell.ai/blog/ai-agent-token-budget-enforcement (figures unverified)
- Repo/local: Axiom docs/ai/AGENT_SYSTEM.md, docs/SUBAGENTS.md, docs/AGENT_WORKFLOW.md, docs/decisions/017 and 022; scratchpad ai-d1-ai-tooling.md, ai-d2-security.md, ai-d3-other-repos.md; ContextGit /home/abullah/Projects/ContextGit (contextgit/mcp/server.py, mcp/tools.py, pyproject.toml, desktop/src/shell/terminal/TerminalPane.tsx)
