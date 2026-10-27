---
name: quickshell-ui
description: "Build Axiom Shell surfaces with Quickshell/QML on the Hyprland session."
---

# quickshell-ui

## When to use

Use for Axiom Shell or desktop UI changes on the Omarchy-derived Hyprland/Quickshell foundation. Do not use for building a compositor or a generic web UI.

## Required inputs

Pinned Quickshell/Hyprland/Qt versions, the design tokens, interaction acceptance criteria, accessibility/reduced-motion needs and the component scope (panel, dock, launcher, Control Center, notification, workspace, agent surface).

## Procedure

1. Read [design tokens](../../../docs/desktop/DESIGN_SYSTEM.md) and reuse Quickshell primitives (`PanelWindow`, `PopupWindow`, `FloatingWindow`, `Variants`, services) before adding custom items; bind semantic tokens rather than constants.
2. Keep compositor boundaries explicit: Hyprland owns windows, workspaces and input; the shell observes through `Quickshell.Hyprland`/IPC and layer-shell surfaces.
3. Define focus order, shortcuts, accessible names/roles, keyboard-only flows, pointer targets and reduced-motion behavior; Quickshell has no automatic reduced-motion switch, so gate animations in the shell.
4. Keep blocking work off the UI thread; use asynchronous models, bounded lists, `LazyLoader` and measured animation budgets.
5. Check multi-monitor/per-monitor workspaces, mixed DPI, 1366×768, 4K, text scaling, lock-screen behavior and shell idle cost.

## Validation

Run available QML lint/tests and demonstrate focus, accessibility, responsiveness, frame timing and idle cost in the pinned Hyprland/Quickshell session.

## Failure handling

Reduce to a minimal QML case; preserve compositor/shell logs. Never weaken Hyprland permissions, grant global input, or run a shell component as root to make a UI path work.

## Project references

- [desktop/DESKTOP_UX.md](../../../docs/desktop/DESKTOP_UX.md)
- [desktop/WAYLAND.md](../../../docs/desktop/WAYLAND.md)
- [migration report](../../../docs/engineering/OMARCHY_MIGRATION.md)
