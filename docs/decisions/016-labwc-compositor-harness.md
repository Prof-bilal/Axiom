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
