import QtQuick
import Quickshell.Io
import qs.apps.shared
import "installfile.js" as IF

// Install an AppImage or Flatpak bundle for the current user only (no root).
// Calls back with { ok, message }. Arch packages are refused here; Phase 7b
// routes them through the privileged helper.
Item {
    id: installer

    // HOME is not reliably set inside the shell session, so ask the account
    // database for the home folder of the current user.
    property string home: ""

    function resolveHome(callback) {
        if (home.length > 0) return callback(true)
        runner.run(["id", "-un"], function (u) {
            var name = u.out.trim()
            if (u.code !== 0 || name.length === 0) return callback(false)
            runner.run(["getent", "passwd", name], function (p) {
                var dir = p.out.split(":")[5] || ""
                if (p.code === 0 && dir.length > 0) home = dir
                callback(home.length > 0)
            })
        })
    }
    property string pendingPath: ""
    property string pendingName: ""
    property var pendingClass: null

    CommandRunner { id: runner }

    function install(path, callback) {
        var name = path.split("/").pop()
        var c = IF.classify(name)
        if (!c) return callback({ ok: false, message: "Unsupported file type." })
        if (c.kind === "arch") {
            // Root work goes through the helper; pkexec shows the polkit prompt.
            return runner.run(["pkexec", "/usr/local/bin/axiom-pkgd", "install", path], function (r) {
                callback(r.code === 0 ? { ok: true, message: "Installed " + name }
                                     : { ok: false, message: (r.err || r.out).trim() || "Install was not approved." })
            })
        }

        if (c.kind === "flatpak") {
            runner.run(IF.flatpakArgv(path), function (r) {
                callback(r.code === 0 ? { ok: true, message: "Installed " + name }
                                     : { ok: false, message: (r.err || r.out).trim() || "Flatpak install failed." })
            })
            return
        }

        // AppImage: copy into ~/Applications, make it executable, add a launcher entry.
        resolveHome(function (ok) {
            if (!ok) return callback({ ok: false, message: "Could not find your home folder." })
            installAppImage(path, name, callback)
        })
    }

    function installAppImage(path, name, callback) {
        var dest = IF.appImageTarget(home, name)
        runner.run(["install", "-D", "-m", "755", path, dest], function (r) {
            if (r.code !== 0) return callback({ ok: false, message: (r.err || "Copy failed.").trim() })
            var apps = home + "/.local/share/applications"
            runner.run(["mkdir", "-p", apps], function () {
                entryFile.path = apps + "/axiom-" + name.replace(/[^A-Za-z0-9._-]/g, "_") + ".desktop"
                entryFile.setText(IF.desktopEntry(name.replace(/\.AppImage$/i, ""), dest))
                callback({ ok: true, message: "Installed " + name + " to ~/Applications" })
            })
        })
    }

    // Facts shown before the user confirms: size and SHA-256 of the file.
    // Calls back with { name, label, root, supported, size, sha256 } or null.
    function inspect(path, callback) {
        var name = path.split("/").pop()
        var c = IF.classify(name)
        if (!c) return callback(null)
        runner.run(["stat", "-c", "%s", path], function (sz) {
            runner.run(["sha256sum", path], function (hs) {
                if (sz.code !== 0 || hs.code !== 0) return callback(null)
                callback({
                    name: name, label: c.label, root: c.root, supported: c.supported,
                    size: parseInt(sz.out.trim(), 10), sha256: hs.out.split(" ")[0]
                })
            })
        })
    }

    // Installable files directly inside a folder (for the Browse list).
    function candidates(callback) {
        resolveHome(function (ok) {
            if (!ok) return callback([])
            runner.run(["find", home + "/Downloads", "-maxdepth", "1", "-type", "f"], function (r) {
            var names = r.code === 0 ? r.out.split("\n") : []
            callback(names.filter(function (p) { return p.length > 0 && IF.classify(p.split("/").pop()) !== null })
                          .map(function (p) { return { path: p, name: p.split("/").pop() } }))
            })
        })
    }

    FileView { id: entryFile; blockWrites: false }
}
