# Dock

## Goal

A functional launch/switch surface: pinned applications, running applications,
and correct activation (focus the existing window or launch a new instance) —
never a purely decorative shelf.

## Projects Studied

COSMIC (`cosmic-panel` dock container, app-library/files applet), Sway/Hyprland
running-window tracking, Quickshell (`ToplevelManager`).

## Important Source Files

- COSMIC: `cosmic-panel/src/container_config.rs` (default "Dock" container),
  `wrapper_space.rs` (applet launch, `WAYLAND_SOCKET` fd).
- Sway: `sway/sway/ipc-json.c` (view nodes carry `app_id`, `focused`, `name`),
  `sway/sway/tree/view.c` (foreign-toplevel handle per view,
  `wlr_foreign_toplevel_handle_v1_set_activated`).
- Quickshell: `src/wayland/toplevel/qml.hpp` (`ToplevelManager`, `Toplevel`:
  `appId`, `title`, `activated`, `maximized`, `minimized`, `fullscreen`,
  `activate()`, `close()`), `src/core/desktopentry.cpp` (`DesktopEntry`,
  `startupClass`).

## Runtime Behavior

- Running windows are discovered from `zwlr_foreign_toplevel_management_v1`
  (Quickshell `ToplevelManager`), giving `appId`/title/activation state, or from
  sway's i3 IPC `GET_TREE` events.
- Activation: `Toplevel.activate()` requests focus; if no window exists the dock
  launches the desktop entry (preferring the session launcher so field codes and
  activation tokens are handled correctly).
- Pinned entries are data (desktop-entry ids), resolved against installed
  entries; unmatched pins are skipped rather than shown as fake icons.

## REA Findings

Sway exposes a foreign-toplevel handle per view (`view.c`,
`server.c: wlr_foreign_toplevel_manager_v1_create`); Quickshell consumes it
generically. No runtime capture needed.

## IPC / Protocols

`zwlr_foreign_toplevel_management_v1` (toplevel list, activate/close/maximize/
minimize requests); XDG activation for launching; desktop entries for app
identity (`startupClass` matches `appId`).

## Dependencies

Compositor foreign-toplevel support; desktop entries; the shell toolkit.

## Good Design Decisions

- Separate "pinned" (data) from "running" (live state).
- Focus-or-launch semantics on left click; force new instance on middle click.
- Match running `appId` to a desktop entry via `startupClass`/id.

## Problems / Tradeoffs

- Tiling compositors (sway) have no real "minimize"; dock "restore" is not
  applicable and must degrade honestly.
- `appId`↔desktop-entry matching is heuristic (apps may set neither cleanly).

## License Notes

COSMIC GPL-3.0-only (reference). Sway MIT. Quickshell LGPL-3.0-only.

## What Axiom Should Reuse

- Foreign-toplevel for running state; desktop entries for identity/launch.
- Pinned-vs-running separation.

## What Axiom Should Reimplement

- The dock UI and the focus-or-launch policy, over `WindowService`/
  `ApplicationService`.

## What Axiom Should Avoid

- Hard-coded app lists or fake running indicators.
- A dock that only launches and never focuses.

## Final Axiom Design

- `src/dock/Dock.qml`: a bottom `PanelWindow` with `exclusiveZone`, centered via
  a computed left margin, containing a `Row` of `DockItem`s.
- `DockItem.qml`: icon + running indicator; left click → `WindowService.
  focusOrReport(appId)` then `ApplicationService.launch(entry)`; middle click →
  always launch.
- `WindowService` (foreign-toplevel) is the only place the protocol is named.
