# ADR-022: Usable core first, differentiators after, extension seams throughout

**Date:** 2026-11-10 (revised the same day after owner direction)
**Status:** Proposed. Nothing below is applied to `AGENTS.md` or `PHASES.md`
until the owner accepts or vetoes each row of "Rule and process changes".
Evidence: [Track 0](../research/track-0-positioning.md),
[Track 1](../research/track-1-profiles.md),
[Track 2](../research/track-2-windows-demand.md),
[Track 3](../research/track-3-maker-tools.md),
[Track 4](../research/track-4-synthesis.md).

## Context

Research found that "AI-native developer desktop" is not unique (Omarchy ships
agents in the OS). The open gap is Omarchy's audience without its problems:
fragile dotfile customization, code-running shared themes (the KDE Store
`rm -rf` incident), root-escalation defaults and forced AI. The positioning is
**the developer desktop you can make your own, with AI you can trust, and tools
that help you ship**; primary user: developers and indie makers.

Owner direction (2026-11-10): this is a student project, not a startup; time
is not the constraint. **First build a conventional distro that works and that
people can use; then build the differentiators; and in every phase keep the
differentiators in mind so they are easy to add and change later.**

## Decision

### 1. Order

1. **Usable core = Phases 7 to 10, exactly as planned** (package management
   and updates, daily-driver, developer edition, hardware and stability).
   Nothing from the differentiator list is inserted into these phases except
   the seam rules below. The **usable line** is the end of Phase 10: a person
   can install Axiom, update it, work on it daily and run it on declared
   hardware.
2. **Differentiator phase "D"** after the usable line, in this order (each
   item gets its own exit criteria and QEMU evidence when it starts):

   | Step | Item | Why here |
   | --- | --- | --- |
   | D1 | Profiles: look layer (tokens from the profile, 3 looks, undo) | Foundation for later profiles; visible differentiator |
   | D2 | Launcher+ and typed `ActionService` | Shared by Zones, Projects and Automate |
   | D3 | Zones | Builds the labwc config adapter |
   | D4 | Capture (full app: annotate, OCR, record, upload on click) | Needs the Phase 8 basic capture service |
   | D5 | Axiom Projects (CLI and Launcher provider) | Needs D2 for the provider |
   | D6 | Connections | Needs Terminal and Files |
   | D7 | Creator profile and bridge pipelines (demo video, launch kit) | Needs D4 and D2 |

3. **Phase 11 (security layer)**, then, because they depend on it: Automate,
   the Capture cursor/click sidecar, and Profiles layout and behavior layers
   with import/export. Then **Phase 12 (AI)** with Write's rewrite and optional
   AI suggestions in Projects, then **Phase 13 (distribution)**.
4. The Windows on-ramp (web-app install flow, tested Wine presets with honest
   status) follows the usable line and is designed when D starts.

Phase 8's existing "screenshots/recording" stays small there (see seam S4); the
full Capture app is D4.

### 2. Extension seams (kept in mind in every phase)

These are the rules that make the later work additive. They apply to all new
shell, app and service code from now on.

| # | Seam | Keeps open |
| --- | --- | --- |
| S1 | No hardcoded colors, fonts, radii or sizes in new UI; read `Theme.qml` tokens only | Profiles look layer: switching a look must not need UI edits |
| S2 | Every user preference lives in `settings.json` through `SettingsService`, with a default, a validated range and a schema version; unknown keys are ignored, never fatal | Profiles, migrations, "updates never break your settings" |
| S3 | Built-in lists (dock pins, panel widgets, quick settings, keybinds) are data with defaults, not QML literals | Profiles layout layer |
| S4 | Compositor configuration is generated only through the ADR-016 harness adapter and never hand-edited; screenshots and recording sit behind a service (`shell/services/`), not a hardcoded tool call | Zones, Automate, Capture; replacing labwc later |
| S5 | Launcher entries and shell commands are typed data (id, argument schema, sensitivity), not ad-hoc shell strings | `ActionService`, Automate, Phase 12 natural-language launcher |
| S6 | New apps follow ADR-017: one Quickshell process, shared config root, access through `shell/services/*` | Capture, Connections, Projects |
| S7 | Package, install and update paths go through the Phase 7 narrow helper; no UI runs a package manager | Profile app suggestions, Windows on-ramp |
| S8 | User files stay under `~/.config/axiom/`, separate from system files, so system rollback never loses them and built-in profiles can stay read-only | Profile undo, import/export |
| S9 | No new daemon and no executable user content (scripts, hooks, plugins) without its own ADR | Keeps the "profiles cannot run code" promise |

