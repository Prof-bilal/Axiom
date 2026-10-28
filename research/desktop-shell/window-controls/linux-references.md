# Linux implementation references

## Quickshell

Installed qmltypes (`quickshell-wayland-toplevel-management.qmltypes`, package
revision `0.3.2.r7.g2b4501a-1`) expose `Toplevel.close()`, `activate()`, and
writable `maximized`, `minimized` and `fullscreen` properties with change
signals. This is the chosen first request path because it preserves native
object identity and avoids shell-string construction. Quickshell is LGPL-3.0;
see the license inventory before redistribution.

## Hyprland

Pinned runtime `0.56.2-4` owns focus, workspaces, layout and compositor state.
Its official dispatcher documentation distinguishes `fullscreen 0` (real
fullscreen) from `fullscreen 1` (maximize-like mode), while the current Lua
dispatcher implementation supports window-targeted fullscreen state actions.
These are compositor-specific references, not a reason to bypass the native
Wayland boundary in the first adapter.

## Wayland

The foreign-toplevel management protocol supplies the state and request surface
used by the installed Quickshell type. It is asynchronous; protocol request
acceptance and model confirmation are separate observations.

## Other desktop references

Waybar and Omarchy were inspected for surface lifecycle and module separation,
not copied. Their code/assets, branding and configuration semantics remain
separate from Axiom. No root service or X11 fallback is needed for this slice.
