.pragma library

// Axiom Hub: pure logic for browsing and system-aware suggestions. No QML, no I/O.
// Unit-tested with tests/apps/hub-logic.test.mjs.

var CATEGORIES = ["Development", "Productivity", "Graphics", "Internet", "System", "Multimedia", "Games", "Utilities", "Education"]

function byCategory(catalog, category) {
    return catalog.filter(function (a) { return a.category === category })
}

function categoryCounts(catalog) {
    var out = {}
    CATEGORIES.forEach(function (c) { out[c] = byCategory(catalog, c).length })
    return out
}

function search(catalog, query) {
    var q = (query || "").trim().toLowerCase()
    if (q.length === 0) return catalog
    return catalog.filter(function (a) {
        return a.name.toLowerCase().indexOf(q) >= 0 || a.summary.toLowerCase().indexOf(q) >= 0
    })
}

function find(catalog, id) {
    for (var i = 0; i < catalog.length; i++) if (catalog[i].id === id) return catalog[i]
    return null
}

// How an app fits this machine. sys = { ramGb, freeDiskGb }. Never guesses: when
// the catalog has no RAM figure the level is "unknown".
function fit(app, sys) {
    if (app.min_ram_gb === null || app.min_ram_gb === undefined)
        return { level: "unknown", reason: "No reliable memory figure for this app." }
    if (sys.ramGb < app.min_ram_gb)
        return { level: "too heavy", reason: "Needs about " + app.min_ram_gb + " GB RAM; this machine has " + sys.ramGb + " GB." }
    if (app.size_mb && sys.freeDiskGb * 1024 < app.size_mb * 2)
        return { level: "low disk", reason: "Not much free disk for a " + app.size_mb + " MB app." }
    if (sys.ramGb < app.min_ram_gb * 2)
        return { level: "tight", reason: "Runs, but leaves little memory spare (needs about " + app.min_ram_gb + " GB of " + sys.ramGb + " GB)." }
    return { level: "fits", reason: "Fits comfortably (needs about " + app.min_ram_gb + " GB of " + sys.ramGb + " GB)." }
}

// Light alternative to show next to a heavy app, only if it fits better.
function lighterOption(catalog, app, sys) {
    if (!app.light_alt) return null
    var alt = find(catalog, app.light_alt)
    if (!alt) return null
    var f = fit(alt, sys).level
    return (f === "fits" || f === "unknown") ? alt : null
}

// Featured and popular apps that fit, for the "Suggested for this machine" strip.
function suggestions(catalog, sys, limit) {
    var out = catalog.filter(function (a) {
        var f = fit(a, sys).level
        return (a.featured || a.popular) && (f === "fits" || f === "unknown")
    })
    return out.slice(0, limit || 4)
}

function formatSize(mb) {
    if (mb === null || mb === undefined) return ""
    return mb >= 1024 ? (mb / 1024).toFixed(1) + " GB" : mb + " MB"
}

function sourceLabel(app) {
    var s = app.sources[0]
    return { flatpak: "Flatpak", pacman: "Repository", npm: "npm", pip: "pip", appimage: "AppImage" }[s.type] || s.type
}

// "Flatpak · 312 MB", or just "Flatpak" when no verified size exists.
function metaLine(app) {
    var size = formatSize(app.size_mb)
    return sourceLabel(app) + (size ? " · " + size : "")
}
