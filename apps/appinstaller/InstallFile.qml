import QtQuick
import Quickshell.Io
import qs.apps.shared
import "installfile.js" as IF

// Install an AppImage, Flatpak bundle or .deb for the current user (no root);
// Arch packages go through the privileged helper after a polkit prompt.
// Calls back with { ok, message }; an optional onStep(step, total, text) feeds
// the progress modal.
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

    // Step reports for the progress modal: onStep(step, total, text). Optional.
    function report(onStep, step, total, text) { if (onStep) onStep(step, total, text) }

    function install(path, callback, onStep) {
        var name = path.split("/").pop()
        var c = IF.classify(name)
        if (!c) return callback({ ok: false, message: "Unsupported file type." })
        if (c.kind === "arch") {
            // Root work goes through the helper; pkexec shows the polkit prompt.
            report(onStep, 1, 2, "Waiting for admin approval, then installing…")
            return runner.run(["pkexec", "/usr/local/bin/axiom-pkgd", "install", path], function (r) {
                callback(r.code === 0 ? { ok: true, message: "Installed " + name }
                                     : { ok: false, message: (r.err || r.out).trim() || "Install was not approved." })
            })
        }

        if (c.kind === "flatpak") {
            report(onStep, 1, 2, "Installing…")
            runner.run(IF.flatpakArgv(path), function (r) {
                callback(r.code === 0 ? { ok: true, message: "Installed " + name }
                                     : { ok: false, message: (r.err || r.out).trim() || "Flatpak install failed." })
            })
            return
        }

        resolveHome(function (ok) {
            if (!ok) return callback({ ok: false, message: "Could not find your home folder." })
            if (c.kind === "deb") installDeb(path, name, callback, onStep)
            else installAppImage(path, name, callback, onStep)
        })
    }

    // AppImage: copy into ~/Applications, make it executable, add a launcher entry.
    function installAppImage(path, name, callback, onStep) {
        var dest = IF.appImageTarget(home, name)
        report(onStep, 1, 3, "Copying the app…")
        runner.run(["install", "-D", "-m", "755", path, dest], function (r) {
            if (r.code !== 0) return callback({ ok: false, message: (r.err || "Copy failed.").trim() })
            var apps = home + "/.local/share/applications"
            report(onStep, 2, 3, "Adding it to your app menu…")
            runner.run(["mkdir", "-p", apps], function () {
                entryFile.path = apps + "/axiom-" + name.replace(/[^A-Za-z0-9._-]/g, "_") + ".desktop"
                entryFile.setText(IF.desktopEntry(name.replace(/\.AppImage$/i, ""), dest))
                callback({ ok: true, message: "Installed " + name + " to ~/Applications" })
            })
        })
    }

    // .deb: stage the file in ~/.cache, install it with apt inside the rootless
    // distrobox container (created on first use), then export its launcher.
    function installDeb(path, name, callback, onStep) {
        var total = 5
        function fail(msg) { callback({ ok: false, message: msg }) }
        function withContainer(next) {
            report(onStep, 1, total, "Preparing the Debian container…")
            runner.run(IF.debListArgv(), function (l) {
                if (l.code !== 0) return fail("distrobox is not available on this system.")
                if (IF.containerListed(l.out)) return next()
                report(onStep, 1, total, "Creating the Debian container (first time only, needs network)…")
                runner.run(IF.debCreateArgv(), function (c) {
                    if (c.code !== 0) return fail((c.err || "Could not create the container.").trim().split("\n").pop())
                    next()
                })
            })
        }
        withContainer(function () {
            var staged = IF.debStagePath(home, name)
            report(onStep, 2, total, "Reading the package…")
            runner.run(["install", "-D", "-m", "644", path, staged], function (cp) {
                if (cp.code !== 0) return fail((cp.err || "Copy failed.").trim())
                runner.run(IF.debNameArgv(staged), function (n) {
                    var pkg = n.out.trim()
                    if (n.code !== 0 || !IF.validDebName(pkg)) return fail("That does not look like a valid .deb package.")
                    report(onStep, 3, total, "Installing " + pkg + "…")
                    runner.run(IF.debInstallArgv(staged), function (i) {
                        if (i.code !== 0) return fail((i.err || i.out).trim().split("\n").pop() || "apt could not install the package.")
                        report(onStep, 4, total, "Adding it to your app menu…")
                        runner.run(IF.debExportArgv(pkg), function (e) {
                            runner.run(["rm", "-f", staged], function () {})
                            // A package with no desktop file (a library or CLI tool) installs but has no launcher.
                            callback({ ok: true, message: e.code === 0 ? "Installed " + pkg
                                                                    : "Installed " + pkg + " (no app launcher to add)" })
                        })
                    })
                })
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
