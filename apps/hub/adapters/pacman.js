.pragma library

// Axiom Hub store: pacman source adapter (pure parsers, no I/O).
// Input is the text of `pacman -Ss <term>` and `pacman -Si <pkg>`, which read the LOCAL sync
// database and need no root and no network. Never run `pacman -Sy` from search (partial upgrade).
// Unit-tested with tests/apps/hub-adapters.test.mjs.

// "160.0.1-1" style sizes in pacman -Si: "86.90 MiB" -> 87 (MB, rounded). Unknown -> null.
function sizeToMb(text) {
    var m = /([\d.]+)\s*(KiB|MiB|GiB|B)/.exec(text || "")
    if (!m) return null
    var n = parseFloat(m[1])
    var f = { B: 1 / 1048576, KiB: 1 / 1024, MiB: 1, GiB: 1024 }[m[2]]
    return Math.round(n * f)
}

// `pacman -Ss` prints two lines per hit:
//   extra/firefox 160.0.1-1 [installed: 158.0.1-1]
//       Fast, Private & Safe Web Browser
function parseSearch(text) {
    var out = []
    var lines = String(text || "").split(/\r?\n/)
    for (var i = 0; i < lines.length; i++) {
        var head = /^(\S+)\/(\S+)\s+(\S+)(?:\s+\[installed(?:: ([^\]]+))?\])?/.exec(lines[i])
        if (!head) continue
        var desc = (lines[i + 1] || "").replace(/^\s+/, "")
        out.push({ repo: head[1], name: head[2], version: head[3],
                   installed: head[0].indexOf("[installed") >= 0,
                   installedVersion: head[4] || null, summary: desc })
        i++
    }
    return out
}

// `pacman -Si <pkg>`: "Key : value" lines. Keys are matched case-sensitively as pacman prints them.
function parseInfo(text) {
    var f = {}
    var last = null
    String(text || "").split(/\r?\n/).forEach(function (line) {
        var m = /^(\S[^:]*?)\s*:\s?(.*)$/.exec(line)
        if (m && !/^\s/.test(line)) { last = m[1].trim(); f[last] = m[2].trim(); return }
        // continuation lines (Optional Deps etc.) are indented; ignored for the store card.
    })
    if (!f["Name"]) return null
    return {
        source: "pacman",
        repo: f["Repository"] || null,
        name: f["Name"],
        version: f["Version"] || null,
        summary: f["Description"] || "",
        arch: f["Architecture"] || null,
        licence: f["Licenses"] || null,
        url: f["URL"] && f["URL"] !== "None" ? f["URL"] : null,
        publisher: f["Packager"] || null,
        downloadMb: sizeToMb(f["Download Size"]),
        installedMb: sizeToMb(f["Installed Size"]),
        validated: (f["Validated By"] || "").indexOf("Signature") >= 0
    }
}
