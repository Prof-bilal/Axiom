# Top panel

## Goal

A slim, information-dense top panel showing workspace state, a launcher entry,
the clock, tray items, system status and a route to session actions — never
placeholder data.

## Projects Studied

COSMIC (`cosmic-panel`), Sway (layer-shell), Wayfire (layer-shell), Quickshell
(`WlrLayershell`, `PanelWindow`).

## Important Source Files

- COSMIC: `cosmic-panel/src/panel_space.rs` (anchor/margin/exclusive-zone,
  `set_exclusive_zone`), `layout.rs`/`overflow.rs` (applet sections),
  `container_config.rs` (default Panel + Dock).
- Sway: `sway/sway/desktop/layer_shell.c` (`arrange_layers` shrinks `usable_area`
  by exclusive zones), `include/sway/server.h` (`SWAY_LAYER_SHELL_VERSION 5`).
- Quickshell: `src/window/panelinterface.hpp` (`PanelWindow`:
  `anchors`/`margins`/`exclusiveZone`/`aboveWindows`/`focusable`),
  `src/wayland/wlr_layershell/wlr_layershell.hpp` (`layer`, `keyboardFocus`,
  `namespace`).

## Runtime Behavior

- A panel is one `zwlr_layer_surface_v1` per output (COSMIC: per config+output).
  `set_anchor` picks edges; `set_margin` offsets; `set_exclusive_zone` reserves
  space so tiled windows do not overlap the panel.
- Sway's `arrange_layers` subtracts exclusive zones from the output's usable
  area, across all outputs.
- Quickshell maps the platform-neutral `PanelWindow` onto `WlrLayershell`; one
  `QQuickWindow` per surface; `aboveWindows` ≈ layer Top/Bottom,
  `focusable` ≈ keyboard interactivity.

## REA Findings

Not required: the anchoring/exclusive-zone behavior is defined in the layer-shell
protocol and implemented in visible source (`layer_shell.c`). Runtime capture
would only re-confirm it.

## IPC / Protocols

`zwlr_layer_shell_v1` (layer, anchor, exclusive zone, keyboard interactivity,
namespace). Panel content reads session state via the shell's services.

## Dependencies

A layer-shell compositor; the shell toolkit; icon/font assets.

## Good Design Decisions

- Reserve space with an exclusive zone so the panel is not overlapped.
- Use the protocol's keyboard-interactivity modes instead of grabbing input.
- Sectioned layout (left/center/right) with defined overflow.

## Problems / Tradeoffs

- Exclusive-zone handling across monitors must be consistent, or windows land
  under the panel.
- `OnDemand` keyboard focus can behave unexpectedly; `None` is safer for a
  non-interactive bar.

## License Notes

COSMIC panel GPL-3.0-only (reference). Sway MIT. Quickshell LGPL-3.0-only.

## What Axiom Should Reuse

- Layer-shell anchoring + exclusive zone + per-output surfaces.
- Left/center/right information layout.

## What Axiom Should Reimplement

- The panel itself (QML) and its status applets, over Axiom services.

## What Axiom Should Avoid

- Applet-hosting sub-compositor architectures (COSMIC) — unnecessary for Phase 3.
- Hard-coded/fake status values.

## Final Axiom Design

- `src/panel/Panel.qml`: one `PanelWindow` per `Quickshell.screens` (via
  `Variants`), `anchors { top, left, right }`, `exclusiveZone: 32`,
  `WlrLayershell.layer: Top`, `keyboardFocus: None`, namespace `axiom-panel`.
- Left: Axiom mark (launcher) + `WorkspaceIndicator`. Center: `Clock`. Right:
  `Tray` + `StatusIndicators` + session button.
- All values are real: workspaces from `WorkspaceService`, tray from
  `SystemTray`, status from `SystemService`.
