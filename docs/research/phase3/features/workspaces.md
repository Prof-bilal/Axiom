# Workspaces

## Goal

Real compositor-backed workspace state: active workspace, switching, moving
windows between workspaces, and a truthful indicator.

## Projects Studied

COSMIC (`cosmic-workspaces` + `cctk`), Sway (`ext-workspace-v1`, i3 IPC),
Wayfire (per-output 2D grid), Hyprland (`ext-workspace-v1`), Quickshell
(`Quickshell.I3`, `Quickshell.WindowManager`).

## Important Source Files

- COSMIC: `cosmic-workspaces/src/backend/wayland/workspace.rs`
  (`WorkspaceState` via ext-workspace + `zcosmic`), `backend/mod.rs`
  (`workspace_handle.activate()`, `manager.move_to_ext_workspace`).
- Sway: `sway/sway/tree/workspace.c` (`sway_ext_workspace_init`,
  `wlr_ext_workspace_manager_v1_create`, per-output `ext_workspace_group`),
  `sway/sway/ipc-json.c` (workspace `num`/`name`/`urgent`/`representation`).
- Quickshell: `src/x11/i3/ipc/qml.hpp` (`I3` singleton: `workspaces`,
  `focusedWorkspace`, `dispatch`, `monitorFor`), `workspace.hpp`
  (`I3Workspace`: `id`/`name`/`number`/`active`/`focused`/`urgent`/`monitor`/
  `activate()`).

## Runtime Behavior

- Sway maintains one workspace per name, with a per-output priority list, and
  publishes `ext-workspace-v1` groups per output plus workspace state over i3
  IPC (`get_workspaces`, `workspace`/`focus` events).
- Switching is a compositor command (`workspace number N`); moving a window is
  `move container to workspace number N`. The shell never re-implements the
  window tree.
- COSMIC additionally exposes pinning and spatial coordinates (not in
  ext-workspace); Wayfire uses a continuous 2D grid per output, which is a
  different model from linear i3-style workspaces.

## REA Findings

Not required; workspace state is visible in sway's `ipc-json.c` and the
`ext-workspace` managers.

## IPC / Protocols

`ext-workspace-v1` (group/workspace handles, activate/remove requests, state
events), i3/sway IPC (`get_workspaces`, `workspace` events, `workspace`/`move`
commands), or `Quickshell.WindowManager` (ext-workspace via wlroots).

## Dependencies

Compositor workspace model; a state source for the indicator.

## Good Design Decisions

- Use the compositor's workspace model rather than a shell-owned duplicate.
- Surface `urgent` state to the indicator.
- Keep switching as compositor commands (one source of truth).

## Problems / Tradeoffs

- Models differ (linear i3/sway vs COSMIC pinned vs Wayfire 2D grid); the shell
  must treat "workspace" as an opaque, named handle with an index.
- Multi-monitor workspace ownership is compositor-specific.

## License Notes

COSMIC GPL-3.0-only (reference). Sway MIT. Quickshell LGPL-3.0-only.

## What Axiom Should Reuse

- `ext-workspace-v1` as the portable model; keep the shell free of a window tree.

## What Axiom Should Reimplement

- The indicator and switching policy through `WorkspaceService`.

## What Axiom Should Avoid

- A shell-owned window/workspace tree duplicating the compositor.

## Final Axiom Design

- `WorkspaceService` wraps `Quickshell.I3` (sway/IPC): `workspaces`,
  `focused`, `activate(ws)`, `switchTo(number)`, `moveFocusedTo(number)`.
- `src/panel/WorkspaceIndicator.qml` renders one chip per real workspace with
  focused/urgent state; click activates. `$mod+1..9` and `$mod+Shift+1..9` in
  the harness config switch/move.
- The adapter is the only place the i3/sway IPC is named; a future
  `ext-workspace`-only adapter can replace it.
