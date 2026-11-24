# ADR-016: labwc replaces Sway as the Phase 3 compositor harness

**Date:** 2026-11-02
**Status:** Accepted for Phase 3. Amends [ADR-015](phase3-shell-architecture.md);
the compositor remains a temporary, replaceable harness, not the product.

## Context

The Axiom desktop identity ([DESKTOP_DESIGN](../DESKTOP_DESIGN.md)) asks for
application windows with an Axiom title bar: app icon, title, working
minimize / maximize / close, rounded corners and a soft cyan edge glow. Sway
(ADR-015's harness) cannot provide this: it is a tiling compositor with square
borders, no title-bar buttons, no minimize, and it ignores client maximize
requests. The previous design worked around it with floating-by-default rules,
foot client-side decorations (close only) and a shell-side cascade hack.

## Options

| Option | Title bar with icon + min/max/close | Rounded corners / shadow | Runs in QEMU software rendering | Shell protocols | Packaging |
| --- | --- | --- | --- | --- | --- |
| Keep Sway | No (close only via client) | No | Yes (pixman) | layer-shell, wlr foreign-toplevel, i3 IPC | Arch `extra` |
| **labwc** | **Yes (server-side, themed)** | **Yes / yes (themed drop shadow)** | **Yes (wlroots pixman)** | **layer-shell, wlr + ext foreign-toplevel, ext-workspace, toplevel capture** | **Arch `extra`, GPL-2.0-only** |
| Hyprland | Only with an unofficial plugin | Yes, plus gradient borders and blur | Uncertain (GL renderer) | layer-shell, foreign-toplevel, own IPC | Arch `extra` |

## Decision

Use **labwc** (0.20, official Arch package) as the Phase 3 harness, chosen by
the product owner on 2026-11-02.

- Session: `axiom-session` → `dbus-run-session` → `labwc -C /etc/axiom/labwc`;
  `/etc/axiom/labwc/autostart` starts the supervised Axiom Shell.
- Window chrome: server-side decorations themed by
  `/usr/local/share/themes/Axiom/labwc/themerc` (graphite title bar, icon,
  left-aligned title, orange close, 12 px corners, cyan-tinted shadow on the
  focused window). foot uses server-side decorations.
- Placement: labwc's `cascade` policy (centre the first window, offset later
  ones), replacing the shell-side cascade added for Sway.
- Workspaces: the shell's `WorkspaceService` now uses the standard
  **ext-workspace-v1** protocol (`Quickshell.WindowManager`) instead of Sway's
  i3 IPC, so the adapter is no longer tied to any one compositor.
- Terminal size: labwc resizes only in absolute pixels, so `axiom-terminal`
  asks the shell (`terminalGeometry` IPC) for 70% × 68% of the usable area and
  passes it to foot.

## Consequences

- **Positive:** real minimize/maximize/close for every server-decorated app;
  consistent Axiom window chrome; standard protocols only between shell and
  compositor; the Sway-specific placement workaround is removed.
- **Negative:** labwc cannot draw gradient borders or blur; the focused-window
  "glow" is a tinted drop shadow. Window sizes for apps other than the terminal
  follow the app's own default. Firefox keeps its own client-side title bar.
- **License:** labwc is GPL-2.0-only; Axiom uses it unmodified as a separate
  program (no linking), with notice retained in `THIRD_PARTY_NOTICES.md`.
- **Rollback:** restore `sway` in `packages.x86_64`, the previous
  `axiom-session` exec line and an i3-IPC `WorkspaceService`; UI components
  are unchanged because they only use the service adapters.

## Revisit when

The Axiom compositor milestone starts, or labwc blocks a required behavior
(per-output workspaces, secure lock, gradient/blur effects).

## Amendment 2026-11-16: labwc is the default compositor again

[ADR-029](029-hyprland-glass-desktop.md) chose Hyprland for backdrop blur and glass. Both were removed for
performance and a solid look, so labwc is the default session again.

- `axiom-session` starts labwc. Hyprland runs only if `/etc/axiom/compositor` contains `hyprland`
  (opt-in), with the old 15 s fallback to labwc. The session exports `AXIOM_COMPOSITOR=labwc|hyprland`;
  the shell and apps read that, never a compositor-specific variable. Software GL is forced only in a VM.
- The shell has no Hyprland dependency: `WindowService` uses `ToplevelManager`
  (wlr-foreign-toplevel: activate, close, `minimized`, `maximized`), `WorkspaceService` uses
  `WindowManager.windowsets` (ext-workspace). The window switcher keeps its own most-recently-used list.
- labwc draws every window's title bar (server-side decorations), themed in `themerc` with the card metal
  gradient and no buttons. The shell-drawn bars (`TerminalTitleBars`) and the apps' own title bar were removed.
- Key bindings (`rc.xml`) match the former Hyprland set: Omarchy-style Super+Left/Right = previous/next window
  (labwc has no directional focus), Super+Alt+Left/Right = snap with the shell's zone hint, Super+Alt+Down =
  centre, Super+Tab = next workspace, Super+Q/W close, Super+H minimize (Iconify), media keys, Print capture,
  Caps Lock OSD, and Alt+Tab through the shell switcher (release of Alt commits).
- Losses, accepted: labwc's toplevel protocol gives no window geometry, so the Activities overview shows
  plain workspace thumbnails and the capture bar has no window mode (region and screen only).
- Unverified until the labwc ISO is booted in QEMU: `canActivate` for workspaces, `MoveTo x=center`,
  Caps Lock key passthrough, release binding of `Alt_L`, and restore of a minimized window from the dock.

## Amendment 2026-11-24: Hyprland is the default again (ADR-031)

The user chose Hyprland as the default session compositor. `axiom-session` starts Hyprland unless `/etc/axiom/compositor`
says `labwc`, and falls back to labwc if Hyprland stops within 15 s. labwc remains the fallback and the opt-out. See ADR-031.
