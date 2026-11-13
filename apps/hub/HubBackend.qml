import QtQuick
import Quickshell
import Quickshell.Io
import qs.apps.shared
import qs.apps.appinstaller
import "catalog.js" as Cat
import "backends.js" as B

// Axiom Hub state: the catalog, this machine's RAM and disk, what is installed,
// and one install/remove/update transaction at a time with live progress.
// Every command is an argv array run without a shell.
Item {
    id: be

    readonly property var catalog: Cat.CATALOG
    property var sys: ({ ramGb: 8, freeDiskGb: 50 })
    property bool sysKnown: false
    property var available: ["pacman"]
    property var installed: []
    property var updates: []

    // current transaction
    property bool busy: false
    property bool done: false
    property var current: null
    property string action: "install"
    property int percent: -1
    property int step: 0
    property string error: ""
    property string log: ""
    property bool cancellable: true
    property string status: "Ready to install applications"

    signal finished(bool ok)

    CommandRunner { id: runner }
    InstallFile { id: local }

    function isInstalled(id) { return installed.indexOf(id) >= 0 }
    function hasUpdate(id) { return updates.indexOf(id) >= 0 }

    // Preview only: AXIOM_HUB_DEMO_INSTALLED=1 pretends a few apps are installed so the
    // Installed screen can be seen without a real install. Off by default.
    function probe() {
        if (Quickshell.env("AXIOM_HUB_DEMO_INSTALLED") === "1") {
            installed = ["vscode", "firefox", "vlc", "gimp"]
            updates = ["firefox"]
            status = "System is up to date"
        }
        runner.run(["awk", "/MemTotal/ {print $2}", "/proc/meminfo"], function (r) {
            var kb = parseInt(r.out.trim(), 10)
            if (r.code === 0 && kb > 0) {
                sys = { ramGb: Math.round(kb / 1048576 * 10) / 10, freeDiskGb: sys.freeDiskGb }; sysKnown = true
            }
        })
        runner.run(["df", "--output=avail", "-B1G", "/home"], function (r) {
            var m = r.out.match(/(\d+)G?\s*$/)
            if (r.code === 0 && m) sys = { ramGb: sys.ramGb, freeDiskGb: parseInt(m[1], 10) }
        })
        ;["flatpak", "npm", "pipx"].forEach(function (cmd) {
            runner.run([cmd, "--version"], function (r) {
                if (r.code === 0 && available.indexOf(cmd) < 0) available = available.concat([cmd])
            })
        })
        local.resolveHome(function () {})
        refreshInstalled()
    }

    function refreshInstalled() {
        if (Quickshell.env("AXIOM_HUB_DEMO_INSTALLED") === "1") return
        runner.run(["flatpak", "list", "--app", "--columns=application"], function (fp) {
            runner.run(["pacman", "-Qq"], function (pm) {
                installed = B.installedIds(catalog, fp.code === 0 ? fp.out : "", pm.code === 0 ? pm.out : "")
            })
        })
    }

    function checkUpdates() {
        status = "Checking for updates..."
        runner.run(["flatpak", "remote-ls", "--updates", "--columns=application"], function (r) {
            var lines = r.code === 0 ? r.out.split("\n").map(function (l) { return l.trim() }) : []
            updates = catalog.filter(function (a) {
                return a.sources.some(function (s) { return s.type === "flatpak" && lines.indexOf(s.ref) >= 0 })
            }).map(function (a) { return a.id })
            status = updates.length > 0 ? updates.length + " update(s) available" : "System is up to date"
        })
    }

    function run(app, act) {
        if (busy) return
        var src = B.chooseSource(app, available)
        var argv = null
        if (src) argv = act === "remove" ? B.removeArgv(src, local.home) : act === "update" ? B.updateArgv(src, local.home) : B.installArgv(src, local.home)
        begin(app, act, true)
        if (!argv) return fail("No supported install method is available for " + app.name + " on this system.")
        if (src.type !== "flatpak") { proc.command = argv; proc.running = true; return }
        // Flatpak needs the flathub remote first.
        runner.run(B.flathubRemoteArgv(), function (r) {
            if (r.code !== 0) return fail("Could not add the Flathub source: " + (r.err.trim().split("\n").pop() || "no network?"))
            proc.command = argv
            proc.running = true
        })
    }

    function runLocal(info) {
        if (busy) return
        begin({ id: "local", name: info.name, category: "Utilities" }, "install", false)
        step = 1
        local.install(info.path, function (r) {
            if (r.ok) finish(0); else { log = r.message; finish(1) }
        })
    }

    function begin(app, act, canCancel) {
        current = app; action = act; percent = -1; step = 0; error = ""; log = ""
        done = false; busy = true; cancellable = canCancel
        status = (act === "remove" ? "Removing " : "Installing ") + app.name + "..."
    }

    function fail(message) { error = message; busy = false; done = true; status = message; finished(false) }

    function cancel() { if (busy && cancellable) { proc.running = false; canceled = true } }
    property bool canceled: false

    function onLine(line) {
        log = (log + line + "\n").slice(-4000)
        var p = B.parseProgress(line)
        if (p >= 0) { percent = p; step = Math.max(step, B.stepFor(p)) }
        var k = B.stepFromLine(line)
        if (k > step) step = k
        else if (step === 0 && line.trim().length > 0) step = 1
    }

    function finish(code) {
        busy = false; done = true
        if (canceled) { canceled = false; error = "Canceled."; status = "Canceled" }
        else if (code !== 0) {
            var lines = log.trim().split("\n")
            error = lines[lines.length - 1] || "The command failed."
            status = error
        } else {
            percent = 100; step = 3
            status = (action === "remove" ? "Removed " : "Installed ") + current.name
        }
        refreshInstalled()
        finished(code === 0 && error === "")
    }

    Process {
        id: proc
        stdout: SplitParser { onRead: function (data) { be.onLine(data) } }
        stderr: SplitParser { onRead: function (data) { be.onLine(data) } }
        onExited: function (code) { be.finish(code) }
    }

    Component.onCompleted: probe()
}
