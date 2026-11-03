import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared
import "software.js" as Sw

// Software backend: installed packages from pacman's local database
// (read-only), the desktop applications the shell knows about, and honest
// database state. Nothing here changes the system: package installation,
// removal and updates are not offered until Axiom's permission layer exists.
Item {
    id: backend

    // "apps" | "all" | "explicit" | "deps" | "unused"
    property string view: "apps"
    property string query: ""
    property string sortKey: "name"

    property var packages: []
    property var unusedSet: ({})
    property bool loading: true
    property string error: ""
    property bool hasDatabases: false
    property bool checkedDatabases: false

    readonly property var visiblePackages: Sw.sortPackages(Sw.filterPackages(packages, query, view === "apps" ? "all" : view, unusedSet), sortKey)

    readonly property var visibleApps: {
        var q = query.trim().toLowerCase()
        var list = ApplicationService.all.filter(function (e) {
            if (e.noDisplay) return false
            if (q.length === 0) return true
            return (e.name || "").toLowerCase().indexOf(q) >= 0
                || (e.comment || "").toLowerCase().indexOf(q) >= 0
                || (e.genericName || "").toLowerCase().indexOf(q) >= 0
        })
        list.sort(function (a, b) { return (a.name || "").toLowerCase() < (b.name || "").toLowerCase() ? -1 : 1 })
        return list
    }

    readonly property int explicitCount: packages.filter(function (p) { return p.explicit }).length
    readonly property int unusedCount: Object.keys(unusedSet).length

    CommandRunner { id: runner }

    function load() {
        loading = true
        error = ""
        runner.runC(["pacman", "-Qi"], function (r) {
            if (r.code === 0) {
                packages = Sw.parseQi(r.out)
                if (Quickshell.env("AXIOM_SOFTWARE_DEBUG") === "1") console.log("software: " + packages.length + " packages")
                if (packages.length === 0) error = "No installed packages were reported by pacman."
            } else {
                packages = []
                error = "The package database could not be read: " + (r.err.split("\n")[0] || "unknown error")
            }
            loading = false
        })
        // Unused dependencies: exit code 1 simply means "none".
        runner.runC(["pacman", "-Qdtq"], function (r) { unusedSet = Sw.parseNameSet(r.out) })
        runner.run(["ls", "-1", "/var/lib/pacman/sync"], function (r) {
            hasDatabases = r.code === 0 && Sw.hasSyncDatabases(r.out)
            checkedDatabases = true
        })
    }

    // Detail lookups (called by the detail pane).
    function packageFiles(name, cb) {
        runner.runC(["pacman", "-Ql", "--", name], function (r) { cb(r.code === 0 ? Sw.parseFiles(r.out, 200) : { count: 0, files: [], error: r.err.split("\n")[0] }) })
    }

    // Which package provides this application's desktop entry?
    function owner(entry, cb) {
        var id = entry.id || ""
        var candidates = ["/usr/share/applications/" + id + ".desktop", "/usr/local/share/applications/" + id + ".desktop"]
        function tryNext(i) {
            if (i >= candidates.length) { cb(null); return }
            runner.runC(["pacman", "-Qo", "--", candidates[i]], function (r) {
                var o = r.code === 0 ? Sw.parseOwner(r.out) : null
                if (o) cb(o); else tryNext(i + 1)
            })
        }
        if (id.length === 0) { cb(null); return }
        tryNext(0)
    }

    Component.onCompleted: load()
}
