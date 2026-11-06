pragma Singleton

// KeyboardService — keyboard layouts. The compositor reads XKB_DEFAULT_LAYOUT
// only when it starts, so the choice is stored in ~/.config/axiom/keyboard.env
// and applied by axiom-session at the next login (the page says so). Layout
// codes come from the xkeyboard-config database and are validated before they
// are written; nothing else can reach the file.

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: kb

    readonly property string dir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/axiom"
    readonly property string path: dir + "/keyboard.env"

    property var layouts: []          // [{code, name}]
    property string primary: "us"
    property string secondary: ""     // "" = single layout; Alt+Shift switches when set
    // Layout the running compositor was started with.
    readonly property string active: Quickshell.env("XKB_DEFAULT_LAYOUT") || "us"
    readonly property bool pendingRestart: composed(primary, secondary) !== active

    function composed(a, b) { return b.length > 0 ? a + "," + b : a }

    function parseLayouts(text) {
        var out = []
        var inLayouts = false
        text.split("\n").forEach(function (l) {
            if (l.indexOf("! ") === 0) { inLayouts = l.trim() === "! layout"; return }
            if (!inLayouts) return
            var m = /^\s+([a-z0-9_]+)\s+(.+)$/.exec(l)
            if (m) out.push({ code: m[1], name: m[2] })
        })
        return out
    }

    function valid(code) { return /^[a-z0-9_]{2,12}$/.test(code) && layouts.some(function (l) { return l.code === code }) }

    function parseEnv(text) {
        var m = /XKB_DEFAULT_LAYOUT=([a-z0-9_,]*)/.exec(text)
        if (!m) return ["us", ""]
        var parts = m[1].split(",")
        return [parts[0] || "us", parts[1] || ""]
    }

    function setLayouts(a, b) {
        if (!valid(a) || (b.length > 0 && !valid(b))) return false
        primary = a
        secondary = b
        makeDir.running = false
        makeDir.running = true
        return true
    }

    Process {
        id: makeDir
        command: ["mkdir", "-p", "--", kb.dir]
        onExited: function (code) {
            if (code !== 0) return
            var lines = ["XKB_DEFAULT_LAYOUT=" + kb.composed(kb.primary, kb.secondary)]
            if (kb.secondary.length > 0) lines.push("XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle")
            file.setText(lines.join("\n") + "\n")
        }
    }

    FileView {
        id: file
        path: kb.path
        printErrors: false
        onLoaded: { var v = kb.parseEnv(text()); kb.primary = v[0]; kb.secondary = v[1] }
    }

    FileView {
        id: rules
        path: "/usr/share/X11/xkb/rules/base.lst"
        printErrors: false
        onLoaded: kb.layouts = kb.parseLayouts(text())
    }
}
