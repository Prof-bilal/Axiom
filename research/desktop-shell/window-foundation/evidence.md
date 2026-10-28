# Window foundation evidence

2026-10-28; SOURCE-INSPECTED unless stated otherwise.

1. [Hyprland IPC](https://wiki.hypr.land/IPC/) documents separate request and
   newline-delimited event sockets under the current runtime session. This is
   compositor-specific IPC, not permission for capture/input injection.
2. [Quickshell 0.3.2 Hyprland](https://quickshell.org/docs/v0.3.2/types/Quickshell.Hyprland/Hyprland/)
   exposes toplevels, workspaces, monitors, active toplevel and `usingLua`.
3. Pinned [connection.cpp](https://github.com/quickshell-mirror/quickshell/blob/v0.3.2/src/wayland/hyprland/ipc/connection.cpp)
   reads `j/status`, subscribes to events and refreshes models. Its internal
   connection-valid flag is not exposed through the QML singleton. Disconnect
   logs alone do not prove QML consumers stopped using cached state.
4. Pinned [hyprland_toplevel.cpp](https://github.com/quickshell-mirror/quickshell/blob/v0.3.2/src/wayland/hyprland/ipc/hyprland_toplevel.cpp)
   binds monitor through workspace and associates the compositor address with
   the Wayland handle. `lastIpcObject` is a snapshot, not every property's live
   event stream. Avoid claiming continuous freshness from that map alone.
5. Installed `/usr/lib/qt6/qml/Quickshell/Hyprland/_Ipc/` and
   `Wayland/_ToplevelManagement/` qmltypes confirm the shipped native interfaces.
   Wayland handles expose appId, activated, minimized, maximized and fullscreen.
   An app ID is identification data, not an executable command or unique window.
6. RUNTIME-OBSERVED: `hyprctl version`, `qs --version`, `hyprctl -j instances`
   and `hyprctl -j monitors` establish the host versions and single display in
   the repository audit. They do not validate shell actions or a guest boot.
7. RUNTIME-OBSERVED: the first diagnostic found `Hyprland.activeToplevel` null
   while `hyprctl activewindow` reported a mapped active window. Source inspection
   confirms `connection.cpp` updates the active pointer on `activewindowv2` but
   does not query initial activation. Wayland's ToplevelManager already supplied
   the active handle; resolving that handle to the native Hyprland object fixed
   initial activation without dispatching focus or changing any window.
8. SOURCE-INSPECTED: [Hyprland 0.56.2 ForeignToplevelWlr.cpp](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/protocols/ForeignToplevelWlr.cpp)
   implements close by `sendClose`, maximize/fullscreen through its fullscreen
   controller, but set/unset-minimized only posts a `minimized` IPC event.
   `sendState` emits activated/fullscreen/maximized flags, not minimized. Thus a
   Wayland `minimized` property alone cannot implement actual hiding/restoration.
   Axiom must specify and prove a compositor policy in 3.2; no such policy is
   enabled in the current read-only adapter.
9. RUNTIME-OBSERVED in the second UEFI fixture: targeted workspace move/switch,
   mixed-scale monitor movement and populated monitor removal matched independent
   compositor JSON. The first attempt exposed bare-hex vs `0x` address mismatch;
   a subsequent attempt exposed stale native scale (2 versus compositor 1.5).
   Both issues were corrected in the adapter and the same test passed. Test
   diagnostic comparisons exclude titles and application content.
10. SOURCE-INSPECTED: [Hyprland monitor Lua binding](https://github.com/hyprwm/Hyprland/blob/v0.56.2/src/config/lua/bindings/LuaBindingsConfigRules.cpp)
    schedules monitor refresh after `hl.monitor()` without the native module's
    configreloaded path. Installed ShellScreen geometry/DPI signals provide
    actual output notifications. The adapter refreshes native monitor data on
    these events instead of trusting a stale scale or adding polling.
11. RUNTIME-OBSERVED: request-only relay removal leaves the event channel alive
    but explicit validation makes the adapter unavailable with empty models.
    Restoring the request relay and revalidating recovers observation. A new
    model process against the unaffected compositor also initializes correctly.
12. RUNTIME-OBSERVED: the fixture's actual secure session lock was independently
    confirmed by its status and Hyprland LOCK blocker. Read-only probes worked
    while locked and after real keyboard/PAM unlock using the published fixture
    credential. Wrong keyboard input did not unlock it; no PAM/credential or
    permission configuration was changed. This does not prove future overlay
    placement/action suppression or PAM failure counters.

REA's installed-directory probe and working MCP transport are documented in
[REA setup](../../../docs/research/REA_SETUP.md). It returned inventory evidence,
not window behavior. No binary decompilation is needed for these open-source
interfaces, and no macOS runtime was investigated.
