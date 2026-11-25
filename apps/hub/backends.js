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

function chooseSource(app, available, prefer) {
    // The source the user picked, if its backend is available here; otherwise the first one that is.
    if (prefer)
        for (var j = 0; j < app.sources.length; j++)
            if (app.sources[j].type === prefer.type && app.sources[j].ref === prefer.ref && available.indexOf(prefer.type) >= 0) return app.sources[j]
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

// Progress from real pacman output when it is not a terminal (the job unit's output): "Packages (N) ..." gives the
// total, ":: Processing package changes..." starts the commit, then one "installing NAME..." per package. Downloads print
// no percentage, so the ring stays a spinner until the commit starts; then 50% to 99% by package.
// Returns a new state { total, count, committing, percent }. Checked against a real transaction in tests/apps/fixtures.
function pacmanProgress(state, line) {
    var s = { total: state.total, count: state.count, committing: state.committing, percent: state.percent }
    var t = (line || "").trim()
    var m = /^Packages \((\d+)\)/.exec(t)
    if (m) s.total = parseInt(m[1], 10)
    else if (/^:: Processing package changes/.test(t)) { s.committing = true; s.percent = Math.max(s.percent, 50) }
    else if (/^(installing|upgrading|reinstalling|removing) \S+\.\.\.$/.test(t)) {
        s.committing = true
        s.count++
        if (s.total > 0) s.percent = Math.max(s.percent, Math.min(99, 50 + Math.round(50 * s.count / s.total)))
    }
    return s
}

function freshPacmanState() { return { total: 0, count: 0, committing: false, percent: -1 } }

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

// npm and pipx installs are found from their own listings: `npm ls -g --parseable` prints
// ".../node_modules/<name>" lines, `pipx list --short` prints "<name> <version>".
function installedIds(catalog, flatpakOut, pacmanOut, npmOut, pipxOut) {
    var fp = parseLines(flatpakOut), pm = parseLines(pacmanOut)
    var npm = parseLines(npmOut).map(function (l) { var i = l.indexOf("/node_modules/"); return i >= 0 ? l.slice(i + 14) : "" })
    var pip = parseLines(pipxOut).map(function (l) { return l.split(/\s+/)[0] })
    return catalog.filter(function (a) {
        return a.sources.some(function (s) {
            return (s.type === "flatpak" && fp.indexOf(s.ref) >= 0)
                || (s.type === "pacman" && pm.indexOf(s.ref) >= 0)
                || (s.type === "npm" && npm.indexOf(s.ref) >= 0)
                || (s.type === "pip" && pip.indexOf(s.ref) >= 0)
        })
    }).map(function (a) { return a.id })
}

// The source that is actually installed (remove and update must act on it, not on the first source listed).
function installedSource(app, types) {
    for (var i = 0; i < app.sources.length; i++) if (types.indexOf(app.sources[i].type) >= 0) return app.sources[i]
    return null
}

// Ids of installed apps that have an update. `flatpakUpdates` are application ids (one per line), `pacmanUpdates` is
// `pacman -Qu` output ("name old -> new" per line); the latter reflects the last package database sync.
function updateIds(apps, flatpakUpdates, pacmanUpdates) {
    var fp = parseLines(flatpakUpdates)
    var pm = parseLines(pacmanUpdates).map(function (l) { return l.split(/\s+/)[0] })
    return apps.filter(function (a) {
        return a.sources.some(function (s) {
            return (s.type === "flatpak" && fp.indexOf(s.ref) >= 0) || (s.type === "pacman" && pm.indexOf(s.ref) >= 0)
        })
    }).map(function (a) { return a.id })
}

// The line to show as the error: the last line that says what went wrong, not a progress line.
// Falls back to the last non-progress line, then to a generic message.
function errorLine(log) {
    var lines = (log || "").split("\n").map(function (l) { return l.trim() }).filter(function (l) { return l.length > 0 })
    var progress = /^\(\s*\d+\/\d+\)|\d+\s*%|^::|^Total\b|^(downloading|installing|checking|loading|resolving|looking|upgrading|removing|retrieving)\b/i
    var wrong = /error|failed|cannot|can't|denied|not found|conflict|could not|couldn't|refus|unable|no such/i
    var calm = lines.filter(function (l) { return !progress.test(l) })
    for (var i = calm.length - 1; i >= 0; i--) if (wrong.test(calm[i])) return calm[i]
    return calm.length > 0 ? calm[calm.length - 1] : "The command failed."
}

// Plain-language text for exit codes the helper and pkexec use (axiom-pkgd). "" means: use the log.
function exitMessage(code) {
    switch (code) {
    case 3: return "System snapshots are not available, so the change was not made."
    case 5: return "Another install or update is already running. Wait for it to finish."
    case 6: return "Too late to cancel: the system is already being changed."
    case 7: return "Nothing is installing right now."
    case 126: return "The authorization was dismissed."
    case 127: return "A required tool is missing on this system."
    }
    return ""
}

// Queue rule for a request that arrives while a job runs. `running` is { id, act } or null. The same request as the
// running one, or one already waiting, changes nothing (a double click must not install twice).
// Returns { queue, accepted }.
function enqueue(queue, running, app, act) {
    if (running && running.id === app.id && running.act === act) return { queue: queue, accepted: false }
    var dup = queue.some(function (q) { return q.app.id === app.id && q.act === act })
    return dup ? { queue: queue, accepted: false } : { queue: queue.concat([{ app: app, act: act }]), accepted: true }
}

// Which of this app's source types are installed right now (same listings as installedIds).
function installedSourceTypes(app, flatpakOut, pacmanOut, npmOut, pipxOut) {
    var fp = parseLines(flatpakOut), pm = parseLines(pacmanOut)
    var npm = parseLines(npmOut).map(function (l) { var i = l.indexOf("/node_modules/"); return i >= 0 ? l.slice(i + 14) : "" })
    var pip = parseLines(pipxOut).map(function (l) { return l.split(/\s+/)[0] })
    var out = []
    app.sources.forEach(function (s) {
        var on = (s.type === "flatpak" && fp.indexOf(s.ref) >= 0) || (s.type === "pacman" && pm.indexOf(s.ref) >= 0)
              || (s.type === "npm" && npm.indexOf(s.ref) >= 0) || (s.type === "pip" && pip.indexOf(s.ref) >= 0)
        if (on && out.indexOf(s.type) < 0) out.push(s.type)
    })
    return out
}
