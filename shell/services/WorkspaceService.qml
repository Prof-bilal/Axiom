pragma Singleton

// WorkspaceService — the Axiom session contract for workspace state.
//
// Adapter: the standard ext-workspace-v1 protocol (Quickshell.WindowManager
// "windowsets") for state and switching under labwc (ADR-016). A future Axiom
// compositor replaces the backend without changing callers. Compositors that
// list workspaces but refuse client activation (canActivate false) get a no-op
// here; their own key bindings still switch.

import QtQuick
import Quickshell
import Quickshell.WindowManager

Singleton {
    id: ws

    readonly property string backend: "ext-workspace-v1"

    // Displayable workspaces, ordered by their number (names are "1".."4").
    readonly property var list: {
        var all = WindowManager.windowsets || []
        var out = []
        for (var i = 0; i < all.length; i++) {
            if (all[i].shouldDisplay) out.push(all[i])
        }
        out.sort(function (a, b) {
            var na = parseInt(a.name), nb = parseInt(b.name)
            if (isNaN(na) || isNaN(nb)) return String(a.name).localeCompare(String(b.name))
            return na - nb
        })
        return out
    }

    readonly property var focused: {
        var l = list
        for (var i = 0; i < l.length; i++) if (l[i].active) return l[i]
        return null
    }

    function activate(workspace) {
        if (workspace && workspace.canActivate) workspace.activate()
    }

    function switchTo(number) {
        var l = list
        for (var i = 0; i < l.length; i++) {
            if (String(l[i].name) === String(number)) { activate(l[i]); return true }
        }
        return false
    }

    function step(delta) {
        var l = list
        if (l.length === 0) return
        var idx = l.indexOf(focused)
        activate(l[(idx + delta + l.length) % l.length])
    }

    function next() { step(1) }
    function previous() { step(-1) }
}
