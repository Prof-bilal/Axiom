# Track 3 / Agent 2 (Judge): verdicts for solo-builder features

Date: 2026-11-10. Input: track3-agent1-pains-tools.md plus repo track-0/1/2 notes (Capture ~8 wk and Launcher typed-action catalog already planned).

## Method
- Scores 1-5 on Demand (pain evidence), Gap (what exists is weak), Buildability (useful MVP <=3 months, one dev), Fit (daily use by the primary user AND real OS-level advantage). Total = sum, max 20.
- Rule: BUILD needs total >=15 and Fit >=4, or be a near-free add-on to a component already planned. Web services, audience problems, and well-solved problems are BRIDGE or KILL.
- Verified with ~6 searches/fetches (drydock page 403'd, so drydock/dev-pulse claims come from search snippets and linuxlinks/docs.rs listings). Anything not confirmed is marked UNVERIFIED.

## What verification changed vs Agent 1
1. **Screen Studio**: macOS-only confirmed across several sources (Ventura 13.1+). Pricing is NOT settled: sources say ~$108/yr subscription, $89/yr, $9/mo annual or $29/mo; one says one-time license closed to new buyers. Only claim "paid, macOS-only".
2. **Wayland cursor data is a weaker gap than Agent 1 said.** The ScreenCast portal has a `metadata` cursor mode: cursor is sent as PipeWire stream metadata, so cursor POSITION is obtainable from any compositor that advertises it (mutter implemented it; check `AvailableCursorModes` on labwc/wlroots, UNVERIFIED). OpenScreen on Linux already captures cursor position for auto-zoom. What is genuinely missing is CLICK events: Recordly's click effects reportedly need evdev access (udev rule / `input` group) per a secondary site (UNVERIFIED), and one source says Recordly/niri cannot record at all (UNVERIFIED). Screenix claims X11+Wayland auto-zoom via PipeWire (unverified quality). So the Linux gap is "reliable, sandbox-clean click+cursor events", not "no cursor data".
3. **Git-aware tools**: drydock (Rust TUI: staged/unstaged/untracked/conflicted + unpushed commits across branches, MIT), ovw (stack, git activity, ports, scripts, `t` opens terminal at project root), dev-pulse (health, last activity, stale repos, dirty worktrees), DevPulse variants (cross-project status, claims a prioritized view, team/ADO oriented). None found that stores a user-chosen next action, a stage, or a kill date, and none picks "today's one". Gap claim holds, but it is a thin gap: the git half is crowded, so build only the decision half.
4. **WakaTime**: has a Linux desktop app (tracks apps beyond editors), terminal plugin for bash/zsh/fish (per-project only reliably on zsh; bash/fish lump into one "Terminal" project), per-project/branch/file metrics. Pricing sources conflict ($9 vs $19 premium). Agent 1's "editor-bound" claim is outdated; time tracking is solved well enough.
5. **git-cliff**: changelog from conventional commits, TOML templates, `--latest`/`--unreleased`, JSON `--context`. No social-post/launch-draft step exists, confirmed by absence only (UNVERIFIED negative); trivially composed with an LLM or template.

## Scored table
| # | Candidate | D | G | B | F | Total | Verdict | One-line reason |
|---|---|---|---|---|---|---|---|---|
| 1 | Project Hub (git scan, stale/dirty, next action, resume, "pick one" nudge) | 4 | 4 | 4 | 5 | 17 | BUILD | Daily pain; decision half is unfilled; git/session state is local |
| 2 | Idea log as Hub fields (stage, hypothesis, test, result, kill-by date) | 4 | 3 | 5 | 4 | 16 | BUILD (folded into #1) | A few frontmatter fields; the kill-by date is what forces choosing |
| 3 | Quick-capture idea hotkey into Hub inbox (Launcher action) | 3 | 3 | 5 | 5 | 16 | BUILD (folded into #1/Launcher) | One typed action; stops ideas becoming new projects |
| 4 | Capture cursor/click event sidecar (compositor-sanctioned) | 3 | 3 | 4 | 3 | 13 | BUILD (small, conditional) | Near-free on planned Capture; doubles as Phase 11 permission UX |
| 5 | Auto-zoom/caption editor on top of Capture | 4 | 2 | 1 | 3 | 10 | BRIDGE | Recordly/OpenScreen/HyperFrames + Whisper exist; an editor is months |
| 6 | Focus/time tracking | 3 | 2 | 3 | 3 | 11 | BRIDGE | WakaTime (Linux app, terminal) or self-hosted Wakapi; Hub git "last touched" is free passive signal |
| 7 | Launch kit (git history -> changelog/notes/post drafts) | 3 | 3 | 4 | 3 | 13 | BRIDGE | git-cliff + one prompt template; used per release, not daily |
| 8 | Social scheduling | 3 | 1 | 3 | 1 | 8 | KILL | Web/API service (Typefully, Buffer); audience problem, zero OS advantage |
| 9 | Landing page generator | 3 | 1 | 4 | 1 | 9 | KILL | Carrd/Framer/any LLM already do it; traffic is the problem, not the page |
| 10 | Portfolio dashboard (users, revenue, analytics) | 3 | 2 | 2 | 2 | 9 | KILL | Stripe/PostHog/Plausible web APIs; needs accounts and keys, not OS |
| 11 | Re-record demos per release via typed-action replay | 2 | 4 | 2 | 2 | 10 | KILL (revisit after Capture ships) | Speculative; needs stable Capture + automation first |
| 12 | Competitor research capture | 3 | 2 | 5 | 3 | 13 | BRIDGE | It is just Axiom Capture screenshots into a Hub project note |
| 13 | Pomodoro / do-not-disturb focus block | 2 | 2 | 4 | 3 | 11 | BRIDGE | Shell notification DND is a platform setting, not a product |
| 14 | Build-in-public auto "ship log" posts | 3 | 2 | 3 | 2 | 10 | KILL | Fabricating cadence is the "second job" problem; audiences are makers, not customers |

## BUILD list (3 deliverables; #2 and #3 ship inside #1)

### 1. Axiom Hub (project list + decision), 17
- What: scan configured dirs for repos (git status, last commit, unpushed, stale days), per-project `next action` + `stage` + free-text resume note, and `hub today` that picks ONE project by a deterministic rule (e.g. stale-but-in-building stage, then oldest next action) and opens terminal+editor at the root via the Launcher's typed action. No model call, no daemon: a CLI plus a Launcher provider, refreshed on demand or by a systemd user timer.
- Evidence: PH thread (solo judgment "susceptible to the whims of the day"), PH maintainer's 15-minute cold-start rule, a crowd of hobby git dashboards (drydock, ovw, dev-pulse, dangit, gv) showing demand but only git state, no decision. Data lives in plain files (e.g. `~/.config/axiom/hub/*.toml`, or per-repo `.axiom/`), matching the SettingsService pattern, git-friendly and local-first.
- Why OS-level: repo scan, notifications, global hotkey, and launching the working set are session features; cross-platform ranking is trivial. Keep resume honest: Wayland has no portable "restore windows", so resume = cwd, branch, dirty files, note, last N shell commands, not window layout.

### 2. Idea log as Hub fields, 16
- Add `hypothesis`, `test`, `result`, `decision: continue|kill|park`, `kill_by` date to the same record. Hub nudges when `kill_by` passes. This directly attacks "builds before validating" and "too many projects" at zero extra infrastructure. Everything outward (landing page, waitlist, interviews) stays BRIDGE to Carrd/Tally; evidence there is about audience, which software cannot fix (Agent 1 agreed).

### 3. Quick-capture hotkey, 16
- One Launcher typed action "new idea" appends to the Hub inbox with timestamp. Seconds of work; high daily-use. Folded to avoid a separate feature.

### 4. Capture cursor/click sidecar, 13 (conditional, the weakest BUILD)
- What: while recording, Capture (or the compositor on its behalf) writes a JSON sidecar of cursor position and click timestamps. Cursor position may come free via the portal `metadata` cursor mode; clicks need the compositor. Rendering stays out: Recordly/OpenScreen/HyperFrames consume it, or a future editor.
- Why only conditional: Fit is 3 (video-making is episodic, not daily) and the gap is narrower than claimed. Kill condition: if, after Capture MVP, Recordly/OpenScreen already deliver click-driven zoom on labwc via the portal with no udev/input-group hack, drop the sidecar. Keep if Phase 11 wants the explicit "app X can see your pointer/clicks" permission anyway.

## BRIDGE list
- Auto-zoom/caption editor: Recordly (AGPL) or OpenScreen (MIT) on Linux; local Whisper for captions; HyperFrames (already in this environment) for composed launch films. Axiom job is to make Capture output friendly to them (good file format, sidecar).
- Focus/time tracking: WakaTime Linux app and terminal plugin (note bash per-project limit) or self-hosted Wakapi. Do not write a tracker; Hub's last-commit data covers "what did I touch".
- Launch kit: `git cliff --latest` (or `--context` JSON) plus a saved prompt/template in the Hub project folder that drafts release notes and a post. Post by hand. Revisit as a Launcher action only if used every release.
- Competitor research capture: Axiom Capture screenshot saved into a Hub project note.
- Pomodoro/DND: use the shell's notification do-not-disturb; no feature.

## KILL list
- Social scheduling (web service, audience problem, no OS leverage; Typefully/Buffer exist).
- Landing page generator (solved; traffic is the bottleneck; the repo already has landing design docs).
- Portfolio dashboard with revenue/users (Stripe/PostHog web APIs; account/key handling plus cloud scope).
- Per-release demo re-record automation (speculative; reopen post-Capture).
- Build-in-public auto posts (artificial cadence, builder audience not customers; Agent 1's own evidence says it burns people out).

## OS-level vs cross-platform
- Must live in the OS: repo/file watching and launch of the working set, global hotkey and Launcher integration, notifications/nudges, compositor-sanctioned cursor/click events and the permission UX for them, screen/audio capture.
- Can be cross-platform: Hub's data format and ranking CLI, release-note templating, caption transcription (Whisper), video rendering/auto-zoom effects, anything touching Stripe/social/analytics APIs.
- Flatpak/cross-distro for marketing reach: **not Flatpak.** Hub must read arbitrary repos and launch host terminals/editors, which the Flatpak sandbox fights. If reach matters, publish the Hub CLI (same plain-file format) as a separate cargo/pip package; honest caveat: the git-dashboard niche is crowded (drydock, ovw, dev-pulse), so expect little organic reach from it. The real reach artefact is a short Axiom demo made WITH Capture, not another tool. Treat any separate release as optional and post-MVP.

## Challenges to Agent 1
- "Time tracking is editor-bound": outdated; WakaTime has a Linux app and terminal plugin.
- "Auto-zoom needs cursor data Wayland won't hand out": cursor position is available via the portal metadata mode and OpenScreen already uses it on Linux; the unfilled part is click events and reliability. The pitch "no Linux tool can do this" is too strong.
- "20+ Screen Studio clones = demand for an Axiom editor": it is also proof the area is saturated; Axiom should supply capture inputs, not a clone.
- Validation/launch pains are audience problems; Agent 1 conceded this, and so do these verdicts: only the decision-making slice (kill-by date) survives.
- Evidence limits: no HN threads, no direct quotes, most prices unverified, drydock page unreadable (403).

## Sources
- Screen Studio pricing/platform: https://trainn.co/blog/screen-studio-pricing/ , https://www.trupeer.ai/tools-comparison/screen-studio-vs-trupeer-pricing , https://toolradar.com/tools/screen-studio/pricing , https://www.capterra.com/p/10138152/Screen-Studio/
- Recordly / OpenScreen / Linux: https://github.com/nonomal/Recordly , https://cdn.jsdelivr.net/gh/siddharthvaddem/openscreen@main/README.md , https://sourceforge.net/projects/screenix/ , https://www.abduzeedo.com/recordly-free-open-source-screen-recorder-auto-zoom , https://github.com/getopenscreen/openscreen/pull/157
- Portal cursor metadata: https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.impl.portal.ScreenCast.html , https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/357 , https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/3853
- WakaTime: https://wakatime.com/linux , https://wakatime.com/terminal-automatic-time-tracking , https://www.saasworthy.com/product/wakatime/pricing , https://subger.com/en/service/wakatime
- git-cliff: https://github.com/orhun/git-cliff , https://www.mintlify.com/orhun/git-cliff/usage/overview
- Git dashboards: https://www.linuxlinks.com/drydock-track-outstanding-work-git-repositories/ , https://terminaltrove.com/drydock/ (403 on fetch) , https://docs.rs/dev-pulse/ , https://dev.to/roie/i-built-a-terminal-dashboard-to-keep-track-of-all-my-local-projects-19k3 , https://github.com/prime001/DevPulse
- Agent 1 sources (pains): see track3-agent1-pains-tools.md Sources section.
