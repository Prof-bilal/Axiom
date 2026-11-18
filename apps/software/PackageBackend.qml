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
    // Updates from the local sync database (no root). Needs a refreshed database to be current.
    property var updates: []
    property bool snapshotsAvailable: false
    property string updateMessage: ""
    function loadUpdates() {
        runner.runC(["pacman", "-Qu"], function (r) {
            updates = r.code === 0 || r.code === 1 ? Sw.parseUpdates(r.out) : []
        })
        runner.run(["sh", "-c", "command -v snapper >/dev/null 2>&1"], function (r) { snapshotsAvailable = r.code === 0 })
    }
    // Admin approval through its own polkit action; the helper snapshots before upgrading.
    function updateAll() {
        updateMessage = "Waiting for admin approval…"
        runner.run(["pkexec", "/usr/local/bin/axiom-pkg-update"], function (r) {
            updateMessage = r.code === 0 ? "System updated." : (r.err || "Update was not approved or failed.").trim().split("\n").pop()
            loadUpdates()
        })
    }

    // Flatpak apps (ADR-034): user scope, no root.
    property var flatpaks: []
    property string flatpakMessage: ""
    function loadFlatpaks() {
        runner.run(Sw.flatpakListArgv(), function (r) { flatpaks = r.code === 0 ? Sw.parseFlatpakList(r.out) : [] })
    }
    function flatpakDo(argv, busy, done) {
        if (!argv) { flatpakMessage = "Enter a valid app id, for example org.gnome.Calculator"; return }
        flatpakMessage = busy
        runner.run(Sw.flatpakRemoteAddArgv(), function () {
            runner.run(argv, function (r) {
                flatpakMessage = r.code === 0 ? done : (r.err || "Failed").trim().split("\n").pop()
                loadFlatpaks()
            })
        })
    }
    function flatpakInstall(id) { flatpakDo(Sw.flatpakInstallArgv(id), "Installing " + id + "…", "Installed " + id) }
    function flatpakRemove(id) { flatpakDo(Sw.flatpakUninstallArgv(id), "Removing " + id + "…", "Removed " + id) }
    function flatpakUpdate(id) { flatpakDo(Sw.flatpakUpdateArgv(id), "Updating " + id + "…", "Updated " + id) }

    // Snapshots and rollback (ADR-033). Listing reads snapper; rollback goes through its own
    // polkit action (org.axiom.installer.rollback) and needs a reboot to finish.
    property var snapshots: []
    property string snapshotMessage: ""
    property int pendingRollback: -1
    function loadSnapshots() {
        runner.run(["snapper", "-c", "root", "list", "--columns", "number,date,description"], function (r) {
            snapshots = r.code === 0 ? Sw.parseSnapshots(r.out) : []
            snapshotMessage = r.code === 0 ? "" : "Snapshots are not available on this system."
        })
    }
    function askRollback(n) { pendingRollback = n }
    function confirmRollback(n) {
        pendingRollback = -1
        snapshotMessage = "Waiting for admin approval…"
        runner.run(["pkexec", "/usr/local/bin/axiom-pkg-rollback", String(n)], function (r) {
            snapshotMessage = r.code === 0 ? "Rolled back to snapshot " + n + ". Restart to finish." : (r.err || "Rollback was not approved or failed.").trim().split("\n").pop()
        })
    }

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

    Component.onCompleted: { load(); loadUpdates(); loadFlatpaks(); loadSnapshots() }
}
