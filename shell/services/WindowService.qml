pragma Singleton

// WindowService — the Axiom session contract for application windows.
// Adapter: zwlr-foreign-toplevel-management through Quickshell's ToplevelManager,
// which labwc (ADR-016) provides. Nothing here talks to a compositor-specific
// IPC. Operations that a compositor ignores stay explicit no-ops; they never
// fabricate state.

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

    function minimize(toplevel) {
        if (toplevel) toplevel.minimized = true
    }

    // The focused window, for keyboard-driven actions.
    function minimizeActive() { minimize(active) }
    function toggleMaximizeActive() { toggleMaximized(active) }

    // Bring a minimized window back and focus it. Returns true when the window was
    // minimized (so the caller knows it was handled), false for a plain window.
    function restore(toplevel) {
        if (!toplevel || !toplevel.minimized) return false
        toplevel.minimized = false
        toplevel.activate()
        return true
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
