pragma Singleton

// WindowService — the Axiom session contract for application windows.
// Phase 3 adapter: zwlr-foreign-toplevel-management via the compositor
// harness. Operations degrade to explicit no-ops when the harness ignores a
// request (e.g. tiling compositor minimize); they never fabricate state.

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Singleton {
    id: windows

    readonly property string backend: "wlr-foreign-toplevel-management"
    readonly property var toplevels: ToplevelManager.toplevels
    readonly property var active: ToplevelManager.activeToplevel

    function list() {
        return toplevels ? toplevels.values : []
    }

    function forAppId(appId) {
        if (!appId) return []
        return list().filter(function (t) { return t.appId === appId })
    }

    function hasAppId(appId) {
        return forAppId(appId).length > 0
    }

    function activate(toplevel) {
        if (toplevel) toplevel.activate()
    }

    function close(toplevel) {
        if (toplevel) toplevel.close()
    }

    function toggleMaximized(toplevel) {
        if (toplevel) toplevel.maximized = !toplevel.maximized
    }

    function toggleFullscreen(toplevel) {
        if (toplevel) toplevel.fullscreen = !toplevel.fullscreen
    }

    // Window buttons for the focused window under Hyprland. Hyprland has no
    // minimize, so a minimized window goes to a hidden special workspace; moving
    // a window there shows that workspace, so it is hidden again.
    function minimizeActive() {
        Hyprland.dispatch("hl.dsp.window.move({ workspace = 'special:minimized', follow = false })")
        var m = Hyprland.focusedMonitor
        if (m && m.specialWorkspace && m.specialWorkspace.name === "special:minimized")
            Hyprland.dispatch("hl.dsp.workspace.toggle_special('minimized')")
    }

    function toggleMaximizeActive() {
        Hyprland.dispatch("hl.dsp.window.fullscreen({ mode = 'maximized' })")
    }

    // A minimized window sits on Hyprland's hidden special workspace, where a
    // plain activate does nothing. Bring it back to the focused workspace, then
    // focus it. Returns true when it handled the window.
    function restore(toplevel) {
        if (!toplevel) return false
        var hs = Hyprland.toplevels ? Hyprland.toplevels.values : []
        for (var i = 0; i < hs.length; i++) {
            if (hs[i].wayland !== toplevel) continue
            var ws = hs[i].lastIpcObject ? hs[i].lastIpcObject.workspace : null
            if (!ws || ws.name !== "special:minimized" || !Hyprland.focusedWorkspace) return false
            // Focus first: Hyprland's move dispatcher acts on the focused window.
            toplevel.activate()
            Hyprland.dispatch("hl.dsp.window.move({ workspace = " + Hyprland.focusedWorkspace.id + ", follow = true })")
            return true
        }
        return false
    }

    // Focus the first window of an app, or return false so the caller launches
    // a new instance.
    function focusOrReport(appId) {
        var matches = forAppId(appId)
        if (matches.length === 0) return false
        matches[0].activate()
        return true
    }
}
