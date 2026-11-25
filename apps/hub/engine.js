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
