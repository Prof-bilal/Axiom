.pragma library

// Axiom Hub backends: pure argv builders and progress parsing. No QML, no I/O.
// Commands are argv arrays run without a shell. Root work goes through
// /usr/local/bin/axiom-pkgd with pkexec (polkit prompt); everything else is user-scope.
// Unit-tested with tests/apps/hub-backends.test.mjs.

var HELPER = "/usr/local/bin/axiom-pkgd"
var PKG_NAME = /^[a-z0-9][a-z0-9@._+-]*$/
var FLATPAK_REF = /^[A-Za-z0-9_.-]+$/

// Flatpak installs name the "flathub" remote; add it for the user first (idempotent).
function flathubRemoteArgv() {
    return ["flatpak", "remote-add", "--user", "--if-not-exists", "flathub", "https://dl.flathub.org/repo/flathub.flatpakrepo"]
}

function chooseSource(app, available) {
    // First source whose backend is available on this machine.
    for (var i = 0; i < app.sources.length; i++)
        if (available.indexOf(app.sources[i].type) >= 0) return app.sources[i]
    return null
}

function installArgv(source, home) {
    if (!source || !source.ref) return null
    switch (source.type) {
    case "flatpak":
        return FLATPAK_REF.test(source.ref) ? ["flatpak", "install", "--user", "-y", "--noninteractive", "flathub", source.ref] : null
    case "pacman":
        return PKG_NAME.test(source.ref) ? ["pkexec", HELPER, "sync", source.ref] : null
    case "npm":
        return ["npm", "install", "-g", "--prefix", home + "/.local", source.ref]
    case "pip":
        return ["pipx", "install", source.ref]
    }
    return null
}

function removeArgv(source, home) {
    if (!source || !source.ref) return null
    switch (source.type) {
    case "flatpak":
        return FLATPAK_REF.test(source.ref) ? ["flatpak", "uninstall", "--user", "-y", "--noninteractive", source.ref] : null
    case "pacman":
        return PKG_NAME.test(source.ref) ? ["pkexec", HELPER, "remove", source.ref] : null
    case "npm":
        return ["npm", "uninstall", "-g", "--prefix", home + "/.local", source.ref]
    case "pip":
        return ["pipx", "uninstall", source.ref]
    }
    return null
}

function updateArgv(source, home) {
    if (!source || !source.ref) return null
    switch (source.type) {
    case "flatpak":
        return FLATPAK_REF.test(source.ref) ? ["flatpak", "update", "--user", "-y", "--noninteractive", source.ref] : null
    case "pacman":
        return PKG_NAME.test(source.ref) ? ["pkexec", HELPER, "sync", source.ref] : null
    case "npm":
        return ["npm", "update", "-g", "--prefix", home + "/.local", source.ref]
    case "pip":
        return ["pipx", "upgrade", source.ref]
    }
    return null
}

// Real progress from one line of command output: the last "NN%", or a "done/total"
// fraction. Returns -1 when the line has neither, so the ring stays a spinner.
function parseProgress(text) {
    var m = (text || "").match(/(\d{1,3})\s*%/g)
    if (m) {
        var n = parseInt(m[m.length - 1], 10)
        if (n <= 100) return n
    }
    var f = (text || "").match(/(\d+)\/(\d+)/g)
    if (f) {
        var p = f[f.length - 1].split("/")
        var a = parseInt(p[0], 10), b = parseInt(p[1], 10)
        if (b > 0 && a <= b) return Math.round(a * 100 / b)
    }
    return -1
}

// Step named by the command's own wording (0-3), or -1 when the line says nothing about it.
function stepFromLine(text) {
    var t = (text || "").toLowerCase()
    if (/finaliz|complete|done\.?$/.test(t)) return 3
    if (/configur|integrat|desktop entr/.test(t)) return 2
    if (/install|download|fetch|pull|copy|sync|remov|uninstall|update/.test(t)) return 1
    return -1
}

var STEPS = ["Preparing installation...", "Installing package...", "Configuring application...", "Finalizing..."]

// Which step (0-3) is active at a given percentage.
function stepFor(pct) {
    if (pct < 15) return 0
    if (pct < 75) return 1
    if (pct < 95) return 2
    return 3
}

// Installed refs from `flatpak list --app --columns=application` and `pacman -Qq` output.
function parseLines(text) {
    return (text || "").split("\n").map(function (l) { return l.trim() }).filter(function (l) { return l.length > 0 })
}

function installedIds(catalog, flatpakOut, pacmanOut) {
    var fp = parseLines(flatpakOut), pm = parseLines(pacmanOut)
    return catalog.filter(function (a) {
        return a.sources.some(function (s) {
            return (s.type === "flatpak" && fp.indexOf(s.ref) >= 0) || (s.type === "pacman" && pm.indexOf(s.ref) >= 0)
        })
    }).map(function (a) { return a.id })
}
