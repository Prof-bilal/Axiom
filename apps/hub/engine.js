.pragma library

// Axiom Hub: turns the search engine's JSON (system/hub/hubengine.py) into the app shape the screens use.
// Pure functions, no I/O. Unit-tested with tests/apps/hub-engine.test.mjs.

var SEARCH_BIN = "/usr/local/bin/axiom-hub"
var TRUST_LABEL = {
    official: "Official Arch repository, signed by the packager",
    verified: "Published by a Flathub-verified publisher",
    community: "Community repository",
    unverified: "Not verified by Flathub"
}

// freedesktop main categories -> the Discover chips. Anything else is "Utilities".
var CATEGORY_MAP = {
    Development: "Development", IDE: "Development",
    Network: "Internet", WebBrowser: "Internet", Email: "Internet", Chat: "Internet",
    Graphics: "Graphics", Photography: "Graphics",
    Office: "Productivity", Education: "Education",
    AudioVideo: "Multimedia", Audio: "Multimedia", Video: "Multimedia",
    Game: "Games", System: "System", Settings: "System"
}

function categoryFor(categories) {
    var cs = categories || []
    for (var i = 0; i < cs.length; i++) if (CATEGORY_MAP[cs[i]]) return CATEGORY_MAP[cs[i]]
    return "Utilities"
}

// Search text: trimmed, control characters removed, 80 characters at most. Empty means "no search".
function cleanQuery(text) {
    return String(text || "").replace(/[\u0000-\u001f\u007f]/g, " ").trim().slice(0, 80)
}

// `bin` overrides the engine path (tests and development only; the Hub passes AXIOM_HUB_BIN when set).
function searchArgv(query, bin) {
    var q = cleanQuery(query)
    return q.length === 0 ? null : [bin || SEARCH_BIN, "search", q]
}

function toApp(r) {
    var srcs = (r.sources || []).map(function (s) {
        return { type: s.type, ref: s.ref, version: s.version || "", publisher: s.publisher || "", trust: s.trust, licence: s.licence || "" }
    })
    var best = srcs.length > 0 ? srcs[0] : null
    return {
        id: r.id, name: r.name, category: categoryFor(r.categories), summary: r.summary || "",
        publisher: best && best.type === "flatpak" ? best.publisher : "", license: best ? best.licence : "",
        sources: srcs, icon: r.icon || "", kind: r.kind, size_mb: null, min_ram_gb: null, weight: null, light_alt: null,
        featured: false, popular: false,
        verified: srcs.some(function (s) { return s.trust === "official" || s.trust === "verified" }),
        trust: best ? best.trust : "unverified", trustLabel: best ? TRUST_LABEL[best.trust] || "" : ""
    }
}

// Returns { ok, apps, error }. Bad or empty output is an error, never an exception.
function parseResults(text) {
    try {
        var j = JSON.parse(text)
        if (!j || !Array.isArray(j.results)) return { ok: false, apps: [], error: "The search service returned an unexpected answer." }
        return { ok: true, apps: j.results.map(toApp), error: "" }
    } catch (e) {
        return { ok: false, apps: [], error: "The search service is not available." }
    }
}

function sourceLabel(src) {
    return { pacman: "Arch repository", flatpak: "Flathub", npm: "npm", pip: "pip" }[src.type] || src.type
}

// `flatpak remote-info --show-metadata` prints the app's metadata as an INI file; we read its [Context] lists.
// [A] The exact output was not checked against a real Flatpak here; the parser only reads key=a;b; lines.
function parseFlatpakContext(text) {
    var ctx = { shared: [], sockets: [], devices: [], filesystems: [] }
    var inContext = false
    String(text || "").split("\n").forEach(function (line) {
        var l = line.trim()
        if (/^\[.*\]$/.test(l)) { inContext = l === "[Context]"; return }
        var m = inContext ? /^(shared|sockets|devices|filesystems)=(.*)$/.exec(l) : null
        if (m) ctx[m[1]] = m[2].split(";").map(function (x) { return x.trim() }).filter(function (x) { return x.length > 0 })
    })
    return ctx
}

// Plain-language notes for the grants that matter. Does not claim the app is safe or unsafe.
function permissionNotes(ctx) {
    var out = []
    var fs = ctx.filesystems.map(function (f) { return f.replace(/:(ro|rw|create)$/, "") })
    if (fs.indexOf("host") >= 0 || fs.indexOf("host-os") >= 0) out.push({ level: "warn", text: "Can read and change all your files." })
    else if (fs.indexOf("home") >= 0) out.push({ level: "warn", text: "Can read and change everything in your home folder." })
    else if (fs.length > 0) out.push({ level: "info", text: "Can access some folders: " + fs.slice(0, 4).join(", ") + (fs.length > 4 ? " and more." : ".") })
    if (ctx.devices.indexOf("all") >= 0) out.push({ level: "warn", text: "Can use all devices, such as cameras and drives." })
    if (ctx.sockets.indexOf("session-bus") >= 0 || ctx.sockets.indexOf("system-bus") >= 0)
        out.push({ level: "warn", text: "Can talk to other apps and services on your computer without limits." })
    if (ctx.sockets.indexOf("x11") >= 0) out.push({ level: "info", text: "Uses the older X11 display system, which isolates apps less." })
    if (ctx.shared.indexOf("network") >= 0) out.push({ level: "info", text: "Can use the network." })
    return out
}

// Notes shown before installing from `src`. `installedTypes` are the source types already installed for this app.
function sourceNotes(src, installedTypes) {
    var notes = []
    var already = (installedTypes || []).filter(function (t) { return t !== src.type })
    if (already.length > 0)
        notes.push({ level: "warn", text: "Already installed from " + already.map(function (t) { return sourceLabel({ type: t }) }).join(" and ") + ". Installing from here adds a second copy." })
    if (src.type === "pacman")
        notes.push({ level: "info", text: "This also upgrades the system. A snapshot is taken first, so you can roll back." })
    if (src.trust === "unverified")
        notes.push({ level: "warn", text: "Flathub has not verified who publishes this. Install it only if you trust the publisher." })
    if (src.trust === "community")
        notes.push({ level: "warn", text: "From a community repository. It is not checked by the Arch team." })
    return notes
}
