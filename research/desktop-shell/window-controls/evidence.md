# Window controls evidence

Status: SOURCE-INSPECTED + GUEST-VALIDATED for the current V1 action slice.
Date: 2026-10-28. Target environment: Quickshell 0.3.2.r7.g2b4501a-1,
Hyprland 0.56.2-4, Qt 6.12.0.

## Observed/source evidence

1. The installed Quickshell Wayland foreign-toplevel metadata at
   `/usr/lib/qt6/qml/Quickshell/Wayland/_ToplevelManagement/quickshell-wayland-toplevel-management.qmltypes`
   exposes a `Toplevel` object with read-only identity/state (`appId`, `title`,
   `activated`, `screens`) and writable `maximized`, `minimized` and
   `fullscreen` properties. It also exposes `activate()` and `close()` methods,
   plus state-change signals. This is shipped metadata evidence, not a promise
   that every compositor accepts every request.
2. The same metadata exposes `ToplevelManager.toplevels` and
   `ToplevelManager.activeToplevel`; the existing Axiom adapter resolves the
   Wayland object to the corresponding live Hyprland object by identity.
3. Hyprland's official dispatcher documentation distinguishes `killactive`
   from client-oriented close behavior and distinguishes fullscreen mode `0`
   from maximize-like mode `1`. The official Lua dispatcher source also shows
   window-targeted fullscreen operations and explicit `set`/`unset` actions.
4. The pinned Hyprland IPC model has `Hyprland.dispatch(request: string)`. The
   current adapter uses only fixed, validated dispatcher templates for the
   operations that the pinned guest accepts reliably: window-targeted
   maximize/fullscreen and a private-workspace minimize policy. It does not
   expose arbitrary dispatch text to callers.

## Disposable guest results

In the pinned UEFI/KVM guest, two owned Foot windows were exercised through the
native Quickshell model and the Axiom action adapter. Close, maximize/restore,
fullscreen/exit and minimize/restore all completed with same-target
post-request verification. Native `Toplevel.minimized = true/false` was also
attempted and timed out in this compositor/client combination; treating that
metadata property as a guaranteed hide operation would therefore be incorrect.
The implemented V1 policy parks the target on the fixed private workspace
`special:axiom-minimized`, records its original numeric workspace in memory,
and verifies the target workspace before reporting success.

The visible non-exclusive layer surface mapped as namespace
`axiom-window-controls` on the active monitor. This is a software/emulated
graphics guest result, not physical-GPU performance evidence.

## Evidence limits

Metadata establishes the available API surface, not runtime success. A
compositor may ignore or reject minimize/maximize requests, and a client may
change state asynchronously. Each action therefore requires a bounded
post-request verification against the same native target. Titles and app IDs
are display data only; they are never selectors or command text.

References:

- [Quickshell Wayland toplevel metadata](https://github.com/quickshell-mirror/quickshell/tree/master/src/wayland)
- [Hyprland dispatcher documentation](https://wiki.hypr.land/Configuring/Dispatchers/)
- [Hyprland Lua dispatcher source](https://github.com/hyprwm/Hyprland/blob/main/src/config/lua/bindings/LuaBindingsDispatchers.cpp)
