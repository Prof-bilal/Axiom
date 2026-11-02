pragma Singleton

// WindowService — the Axiom session contract for application windows.
// Phase 3 adapter: zwlr-foreign-toplevel-management via the compositor
// harness. Operations degrade to explicit no-ops when the harness ignores a
// request (e.g. tiling compositor minimize); they never fabricate state.

import Quickshell
import Quickshell.Wayland

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

    // Focus the first window of an app, or return false so the caller launches
    // a new instance.
    function focusOrReport(appId) {
        var matches = forAppId(appId)
        if (matches.length === 0) return false
        matches[0].activate()
        return true
    }
}
