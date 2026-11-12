# Track 3: Indie maker tools (focus, validation, launch, demo video)

Date: 2026-11-10. Method: the same 4-agent pipeline as Track 2 (Finder → Judge
→ 2 MVP designers). Primary user: the developer building Axiom. Reddit was not
reachable by the tools; the evidence is mostly Indie Hackers, Product Hunt,
GitHub and blogs, so it is anecdotal. Details:

1. [Pains and tools](track-3/1-pains-tools.md)
2. [Verdicts](track-3/2-verdicts.md): 14 features scored; 4 BUILD, 5 BRIDGE, 5 KILL.
3. [Axiom Projects MVP](track-3/3-projects-mvp.md)
4. [Capture sidecar and bridge pipelines](track-3/4-sidecar-and-pipelines.md)

## Outcome: one thing to build, the rest bridged

| Item | Verdict | Why |
|---|---|---|
| **Axiom Projects** (was "Hub"): git scan, next action per project, deterministic `today` pick, idea fields with kill-by date, `capture` inbox, `open` | **BUILD** | Git listing is crowded (drydock, ovw, dev-pulse), but nothing joins git state with a next action and a daily "pick one". This is the user's own pain. |
| Capture cursor/click sidecar | **NO-GO on labwc; GO in Phase 11** | The portal `metadata` cursor mode is rejected by xdg-desktop-portal-wlr; libinput needs a keylogger-class grant; labwc has no cursor IPC. Needs the Axiom compositor (~1.5 wk then). |
| Auto-zoom and captions | BRIDGE | Capture → OpenScreen (MIT) or Recordly (AGPL, recommend only) → whisper.cpp → HyperFrames/ffmpeg/Kdenlive. Zoom is manual until Phase 11. |
| Launch kit | BRIDGE | `git cliff --latest` → saved prompt template → LLM draft → user posts by hand. |
| Focus/time tracking, Pomodoro | BRIDGE | WakaTime/Wakapi; the shell's Do Not Disturb. |
| Social scheduling, landing-page generator, revenue dashboard, auto re-record demos, auto build-in-public posts | KILL | Audience or web-service problems, or already solved. |

## Axiom Projects: what the MVP is

- A stdlib Python CLI over plain TOML-front-matter files in
  `~/.config/axiom/projects`, with a capped safe git scan cached in
  `~/.cache`. No daemon, no model call, no network.
- `today`: a deterministic, explainable pick (integer score table; pin, skip
  and priority overrides; shows why).
- Idea fields (hypothesis, test, result, continue/kill/park, kill-by date);
  `capture` appends to `inbox.md`; `open <id>` launches terminal, editor and
  notes.
- **~3.5 weeks** for the CLI; ~4.5 weeks with a Launcher provider and keybind,
  but only if Launcher+ and `ActionService` (Track 2) exist; otherwise their
  ~4 weeks is the real cost.
- Not merged with the Phase 6 Developer Hub (ADR-021): that is a first-boot
  installer catalogue and shares no data or code. Hence the new name.
- Cut from the judge's version: panel/lock-screen widget, systemd timer,
  "last shell commands" in the resume note.

## Security finding (tested by Agent 3)

Repo contents are untrusted. With `core.fsmonitor` set in `.git/config`, a
plain `git status` **executed the payload**; the same call with
`-c core.fsmonitor=false` did not. Every git call must go through one runner
with a minimal environment, `GIT_CONFIG_NOSYSTEM`, `GIT_CONFIG_GLOBAL=/dev/null`,
a `-c` override prefix and a subcommand allow-list. The spec holds a 20-case
adversarial corpus (fsmonitor, sshCommand, hooks, filter drivers, includeIf,
`.git` redirects, symlink loops, huge repos, escape sequences, corrupt files)
and a QEMU test under an execve trace that also proves plain git fires the
canary, so the test can fail. Fallback if any canary fires: drop dirty-state
detection and use only `log` and `for-each-ref`.

## Kill criterion for Projects itself

Open `today` on 15 of 20 working days over 4 weeks and kill or park at least
one project via kill-by. If not, the tool gets killed. This guards against the
"build a tool instead of shipping" trap.

## Corrections to earlier claims

- Agent 1 said Wayland gives no cursor data; the judge found a portal
  `metadata` mode, and Agent 4 then found wlroots rejects it. Net: it is a
  compositor-side gap, not solved.
- WakaTime does have Linux and terminal support (Agent 1's "editor-bound"
  claim was outdated).
- Screen Studio is macOS-only and paid; pricing sources conflict.

## Risks and unverified

- **Do not claim Screen-Studio-style auto-zoom before Phase 11.** It would be
  false on labwc.
- Not verified: how Recordly gets click data on Linux, Flatpak availability of
  Recordly/OpenScreen, HyperFrames/git-cliff/release-please licenses, most
  competitor prices, any Hacker News evidence.
- Agent 3 ran no web searches; its git claims rest on local tests.
- Licensing: Recordly (AGPL) and Kdenlive (GPL) stay separate installs;
  Axiom is Apache-2.0.

## Overlap with other tracks

- **Track 2:** Capture and the Launcher/`ActionService` are dependencies.
- **Track 1:** a "Creator" profile ships Capture, ffmpeg, whisper.cpp,
  git-cliff, the Launcher actions and a HyperFrames starter; OpenScreen,
  Recordly, Kdenlive and OBS are Software Center recommendations.
