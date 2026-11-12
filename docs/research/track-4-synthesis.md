# Track 4: Synthesis, roadmap and rules check

Date: 2026-11-10. Merges [Track 0](track-0-positioning.md),
[Track 1](track-1-profiles.md), [Track 2](track-2-windows-demand.md) and
[Track 3](track-3-maker-tools.md). No new web research; this is judgment over
the earlier evidence. The proposed rule and phase changes are recorded in
[ADR-022](../decisions/022-differentiation-direction.md) (Proposed).

## 1. One-paragraph direction

**Axiom: the developer desktop you can make your own, with AI you can trust,
and tools that help you ship.** Primary user: developers and indie makers
(you are user #1). Windows switchers are a secondary on-ramp. The direct
competitor is Omarchy; the gap is its audience without its problems
(fragile dotfiles, root-escalation defaults, forced AI, code-running themes).

## 2. Everything that survived, in one table

| # | Item | Source | Form | Effort (1 dev) | Needs | Where it lands |
|---|---|---|---|---|---|---|
| 1 | **Axiom Projects** (`today` pick, idea log, `capture`, `open`) | T3 | Python CLI, plain files, no daemon | 3.5 wk (+1 for Launcher provider) | Nothing; works on any Linux | D5 |
| 2 | **Profiles: look layer** (Theme.qml reads tokens from the profile, 3 looks, undo) | T1 | Shell + Settings page | 2-3 wk (**my estimate**, Track 1 gave none) | `SettingsService`, `colors.toml` | D1 |
| 3 | **Capture** | T2 | App | 8 wk | wf-recorder, grim, tesseract | D4 (basic capture service stays in Phase 8) |
| 4 | **Zones** | T2 | Settings page + generated labwc regions | 3 wk | labwc adapter (ADR-016) | D3 |
| 5 | **Launcher+** (plocate index, script commands, typed `ActionService`) | T2 | Extends `Launcher.qml` | 4 wk | `ActionService` | D2 |
| 6 | **Connections** | T2 | App over `~/.ssh/config` | 4.5 wk | Terminal, Files/GVfs | D6 |
| 7 | **Creator profile + bridge pipelines** (demo video, launch kit) | T3 | Profile + Launcher/Files actions | ~1 wk (**my estimate**) | Items 3, 5 | D7 |
| 8 | **Automate** (hotkeys, snippets, curated remaps; AI only proposes) | T2 | Typed actions on `ActionService` | 5 wk | Items 4, 5; security review | Phase 11 |
| 9 | **Capture cursor/click sidecar** | T3 | Compositor feature | 1.5 wk | Axiom compositor input path | Phase 11 |
| 10 | **Profiles: layout + behavior layers, import/export** | T1 | Shell | not estimated | Compositor decision; schema stable | After Phase 10-11 |
| 11 | **Write** (fix selected text; Harper local) | T2 | Selection action | 3 wk (+1.5 rewrite) | Phase 12 provider router for rewrite | Phase 12 |
| 12 | **Web-app install flow + tested Wine presets** (Windows on-ramp) | T2 | Software Center entries | not estimated | Phase 7 package path | After the usable line |

Estimates for rows 1 and 3-11 come from the Track 2/3 agents and are rough
(plan on ±50%); rows 2, 7 and 12 are mine or missing. Sum of estimated
differentiator work: about 38 weeks. Time is not a constraint, so this is
information, not a limit.

## 3. Roadmap (revised 2026-11-10 on owner direction)

Time is not a constraint (student project, not a startup). So: **build a
working conventional distro first, then the differentiators, and keep
extension seams in every phase** so the later work is additive.

1. **Usable core = Phases 7 to 10, unchanged:** packages/updates/rollback,
   daily-driver, developer edition, hardware and stability. The **usable
   line** is the end of Phase 10.
2. **Phase D, after the usable line:** D1 Profiles look layer, D2 Launcher+
   and `ActionService`, D3 Zones, D4 Capture (full app), D5 Axiom Projects,
   D6 Connections, D7 Creator profile and bridge pipelines.
3. **Phase 11 (security)**, then Automate, the Capture sidecar and the
   Profiles layout/behavior layers.
4. **Phase 12 (AI)**, then Write's rewrite and optional AI in Projects.
5. **Phase 13 (distribution).**
6. The Windows on-ramp follows the usable line.

The seam rules S1-S9 (see ADR-022) apply from today: tokens not hardcoded
colors, preferences in `settings.json` with a schema version, built-in lists as
data, generated compositor config only through the adapter, typed actions,
ADR-017 apps, package paths through the Phase 7 helper, user files under
`~/.config/axiom/`, and no new daemon or executable user content.

Non-code actions that stay optional (from Track 0): a waitlist landing page,
interviews with developers who quit Omarchy, one HN/X post to read reactions.

## 4. Rules check against AGENTS.md

| Rule | Verdict | Note |
|---|---|---|
| AI never gets unrestricted root, sudo or shell | Holds | Automate: AI may only *propose*; sensitive actions are created in Settings only. Projects: AI optional, suggest-only. |
| UI never runs as root; privileged APIs narrow | Holds | Nothing in the list needs root. No new privileged component. |
| Secrets out of repo and logs | Holds, with a gate | No secret store exists. Stored upload tokens and SSH passphrases are **deferred** until a Phase 11 ADR. Snippet text is never logged. |
| Wayland and portal boundaries | **Open risk** | On labwc any unsandboxed client can capture the screen and inject input. Our items do not widen this, but Capture and Automate expose it. Phase 11 must gate it. |
| Core desktop works without cloud AI | Holds | Every BUILD item is deterministic; Write's local checker is Harper, LanguageTool is opt-in and loopback-only. |
| Deterministic routines avoid model calls | Holds | `today` is a score table. |
| Every daemon justified | Holds | No new daemon. The Launcher index refreshes from a user timer (a unit, not a daemon); justify it in its own spec. |
| Measure performance claims | Holds | Targets, not claims: profile switch under 1 s, Launcher keypress-to-result, scan time per repo count. Measure in QEMU before any public number. |
| No fake UI; QEMU evidence per milestone | Holds | Each spec lists QEMU acceptance tests. |
| No empty scaffolds; new top-level dirs only when their phase starts | Holds | `apps/capture`, `apps/connections`, `apps/projects` appear when their phase starts. |
| Reuse mature primitives | Holds | grim, wf-recorder, tesseract, plocate, OpenSSH, GVfs, Harper, git-cliff, whisper.cpp. |

**Conclusion: no security or privacy rule needs weakening.** Only process
rules change (ADR-022): recording phase D, adding the seam rules S1-S9 to the
architecture doc and each phase's exit check, and adding the untrusted-input,
secret-deferral and claims rules, which tighten safety.

## 5. Claims we must not make yet

| Claim | Why not yet | Earliest |
|---|---|---|
| "Auto-zoom demo videos like Screen Studio" | labwc gives no cursor/click stream; portal `metadata` mode is rejected by wlroots | Phase 11 |
| "Install any profile; it can't run code" | True by design, but unproven until a schema validator and an adversarial profile corpus pass | After the look layer ships with its tests |
| "Updates never break your profile" | Needs schema versioning plus migration tests across versions | After two schema versions exist |
| "Photoshop / Office / Fusion run on Axiom" | Wine support is unreliable; Fusion script archived and breaks on updates | Never promise; show honest status |
| "Instant file search" | Index refresh is about 15 minutes | Measure first |
| "Switch your whole desktop in under 10 s" | Not measured | After measurement |

## 6. Where I disagree with earlier tracks, and challenges for you

(Revised 2026-11-10. Withdrawn: the Phase 8 split and the "38 weeks is a lot"
warning; the owner builds a usable core first and time is not a constraint.)

1. **Where is the usable line?** I put it after Phase 10 (hardware). Phase 9
   (developer edition) is the earliest defensible alternative. Phase 10
   matters because a distro that fails on real hardware is not usable by
   others. Your call.
2. **Seams only work if they are checked.** The nine rules (ADR-022) are cheap
   to follow while writing new code and expensive to retrofit. Existing code
   that breaks them (hardcoded colors in `Theme.qml`, QML-literal dock or
   panel content) is listed when D1 starts, not refactored now.
3. **Track 1's profile format is JSON, Track 3's Projects uses TOML
   front-matter.** Both are defensible, but pick one convention for anything a
   user shares. Decide in the profile-schema spec.
4. **Projects is the least differentiating item and the most useful to you.**
   Do not market it as a distro feature. It is deferred to D5; you can still
   run a throwaway script for yourself meanwhile.
5. **The Windows on-ramp (row 12) is the least designed.** It is mostly Wine
   presets and web-app wrappers with honest warnings, and nobody has estimated
   it.
6. **All effort numbers except where marked are agent guesses.** Re-estimate
   each item when its step starts.

## 7. Next actions

1. Review and accept or veto the changes in
   [ADR-022](../decisions/022-differentiation-direction.md).
2. If accepted: update `docs/PHASES.md`, `docs/ROADMAP.md` and
   `docs/ARCHITECTURE.md` (seams), then continue with **Phase 7**.
3. Run the one-day spikes listed in Track 2 and Track 3 before their steps.
