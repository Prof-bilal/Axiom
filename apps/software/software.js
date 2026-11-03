.pragma library

// Axiom Software: pure logic for package data. No QML, no I/O. Parses the
// output of `pacman -Qi` / `-Qq` / `-Qo` / `-Ql` (run with LC_ALL=C) and
// filters it. Unit-tested on the host with tests/apps/software-logic.test.mjs.

var REASON_EXPLICIT = "Explicitly installed"
var REASON_DEP = "Installed as a dependency for another package"

// Fields that hold space-separated package lists in `pacman -Qi`.
var LIST_FIELDS = ["Provides", "Depends On", "Required By", "Optional For", "Conflicts With", "Replaces", "Licenses", "Groups"]

function splitList(value) {
    if (!value || value === "None") return []
    return value.split(/  +/).filter(function (s) { return s.length > 0 })
}

// `pacman -Qi` with no arguments prints every installed package as a block of
// "Field : value" lines, blocks separated by a blank line; long values (Optional
// Deps) continue on lines indented under the colon.
function parseQi(text) {
    var blocks = text.split(/\n\n+/)
    var out = []
    for (var b = 0; b < blocks.length; b++) {
        var lines = blocks[b].split("\n")
        var fields = {}
        var last = ""
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            var m = /^([A-Za-z][A-Za-z ]*?)\s*: (.*)$/.exec(line)
            if (m) {
                last = m[1]
                fields[last] = m[2]
            } else if (last && /^\s+\S/.test(line)) {
                fields[last] += (last === "Optional Deps" ? "\n" : "  ") + line.trim()
            }
        }
        if (!fields["Name"]) continue
        var reason = fields["Install Reason"] || ""
        out.push({
            name: fields["Name"],
            version: fields["Version"] || "",
            description: fields["Description"] || "",
            architecture: fields["Architecture"] || "",
            url: fields["URL"] === "None" ? "" : (fields["URL"] || ""),
            licenses: splitList(fields["Licenses"]),
            groups: splitList(fields["Groups"]),
            provides: splitList(fields["Provides"]),
            depends: splitList(fields["Depends On"]),
            optionalDeps: (fields["Optional Deps"] && fields["Optional Deps"] !== "None")
                ? fields["Optional Deps"].split("\n").filter(function (s) { return s.length > 0 }) : [],
            requiredBy: splitList(fields["Required By"]),
            optionalFor: splitList(fields["Optional For"]),
            conflicts: splitList(fields["Conflicts With"]),
            replaces: splitList(fields["Replaces"]),
            installedSize: fields["Installed Size"] || "",
            sizeBytes: sizeToBytes(fields["Installed Size"] || ""),
            packager: fields["Packager"] || "",
            buildDate: fields["Build Date"] || "",
            installDate: fields["Install Date"] || "",
            explicit: reason === REASON_EXPLICIT,
            reason: reason
        })
    }
    return out
}

// "12.30 MiB" -> bytes (pacman prints binary units).
function sizeToBytes(text) {
    var m = /^([\d.]+)\s*(B|KiB|MiB|GiB|TiB)$/.exec(text.trim())
    if (!m) return 0
    var f = { B: 1, KiB: 1024, MiB: 1048576, GiB: 1073741824, TiB: 1099511627776 }[m[2]]
    return Math.round(parseFloat(m[1]) * f)
}

// One name per line (`pacman -Qq`, `-Qdtq`, ...) -> { name: true }.
function parseNameSet(text) {
    var set = {}
    text.split("\n").forEach(function (n) { n = n.trim(); if (n) set[n] = true })
    return set
}

// view: "all" | "explicit" | "deps" | "unused"; unusedSet from `pacman -Qdtq`.
function filterPackages(pkgs, query, view, unusedSet) {
    var q = query.trim().toLowerCase()
    return pkgs.filter(function (p) {
        if (view === "explicit" && !p.explicit) return false
        if (view === "deps" && p.explicit) return false
        if (view === "unused" && !unusedSet[p.name]) return false
        if (q.length === 0) return true
        return p.name.toLowerCase().indexOf(q) >= 0 || p.description.toLowerCase().indexOf(q) >= 0
    })
}

// key: "name" | "size"
function sortPackages(pkgs, key) {
    var list = pkgs.slice()
    if (key === "size") {
        list.sort(function (a, b) { return b.sizeBytes - a.sizeBytes || (a.name < b.name ? -1 : 1) })
    } else {
        list.sort(function (a, b) { return a.name < b.name ? -1 : (a.name > b.name ? 1 : 0) })
    }
    return list
}

// `pacman -Qo FILE`: "/path is owned by pkg 1.2-3" or an error line.
function parseOwner(text) {
    var m = /is owned by (\S+) (\S+)/.exec(text)
    return m ? { name: m[1], version: m[2] } : null
}

// `pacman -Ql PKG`: "pkg /path" per line. Returns { count, files } with
// directories (trailing slash) excluded from the count.
function parseFiles(text, limit) {
    var files = []
    var count = 0
    var lines = text.split("\n")
    for (var i = 0; i < lines.length; i++) {
        var sp = lines[i].indexOf(" ")
        if (sp < 0) continue
        var path = lines[i].substring(sp + 1)
        if (path.charAt(path.length - 1) === "/") continue
        count++
        if (files.length < limit) files.push(path)
    }
    return { count: count, files: files }
}

// Whether package databases exist. Input: the output of
// `ls -1 /var/lib/pacman/sync` (error text or empty means none).
function hasSyncDatabases(text) {
    return /\.db(\s|$)/m.test(text)
}

function humanSize(bytes) {
    var units = ["B", "KiB", "MiB", "GiB"]
    var v = bytes
    var i = 0
    while (v >= 1024 && i < units.length - 1) { v /= 1024; i++ }
    return (i === 0 ? v : v.toFixed(v < 10 ? 1 : 0)) + " " + units[i]
}
