pragma Singleton

// ApplicationService — the Axiom boundary for installed applications.
// Discovered from XDG desktop entries; launching goes through the entry's own
// resolved command (no shell string building in UI code). A future Axiom app
// index replaces this adapter without changing callers.

import QtQuick
import Quickshell

Singleton {
    id: apps

    readonly property string backend: "xdg-desktop-entries"
    readonly property var all: DesktopEntries.applications ? DesktopEntries.applications.values : []

    // Desktop-entry ids launched in this session, most recent first. Session
    // memory only: nothing is written to disk.
    property var recentIds: []
    readonly property int recentLimit: 4

    // Icons that recent icon themes dropped, mapped to names that still exist.
    // Without this, e.g. pcmanfm's `system-file-manager` resolves to nothing
    // and Qt renders its magenta/black missing-image texture.
    readonly property var iconAliases: ({
        "system-file-manager": ["org.gnome.Nautilus", "folder", "inode-directory"],
        "utilities-terminal": ["foot", "org.gnome.Terminal", "terminal"],
        "accessories-text-editor": ["org.xfce.mousepad", "text-editor", "text-x-generic"]
    })

    function visibleEntries() {
        return all.filter(function (e) { return !e.noDisplay && e.name && e.name.length > 0 })
    }

    function search(query) {
        var q = (query || "").toLowerCase().trim()
        var list = visibleEntries()
        if (q.length === 0) {
            return list.slice().sort(function (a, b) { return a.name.localeCompare(b.name) })
        }
        var scored = []
        for (var i = 0; i < list.length; i++) {
            var e = list[i]
            var name = e.name.toLowerCase()
            var idx = name.indexOf(q)
            var generic = (e.genericName || "").toLowerCase().indexOf(q)
            if (idx === -1 && generic === -1 && e.id.toLowerCase().indexOf(q) === -1) continue
            scored.push({ entry: e, rank: idx === -1 ? (generic === -1 ? 2000 : 1000 + generic) : idx })
        }
        scored.sort(function (a, b) { return a.rank - b.rank || a.entry.name.localeCompare(b.entry.name) })
        return scored.map(function (s) { return s.entry })
    }

    // Resolve a running app id to its desktop entry (for dock icons/labels).
    function entryForAppId(appId) {
        if (!appId) return null
        var direct = DesktopEntries.byId(appId)
        if (direct) return direct
        var list = all
        var needle = String(appId).toLowerCase()
        for (var i = 0; i < list.length; i++) {
            var e = list[i]
            if (e.startupClass && e.startupClass.toLowerCase() === needle) return e
            if (e.id && e.id.toLowerCase() === needle) return e
        }
        // Reverse-DNS ids (org.xfce.mousepad) vs short app ids (mousepad).
        for (var j = 0; j < list.length; j++) {
            var id = list[j].id ? list[j].id.toLowerCase() : ""
            if (id.endsWith("." + needle)) return list[j]
        }
        return null
    }

    function launch(entry) {
        if (!entry) return
        entry.execute()
        var next = [entry.id].concat(recentIds.filter(function (id) { return id !== entry.id }))
        recentIds = next.slice(0, recentLimit)
    }

    function launchId(appId) {
        var e = entryForAppId(appId)
        if (e) launch(e)
        return e !== null
    }

    function recentEntries() {
        var out = []
        for (var i = 0; i < recentIds.length; i++) {
            var e = DesktopEntries.byId(recentIds[i])
            if (e) out.push(e)
        }
        return out
    }

    // Resolve an icon name to a path that exists, or "" if none does. Callers
    // render an Axiom fallback glyph for "" instead of a broken image.
    function resolveIcon(name) {
        if (!name || name.length === 0) return ""
        if (name.charAt(0) === "/") return "file://" + name
        var p = Quickshell.iconPath(name, true)
        if (p && p.length > 0) return p
        var alts = iconAliases[name] || []
        for (var i = 0; i < alts.length; i++) {
            p = Quickshell.iconPath(alts[i], true)
            if (p && p.length > 0) return p
        }
        return ""
    }

    function iconFor(entry) {
        if (!entry) return ""
        return resolveIcon(entry.icon)
    }
}