Each phase's exit checklist gains one line: **"seams S1 to S9 respected;
deviations listed."** A deviation is allowed if recorded with a reason.

## Rule and process changes (owner may veto each row)

| # | Proposed change | Why | Stability, privacy, security impact |
| --- | --- | --- | --- |
| R1 | Record phase D (steps D1-D7, then post-Phase-11 and post-Phase-12 items) in `docs/PHASES.md` and `docs/ROADMAP.md` | No slot exists for this work today | None: documentation only |
| R2 | Add the seam rules S1-S9 to `docs/ARCHITECTURE.md` and a one-line seam check to each phase's exit criteria | Makes later additions cheap and cheap to review | None; S9 and S8 strengthen safety |
| R3 | Add to `docs/SECURITY.md`: repository contents and shared profile files are untrusted input; git runs through a locked-down runner (a repo's `core.fsmonitor` executed code in a test); profile files contain no executable content | Found by testing | Strengthens security |
| R4 | Defer anything that stores secrets (upload tokens, saved SSH passphrases) until a Phase 11 secret-store ADR | No user secret store exists on the image | Strengthens privacy and security |
| R5 | Marketing claims need a retained test first (Track 4 "Claims we must not make yet") | Extends the measured-claims rule to security and compatibility claims | Strengthens honesty; no runtime effect |

Withdrawn from the first draft: splitting Phase 8 into 8a/8b and building
Axiom Projects host-side ahead of its phase. Neither is needed now.

**Not changed:** AI never gets unrestricted root, sudo or shell; UI never runs
as root; privileged APIs stay narrow; secrets stay out of the repository and
logs; Wayland and portal boundaries; the core desktop works without cloud AI;
performance claims require measurements. No daemon is added.

## Alternatives considered

- **Slot differentiators into Phases 7-12** (first draft). Rejected by the
  owner: a usable distro first is a better base and lower risk.
- **Build differentiators first.** Skips package rollback, which "customize
  without fear" depends on.
- **Embed Vicinae as the launcher.** Rejected: GPL-3.0 against Apache-2.0, a
  second Qt process and unsandboxed Node extensions.
- **Marketplace-style profile store with scripts (KDE Store model).**
  Rejected: the KDE Store incident; profiles stay data-only.
- **Build Photoshop/Office/CAD equivalents.** Rejected: years of work; bridge
  with honest status instead.

## Migration cost, compatibility and performance

- Documentation edits (R1-R3) and a seam check in each phase. Existing code
  that breaks S1-S3 (for example hardcoded colors in `Theme.qml` and some QML
  literals for dock or panel content) is not refactored now; it is listed
  when D1 starts, and new code follows the seams immediately.
- Performance targets, not claims: profile switch under 1 s without a restart,
  Launcher keypress-to-result latency, repo scan time versus repo count.
  Measure in QEMU before any public number.

## Review and rollback

Independent review is required before Capture, Connections and Automate start,
because they touch trust boundaries (screen capture, SSH config, input).
Everything here is additive; removing an app directory and its Settings page
reverts it, and the documentation changes revert with git.

## Open choices

- Profile and project file format convention (JSON for profiles, TOML
  front-matter for Projects): one convention for anything shared.
- Whether the usable line should be after Phase 9 instead of Phase 10.
- Owner and review assignments for the three trust-boundary apps.
