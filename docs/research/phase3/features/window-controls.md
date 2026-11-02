# Window controls

## Goal

Real close / (un)maximize / fullscreen / focus behavior driven by the
compositor, with an honest account of client- vs server-side decorations and of
operations a tiling harness cannot provide.

## Projects Studied

COSMIC (`cosmic-comp` decorations), Sway (CSD, no SSD), Wayfire decor plugin,
Hyprland (decoration rules), Quickshell (`Toplevel`).

## Important Source Files

- COSMIC: `cosmic-comp/src/shell/element/window.rs` (`has_ssd`/`SSD_HEIGHT`,
  resize/border grabs), `wayland/handlers/decoration.rs` (xdg-decoration + KDE
  server-decoration; stacks forced to ServerSide).
- Sway: `sway/sway/tree/view.c` (`wlr_foreign_toplevel_handle_v1_set_activated`
  on focus), `sway/sway/desktop/xdg_shell.c` (no server-side decorations; sway
  relies on CSD).
- Quickshell: `src/wayland/toplevel/qml.hpp` (`Toplevel.activate/close`,
  `maximized`/`minimized`/`fullscreen` as requests the compositor may ignore,
  `fullscreenOn(screen)`).

## Runtime Behavior

- **Decorations:** COSMIC draws server-side decorations and can force them.
  Sway is a *tiling* compositor with **no server-side decorations**; applications
  draw their own (CSD). This directly bounds what window buttons the shell can
  promise.
- **Window requests:** foreign-toplevel exposes `close`, `activate`, and
  maximize/minimize/fullscreen as *requests*. Sway honors close/activate; tiling
  has no real minimize, and maximize maps to fullscreen semantics.
- **Focus:** the compositor owns focus; the shell only requests activation.

## REA Findings

Decoration policy is visible in COSMIC source (SSD height/grabs) and sway's
xdg-shell handler (CSD). Not required at runtime for Phase 3.

## IPC / Protocols

`zwlr_foreign_toplevel_management_v1` requests; xdg-decoration (client vs server)
where supported; XDG activation.

## Dependencies

Compositor decoration policy; foreign-toplevel support.

## Good Design Decisions

- Treat maximize/minimize/fullscreen as *requests* the compositor may ignore and
  reflect the resulting state, not an assumed one.
- Let the compositor own focus and decorations.

## Problems / Tradeoffs

- With a tiling harness, "minimize" and server-side decorations are unavailable;
  a shell that draws fake title-bar buttons would be dishonest.
- Apps without CSD have no visible close button under sway.

## License Notes

COSMIC comp GPL-3.0-only (reference). Sway MIT. Quickshell LGPL-3.0-only.

## What Axiom Should Reuse

- The request/reflect model for window state.

## What Axiom Should Reimplement

- Window controls as shell actions over `WindowService`, plus compositor
  keybindings for focus/close/fullscreen.

## What Axiom Should Avoid

- **Faking window buttons in screenshots.** No hard-coded title bars.
- Assuming SSD exists on a tiling harness.

## Final Axiom Design

- `WindowService` exposes `activate`, `close`, `toggleMaximized`,
  `toggleFullscreen` over `Toplevel`, degrading to no-ops when the harness
  ignores a request.
- Window management in Phase 3 is compositor-driven: sway bindings
  (`$mod+q` kill, `$mod+f` fullscreen, `$mod+Shift+space` floating). The shell
  does not paint decorations for other applications.
- **Known limitation:** under the temporary tiling harness there are no
  server-side decorations and no true minimize; these are recorded, not faked.
  Window controls become complete when the Axiom compositor provides SSD.
